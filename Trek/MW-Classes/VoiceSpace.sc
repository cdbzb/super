// VoiceSpace: persistent voices + parameter-trajectory engine for \keyFrame events.
// Each voice is a long-lived Synth whose controls are bus-mapped; events update those
// busses, with Env-typed values rendered as ramp synths sample-accurately.
//
// Synth-agnostic: user provides SynthDefs by name. Per-voice def lookup falls back
// to defaultDef (\graphSynth in SynthDefLibrary).
//
// Pairs with EventList: list.voiceSpace_(vs) routes list.play through vs.playFrom.
//
// Ndef voices: an event carrying ndef: (a Symbol naming an Ndef, or any NodeProxy)
// makes its voice drive that proxy instead of a synth. The voice's busses are
// allocated lazily, one per proxy control a keyframe names, seeded with the
// proxy's current value and mapped onto the proxy (proxy.set(k, bus.asMap)); every
// existing path (dispatch, ramps, timelines, plus) then writes those busses as
// usual. The voice's `syn` is a Group, so everything placed \addBefore it still
// lands. gate <= 0 (or release) ends the voice: each control still mapped to its
// bus is set back to a plain number (the value it reached), then the busses are
// freed. No lane fan-out for Ndef voices; audio-rate and multichannel controls are
// not driven.

