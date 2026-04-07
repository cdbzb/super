SynthVVST {
	classvar <>cache;
	var <>synthV, <>params, <>voice, <>version, <cacheKey, <>voices, <>isMulti, <>cleanup, <ready, <>frozenBuffers;

	*initClass {
		cache = IdentityDictionary.new;
		CmdPeriod.add(this);
	}

	*frozenDir { ^SynthV.directory +/+ "frozen" }

	frozenPath { |vi|
		vi.notNil.if{
			^this.class.frozenDir +/+ cacheKey.asHexString ++ "_" ++ vi +/+ "synthV_MixDown.wav"
		}{
			^this.class.frozenDir +/+ cacheKey.asHexString +/+ "synthV_MixDown.wav"
		}
	}

	isFrozen {
		isMulti.if{
			^voices.size.collect{|vi| File.exists(this.frozenPath(vi)) }.every{|i| i }
		}{
			^File.exists(this.frozenPath)
		}
	}

	checkDirty { ^this.isFrozen.not }

	render {
		var script = SynthV.directory +/+ "SCRIPTS/renderSynthV-recompute_2.sh";
		this.isFrozen.if{
			"SynthVVST: % already frozen".format(voice).postln;
			^this
		};
		isMulti.if{
			synthV.do{|sv, vi|
				var dest = this.class.frozenDir +/+ cacheKey.asHexString ++ "_" ++ vi;
				var svpPath = "/private/tmp/" ++ cacheKey.asHexString ++ "_" ++ vi ++ ".svp";
				File.mkdir(dest);
				sv.writeProjectVST(svpPath);
				sv.project.renderConfig[\destination] = dest;
				sv.project.renderConfig[\numChannels] = 2;
				JSON.stringify(sv.project).write(svpPath, overwrite: true, ask: false);
				(script + svpPath).unixCmd;
			}
		}{
			var dest = this.class.frozenDir +/+ cacheKey.asHexString;
			var svpPath = "/private/tmp/" ++ cacheKey.asHexString ++ ".svp";
			File.mkdir(dest);
			synthV.writeProjectVST(svpPath);
			synthV.project.renderConfig[\destination] = dest;
			synthV.project.renderConfig[\numChannels] = 2;
			JSON.stringify(synthV.project).write(svpPath, overwrite: true, ask: false);
			(script + svpPath).unixCmd;
		};
		^this
	}

	unfreeze {
		isMulti.if{
			voices.size.do{|vi|
				("rm -rf" + (this.class.frozenDir +/+ cacheKey.asHexString ++ "_" ++ vi).shellQuote).unixCmd;
			}
		}{
			("rm -rf" + (this.class.frozenDir +/+ cacheKey.asHexString).shellQuote).unixCmd;
		};
		frozenBuffers = nil;
	}

	*new { |voice params version=2|
		^super.new.init(voice, params, version)
	}

	init { |v p ver|
		var voiceCount;
		voice = v;
		version = ver;
		voiceCount = p.values.collect{|val|
			(val.respondsTo(\rank) and: { val.rank > 1 }).if{ val.size }{ 1 }
		}.maxItem;
		(voiceCount > 1).if{
			voices = voiceCount.collect{|i|
				p.collect{|val|
					(val.respondsTo(\rank) and: { val.rank > 1 }).if{ val[i] }{ val }
				}
			};
			params = voices[0];
			isMulti = true;
		}{
			params = p.copy;
			voices = nil;
			isMulti = false;
		};
		cacheKey = [voice, params, version, voices].hash;
		^this
	}

	morphPhonemes { |languages randomSeed=12345|
		isMulti.if{
			voices.do{|p, i|
				var morphed = p.lyrics.morphPhonemes(nil, languages.sort, randomSeed + i);
				p.putAll((
					phonemes: morphed.phonemes,
					languageOverride: morphed.languageOverride,
					phonesetOverride: morphed.phonesetOverride
				));
			}
		}{
			var morphed = params.lyrics.morphPhonemes(nil, languages.sort, randomSeed);
			params.putAll((
				phonemes: morphed.phonemes,
				languageOverride: morphed.languageOverride,
				phonesetOverride: morphed.phonesetOverride
			));
		};
		cacheKey = [voice, params, version, voices].hash;
		^this
	}

	build {
		var readyCount = 0, targetCount;
		cache[cacheKey].notNil.if{
			synthV = cache[cacheKey].synthV;
			ready = cache[cacheKey].ready;
			frozenBuffers = cache[cacheKey].frozenBuffers;
			(this.isFrozen and: { frozenBuffers.isNil }).if{
				isMulti.if{
					frozenBuffers = voices.size.collect{|vi|
						Buffer.read(Server.default, this.frozenPath(vi))
					};
				}{
					frozenBuffers = Buffer.read(Server.default, this.frozenPath);
				};
				ready = Condition(false);
				cache[cacheKey] = this;
				fork{
					Server.default.sync;
					ready.test_(true).signal;
					"SynthVVST: % ready (frozen)".format(voice).postln;
				};
			};
			^this
		};
		ready = Condition(false);
		this.isFrozen.if{
			isMulti.if{
				frozenBuffers = voices.size.collect{|vi|
					Buffer.read(Server.default, this.frozenPath(vi))
				};
			}{
				frozenBuffers = Buffer.read(Server.default, this.frozenPath);
			};
			cache[cacheKey] = this;
			fork{
				Server.default.sync;
				ready.test_(true).signal;
				"SynthVVST: % ready (frozen)".format(voice).postln;
			};
			^this
		};
		isMulti.if{
			targetCount = voices.size;
			synthV = voices.collect{|voiceParams, vi|
				var path, sv, buildParams;
				path = "/private/tmp/" ++ cacheKey.asHexString ++ "_" ++ vi;
				sv = SynthV.newVST(voice, \default, nil, nil, version);
				buildParams = voiceParams.copy;
				buildParams.lyrics = buildParams.lyrics.replace($, , "").split(Char.space).reject{|i| i.size==0};
				buildParams.pitch = buildParams.midinote.asInteger;
				sv.makeNotes(buildParams.dur.size);
				sv.setDatabase(voice);
				sv.set(buildParams);
				sv.writeProjectVST(path ++ ".svp");
				sv.writeFxp(path);
				sv.vst = SV(path ++ ".fxp", onReady: {
					readyCount = readyCount + 1;
					(readyCount >= targetCount).if { ready.test_(true).signal };
				});
				sv
			};
		}{
			var path, buildParams;
			targetCount = 1;
			path = "/private/tmp/" ++ cacheKey.asHexString;
			synthV = SynthV.newVST(voice, \default, nil, nil, version);
			buildParams = params.copy;
			buildParams.lyrics = buildParams.lyrics.replace($, , "").split(Char.space).reject{|i| i.size==0};
			buildParams.pitch = buildParams.midinote.asInteger;
			synthV.makeNotes(buildParams.dur.size);
			synthV.setDatabase(voice);
			synthV.set(buildParams);
			synthV.writeProjectVST(path ++ ".svp");
			synthV.writeFxp(path);
			synthV.vst = SV(path ++ ".fxp", onReady: {
				ready.test_(true).signal;
			});
		};
		cache[cacheKey] = this;
		fork{
			ready.wait;
			"SynthVVST: % ready".format(voice).postln;
		};
		^this
	}

	play { |func tail=1|
		var syn, dur;
		func = func ? I.d;
		dur = params.dur.sum + tail;
		cleanup.notNil.if{ cleanup.stop };
		isMulti.if{
			cleanup = fork{
				ready.wait;
				syn = { synthV.collect{|sv| In.ar(sv.vst.bus) }.sum => func }.play;
				synthV.do{|sv|
					sv.vst.controller.setTransportPos(0);
					sv.vst.controller.setPlaying(true);
				};
				dur.wait;
				synthV.do{|sv| sv.vst.controller.setPlaying(false) };
				syn.free;
			}
		}{
			cleanup = fork{
				ready.wait;
				syn = { In.ar(synthV.vst.bus) => func }.play;
				synthV.vst.controller.setTransportPos(0);
				synthV.vst.controller.setPlaying(true);
				dur.wait;
				synthV.vst.controller.setPlaying(false);
				syn.free;
			}
		}
	}

	buses {
		isMulti.if{
			^synthV.collect{|sv| sv.vst.bus }
		}{
			^synthV.vst.bus
		}
	}

	*doOnCmdPeriod {
		cache.do{|item|
			item.ready.test_(false);
		}
	}

	*freeAll {
		cache.do{|item|
			item.synthV.asArray.do{|sv|
				sv.notNil.if{
					sv.vst.notNil.if{
						try{ sv.vst.bus.free };
						try{ sv.vst.controller.close };
					}
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
	*synthVVST { |voice start params syl lag=0 music song resources filters version=2 take tail=1|
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
		sv.isFrozen.not.if{
			"SynthVVST: % not frozen.\nSong.%.synthV.render".format(key, key).postln;
		};
		^P(key, start, syl, lag, {|p b e|
			var syn, dur;
			sv.isFrozen.if{
				syn = music.(p, b, e);
			}{
				sv.cleanup.notNil.if{ sv.cleanup.stop };
				sv.isMulti.if{
					sv.synthV.do{|svv|
						svv.vst.controller.setTransportPos(0);
						svv.vst.controller.setPlaying(true);
					}
				}{
					sv.synthV.vst.controller.setTransportPos(0);
					sv.synthV.vst.controller.setPlaying(true);
				};
				syn = music.(p, b, e);
				dur = sv.params.dur.sum + tail;
				sv.cleanup = fork{
					dur.wait;
					sv.isMulti.if{
						sv.synthV.do{|svv| svv.vst.controller.setPlaying(false) }
					}{
						sv.synthV.vst.controller.setPlaying(false)
					};
					syn.free;
				}
			}
		}, song,
			resources: resources ++ (
				bus: sv.isFrozen.if{
					sv.isMulti.if{
						{ sv.frozenBuffers.collect{|buf| PlayBuf.ar(2, buf, doneAction: 2) } }
					}{
						{ PlayBuf.ar(2, sv.frozenBuffers, doneAction: 2) }
					}
				}{
					sv.isMulti.if{
						{ sv.synthV.collect{|svv| In.ar(svv.vst.bus, 2) } }
					}{
						{ In.ar(sv.synthV.vst.bus, 2) }
					}
				},
				sv: sv,
				synthV: sv
			)
		)
	}
}
