SynthVVST {
	classvar <>cache;
	var <>synthV, <>params, <>voice, <>version, <cacheKey, <>voices, <>isMulti, <>cleanup, <ready, <>frozenBuffers;
	var <leadIn;
	/* nil = never built, \building = VSTs opening, \ready = usable,
	   \failed = the plugin or its program did not load, \stale = invalidated by
	   Cmd-.. `ready` alone cannot express these: it is down for all four of the
	   non-ready states, which is why an in-flight build used to look broken. */
	var <>buildState;

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

	isOpen {
		/* synthV survives freezing so its project can still be inspected; the VSTI
		   reference is the actual live-resource test. `any` also handles a partially
		   opened multi-voice instance without declaring the whole take closed. */
		^synthV.notNil and: {
			synthV.asArray.any{|sv| sv.notNil and: { sv.vst.notNil } }
		}
	}

	checkDirty { ^this.isFrozen.not }

	svpPaths {
		// Returns array of SVP paths for this instance
		isMulti.if{
			^voices.size.collect{|vi|
				"/private/tmp/" ++ cacheKey.asHexString ++ "_" ++ vi ++ ".svp"
			}
		}{
			^["/private/tmp/" ++ cacheKey.asHexString ++ ".svp"]
		}
	}

	prepareRender {
		// Write SVP files with frozen destination, return SVP paths
		this.isFrozen.if{ ^nil };
		isMulti.if{
			synthV.do{|sv, vi|
				var dest = this.class.frozenDir +/+ cacheKey.asHexString ++ "_" ++ vi;
				var svpPath = "/private/tmp/" ++ cacheKey.asHexString ++ "_" ++ vi ++ ".svp";
				File.mkdir(dest);
				sv.writeProjectVST(svpPath);
				sv.project.renderConfig[\destination] = dest;
				sv.project.renderConfig[\numChannels] = 2;
				JSON.stringify(sv.project).write(svpPath, overwrite: true, ask: false);
			}
		}{
			var dest = this.class.frozenDir +/+ cacheKey.asHexString;
			var svpPath = "/private/tmp/" ++ cacheKey.asHexString ++ ".svp";
			File.mkdir(dest);
			synthV.writeProjectVST(svpPath);
			synthV.project.renderConfig[\destination] = dest;
			synthV.project.renderConfig[\numChannels] = 2;
			JSON.stringify(synthV.project).write(svpPath, overwrite: true, ask: false);
		};
		^this.svpPaths
	}

	freeze {
		this.class.freeze([this]);
		^this
	}

	// Compatibility name; all rendering now uses the single batch coordinator.
	render { ^this.freeze }

	freeVSTs {
		synthV.asArray.do{|sv|
			sv.notNil.if{
				sv.vst.notNil.if{
					try{ sv.vst.bus.free };
					/* dispose also removes VSTI's CmdPeriod callback and registry
					   entry; controller.close alone allowed Cmd-. to reopen it. */
					try{ sv.vst.dispose };
					sv.vst = nil;
				}
			}
		};
		buildState = nil;
		"SynthVVST: % VSTs freed".format(voice).postln;
	}

	*freeAllVSTs {
		cache.do{|item| item.freeVSTs };
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

	calcCacheKey {
		// Array.hash and Event.hash are identity-based in SC; only String.hash is content-based
		/*
		 leadIn is baked into the RENDER (build shifts every onset by it), so it has to
		 key the cache — two lead-ins are two different takes. Appended only when it is
		 non-zero, so leadIn: 0 reproduces the pre-leadIn key exactly and an existing
		 frozen library stays valid.
		*/
		^([voice, params.asSortedArray, version,
			voices.notNil.if{ voices.collect{|v| v.asSortedArray} }
		] ++ (leadIn > 0).if { [leadIn] } { [] }).asCompileString.hash
	}

	*new { |voice params version=2 leadIn=0.1|
		^super.new.init(voice, params, version, leadIn)
	}

	isExpandable { |key, val|
		// envelope params: Array means one-per-voice
		// other params: rank > 1 means one-per-voice (e.g. [[notes],[notes]])
		(SynthV.envelopes.includes(key) and: { val.isKindOf(Array) }).if{ ^true };
		^(val.respondsTo(\rank) and: { val.rank > 1 })
	}

	init { |v p ver lead|
		var voiceCount;
		voice = v;
		version = ver;
		leadIn = lead ? 0;
        p = p.asEvent;
		voiceCount = p.collect{|val, key| this.isExpandable(key, val).if{ val.size }{ 1 }}.values.maxItem ? 1;
		(voiceCount > 1).if{
			voices = voiceCount.collect{|i|
				p.collect{|val, key| this.isExpandable(key, val).if{ val[i] }{ val } }
			};
			params = voices[0];
			isMulti = true;
		}{
			params = p.copy;
			voices = nil;
			isMulti = false;
		};
		cacheKey = this.calcCacheKey;
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
		cacheKey = this.calcCacheKey;
		^this
	}

	/* Split out so the decision is testable without opening a plugin. */
	prShouldRebuild { |cached|
		^cached.notNil
			and: { cached.buildState != \building }
			and: { cached.ready.notNil }
			and: { cached.ready.test.not }
			and: { this.isFrozen.not }
	}

	/*
	 Opening a VST is asynchronous: VSTI forks, syncs, opens the plugin, and only
	 then does SV's action read the .fxp, so `ready` stays down for the whole
	 bring-up. Rebuilding on a down `ready` therefore treated a build still in
	 flight as a broken one — and since both takes name the same
	 /private/tmp/<cacheKey>.fxp, the replacement opened a project the outgoing
	 plugin had not released yet, which is exactly what makes Synthesizer V ask
	 whether to save a copy. Loading a whole source file, or nesting one EventList
	 under two parents, calls build for the same key several times in a row and hit
	 this every time.

	 So distinguish the states. Only a take that actually died (\failed) or was
	 invalidated by Cmd-. (\stale) is rebuilt; one still opening is adopted by
	 falling through to the ordinary cache hit below, where its Condition is shared
	 and every waiter is released by the single build already running.

	 A build wedged before either callback stays \building and is never rebuilt.
	 That is deliberate: the old behaviour rebuilt it on every call, and each rebuild
	 was another dialog. Call freeVSTs (or SynthVVST.freeAll) to clear it.
	*/
	build {
		var readyCount = 0, targetCount;
		var cached = cache[cacheKey];
		var stale, openVSTs;
		this.prShouldRebuild(cached).if{
			"SynthVVST: % cached VST was %; rebuilding"
				.format(voice, cached.buildState ? "not ready").postln;
			/* Removed from the cache now, but freed later: the teardown has to
			   complete before the replacement opens the same project. */
			stale = cached;
			cached = nil;
			cache.removeAt(cacheKey);
		};
		cached.notNil.if{
			synthV = cached.synthV;
			ready = cached.ready;
			buildState = cached.buildState;
			frozenBuffers = cached.frozenBuffers;
			this.isFrozen.if{
				frozenBuffers.isNil.if{
					this.freeVSTs;
					isMulti.if{
						frozenBuffers = voices.size.collect{|vi|
							Buffer.read(Server.default, this.frozenPath(vi))
						};
					}{
						frozenBuffers = Buffer.read(Server.default, this.frozenPath);
					};
				};
				/*
				 Re-arm on ANY frozen cache hit whose Condition is down, not only when
				 the buffers were missing. *doOnCmdPeriod clears `ready` on every cached
				 item; a frozen take then passes neither the rebuild guard above (which
				 wants isFrozen.not) nor the buffers-missing branch, so it used to fall
				 through with `ready` false and nothing left to signal it — every later
				 ready.wait hung forever.

				 NOT covered: a server REBOOT leaves frozenBuffers non-nil but holding
				 dead Buffers, so this re-arms over invalid buffers. Needs a validity
				 check (or nilling them on reboot) — see synthvvst-eventlist-proposal.md.
				*/
				(ready.isNil or: { ready.test.not }).if{
					ready = Condition(false);
					buildState = \building;
					cache[cacheKey] = this;
					fork{
						Server.default.sync;
						buildState = \ready;
						ready.test_(true).signal;
						"SynthVVST: % ready (frozen)".format(voice).postln;
					};
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
			buildState = \building;
			cache[cacheKey] = this;
			fork{
				Server.default.sync;
				buildState = \ready;
				ready.test_(true).signal;
				"SynthVVST: % ready (frozen)".format(voice).postln;
			};
			^this
		};
		buildState = \building;
		/* Published BEFORE the asynchronous open, not after it: a second build of
		   this key during the same source-file load has to find the in-flight take
		   and adopt it, or it opens its own plugin on the same project. */
		cache[cacheKey] = this;
		openVSTs = {
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
					/* silence for the plugin to spin up in — see prPerform */
					(leadIn > 0).if{ sv.shiftNotes(leadIn) };
					sv.writeProjectVST(path ++ ".svp");
					sv.writeFxp(path);
					sv.vst = SV(path ++ ".fxp", onReady: {|success|
						success.if{
							readyCount = readyCount + 1;
							(readyCount >= targetCount).if {
								buildState = \ready;
								ready.test_(true).signal
							};
						}{
							buildState = \failed;
							"SynthVVST: % failed to load FXP %".format(voice, path ++ ".fxp").warn;
						}
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
				/* silence for the plugin to spin up in — see prPerform */
				(leadIn > 0).if{ synthV.shiftNotes(leadIn) };
				synthV.writeProjectVST(path ++ ".svp");
				synthV.writeFxp(path);
				synthV.vst = SV(path ++ ".fxp", onReady: {|success|
					success.if{
						buildState = \ready;
						ready.test_(true).signal;
					}{
						buildState = \failed;
						"SynthVVST: % failed to load FXP %".format(voice, path ++ ".fxp").warn;
					}
				});
			};
		};
		stale.notNil.if{
			/* The replacement writes the same .svp/.fxp the outgoing plugin still has
			   open, and VSTI:dispose is asynchronous server traffic. Let the teardown
			   land before reopening, or Synthesizer V finds its project open twice and
			   asks the user to save a copy. */
			fork{
				stale.freeVSTs;
				Server.default.sync;
				openVSTs.value;
			}
		}{
			openVSTs.value
		};
		fork{
			ready.wait;
			"SynthVVST: % ready".format(voice).postln;
		};
		^this
	}

	/*
	 The audio graph for this take, as a Function to use inside a UGen graph: frozen
	 buffers or the live VST bus, single or multi, STEREO in every case. This is the
	 one definition — P.synthVVST's resources[\bus] and play both go through it, so
	 they cannot drift again (they had: play read 1 channel and had no frozen branch
	 at all, so a frozen take played through it was silent).

	 Deliberately rebuilt per call, never cached: frozenBuffers is nil'd by unfreeze
	 and dies on a server reboot, so a cached Function closes over stale Buffers.
	*/
	source { |tail=1|
		this.isFrozen.if{
			isMulti.if{
				^{
					var bufs = frozenBuffers;
					/* buffers exist at graph-build time, so take the max in the
					   language: maxItem on BufDur UGens compares with `>`, which
					   builds a BinaryOpUGen and throws Non Boolean in test. */
					var dur = bufs.collect{|b| b.duration}.maxItem + tail;
					Line.kr(0, 0, dur, doneAction: 2);
					bufs.collect{|buf| PlayBuf.ar(2, buf, doneAction: 0) }
				}
			}{
				^{
					var buf = frozenBuffers;
					Line.kr(0, 0, BufDur.kr(buf) + tail, doneAction: 2);
					PlayBuf.ar(2, buf, doneAction: 0)
				}
			}
		}{
			isMulti.if{
				^{ synthV.collect{|sv| In.ar(sv.vst.bus, 2) } }
			}{
				^{ In.ar(synthV.vst.bus, 2) }
			}
		}
	}

	/* setTransportPos(0) only on start — stopping must not rewind. */
	prTransport { |playing|
		var each = { |sv|
			playing.if{ sv.vst.controller.setTransportPos(0) };
			sv.vst.controller.setPlaying(playing);
		};
		isMulti.if{ synthV.do(each) }{ each.(synthV) }
	}

	/*
	 The one playback lifecycle: ready-gate, transport, cleanup. `makeSynth` builds
	 and returns the Synth — play passes a filtered source, P.synthVVST passes the
	 song's own music function, so both share this. The caller must not wrap this in
	 Server.bind: prPerform owns the two distinct timestamps below, and a nested
	 makeBundle is folded into the outer bundle at the outer timestamp.

	 The live reader is made immediately so it is already in the node graph when the
	 timestamped transport starts. The frozen reader is itself timestamped early. The
	 not-ready path waits, then uses the same scheduling logic.
	*/
	prPerform { |makeSynth, tail=1|
		var lat = Server.default.latency ? 0.2;
		/*
		 build shifted every onset by leadIn. Start the live transport, or the frozen
		 reader, at latency - leadIn: the shifted note still lands at plain latency while
		 the full preroll remains audible and the plugin has time to spin up.

		 A bundle, not a sync: VSTPluginController.sendMsg goes through server.sendMsg,
		 which openBundle collects, so /transport_play carries an exact timestamp.
		 Server.sync waits on a round trip and would put back the nondeterminism the
		 bundle exists to remove.
		*/
		var at = lat - leadIn;
		var doIt;
		(at < 0).if{
			"SynthVVST %: leadIn (%s) exceeds server latency (%s) — first note lands %s "
				"late. Lower leadIn or raise s.latency."
				.format(voice, leadIn, lat, at.neg.round(0.001)).warn;
			at = 0
		};
		doIt = {
			var syn;
			this.isFrozen.if{
				/* Play from frame zero at the live transport's early timestamp. The
				   rendered note was shifted by leadIn, so its nominal onset lands at
				   plain latency while the complete preroll remains audible. */
				Server.default.makeBundle(at, {
					syn = makeSynth.value
				});   /* Line.kr in `source` frees it */
			}{
				cleanup.notNil.if{ cleanup.stop };
				syn = makeSynth.value;
				Server.default.makeBundle(at, {
					this.prTransport(true);
				});
				cleanup = fork{
					(leadIn + params.dur.sum + tail).wait;
					this.prTransport(false);
					syn.free;
				}
			};
			syn
		};
		/*
		 `ready` is assigned only inside build, so a direct SynthVVST(...) that was
		 never built has nil here and the fork below died on nil.wait with an error
		 naming neither build nor this class. P.synthVVST always calls build, so
		 only the direct-construction route could reach it. build is idempotent on a
		 cache hit, so recover rather than throw.
		*/
		ready ?? {
			"SynthVVST: % played before build — building now".format(voice).postln;
			this.build;
		};
		ready.test.if{
			doIt.value
		}{
			/* doIt applies latency itself. An outer bind would collapse its early
			   bundle back to plain server latency. */
			fork{ ready.wait; doIt.value }
		};
		^this
	}

	play { |func tail=1|
		func = func ? I.d;
		^this.prPerform({ { this.source(tail).value => func }.play }, tail)
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
			/* Down but not broken. Without the tag the next build cannot tell this
			   apart from a build still opening, and rebuilds one of them wrongly. */
			item.buildState_(\stale);
		}
	}

	*freeAll {
		cache.do{|item| item.freeVSTs };
		cache = IdentityDictionary.new;
	}

	*clearCache {
		this.freeAll;
	}

	/*
	 Freeze a collection in one SynthV Studio batch. With no argument, select only
	 currently open SynthVVSTs. An explicit item or collection is accepted so other
	 owners can provide a scope without duplicating the render coordinator.
	*/
	*freeze { |items|
		var script = SynthV.directory +/+ "SCRIPTS/renderSynthV-batch.sh";
		var paths = List.new;
		var selected = this.prFreezeItems(items);
		var frozen = 0, unbuilt = 0, pid;
		selected.do{|item|
			item.isFrozen.if {
				frozen = frozen + 1
			} {
				item.synthV.isNil.if {
					unbuilt = unbuilt + 1;
					"SynthVVST.freeze: % has not been built; skipping".format(item.voice).warn
				} {
					paths.addAll(item.prepareRender)
				}
			}
		};
		(paths.size > 0).if{
			pid = (script + paths.collect{|p| p.shellQuote}.join(" ")).unixCmd;
			"SynthVVST.freeze: % files for % takes queued (pid %)"
				.format(paths.size, selected.size - frozen - unbuilt, pid).postln;
		}{
			(selected.isEmpty).if {
				"SynthVVST.freeze: no instances selected".postln
			} {
				"SynthVVST.freeze: nothing queued (% already frozen, % not built)"
					.format(frozen, unbuilt).postln
			}
		};
		^pid
	}

	/* Normalize a single item or collection, prefer the cache's canonical wrapper,
	   and submit a content hash once even if the input repeats it. */
	*prFreezeItems { |items|
		var byKey = IdentityDictionary.new;
		items = items ?? { cache.values.select{|item| item.isOpen } };
		items.asArray.do{|item|
			item.isKindOf(SynthVVST).if {
				item = cache[item.cacheKey] ? item;
				byKey[item.cacheKey] = item
			} {
				"SynthVVST.freeze: expected SynthVVST, got %; skipping"
					.format(item.class).warn
			}
		};
		^byKey.values.asArray
	}

	// Compatibility name: preserve its old all-cached scope.
	*renderAll { ^this.freeze(cache.values) }
}
+ P {
	*synthVVST { |voice start params syl lag=0 music song resources filters version=2 take tail=1 leadIn=0.1|
		var sv, section, key;
		key = take.notNil.if{ voice ++ "_" ++ take }{ voice };
		section = P.calcStart(start);
		song = song ? Song.currentSong;
		sv = SynthVVST(voice, version: version, leadIn: leadIn, params:
			song.pbind[section].patternpairs.collect{|i| (i.class==Pseq).if{i.list}{i} }
			++ params.value(song, song.durs[section].list, voice)
			=> Event.newFrom(_)
		);
		filters = filters ? [];
		filters.isKindOf(Function).if{ filters = [filters] };
		filters.do{|f| f.(sv) };
		sv = sv.build;
		sv.isFrozen.not.if{
			"SynthVVST: % not frozen. Call SynthVVST.freeze to render all open takes."
				.format(key).postln;
		};
		/* lifecycle lives on the class now (prPerform); `music` keeps its (p, b, e)
		   signature and still returns the Synth, so existing songs are unchanged. */
		^P(key, start, syl, lag, {|p b e|
			sv.prPerform({ music.(p, b, e) }, tail)
		}, song,
			resources: resources ++ (
				/* e.bus.() still answers the UGen graph; asking `source` fresh each
				   call means a freeze/unfreeze between build and play is honoured. */
				bus: { sv.source(tail).value },
				sv: sv,
				synthV: sv
			)
		)
	}
}
