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
			envSyns: List[]
		);
		voices[voice].syn.onFree {
			voices[voice] !? { |v|
				v.envSyns.do { |syn| syn.free };
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

	// ---- per-event dispatch (sets busses; spawns ramp synths) --------------

	dispatch { |ev, voice|
		var v = voices[voice];
		v.isNil.if { ^this };
		ev.keys.do { |k|
			var val = ev[k];
			(k != \voice).if {
				v.busses[k] !? { |bus|
					case
						{ val.isNumber }         { bus.set(val) }
						{ val.isKindOf(Tuple3) } { this.go(bus, val.at1, val.at2, val.at3, 0, v.syn) }
						{ val.isKindOf(Tuple4) } { this.go(bus, val.at1, val.at2, val.at3, val.at4, v.syn) }
						{ val.isKindOf(Env) }    { { EnvGen.kr(val, doneAction: 2) => Out.kr(bus.index, _) }.play(target: v.syn, addAction: \addBefore) }
					;
				}
			}
		}
	}

	// ---- live event firing (used by \keyFrame event type) -------------------

	fireLive { |ev|
		this.fanLive(ev).do { |laneEv|
			var voice = laneEv[\voice] ? \default;
			var defName;
			laneEv[\defName] !? { |d| voiceDefs[voice] = d };
			defName = voiceDefs[voice] ? defaultDef;
			Server.default.bind {
				voices[voice].isNil.if { this.startVoice(defName, voice) };
				this.dispatch(laneEv, voice);
			}
		}
	}

	// ---- live fan-out: persistent per-voice lane state ---------------------

	fanLive { |ev|
		var skip = [\when, \voice, \type, \newType, \beat, \delta, \dur, \tempo, \defName, \server, \voiceSpace];
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

	// ---- timeline → Env ----------------------------------------------------

	timelineToEnv { |timeline, initial|
		var levels = [initial];
		var times  = [];
		var curves = [];
		var curBeat = 0, curLevel = initial;
		timeline.do { |pair|
			var beat = pair[0];
			var val  = pair[1];
			var dt   = beat - curBeat;
			(dt > 0).if {
				levels = levels.add(curLevel);
				times  = times.add(dt);
				curves = curves.add(\step);
			};
			case
				{ val.isNumber } {
					levels = levels.add(val);
					times  = times.add(0);
					curves = curves.add(\step);
					curLevel = val;
					curBeat = beat;
				}
				{ val.isKindOf(Tuple3) } {
					var resolved = val.at1.value;
					levels = levels.add(resolved);
					times  = times.add(val.at2);
					curves = curves.add(val.at3);
					curLevel = resolved;
					curBeat = beat + val.at2;
				}
				{ val.isKindOf(Env) } {
					levels = levels.add(val.levels[0]);
					times  = times.add(0);
					curves = curves.add(\step);
					val.times.do { |t, i|
						levels = levels.add(val.levels[i+1]);
						times  = times.add(t);
						curves = curves.add(val.curves.isArray.if { val.curves.wrapAt(i) } { val.curves });
					};
					curLevel = val.levels.last;
					curBeat = beat + val.times.sum;
				};
		};
		while { (times.size > 0) and: { times[0] == 0 } } {
			levels = levels.drop(1);
			times  = times.drop(1);
			curves = curves.drop(1);
		};
		(times.size == 0).if {
			levels = [levels[0], levels[0]];
			times  = [0];
			curves = [\step];
		};
		^Env(levels, times, curves)
	}

	// ---- pre-baked-timeline expansion (playFrom path) ----------------------

	expandLanes { |events|
		var skip = [\when, \voice, \type, \newType, \beat, \delta, \dur, \tempo, \defName];
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
		var skip = [\when, \voice, \type, \newType, \beat, \delta, \dur, \tempo, \defName];
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

	extractTempo { |events|
		var tl = List[];
		events.do { |ev|
			ev[\tempo] !? { |v| tl.add([ev[\when] ? 0, v]) }
		};
		tl.sort({ |a, b| a[0] < b[0] });
		^tl
	}

	beatToWall { |beat, tempoEnv|
		var levels, times, curves;
		var cur = 0, sum = 0, i = 0, done = false;
		tempoEnv.isNil.if { ^beat };
		levels = tempoEnv.levels;
		times  = tempoEnv.times;
		curves = tempoEnv.curves;
		while { (i < times.size) and: { done.not } } {
			var segBeats = times[i];
			var segEnd   = cur + segBeats;
			var cv       = curves.isArray.if { curves.wrapAt(i) } { curves };
			(beat >= segEnd).if {
				(cv == \step).if {
					sum = sum + (levels[i] * segBeats);
				} {
					sum = sum + ((levels[i] + levels[i+1]) / 2 * segBeats);
				};
				cur = segEnd;
				i = i + 1;
			} {
				var partial = beat - cur;
				(cv == \step).if {
					sum = sum + (levels[i] * partial);
				} {
					var endLevel = levels[i] + (partial / segBeats * (levels[i+1] - levels[i]));
					sum = sum + ((levels[i] + endLevel) / 2 * partial);
				};
				done = true;
			};
		};
		(done.not and: { beat > cur }).if { sum = sum + (levels.last * (beat - cur)) };
		^sum
	}

	rescaleEnv { |env, startBeat, tempoEnv|
		var newTimes = [];
		var cur = startBeat;
		env.times.do { |t|
			var next = cur + t;
			var wallDur = this.beatToWall(next, tempoEnv) - this.beatToWall(cur, tempoEnv);
			newTimes = newTimes.add(wallDur);
			cur = next;
		};
		^Env(env.levels, newTimes, env.curves)
	}

	// ---- timeline-driven playback (cancelable via stop) --------------------

	playFrom { |list, from=0|
		var events, keyEvents, otherEvents, tempoTl, tempoEnv, fromWall, expanded, tls, pending;
		from = from ? 0;
		events      = list.scopedEvents.select { |e| list.shouldPlay(e) };
		keyEvents   = events.select { |e| (e[\type] ? \keyFrame) == \keyFrame };
		otherEvents = events.reject { |e| (e[\type] ? \keyFrame) == \keyFrame };
		tempoTl     = this.extractTempo(events);
		tempoEnv    = (tempoTl.size > 0).if { this.timelineToEnv(tempoTl, 1) };
		fromWall    = this.beatToWall(from, tempoEnv);
		expanded    = this.expandLanes(keyEvents);
		tls         = this.extractTimelines(expanded);
		pending     = List[];

		expanded.do { |e|
			(e[\defName].notNil and: { e[\voice].notNil }).if {
				voiceDefs[e[\voice]] = e[\defName]
			}
		};

		otherEvents.do { |ev|
			var beat  = ev[\when] ? 0;
			var delay = this.beatToWall(beat, tempoEnv) - fromWall;
			(delay >= 0).if {
				pending.add([delay, { ev.copy.play }])
			}
		};

		tls.keysValuesDo { |voice, params|
			var firstBeat = params.values.collect({ |tl| tl[0][0] }).minItem;
			var firstWall = this.beatToWall(firstBeat, tempoEnv);
			var delayWall = (firstWall - fromWall).max(0);
			var startBeat = from.max(firstBeat);
			pending.add([delayWall, {
				Server.default.bind {
					var v;
					voices[voice].isNil.if { this.startVoice(voiceDefs[voice] ? defaultDef, voice) };
					v = voices[voice];
					params.keysValuesDo { |param, tl|
						v.busses[param] !? { |bus|
							var env = this.timelineToEnv(tl, v.defaults[param]);
							var total = env.times.sum;
							bus.set(env.at(startBeat));
							(startBeat < total).if {
								var trimmed = (startBeat > 0).if { env.segment(startBeat, total) } { env };
								var rescaled = this.rescaleEnv(trimmed, startBeat, tempoEnv);
								v.envSyns.add(
									{ EnvGen.kr(rescaled, doneAction: 0) => ReplaceOut.kr(bus.index, _) }
										.play(target: v.syn, addAction: \addBefore)
								);
							}
						}
					};
				}
			}])
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
