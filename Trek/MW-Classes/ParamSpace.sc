// ParamSpace: a collection of named control busses keyed off a SynthDef's controls.
// Each bus is allocated with the SynthDef's default value for that control. MicroKeys
// per-note synths get the busses bus-mapped via .asMap (so envelopes written to a bus
// modulate every voice), while \paramSet events route keys → bus writes with the same
// value semantics as VoiceSpace.dispatch (number/Env/Tuple3/Tuple4).

ParamSpace {
	classvar <>defaultSkipKeys;
	var <busses, <defaults, <defName;
	// key -> the ramp synth currently writing that bus. Out.kr writes in the same
	// block SUM, so a second ramp on a key must replace the first, not join it.
	var rampSyns;

	*initClass {
		defaultSkipKeys = [\out, \in, \freq, \amp, \num, \gate, \poly, \bend, \pressure, \vel];
		Class.initClassTree(Event);
		Event.addEventType(\paramSet, {
			var ps = ~paramSpace ?? { Error("\\paramSet event requires ~paramSpace").throw };
			ps.dispatch(currentEnvironment)
		});
	}

	*new { |defName, skipKeys|
		^super.new.init(defName, skipKeys ? defaultSkipKeys)
	}

	init { |aDefName, skipKeys|
		var desc = SynthDescLib.global[aDefName];
		desc.isNil.if { Error("ParamSpace: no SynthDesc for %".format(aDefName)).throw };
		defName = aDefName;
		busses = ();
		defaults = ();
		rampSyns = ();
		desc.controls.do { |ctl|
			var n = ctl.name.asSymbol;
			skipKeys.includes(n).not.if {
				var nc = ctl.defaultValue.asArray.size.max(1);
				var bus = Bus.control(Server.default, nc);
				bus.set(ctl.defaultValue);
				busses[n] = bus;
				defaults[n] = ctl.defaultValue
			}
		}
	}

	bus { |key| ^busses[key] }

	// Event of (key: bus.asMap) — splice into a note's params: to bus-map per-note
	// synth controls onto these shared busses.
	asEvent {
		var e = ();
		busses.keysValuesDo { |k, b| e[k] = b.asMap };
		^e
	}

	dispatch { |ev|
		ev.keysValuesDo { |k, val|
			val = val.asRamp;
			busses[k] !? { |bus|
				case
					{ val.isNumber }         { this.freeRamp(k); bus.set(val) }
					{ val.isKindOf(Tuple3) } { this.prRamp(k, { this.go(bus, val.at1, val.at2, val.at3) }) }
					{ val.isKindOf(Tuple4) } { this.prRamp(k, { this.go(bus, val.at1, val.at2, val.at3, val.at4) }) }
					{ val.isKindOf(Env) } {
						this.prRamp(k, { { EnvGen.kr(val, doneAction: 2) => Out.kr(bus.index, _) }
							.play(target: Server.default.defaultGroup, addAction: \addToHead) })
					}
			}
		}
	}

	go { |bus, dest, time=1, curve=\lin, lag=0|
		^{
			Env([In.kr(bus.index, bus.numChannels) => Latch.kr(_, 1), dest], time, curve)
				.kr(2, gate: 1).lag2(lag)
			=> Out.kr(bus.index, _)
		}.play(target: Server.default.defaultGroup, addAction: \addToHead)
	}

	// Stop whatever ramp is writing `key`'s bus; the bus keeps the value it reached.
	freeRamp { |key|
		rampSyns[key] !? { |syn| syn.free };
		rampSyns[key] = nil;
	}

	/* `start` builds the new ramp synth; it runs only after the old ramp is freed, so
	   the free reaches the server first. go latches the bus as its start value, which
	   still holds what the old ramp last wrote, so the handover is continuous. onFree
	   clears the entry when a ramp ends on its own, only if it is still the current one. */
	prRamp { |key, start|
		var syn;
		this.freeRamp(key);
		syn = start.value;
		rampSyns[key] = syn;
		syn.onFree { (rampSyns[key] === syn).if { rampSyns[key] = nil } };
		^syn
	}

	resetToDefaults {
		rampSyns.keys.copy.do { |k| this.freeRamp(k) };
		defaults.keysValuesDo { |k, v| busses[k].set(v) }
	}

	free {
		rampSyns.keys.copy.do { |k| this.freeRamp(k) };
		busses.do(_.free);
		busses = ();
		defaults = ();
	}
}