VoiceSpace {
	classvar default;
	// proxy -> (control -> voice entry): the one voice allowed to drive each control
	classvar ndefOwners;
	var <voices, <aliveLanes, <lastScalar, <>voiceDefs, <>defaultDef;
	var <voiceNdefs;
	var <>scheduledRoutine;
	// TODO: target/addAction are per-VoiceSpace, not per-voice. If a single VoiceSpace
	// ever needs voices placed in different groups, add a voiceTargets dict mirroring voiceDefs.
	var <>target, <>addAction;

	*default { ^default ?? { default = this.new } }
	*resetDefault { default = nil }

	*initClass {
		ndefOwners = IdentityDictionary.new;
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
		voiceNdefs = ();
		defaultDef = \graphSynth;
	}

	// ---- voice lifecycle ----------------------------------------------------

	startVoice { |defName, voice|
		var desc;
		var args = [];
		var busses = ();
		var defaults = ();
		var srv = Server.default;
		voiceNdefs[voice] !? { |proxy| ^this.startNdefVoice(proxy, voice) };
		desc = SynthDescLib.global[defName];
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
			voiceNdefs[v].notNil.if { this.endNdefVoice(v) } {
				voices[v] !? { |entry| entry.syn.set(\gate, gate) }
			}
		}
	}

	// ---- Ndef voices ----------------------------------------------------------

	*prAsProxy { |n| ^n.isKindOf(NodeProxy).if { n } { Ndef(n.asSymbol) } }

	isNdefVoice { |voice| ^voiceNdefs[voice].notNil }

	// Remember which proxy a voice drives. Called wherever an event reaches a voice.
	prNoteNdef { |ev, voice|
		ev[\ndef] !? { |n| voiceNdefs[voice] = VoiceSpace.prAsProxy(n) }
	}

	// Voices named by ndef: events in a batch (plus any already known), so lane
	// expansion can leave them alone.
	prNdefVoicesIn { |events|
		var set = voiceNdefs.keys.copy;
		events.do { |ev| ev[\ndef] !? { set.add(ev[\voice] ? \default) } };
		^set
	}

	startNdefVoice { |proxy, voice|
		var grp = Group(target, addAction ? \addToHead);
		var entry = (
			syn: grp, proxy: proxy, ndef: true,
			busses: (), defaults: (), lastVal: (),
			envSyns: List[], plusSyns: (), rampSyns: (), rampBuses: (),
			dispatchRamps: (), rampInfo: ()
		);
		voices[voice] = entry;
		// Cmd-. frees the group too: end the voice then, but only if it is still
		// this entry (a restarted voice of the same name must survive).
		grp.register;
		grp.onFree { (voices[voice] === entry).if { this.endNdefVoice(voice, false) } };
	}

	// Map each named proxy control that is not mapped yet. Keys that are not
	// scalar control-rate controls of the proxy are ignored (dispatch skips keys
	// without a bus, as for synth voices).
	prNdefEnsure { |voice, keys|
		var v = voices[voice], proxy, names;
		(v.isNil or: { v[\ndef] != true }).if { ^this };
		proxy = v[\proxy];
		names = proxy.controlNames(nil, false);
		keys.do { |k|
			v.busses[k].isNil.if {
				names.detect { |cn| cn.name.asSymbol == k } !? { |cn|
					case
						{ cn.rate == \audio } {
							"VoiceSpace: % is audio-rate on % — not driven".format(k, proxy).warn
						}
						{ cn.defaultValue.isArray } {
							"VoiceSpace: % is multichannel on % — not driven".format(k, proxy).warn
						}
						{ this.prNdefMap(voice, v, proxy, k, cn.defaultValue) }
				}
			}
		}
	}

	prNdefMap { |voice, v, proxy, k, default|
		var cur = proxy.nodeMap[k];
		var val = cur.isNumber.if { cur } { default };
		var bus = Bus.control(Server.default, 1);
		var owners = ndefOwners[proxy] ?? { ndefOwners[proxy] = IdentityDictionary.new };
		owners[k] !? { |other|
			(other !== v).if {
				"VoiceSpace: voice % takes over %.% from another voice".format(voice, proxy, k).warn
			}
		};
		owners[k] = v;
		bus.set(val);
		v.busses[k] = bus;
		v.defaults[k] = val;
		v.lastVal[k] = val;
		proxy.set(k, bus.asMap);
	}

	/* Unmap, then free. A control is handed back only while it still reads THIS
	   voice's bus — a hand proxy.set or another voice's takeover already replaced
	   the mapping, and must not be overwritten. The value handed back is what the
	   bus holds now (shared memory, localhost), falling back to the last value
	   written. freeGroup false = the group is already gone (Cmd-.). */
	endNdefVoice { |voice, freeGroup = true|
		var v = voices[voice], proxy, owners;
		(v.isNil or: { v[\ndef] != true }).if { ^this };
		voices[voice] = nil;
		proxy = v[\proxy];
		owners = ndefOwners[proxy];
		v.busses.keysValuesDo { |k, bus|
			(proxy.nodeMap[k] == bus.asMap).if {
				// getSynchronous needs shared memory (local server); else last written
				proxy.set(k, (try { bus.getSynchronous }) ? v.lastVal[k] ? v.defaults[k])
			};
			owners !? { (owners[k] === v).if { owners.removeAt(k) } };
		};
		v.envSyns.do { |syn| try { syn.free } };
		v.plusSyns.do { |syn| try { syn.free } };
		v.rampSyns.do { |syn| try { syn.free } };
		v.dispatchRamps.do { |syn| try { syn.free } };
		v.rampBuses.do { |b| b.free };
		v.busses.do { |b| b.free };
		freeGroup.if { try { v.syn.free } };
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

	// ---- mod: per-param Function synths layered onto busses ----------------
	// Authored as mod: (amp: { SinOsc.kr(1) * 0.1 }) — the Function is ADDED to the
	// control's keyframed baseline. plus: is the original name and still works
	// (mod: wins if an event names both); internally everything is still "plus".
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
			var val = ev[k].asRamp;
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
		var plusEv = ev.modEvent;
		var plusVoice = ev[\voice] ? \default;
		this.prNoteNdef(ev, plusVoice);
		this.fanLive(ev).do { |laneEv|
			var voice = laneEv[\voice] ? \default;
			var defName;
			laneEv[\defName] !? { |d| voiceDefs[voice] = d };
			defName = voiceDefs[voice] ? defaultDef;
			Server.default.bind {
				var ending = this.isNdefVoice(voice) and: {
					laneEv[\gate].isNumber and: { laneEv[\gate] <= 0 } };
				voices[voice].isNil.if { ending.not.if { this.startVoice(defName, voice) } };
				this.prNdefEnsure(voice, laneEv.keys);
				this.dispatch(laneEv, voice);
				ending.if { this.endNdefVoice(voice) };
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
					this.prNdefEnsure(laneVoice, plusEv.keys);
					this.applyPlus(laneVoice, plusEv);
				}
			}
		}
	}

	// ---- live fan-out: persistent per-voice lane state ---------------------

	fanLive { |ev|
		var skip = [\when, \voice, \type, \newType, \beat, \delta, \dur, \tempoTrack, \tempo, \defName, \server, \voiceSpace, \plus, \mod, \ndef];
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
		// one proxy, one voice: an array value is not a lane request
		this.isNdefVoice(voice).if { ^[ev] };
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
		var skip = [\when, \voice, \type, \newType, \beat, \delta, \dur, \tempoTrack, \tempo, \defName, \plus, \mod, \ndef];
		var isLaneParam = { |v|
			v.isArray and: { v.isKindOf(Tuple3).not }
				and: { v.isKindOf(Tuple4).not } and: { v.isKindOf(Env).not }
		};
		var counts = ();
		var ndefVoices = this.prNdefVoicesIn(events);
		events.do { |ev|
			var voice = ev[\voice] ? \default;
			var w = 1;
			ndefVoices.includes(voice).not.if {
				ev.keysValuesDo { |k, v|
					(skip.includes(k).not and: { isLaneParam.(v) }).if { w = w.max(v.size) }
				}
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
		var skip = [\when, \voice, \type, \newType, \beat, \delta, \dur, \tempoTrack, \tempo, \defName, \plus, \mod, \ndef];
		var isLaneParam, maxWidth, lastScalarLocal, aliveLanesLocal, out, ndefVoices;
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
		ndefVoices      = this.prNdefVoicesIn(events);
		events.do { |ev|
			var voice = ev[\voice] ? \default;
			var w = 1;
			ndefVoices.includes(voice).not.if {
				ev.keysValuesDo { |k, v|
					(skip.includes(k).not and: { isLaneParam.(v) }).if { w = w.max(v.size) }
				}
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
		var skip = [\when, \voice, \type, \newType, \beat, \delta, \dur, \tempoTrack, \tempo, \defName, \plus, \mod, \ndef];
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

	// prWarpItemToTrack moved to EventList.prEmitMi2Follow (§10): the warp is beat-domain
	// and placement goes through `place`, so it works in plain EventList.play and
	// composes under nested \eventList events.

	// Rescale an env's beat-durations to wall-durations through the list's `place`
	// (absolute beat -> absolute wall-second; differences give segment wall lengths).
	rescaleEnv { |env, startBeat, place|
		var newTimes = [];
		var cur = startBeat;
		var prevWall = place.(cur); // carried: each node's place.(next) is the next node's place.(cur)
		env.times.do { |t|
			var nextWall;
			cur = cur + t;
			nextWall = place.(cur);
			newTimes = newTimes.add(nextWall - prevWall);
			prevWall = nextWall;
		};
		^Env(env.levels, newTimes, env.curves)
	}

	// ---- timeline-driven playback ------------------------------------------

	// Superseded by EventList.prepare/fire (§10): EventList.play no longer routes
	// through here. Kept as a compat shim for direct callers.
	playFrom { |list, from=0|
		^list.play(from)
	}

	// §10: emit schedule entries for the \keyFrame timeline machinery — a refactor of
	// the old playFrom voice/plus blocks. Same math, but times are absolute
	// wall-seconds through `place` and entries are returned for EventList.fire instead
	// of scheduled here. `events` is the list's filtered (scoped + shouldPlay) set,
	// `tempoEnv` the env prepare derived from it.
	prepareVoices { |list, epoch, from = 0, place, events, tempoEnv|
		var out = List[];
		var keyEvents, expanded, tls, plusParams, laneCounts;
		keyEvents   = events.select { |e| (e[\type] ? \keyFrame) == \keyFrame };
		laneCounts  = this.computeLaneCounts(keyEvents);
		expanded    = this.expandLanes(keyEvents);
		tls         = this.extractTimelines(expanded);
		plusParams  = ();

		expanded.do { |e|
			(e[\defName].notNil and: { e[\voice].notNil }).if {
				voiceDefs[e[\voice]] = e[\defName]
			};
			this.prNoteNdef(e, e[\voice] ? \default);
		};

		// Pre-scan: which (voice, param) pairs will ever have a plus event?
		// Those get routed through a private rampBus so the persistent plus synth
		// can read the timeline env into its baseline (\<param>_val) and ride on top.
		// Plus fans out across lanes for any base voice that was lane-expanded.
		keyEvents.do { |ev|
			ev.modEvent !? { |plusEv|
				var baseVoice = ev[\voice] ? \default;
				this.laneVoicesFor(baseVoice, laneCounts).do { |laneVoice|
					plusParams[laneVoice] ?? { plusParams[laneVoice] = Set[] };
					plusEv.keys.do { |param| plusParams[laneVoice].add(param) };
				}
			}
		};

		tls.keysValuesDo { |voice, params|
			var firstBeat = params.values.collect({ |tl| tl[0][0] }).minItem;
			var startBeat = from.max(firstBeat);
			out.add((time: place.(startBeat), label: \voice, send: {
				Server.default.bind {
					var v;
					voices[voice].isNil.if { this.startVoice(voiceDefs[voice] ? defaultDef, voice) };
					this.prNdefEnsure(voice, params.keys);
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
								var rescaled = this.rescaleEnv(trimmed, startBeat, place);
								v.envSyns.add(
									{ EnvGen.kr(rescaled, doneAction: 0) => ReplaceOut.kr(writeBus.index, _) }
										.play(target: v.syn, addAction: \addBefore)
								);
							}
						}
					};
				}
			}))
		};

		// Ndef voices end on gate <= 0. gate is not a proxy control, so the timeline
		// never writes it anywhere; the end is its own schedule entry.
		expanded.do { |ev|
			var voice = ev[\voice] ? \default;
			var beat  = ev[\when] ? 0;
			(this.isNdefVoice(voice) and: { ev[\gate].isNumber } and: { ev[\gate] <= 0 }
				and: { beat >= from }).if {
				out.add((time: place.(beat), label: \ndefEnd, send: {
					Server.default.bind { this.endNdefVoice(voice) }
				}))
			}
		};

		// Plus events: free the passthrough/old plus and spawn a new one carrying userFunc.
		// rampBus mapping is restored so plus's baseline continues tracking the timeline env.
		// Fans across lanes for any base voice that was lane-expanded.
		keyEvents.do { |ev|
			ev.modEvent !? { |plusEv|
				var baseVoice = ev[\voice] ? \default;
				var beat  = ev[\when] ? 0;
				var laneVoices = this.laneVoicesFor(baseVoice, laneCounts);
				(beat >= from).if {
					out.add((time: place.(beat), label: \plus, send: {
						Server.default.bind {
							laneVoices.do { |voice|
								ev[\defName] !? { |d| voiceDefs[voice] = d };
								voices[voice].isNil.if {
									this.startVoice(voiceDefs[voice] ? defaultDef, voice)
								};
								this.prNdefEnsure(voice, plusEv.keys);
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
					}))
				}
			}
		};

		^out
	}
}

// Sugar: a \keyFrame list whose adds drive this proxy by default —
//   k = Ndef(\verb).asEventList.clear;  k.add(4, mix: T(0.9, 2));  k.add(12, gate: 0);
// Its events are ordinary Ndef-voice keyframes (voice: <proxy key>, ndef: proxy),
// so they can equally be written into any other \keyFrame list by hand.
+ NodeProxy {
	asEventList { |name, voiceSpace|
		var key = (this.tryPerform(\key) ? this.identityHash).asSymbol;
		var list = EventList.kf(name ?? { ("ndef_" ++ key).asSymbol }, voiceSpace);
		list.addFunc = { |e|
			((e[\type] ? \keyFrame) == \keyFrame).if {
				e[\voice] = e[\voice] ? key;
				e[\ndef]  = e[\ndef] ? this
			}
		};
		^list
	}
}

// mod: is the authoring name for VoiceSpace's plus-layers; plus: stays an alias.
+ Event { modEvent { ^this[\mod] ?? { this[\plus] } } }
