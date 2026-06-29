// VoiceSpace: persistent voices + parameter-trajectory engine for \keyFrame events.
// Each voice is a long-lived Synth whose controls are bus-mapped; events update those
// busses, with Env-typed values rendered as ramp synths sample-accurately.
//
// Synth-agnostic: user provides SynthDefs by name. Per-voice def lookup falls back
// to defaultDef (\graphSynth in SynthDefLibrary).
//
// Pairs with EventList: list.voiceSpace_(vs) routes list.play through vs.playFrom.

VoiceSpace {
	classvar default;
	var <voices, <aliveLanes, <lastScalar, <>voiceDefs, <>defaultDef;
	var <>scheduledRoutine;
	// TODO: target/addAction are per-VoiceSpace, not per-voice. If a single VoiceSpace
	// ever needs voices placed in different groups, add a voiceTargets dict mirroring voiceDefs.
	var <>target, <>addAction;

	*default { ^default ?? { default = this.new } }
	*resetDefault { default = nil }

	*initClass {
		Class.initClassTree(Event);
		Event.addEventType(\keyFrame, {
			var ev = currentEnvironment;
			var vs = ~voiceSpace ?? { Error("\\keyFrame event requires ~voiceSpace (set list.voiceSpace_)").throw };
			vs.fireLive(ev);
		});
	}

	*new { ^super.new.init }

	init {
		voices = ();
		aliveLanes = ();
		lastScalar = ();
		voiceDefs = ();
		defaultDef = \graphSynth;
	}

	// ---- voice lifecycle ----------------------------------------------------

	startVoice { |defName, voice|
		var desc = SynthDescLib.global[defName];
		var args = [];
		var busses = ();
		var defaults = ();
		var srv = Server.default;
		desc.isNil.if { Error("VoiceSpace.startVoice: no SynthDesc for %".format(defName)).throw };
		desc.controls.do { |ctl|
			var n  = ctl.name.asSymbol;
			var nc = ctl.defaultValue.asArray.size.max(1);
			var bus = Bus.control(srv, nc);
			bus.set(ctl.defaultValue);
			busses[n] = bus;
			defaults[n] = ctl.defaultValue;
			args = args ++ [n, bus.asMap];
		};
		voices[voice] = (
			syn: Synth(defName, args, target, addAction ? \addToHead).register,
			busses: busses,
			defaults: defaults,
			lastVal: defaults.copy,
			envSyns: List[],
			plusSyns: (),
			rampSyns: (),
			rampBuses: (),
			dispatchRamps: (),
			rampInfo: ()
		);
		voices[voice].syn.onFree {
			voices[voice] !? { |v|
				v.envSyns.do { |syn| try { syn.free } };
				v.plusSyns.do { |syn| try { syn.free } };
				v.rampSyns.do { |syn| try { syn.free } };
				v.dispatchRamps.do { |syn| try { syn.free } };
				v.rampBuses.do { |b| b.free };
				v.busses.do { |bus| bus.free };
				voices[voice] = nil;
			};
			"voice % freed".format(voice).postln;
		};
	}

	release { |voiceList, gate = -1.05|
		voiceList.asArray.do { |v|
			voices[v] !? { |entry| entry.syn.set(\gate, gate) }
		}
	}

	stop {
		scheduledRoutine !? { |r| r.stop };
		scheduledRoutine = nil;
	}

	// ---- ramp helper (Tuple3/Tuple4 transitions) -----------------------------

	go { |bus, dest, time=1, curve=\lin, lag=0, syn|
		^{
			Env([In.kr(bus.index, bus.numChannels) => Latch.kr(_, 1), dest], time, curve)
				.kr(2, gate: 1).lag2(lag)
			=> Out.kr(bus.index, _)
		}.play(target: syn, addAction: \addBefore)
	}

	// ---- plus: per-param Function synths layered onto busses ---------------
	// The plus synth uses ReplaceOut.kr and combines a baseline (named control
	// "<param>_val") with the user's modulation function. dispatch routes
	// scalar/Tuple/Env writes through that baseline control: scalars via .set,
	// ramps via a private rampBus that the named control is .map'd onto.
	// plusSyns may free themselves early (user func can include its own
	// done-action), so all .free/.release are try-wrapped.
	//
	// Note: this is the live/preview path. playFrom uses additive Out.kr
	// plus over the timeline's ReplaceOut env, which is a different (also
	// correct) shape — see top of playFrom.

	plusBaseKey { |param| ^(param.asString ++ "_val").asSymbol }

	freeRamp { |voice, param|
		var v = voices[voice];
		v.isNil.if { ^this };
		v.rampSyns[param] !? { |syn| try { syn.free } };
		v.rampSyns[param] = nil;
		v.rampBuses[param] !? { |b| b.free };
		v.rampBuses[param] = nil;
	}

	freeDispatchRamp { |voice, param|
		var v = voices[voice];
		v.isNil.if { ^this };
		v.dispatchRamps[param] !? { |syn| try { syn.free } };
		v.dispatchRamps[param] = nil;
		v.rampInfo[param] = nil;
	}

	// Snapshot a dispatchRamp's current state. Returns (currentVal, remainingEnv, lag)
	// where remainingEnv is non-nil only when the original was a Tuple3/Tuple4 ramp
	// still in progress. Multi-segment Env ramps are snapshotted to currentVal only.
	dispatchRampSnapshot { |voice, param|
		var v = voices[voice];
		var info, elapsed, remaining, fullEnv, currentVal, remainingEnv, lag = 0;
		v.isNil.if { ^(currentVal: nil, remainingEnv: nil, lag: 0) };
		info = v.rampInfo[param];
		info.isNil.if { ^(currentVal: nil, remainingEnv: nil, lag: 0) };
		elapsed = Main.elapsedTime - info[\start];
		remaining = (info[\dur] - elapsed).max(0);
		fullEnv = info[\env] ?? {
			Env([info[\startVal], info[\dest]], [info[\dur]], [info[\curve]])
		};
		currentVal = fullEnv.at(elapsed.min(info[\dur]));
		((remaining > 0) and: { info[\env].isNil }).if {
			remainingEnv = Env([currentVal, info[\dest]], [remaining], [info[\curve]]);
			lag = info[\lag] ? 0;
		};
		^(currentVal: currentVal, remainingEnv: remainingEnv, lag: lag)
	}

	scheduleRamp { |voice, param, dest, time, curve=\lin, lag=0|
		var v = voices[voice];
		var plus = v.plusSyns[param];
		var rampBus = v.rampBuses[param];
		var fresh = rampBus.isNil;
		plus.isNil.if { ^this };
		// Free only the running rampSyn; keep rampBus alive so the new env can
		// pick up its actual current value via In.kr (avoids jumping back to
		// a stale lastVal when re-ramping mid-flight).
		v.rampSyns[param] !? { |syn| try { syn.free } };
		v.rampSyns[param] = nil;
		fresh.if {
			var start = v.lastVal[param] ? v.defaults[param];
			rampBus = Bus.control(Server.default, 1);
			rampBus.set(start);
			v.rampBuses[param] = rampBus;
		};
		v.rampSyns[param] = {
			Env([In.kr(rampBus.index) => Latch.kr(_, 1), dest], [time], [curve])
				.kr(0, gate: 1).lag2(lag)
			=> ReplaceOut.kr(rampBus.index, _)
		}.play(target: plus, addAction: \addBefore);
		fresh.if { plus.map(this.plusBaseKey(param), rampBus) };
	}

	scheduleRampEnv { |voice, param, env|
		var v = voices[voice];
		var plus = v.plusSyns[param];
		var rampBus = v.rampBuses[param];
		var fresh = rampBus.isNil;
		plus.isNil.if { ^this };
		v.rampSyns[param] !? { |syn| try { syn.free } };
		v.rampSyns[param] = nil;
		fresh.if {
			rampBus = Bus.control(Server.default, 1);
			rampBus.set(env.levels[0]);
			v.rampBuses[param] = rampBus;
		};
		v.rampSyns[param] = {
			ReplaceOut.kr(rampBus.index, EnvGen.kr(env, doneAction: 0))
		}.play(target: plus, addAction: \addBefore);
		fresh.if { plus.map(this.plusBaseKey(param), rampBus) };
	}

	applyPlus { |voice, plusEv|
		var v = voices[voice];
		v.isNil.if { ^this };
		plusEv.keysValuesDo { |param, val|
			var bus = v.busses[param];
			var existing = v.plusSyns[param];
			var baseKey = this.plusBaseKey(param);
			var lastVal = v.lastVal[param] ? v.defaults[param];
			bus.notNil.if {
				case
					{ val == \free } {
						var rampBus = v.rampBuses[param];
						existing !? { try { existing.free } };
						rampBus.notNil.if {
							// Keep rampSyn alive; replace user func with a passthrough
							// so the voice bus continues tracking the in-flight ramp.
							v.plusSyns[param] = {
								ReplaceOut.kr(bus.index, baseKey.kr(0))
							}.play(target: v.syn, addAction: \addBefore,
								args: [baseKey, rampBus.asMap]);
						} {
							v.plusSyns[param] = nil;
							bus.set(lastVal);
						};
					}
					{ val == \release } {
						existing !? { |syn| try { syn.set(baseKey, lastVal) } };
						this.freeRamp(voice, param);
						existing !? { try { existing.release } };
						v.plusSyns[param] = nil;
					}
					{ val.isKindOf(SequenceableCollection) and: { val[0] == \release } } {
						existing !? { |syn| try { syn.set(baseKey, lastVal) } };
						this.freeRamp(voice, param);
						existing !? { try { existing.release(val[1]) } };
						v.plusSyns[param] = nil;
					}
					{ val.isKindOf(Function) } {
						var snap = this.dispatchRampSnapshot(voice, param);
						var baseVal = snap[\currentVal] ? lastVal;
						this.freeRamp(voice, param);
						this.freeDispatchRamp(voice, param);
						existing !? { try { existing.free } };
						snap[\remainingEnv].notNil.if {
							// Continue the in-flight ramp on a private rampBus so plus
							// baseline (\<param>_val) tracks the rising/falling motion.
							var rampBus = Bus.control(Server.default, 1);
							rampBus.set(baseVal);
							v.rampBuses[param] = rampBus;
							v.plusSyns[param] = {
								ReplaceOut.kr(bus.index, baseKey.kr(0) + val.value)
							}.play(target: v.syn, addAction: \addBefore,
								args: [baseKey, rampBus.asMap]);
							v.rampSyns[param] = {
								ReplaceOut.kr(rampBus.index,
									EnvGen.kr(snap[\remainingEnv], doneAction: 0).lag2(snap[\lag]))
							}.play(target: v.syn, addAction: \addBefore);
						} {
							v.plusSyns[param] = {
								ReplaceOut.kr(bus.index, baseKey.kr(baseVal) + val.value)
							}.play(target: v.syn, addAction: \addBefore);
						};
						v.lastVal[param] = baseVal;
					}
				;
			}
		}
	}

	// ---- per-event dispatch (sets busses; spawns ramp synths) --------------

	dispatch { |ev, voice|
		var v = voices[voice];
		v.isNil.if { ^this };
		ev.keys.do { |k|
			var val = ev[k];
			(k != \voice).if {
				v.busses[k] !? { |bus|
					var plus = v.plusSyns[k];
					var baseKey = this.plusBaseKey(k);
					case
						{ val.isNumber } {
							this.freeDispatchRamp(voice, k);
							plus.notNil.if {
								this.freeRamp(voice, k);
								try { plus.set(baseKey, val) };
							} {
								bus.set(val);
							};
							v.lastVal[k] = val;
						}
						{ val.isKindOf(Tuple3) } {
							var dest = val.at1.value;
							plus.notNil.if {
								this.scheduleRamp(voice, k, dest, val.at2, val.at3);
							} {
								// `go` reads current bus via In.kr — sample it here too so
								// rampInfo's startVal matches what go's EnvGen will actually use.
								// But getSynchronous only reflects committed state: if startVoice's
								// bus.set(default) is bundled with this same dispatch, the bundle
								// hasn't been sent yet → getSynchronous returns 0. Only trust it
								// when a previous dispatchRamp was running (proves bus is committed
								// and actively moving); otherwise lastVal/defaults is authoritative.
								var startVal = v.dispatchRamps[k].notNil.if(
									{ bus.getSynchronous },
									{ v.lastVal[k] ? v.defaults[k] }
								);
								this.freeDispatchRamp(voice, k);
								v.dispatchRamps[k] = this.go(bus, dest, val.at2, val.at3, 0, v.syn);
								v.rampInfo[k] = (
									start: Main.elapsedTime, dur: val.at2,
									startVal: startVal, dest: dest, curve: val.at3,
									lag: 0, env: nil
								);
							};
							v.lastVal[k] = dest;
						}
						{ val.isKindOf(Tuple4) } {
							var dest = val.at1.value;
							plus.notNil.if {
								this.scheduleRamp(voice, k, dest, val.at2, val.at3, val.at4);
							} {
								var startVal = v.dispatchRamps[k].notNil.if(
									{ bus.getSynchronous },
									{ v.lastVal[k] ? v.defaults[k] }
								);
								this.freeDispatchRamp(voice, k);
								v.dispatchRamps[k] = this.go(bus, dest, val.at2, val.at3, val.at4, v.syn);
								v.rampInfo[k] = (
									start: Main.elapsedTime, dur: val.at2,
									startVal: startVal, dest: dest, curve: val.at3,
									lag: val.at4, env: nil
								);
							};
							v.lastVal[k] = dest;
						}
						{ val.isKindOf(Env) } {
							plus.notNil.if {
								this.scheduleRampEnv(voice, k, val);
							} {
								this.freeDispatchRamp(voice, k);
								v.dispatchRamps[k] = {
									EnvGen.kr(val, doneAction: 2) => Out.kr(bus.index, _)
								}.play(target: v.syn, addAction: \addBefore);
								v.rampInfo[k] = (
									start: Main.elapsedTime, dur: val.times.sum,
									startVal: val.levels[0], dest: val.levels.last,
									curve: nil, lag: 0, env: val
								);
							};
							v.lastVal[k] = val.levels.last;
						}
					;
				}
			}
		}
	}

	// ---- live event firing (used by \keyFrame event type) -------------------

	fireLive { |ev|
		var plusEv = ev[\plus];
		var plusVoice = ev[\voice] ? \default;
		this.fanLive(ev).do { |laneEv|
			var voice = laneEv[\voice] ? \default;
			var defName;
			laneEv[\defName] !? { |d| voiceDefs[voice] = d };
			defName = voiceDefs[voice] ? defaultDef;
			Server.default.bind {
				voices[voice].isNil.if { this.startVoice(defName, voice) };
				this.dispatch(laneEv, voice);
			}
		};
		plusEv !? {
			Server.default.bind {
				var n = aliveLanes[plusVoice] ? 0;
				var targets;
				ev[\defName] !? { |d| voiceDefs[plusVoice] = d };
				targets = (n > 0).if(
					{ (0 .. n - 1).collect { |i| (plusVoice ++ "_" ++ i).asSymbol } },
					{ [plusVoice] }
				);
				targets.do { |laneVoice|
					var def = voiceDefs[laneVoice] ? voiceDefs[plusVoice] ? defaultDef;
					voices[laneVoice].isNil.if { this.startVoice(def, laneVoice) };
					this.applyPlus(laneVoice, plusEv);
				}
			}
		}
	}

	// ---- live fan-out: persistent per-voice lane state ---------------------

	fanLive { |ev|
		var skip = [\when, \voice, \type, \newType, \beat, \delta, \dur, \tempoTrack, \tempo, \defName, \server, \voiceSpace, \plus];
		var isLaneParam = { |v|
			v.isArray
				and: { v.isKindOf(Tuple3).not }
				and: { v.isKindOf(Tuple4).not }
				and: { v.isKindOf(Env).not }
		};
		var voice = ev[\voice] ? \default;
		var beat  = ev[\when] ? 0;
		var eventWidth = 1;
		var fanned, out;
		ev.keysValuesDo { |k, v|
			(skip.includes(k).not and: { isLaneParam.(v) }).if { eventWidth = eventWidth.max(v.size) }
		};
		aliveLanes[voice] ?? { aliveLanes[voice] = 0 };
		lastScalar[voice] ?? { lastScalar[voice] = () };
		fanned = (aliveLanes[voice] > 0) or: { eventWidth > 1 };
		out = List[];
		fanned.if {
			(aliveLanes[voice] == 0 and: { voices[voice].notNil }).if {
				voices[voice].syn.free;
				voices[voice] = nil;
			};
			(eventWidth > aliveLanes[voice]).if {
				(aliveLanes[voice] .. eventWidth - 1).do { |i|
					var birth = ();
					birth[\when]  = beat;
					birth[\voice] = (voice ++ "_" ++ i).asSymbol;
					ev[\defName] !? { |d| birth[\defName] = d };
					lastScalar[voice].keysValuesDo { |k, v| birth[k] = v };
					(birth.size > 2).if { out.add(birth) };
				};
				aliveLanes[voice] = eventWidth;
			};
			aliveLanes[voice].do { |i|
				var laneEv = ();
				laneEv[\when]  = beat;
				laneEv[\voice] = (voice ++ "_" ++ i).asSymbol;
				ev[\defName] !? { |d| laneEv[\defName] = d };
				ev.keysValuesDo { |k, v|
					skip.includes(k).not.if {
						isLaneParam.(v).if {
							(i < v.size).if { laneEv[k] = v[i] }
						} {
							laneEv[k] = v;
						}
					}
				};
				(laneEv.size > 2).if { out.add(laneEv) };
			};
		} {
			out.add(ev);
		};
		ev.keysValuesDo { |k, v|
			skip.includes(k).not.if {
				isLaneParam.(v).not.if { lastScalar[voice][k] = v }
			}
		};
		^out
	}

	// timelineToEnv / extractTempo / beatToWall live on EventList (single engine);
	// playFrom calls them through `list`. See EventList.sc.

	// max lane-fan width per base voice across the event list. >1 means fanned.
	computeLaneCounts { |events|
		var skip = [\when, \voice, \type, \newType, \beat, \delta, \dur, \tempoTrack, \tempo, \defName, \plus];
		var isLaneParam = { |v|
			v.isArray and: { v.isKindOf(Tuple3).not }
				and: { v.isKindOf(Tuple4).not } and: { v.isKindOf(Env).not }
		};
		var counts = ();
		events.do { |ev|
			var voice = ev[\voice] ? \default;
			var w = 1;
			ev.keysValuesDo { |k, v|
				(skip.includes(k).not and: { isLaneParam.(v) }).if { w = w.max(v.size) }
			};
			counts[voice] = (counts[voice] ? 0).max(w);
		};
		^counts
	}

	// Return the lane voice symbols for a base voice given a lane-count dict.
	// Voices with count <= 1 stay as-is; otherwise expand to \base_0..\base_(n-1).
	laneVoicesFor { |voice, laneCounts|
		var n = laneCounts[voice] ? 1;
		^(n > 1).if(
			{ (0 .. n - 1).collect { |i| (voice ++ "_" ++ i).asSymbol } },
			{ [voice] }
		)
	}

	// ---- pre-baked-timeline expansion (playFrom path) ----------------------

	expandLanes { |events|
		var skip = [\when, \voice, \type, \newType, \beat, \delta, \dur, \tempoTrack, \tempo, \defName, \plus];
		var isLaneParam, maxWidth, lastScalarLocal, aliveLanesLocal, out;
		isLaneParam = { |v|
			v.isArray
				and: { v.isKindOf(Tuple3).not }
				and: { v.isKindOf(Tuple4).not }
				and: { v.isKindOf(Env).not }
		};
		maxWidth        = ();
		lastScalarLocal = ();
		aliveLanesLocal = ();
		out             = List[];
		events.do { |ev|
			var voice = ev[\voice] ? \default;
			var w = 1;
			ev.keysValuesDo { |k, v|
				(skip.includes(k).not and: { isLaneParam.(v) }).if { w = w.max(v.size) }
			};
			maxWidth[voice] = (maxWidth[voice] ? 1).max(w);
		};
		events.do { |ev|
			var voice = ev[\voice] ? \default;
			var beat  = ev[\when] ? 0;
			var fan;
			var eventWidth = 1;
			fan = maxWidth[voice] > 1;
			ev.keysValuesDo { |k, v|
				(skip.includes(k).not and: { isLaneParam.(v) }).if { eventWidth = eventWidth.max(v.size) }
			};
			aliveLanesLocal[voice] ?? { aliveLanesLocal[voice] = 0 };
			lastScalarLocal[voice] ?? { lastScalarLocal[voice] = () };
			fan.if {
				(eventWidth > aliveLanesLocal[voice]).if {
					(aliveLanesLocal[voice] .. eventWidth - 1).do { |i|
						var birthEv = ();
						birthEv[\when]  = beat;
						birthEv[\voice] = (voice ++ "_" ++ i).asSymbol;
						ev[\defName] !? { |d| birthEv[\defName] = d };
						lastScalarLocal[voice].keysValuesDo { |k, v| birthEv[k] = v };
						(birthEv.size > 2).if { out.add(birthEv) };
					}
				};
				aliveLanesLocal[voice] = aliveLanesLocal[voice].max(eventWidth);
				aliveLanesLocal[voice].do { |i|
					var laneEv = ();
					laneEv[\when]  = beat;
					laneEv[\voice] = (voice ++ "_" ++ i).asSymbol;
					ev[\defName] !? { |d| laneEv[\defName] = d };
					ev.keysValuesDo { |k, v|
						skip.includes(k).not.if {
							isLaneParam.(v).if {
								(i < v.size).if { laneEv[k] = v[i] }
							} {
								laneEv[k] = v;
							}
						}
					};
					(laneEv.size > 2).if { out.add(laneEv) };
				};
			} {
				out.add(ev);
			};
			ev.keysValuesDo { |k, v|
				skip.includes(k).not.if {
					isLaneParam.(v).not.if { lastScalarLocal[voice][k] = v }
				}
			};
		};
		^out
	}

	extractTimelines { |events|
		var skip = [\when, \voice, \type, \newType, \beat, \delta, \dur, \tempoTrack, \tempo, \defName, \plus];
		var tls = ();
		events.do { |ev|
			var voice = ev[\voice] ? \default;
			var beat  = ev[\when] ? 0;
			ev.keysValuesDo { |k, v|
				skip.includes(k).not.if {
					tls[voice] ?? { tls[voice] = () };
					tls[voice][k] ?? { tls[voice][k] = List[] };
					tls[voice][k].add([beat, v]);
				}
			}
		};
		tls.do { |params| params.do { |tl| tl.sort({|a,b| a[0] < b[0]}) } };
		^tls
	}

	// Route (c): warp a \mi2 item's internal events onto the list's tempo track. Each
	// event at item-time t is placed at list-beat originBeat + (t / rate), rate =
	// ~tempo/~stretch (the item's nominal playback rate), then mapped to wall-clock by
	// beatToWall — so the item's notes follow the global tempo, not a private constant
	// clock. Onsets AND sustains are warped (a held note stretches/compresses with the
	// track). When `from` is past the item's onset, the item is trimmed to the matching
	// item-time (player.from also chases CC state) so play(from) starts partway INTO the
	// item rather than dropping it; returns nil if `from` is past the whole item.
	// Returned player's timestamps are wall-seconds relative to its first event (play it
	// on a unit clock). A flat track reproduces the sealed \mi2 timing exactly.
	// beat -> wall conversion is delegated to the EventList (single engine, so a
	// recorded tempoMap composes with \tempoTrack); `list` is threaded in for it.
	prWarpItemToTrack { |list, ev, tempoEnv, from = 0|
		var player = ev[\player];
		var b0     = ev[\when] ? 0;
		var rate   = ((ev[\tempo] ? 1) / (ev[\stretch] ? 1));
		var originBeat = b0.max(from), base, pstart, warped, out;
		player.isNil.if { ^nil };
		ev[\filter] !? { |f| player = f.(player) };
		ev[\params] !? { |p| player = player.setParams(p) }; // \mi2 finish does this
		(from > b0).if {
			var tFrom = (player.start ? 0) + ((from - b0) * rate);
			(tFrom >= (player.end ? player.bounds.end)).if { ^nil }; // item fully before `from`
			player = player.from(tFrom); // rebases to 0 and chases CC state to tFrom
		};
		base   = list.beatToWall(originBeat, tempoEnv);
		pstart = player.start ? 0;
		warped = player.midiEvents.collect { |e|
			var c   = e.copy;
			var rel = (e[\timestamp] ? 0) - pstart;
			c[\timestamp] = list.beatToWall(originBeat + (rel / rate), tempoEnv) - base;
			e[\sustain] !? { |s|
				c[\sustain] = list.beatToWall(originBeat + ((rel + s) / rate), tempoEnv)
					- list.beatToWall(originBeat + (rel / rate), tempoEnv)
			};
			c
		};
		out = MIDIItemPlayer(warped, player.source);
		out.start = 0; // timestamps are already wall-relative to playback start
		^out
	}

	rescaleEnv { |list, env, startBeat, tempoEnv|
		var newTimes = [];
		var cur = startBeat;
		env.times.do { |t|
			var next = cur + t;
			var wallDur = list.beatToWall(next, tempoEnv) - list.beatToWall(cur, tempoEnv);
			newTimes = newTimes.add(wallDur);
			cur = next;
		};
		^Env(env.levels, newTimes, env.curves)
	}

	// ---- timeline-driven playback (cancelable via stop) --------------------

	playFrom { |list, from=0|
		var events, keyEvents, otherEvents, tempoEnv, fromWall, expanded, tls, pending;
		var plusParams, laneCounts;
		from = from ? 0;
		// No tempoMap on a VoiceSpace list => base of 1 s/beat, so \tempoTrack values
		// read as absolute s/beat (identity = 1), matching the pre-delegation behavior.
		list.beatDur ?? { list.beatDur_(1) };
		events      = list.scopedEvents.select { |e| list.shouldPlay(e) };
		keyEvents   = events.select { |e| (e[\type] ? \keyFrame) == \keyFrame };
		otherEvents = events.reject { |e| (e[\type] ? \keyFrame) == \keyFrame };
		tempoEnv    = list.tempoEnv(events);
		fromWall    = list.beatToWall(from, tempoEnv);
		laneCounts  = this.computeLaneCounts(keyEvents);
		expanded    = this.expandLanes(keyEvents);
		tls         = this.extractTimelines(expanded);
		pending     = List[];
		plusParams  = ();

		expanded.do { |e|
			(e[\defName].notNil and: { e[\voice].notNil }).if {
				voiceDefs[e[\voice]] = e[\defName]
			}
		};

		// Pre-scan: which (voice, param) pairs will ever have a plus event?
		// Those get routed through a private rampBus so the persistent plus synth
		// can read the timeline env into its baseline (\<param>_val) and ride on top.
		// Plus fans out across lanes for any base voice that was lane-expanded.
		keyEvents.do { |ev|
			ev[\plus] !? { |plusEv|
				var baseVoice = ev[\voice] ? \default;
				this.laneVoicesFor(baseVoice, laneCounts).do { |laneVoice|
					plusParams[laneVoice] ?? { plusParams[laneVoice] = Set[] };
					plusEv.keys.do { |param| plusParams[laneVoice].add(param) };
				}
			}
		};

		otherEvents.do { |ev|
			var beat  = ev[\when] ? 0;
			var delay = list.beatToWall(beat, tempoEnv) - fromWall;
			// Route (c): a \mi2 item opts in (followTrack:) to having its INTERNAL notes
			// warped by the tempo track, not just its onset. It is NOT gated on its onset
			// >= `from`: prWarpItemToTrack trims the item to `from`, so play(from) starts
			// partway INTO the item rather than dropping it.
			// (\mi is excluded: its fromNote(~from,~to) sub-range isn't replicated here.)
			(ev[\type] == \audioItemTempoFollow).if {
				var actions = (ev[\tempoFollowMode] == \env).if {
					AudioItem.tempoFollowEnvActions(ev, list, tempoEnv, from)
				} {
					AudioItem.tempoFollowActions(ev, list, tempoEnv, from)
				};
				actions.do { |pair|
					pending.add(pair)
				}
			} {
				((ev[\followTrack] == true) and: { ev[\type] == \mi2 }).if {
					var warped = this.prWarpItemToTrack(list, ev, tempoEnv, from);
					warped !? {
						pending.add([delay.max(0), { warped.play(ev[\mk] ? MicroKeys(\default), clock: TempoClock(1)) }])
					}
				} {
					// self-contained event type (private constant clock); preview/standalone path
					(delay >= 0).if { pending.add([delay, { ev.copy.play }]) }
				}
			}
		};

		tls.keysValuesDo { |voice, params|
			var firstBeat = params.values.collect({ |tl| tl[0][0] }).minItem;
			var firstWall = list.beatToWall(firstBeat, tempoEnv);
			var delayWall = (firstWall - fromWall).max(0);
			var startBeat = from.max(firstBeat);
			pending.add([delayWall, {
				Server.default.bind {
					var v;
					voices[voice].isNil.if { this.startVoice(voiceDefs[voice] ? defaultDef, voice) };
					v = voices[voice];
					params.keysValuesDo { |param, tl|
						v.busses[param] !? { |bus|
							var env = list.timelineToEnv(tl, v.defaults[param]);
							var total = env.times.sum;
							var hasPlus = (plusParams[voice] ?? { Set[] }).includes(param);
							var writeBus, baseKey, rampBus;
							v.lastVal[param] = env.at(startBeat);
							hasPlus.if {
								var seed = env.at(startBeat);
								rampBus = Bus.control(Server.default, 1);
								rampBus.set(seed);
								v.rampBuses[param] = rampBus;
								baseKey = this.plusBaseKey(param);
								// Passthrough plus until the first plus event swaps in userFunc.
								// Mapping is set via /s_new args (atomic with synth creation).
								// .map after .play would race against /d_recv's async load.
								v.plusSyns[param] = {
									ReplaceOut.kr(bus.index, baseKey.kr(seed))
								}.play(target: v.syn, addAction: \addBefore,
									args: [baseKey, rampBus.asMap]);
								writeBus = rampBus;
							} {
								bus.set(env.at(startBeat));
								writeBus = bus;
							};
							(startBeat < total).if {
								var trimmed = (startBeat > 0).if { env.segment(startBeat, total) } { env };
								var rescaled = this.rescaleEnv(list, trimmed, startBeat, tempoEnv);
								v.envSyns.add(
									{ EnvGen.kr(rescaled, doneAction: 0) => ReplaceOut.kr(writeBus.index, _) }
										.play(target: v.syn, addAction: \addBefore)
								);
							}
						}
					};
				}
			}])
		};

		// Plus events: free the passthrough/old plus and spawn a new one carrying userFunc.
		// rampBus mapping is restored so plus's baseline continues tracking the timeline env.
		// Fans across lanes for any base voice that was lane-expanded.
		keyEvents.do { |ev|
			ev[\plus] !? { |plusEv|
				var baseVoice = ev[\voice] ? \default;
				var beat  = ev[\when] ? 0;
				var delay = list.beatToWall(beat, tempoEnv) - fromWall;
				var laneVoices = this.laneVoicesFor(baseVoice, laneCounts);
				(delay >= 0).if {
					pending.add([delay, {
						Server.default.bind {
							laneVoices.do { |voice|
								ev[\defName] !? { |d| voiceDefs[voice] = d };
								voices[voice].isNil.if {
									this.startVoice(voiceDefs[voice] ? defaultDef, voice)
								};
								plusEv.keysValuesDo { |param, val|
									var v = voices[voice];
									var bus = v !? { v.busses[param] };
									var existing = v !? { v.plusSyns[param] };
									var rampBus = v !? { v.rampBuses[param] };
									var baseKey = this.plusBaseKey(param);
									(v.notNil and: { bus.notNil }).if {
										case
											{ val == \free } {
												existing !? { try { existing.free } };
												// Revert to passthrough so the timeline env still reaches voice bus.
												// Mapping via /s_new args avoids /n_mapn-before-/s_new race.
												v.plusSyns[param] = {
													ReplaceOut.kr(bus.index, baseKey.kr(0))
												}.play(target: v.syn, addAction: \addBefore,
													args: rampBus.notNil.if({ [baseKey, rampBus.asMap] }, { [] }));
											}
											{ val == \release } {
												existing !? { try { existing.release } };
											}
											{ val.isKindOf(SequenceableCollection) and: { val[0] == \release } } {
												existing !? { try { existing.release(val[1]) } };
											}
											{ val.isKindOf(Function) } {
												existing !? { try { existing.free } };
												v.plusSyns[param] = {
													ReplaceOut.kr(bus.index, baseKey.kr(0) + val.value)
												}.play(target: v.syn, addAction: \addBefore,
													args: rampBus.notNil.if({ [baseKey, rampBus.asMap] }, { [] }));
											}
										;
									}
								}
							}
						}
					}])
				}
			}
		};

		pending.sort { |a, b| a[0] < b[0] };
		this.stop;
		scheduledRoutine = Routine {
			var t = 0;
			pending.do { |pair|
				(pair[0] - t).max(0).wait;
				t = pair[0];
				pair[1].value;
			};
		}.play(SystemClock);
	}
}
