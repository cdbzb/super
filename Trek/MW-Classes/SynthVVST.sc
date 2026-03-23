SynthVVST {
	classvar <>cache;
	var <>synthV, <>params, <>voice, <>version, <cacheKey;

	*initClass {
		cache = IdentityDictionary.new;
	}

	*new { |voice params version=2|
		^super.new.init(voice, params, version)
	}

	init { |v p ver|
		voice = v;
		params = p.copy;
		version = ver;
		cacheKey = [voice, params, version].hash;
		^this
	}

	morphPhonemes { |languages randomSeed=12345|
		var morphed = params.lyrics.morphPhonemes(nil, languages.sort, randomSeed);
		params.putAll((
			phonemes: morphed.phonemes,
			languageOverride: morphed.languageOverride,
			phonesetOverride: morphed.phonesetOverride
		));
		cacheKey = [voice, params, version].hash;
		^this
	}

	build {
		var path, buildParams;
		cache[cacheKey].notNil.if{
			^cache[cacheKey]
		};
		path = "/private/tmp/" ++ UniqueID.next.asString.padLeft(13, "0");
		synthV = SynthV.newVST(voice, \default, nil, nil, version);
		buildParams = params.copy;
		buildParams.lyrics = buildParams.lyrics.replace($, , "").split(Char.space).reject{|i| i.size==0};
		buildParams.pitch = buildParams.midinote.asInteger;
		synthV.makeNotes(buildParams.dur.size);
		synthV.setDatabase(voice);
		synthV.set(buildParams);
		synthV.writeProjectVST(path ++ ".svp");
		synthV.writeFxp(path);
		synthV.vst = SV(path ++ ".fxp");
		cache[cacheKey] = this;
		^this
	}

	play { |func tail=1|
		var syn, dur;
		func = func ? I.d;
		dur = params.dur.sum + tail;
		fork{
			synthV.vst.condition.wait;
			syn = { In.ar(synthV.vst.bus) => func }.play;
			synthV.vst.controller.setTransportPos(0);
			synthV.vst.controller.setPlaying(true);
			dur.wait;
			synthV.vst.controller.setPlaying(false);
			syn.free;
		}
	}

	*freeAll {
		cache.do{|item|
			item.synthV.notNil.if{
				item.synthV.vst.notNil.if{
					try{ item.synthV.vst.bus.free };
					try{ item.synthV.vst.controller.close };
				}
			}
		};
		cache = IdentityDictionary.new;
	}

	*clearCache {
		this.freeAll;
	}
}
+ P {
	*synthVVST { |voice start params syl lag=0 music song resources filters version=2 take|
		var sv, section, key;
		key = take.notNil.if{ voice ++ "_" ++ take }{ voice };
		section = P.calcStart(start);
		song = song ? Song.currentSong;
		sv = SynthVVST(voice, version: version, params: params.value(
			song,
			song.durs[section].list,
			voice
		) => Event.newFrom(_));
		filters = filters ? [];
		filters.isKindOf(Function).if{ filters = [filters] };
		filters.do{|f| f.(sv) };
		sv = sv.build;
		^P(key, start, syl, lag, {|p b e|
			sv.synthV.vst.controller.setTransportPos(0);
			sv.synthV.vst.controller.setPlaying(true);
			music.(p, b, e);
		}, song,
			resources: resources ++ (
				bus: { In.ar(sv.synthV.vst.bus) },
				sv: sv
			)
		)
	}
}
