// Pattern ingestion is kept out of EventList.sc: none of these methods touches
// EventList's instance variables directly, so a class extension is a clean seam.
+ EventList {
	/*
	 Drain a pattern into stored events, walking `beat` forward by each event's
	 \dur. Three independent stops: maxEvents (nil = uncapped), maxWhen as a beat
	 ceiling, and the stream itself running out — so an endless pattern with no
	 maxEvents still terminates at maxWhen. The count is checked before pulling,
	 so maxEvents: 8 stores exactly 8.
	*/
	addPattern { |when=0, pattern, maxEvents, maxWhen=300, eventName|
		var stream, beat = when, i = 0;
		// Pmono's stream needs the preceding event to PLAY before it can produce a
		// monoSet: monoNote's updatePmono callback supplies the server node ID.
		// addPattern drains first and plays later, so an unadapted Pmono yields only
		// monoNotes. Compile its value pairs into replay-safe mono score events instead.
		pattern.isKindOf(Pmono).if {
			^this.prAddMonoPattern(when, pattern, maxEvents, maxWhen, eventName)
		};
		stream = pattern.asStream;
		block { |break|
			loop {
				var event, previewOffset;
				(maxEvents.notNil and: { i >= maxEvents }).if { break.value };
				(beat > maxWhen).if { break.value };
				event = stream.next(());
				event.isNil.if { break.value };
				event.put(\when, beat);
				eventName !? { event.put(\name, eventName) };
				previewOffset = this.nextPreviewOffset(beat);
				// via dispatch, so pattern events get routes/addFunc/type stamping too.
				// A \type the pattern set is promoted to \newType, else dispatch's
				// fallback stamp overwrites it with defaultType.
				(event[\type].notNil and: { event[\newType].isNil }).if {
					event.put(\newType, event[\type])
				};
				this.dispatch(event, { |e| this.storeAndPreview(e, previewOffset) });
				beat = beat + (event[\dur] ? 1);
				i = i + 1;
			}
		};
		^this
	}

	/*
	 Compile a direct Pmono/PmonoArtic without consuming its stateful stream. The
	 ordinary Pbind supplies the same values; lightweight metadata groups those
	 values into mono runs. Node IDs are deliberately NOT allocated here: prepare
	 creates fresh playback-local state, so a stored list can be replayed safely.

	 EventList's established pattern contract advances by \dur (not Event:delta).
	 PmonoArtic's sustain is therefore normalized from its native delta interval
	 into that same beat interval before recording a release offset.
	*/
	prAddMonoPattern { |when=0, pattern, maxEvents, maxWhen=300, eventName|
		var source = Pbind(*(
			pattern.patternpairs ++ [\instrument, pattern.synthName]
		));
		var stream = source.asStream;
		var artic = pattern.isKindOf(PmonoArtic);
		var compiled = List[];
		var runEvents = List[];
		var run = Ref(nil);
		var beat = when;
		var i = 0;
		var closeRun;

		closeRun = { |offBeat|
			runEvents.do { |event|
				// Relative to each event so copyVoice(offset:) moves the release too.
				event[\eventListMonoRelease] = offBeat - (event[\when] ? 0)
			};
			runEvents = List[];
		};

		block { |break|
			loop {
				var event, step;
				(maxEvents.notNil and: { i >= maxEvents }).if { break.value };
				(beat > maxWhen).if { break.value };
				// PmonoArtic reads inherited \sustain/\legato/\stretch while its
				// stream is running; use the same default prototype as a player.
				event = stream.next(Event.default);
				event.isNil.if { break.value };
				step = event[\dur] ? 1;
				event[\when] = beat;
				event[\eventListMonoRun] = run;
				runEvents.add(event);
				compiled.add(event);

				artic.if {
					var delta = event.delta;
					var sustain = event.use { ~sustain.value };
					(sustain.notNil and: { sustain < delta }).if {
						var release = (delta == 0).if { 0 } { sustain * step / delta };
						closeRun.(beat + release);
						run = Ref(nil);
					}
				};
				beat = beat + step;
				i = i + 1;
			}
		};
		// Pmono holds through the final delta; PmonoArtic does too unless its last
		// event already scheduled an early release.
		runEvents.notEmpty.if { closeRun.(beat) };

		compiled.do { |event|
			var previewOffset;
			eventName !? { event[\name] = eventName };
			(event[\type].notNil and: { event[\newType].isNil }).if {
				event[\newType] = event[\type]
			};
			previewOffset = this.nextPreviewOffset(event[\when] ? 0);
			this.dispatch(event, { |e| this.storeAndPreview(e, previewOffset) });
		};
		^this
	}

	/*
	 addPattern with this list's clock injected into the pattern's OWN value
	 expressions — the one thing the stamping routes cannot do, because addFunc runs
	 after `stream.next` has already computed every key.

	 Read the clock with Pfunc, not a bare Function: miSCellaneous's `.pa` wraps a
	 Function value in Pfunc and evaluates it at drain time, before any of this
	 exists, so `{ ~secPerBeat }` inside `[...].p` silently yields nil — and a nil
	 from any key ends the Pbind, so the pattern stores NOTHING.

		 e.addClockPattern(0, Pseq([2], 5), [
		     instrument: \harp,
		     delayTime: Pfunc { |ev| ev[\secsFor].(0.5) }
		 ].p);

	 `dur` drives both the beat walk and the emitted \dur. The supplier runs FIRST
	 (Pchain feeds right-to-left) and accumulates the beat itself, while `pattern`
	 runs last and wins key collisions — so `pattern` must not set \dur, or its walk
	 and addPattern's `beat + (event[\dur] ? 1)` diverge.
	*/
	addClockPattern { |when = 0, dur, pattern, maxEvents, maxWhen = 300, eventName|
		^this.addPattern(when, pattern <> this.clockPattern(when, dur),
			maxEvents, maxWhen, eventName)
	}

	/*
	 The clock supplier alone, for hand-built chains. Each event carries \beat, its
	 \secPerBeat, and a \secsFor answering the seconds spanned by n beats FROM THAT
	 EVENT — integrated through the tempo env, so under a ramp it is not
	 secPerBeat * n. Both \secsFor forms of prTempoContext work: ev[\secsFor].(n)
	 and ev.secsFor(n), the latter arriving with the environment prepended.

	 The per-event event is built by CALLING `mk`: a function call is the one thing
	 that guarantees a fresh frame, so each closure keeps the beat it was made with
	 rather than the loop variable's final value.

	 tempoEnv is read inside the Prout, so a map edited between building this
	 pattern and draining it still applies.
	*/
	clockPattern { |startBeat = 0, dur|
		^Prout({ |inev|
			var env  = this.tempoEnv;
			var beat = startBeat;
			var ds   = dur.asStream;
			var d;
			var mk = { |b, dd|
				var wall = this.beatToWall(b, env);
				(
					dur: dd,
					beat: b,
					secPerBeat: this.beatToWall(b + 1, env) - wall,
					secsFor: { |a, c|
						var n = a.isKindOf(Environment).if { c ? 1 } { a ? 1 };
						this.beatToWall(b + n, env) - wall
					}
				)
			};
			while { (d = ds.next(inev)).notNil } {
				inev = ((inev ? ()) ++ mk.(beat, d)).yield;
				beat = beat + d;
			}
		})
	}

	// Remove EventList's private mono-score keys before asking the normal Event
	// machinery to build synth-control messages.
	prMonoEvent { |ev|
		var out = ev.copy;
		out.removeAt(\eventListMonoRun);
		out.removeAt(\eventListMonoRelease);
		^out
	}

	// Playback-local state shared by the \on, \set and \off entries of one run.
	// `off` is idempotent, which makes natural end, a `to:` cutoff, replay and stop
	// safe to converge on the same cleanup action.
	prNewMonoState {
		var state = IdentityDictionary.new;
		state[\off] = {
			var offEvent = state[\offEvent];
			state[\offEvent] = nil;
			state[\id] = nil;
			state[\active] = false;
			offEvent !? { offEvent.play };
		};
		^state
	}

	// Turn one compiled mono value into schedule entries. The first sounding event
	// surviving `from` is always \on; later values are \set. Thus a mid-run start
	// creates a new synth with the correct current controls rather than addressing a
	// node that belonged to an earlier playback.
	prEmitMono { |ev, place, from = 0, states|
		var out = List[];
		var when = ev[\when] ? 0;
		var token = ev[\eventListMonoRun];
		var state, first, offWhen;
		(when < from).if { ^out };
		states = states ?? { IdentityDictionary.new };
		state = states[token];
		state.isNil.if {
			state = this.prNewMonoState;
			states[token] = state;
		};

		ev.isRest.not.if {
			first = state[\planned] != true;
			state[\planned] = true;
			out.add((
				time: place.(when),
				label: first.if({ \monoOn }, { \monoSet }),
				monoState: state,
				send: {
					var event = this.prMonoEvent(ev);
					first.if {
						var capture, original;
						event[\type] = \on;
						capture = { |played|
							state[\id] = played[\id];
							state[\server] = played[\server];
							state[\active] = true;
							// Match PmonoStream's minimal cleanup event. In particular,
							// keep the event's scheduling functions and detected gate flag.
							state[\offEvent] = (
								type: \off,
								id: played[\id],
								server: played[\server],
								hasGate: played[\hasGate],
								hasGates: played[\hasGates],
								schedBundleArray: played[\schedBundleArray],
								schedBundle: played[\schedBundle]
							)
						};
						original = event[\callback];
						event[\callback] = original.isNil.if {
							capture
						} {
							capture.addFunc(original)
						}
					} {
						event[\type] = \set;
						event[\id] = state[\id];
						state[\server] !? { |server| event[\server] = server };
						// An inherited default args list updates only freq/amp/pan/trig;
						// [] tells \set to derive every control from the SynthDesc,
						// matching Pmono's msgFunc behavior.
						event.includesKey(\args).not.if { event[\args] = [] }
					};
					event.play
				}
			))
		};

		offWhen = ev[\eventListMonoRelease] !? { |d| when + d };
		(offWhen.notNil and: { state[\offPlanned] != true }).if {
			state[\offPlanned] = true;
			out.add((time: place.(offWhen), send: state[\off], label: \monoOff,
				monoState: state))
		};
		^out
	}
}