+ EventList {
	paramSpace_ { |ps|
		ps.busses.keysDo { |k| this.addRoute(k, \paramSet) };
		this.addFunc_({ |e, list| e[\paramSpace] = ps });
		env[\paramSpace] = ps;
		^this
	}
	paramSpace { ^env[\paramSpace] }
}

+ AbstractMidiEvents {
	// Build an EventList from this MIDI item.
	//   mkOrDefName — a MicroKeys instance, or a Symbol naming a SynthDef. If a
	//     Symbol is passed, both a MicroKeys and a ParamSpace are auto-created
	//     from that SynthDef. Pass nil to skip both (events have no \mk and no
	//     bus-mapped params).
	//   paramSpace — optional override; if given, used instead of the auto-built
	//     one (or with a MicroKeys-typed mkOrDefName).
	asEventList { |name mkOrDefName paramSpace|
		var el = EventList(name);
		var mk, psEvent, tm, player, srcName;
		case
			{ mkOrDefName.isKindOf(MicroKeys) } {
				mk = mkOrDefName;
				paramSpace = paramSpace ?? {
					mk.defName !? { |dn|
						SynthDescLib.global[dn].notNil.if { ParamSpace(dn) }
					}
				}
			}
			{ mkOrDefName.isKindOf(Symbol) } {
				mk = MicroKeys(mkOrDefName, mkOrDefName);
				paramSpace = paramSpace ?? {
					SynthDescLib.global[mkOrDefName].notNil.if { ParamSpace(mkOrDefName) }
				}
		};
		psEvent = paramSpace !? { paramSpace.asEvent };
		tm = { this.tempomap }.try;
		el.beatDur = 1;
		tm !? { el.tempoMap = tm };
		paramSpace !? { el.paramSpace_(paramSpace) };
		player = this.player;
		// tag with the source MIDIItem's name so EventList solo_/mute_ can
		// isolate these events from ones added to the list later
		srcName = player.source.tryPerform(\name) !? { |n| n.asString.asSymbol };
		player.midiEvents.do { |e|
			var when = tm.notNil.if(
				{ tm.prAtExtrapolated(e.timestamp - tm.t0, tm.env) },
				{ e.timestamp - (player.start ? 0) }
			);
			var copy;
			/*
			 MIDIItem.record writes the take's setup (\setPoly, the recorded initial
			 CC values, the leading \rest) at timestamp 0, but t0 is the first
			 SELECTED note — so on a selection those land at a NEGATIVE beat and any
			 prepare from beat 0 trims them: nested \eventList inserts (addItem's
			 align: mode) lost setPoly and the recorded CC state while the flattening
			 path, which never rebases, kept them. They set state rather than sounding
			 at a time, so clamp them to the child's start; every other `when` is
			 untouched.
			*/
			(e[\initialEvent] == true or: { e[\type] == \rest }).if { when = when.max(0) };
			copy = e.copy.put(\when, when);
			srcName !? { copy[\name] = copy[\name] ? srcName };
			copy.put(\latency, Server.default.latency);
			mk !? { copy.put(\mk, mk.name ? mk) };
			(copy[\type] == \mk and: { psEvent.notNil }).if {
				copy.put(\params, psEvent ++ (copy[\params] ? ()))
			};
			el.events.add(copy)
		};
		^el
	}
}

/* T(dest, time) is a Tuple2 (FPLib), which every ramp reader here used to ignore
   silently — only Tuple3/Tuple4 ramped. asRamp normalises: a Tuple2 is a linear
   Tuple3, anything else passes through. Read by VoiceSpace.dispatch,
   EventList.timelineToEnv and ParamSpace.dispatch. */
+ Object { asRamp { ^this } }
+ Tuple2 { asRamp { ^T(this.at1, this.at2, \lin) } }
