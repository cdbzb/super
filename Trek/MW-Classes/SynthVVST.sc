SynthVVST {
	classvar <>cache;
	var <>synthV, <>params, <>voice, <>version;

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
		^this
	}

	morphPhonemes { |languages randomSeed=12345|
		var morphed = params.lyrics.morphPhonemes(nil, languages.sort, randomSeed);
		params.putAll((
			phonemes: morphed.phonemes,
			languageOverride: morphed.languageOverride,
			phonesetOverride: morphed.phonesetOverride
		));
		^this
	}

	build {
		var path, h;
		h = [voice, params, version].hash;
		cache[h].notNil.if{
			^cache[h]
		};
		path = "/private/tmp/" ++ UniqueID.next.asString.padLeft(13, "0");
		synthV = SynthV.newVST(voice, \default, nil, nil, version);
		params.lyrics = params.lyrics.replace($, , "").split(Char.space).reject{|i| i.size==0};
		params.pitch = params.midinote.asInteger;
		synthV.makeNotes(params.dur.size);
		synthV.setDatabase(voice);
		synthV.set(params);
		synthV.writeProjectVST(path ++ ".svp");
		synthV.writeFxp(path);
		fork{ 0.1.wait; synthV.vst = SV(path ++ ".fxp") };
		cache[h] = this;
		^this
	}

	play { |func tail=1|
		var syn, dur;
		func = func ? I.d;
		dur = params.dur.sum + tail;
		fork{
			syn = { In.ar(synthV.vst.bus) => func }.play;
			synthV.vst.controller.setTransportPos(0);
			synthV.vst.controller.setPlaying(true);
			dur.wait;
			synthV.vst.controller.setPlaying(false);
			syn.free;
		}
	}

	*clearCache {
		cache = IdentityDictionary.new;
	}
}
