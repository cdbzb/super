EventList {
	classvar <all, <>current, <>playFn, <>cursor;
	var <events, <preview, <>defaultType, <routes, <>addFunc, <>previewPrep;
	var <>env, <>context;
	var <>autoExpand = false;
	var <>batchWindow = 0.05, batchEndTime = -1e9, batchFirstWhen = 0;
	var <>scope, <>voiceSpace;
	var <solo, <mute;
	var <>beatDur, <>tempoMap;
	// Memoized beat->wall integral (see beatToWall): cumulative wall-seconds at each
	// tempoEnv segment boundary, built once per tempoEnv so completed segments aren't
	// re-integrated for every event. Keyed on tempoEnv identity.
	var prWallEnv, prWallStarts, prWallCum, prWallLevels, prWallTimes, prWallCurves;

	*initClass {
		all = ();
		Class.initClassTree(Event);
        Event.addEventType(\eventList, {~eventList.isKindOf(EventList).if{~eventList}{EventList(~eventList)}.play(~start ? 0)});
	}

	*new { |name, defaultType|
		var instance;
		name.notNil.if {
			all[name].notNil.if {
				current = all[name];
				defaultType !? { current.defaultType_(defaultType) };
				^current
			}
		};
		instance = super.new.init(defaultType);
		name !? {
			all[name] = instance;
			current = instance;
			instance.scope = name;
		};
		^instance
	}

	*at { |name| ^all[name] }

	*kf { |name, voiceSpace|
		^this.new(name, \keyFrame).voiceSpace_(voiceSpace ? VoiceSpace.default)
	}

	*newFrom { |other, name, newVoiceSpace=false|
		var src = other.isKindOf(Symbol).if { all[other] } { other };
		var instance;
		src.isNil.if { Error("EventList.newFrom: no list named %".format(other)).throw };
		instance = this.new(name, src.defaultType);
		^instance.copyFrom(src, newVoiceSpace)
	}

	copy { |newVoiceSpace=false|
		var instance = this.class.new(nil, defaultType);
		^instance.copyFrom(this, newVoiceSpace)
	}

	copyFrom { |other, newVoiceSpace=false|
		events      = other.events.copy;
		context     = other.context.copy;
		routes      = other.routes.copy;
		env         = other.env.copy;
		addFunc     = other.addFunc;
		previewPrep = other.previewPrep;
		autoExpand  = other.autoExpand;
		batchWindow = other.batchWindow;
		voiceSpace  = newVoiceSpace.if { VoiceSpace.new } { other.voiceSpace };
		^this
	}

	// class-level forwarding for common methods
	*add { |...args, kwargs|
		var when = args[0];
		args[1].isKindOf(Pattern).if { ^current.addPattern(when ? 0, args[1]) };
		when.isKindOf(Array).if {
			var whens = when;
			var n = whens.size;
			var base = (when: whens) ++ kwargs.asEvent;
			var previewAts = current.previewAtFor(whens);
			^n.collect { |i|
				var ev = current.sliceAxis(base, i, n);
				current.dispatch(ev, { |e| current.gateWithPreviewAt(e, previewAts[i]) });
				ev
			}
		};
		when.isKindOf(Event).if { ^current.add(when) };
		^current.add((when: when ? 0) ++ kwargs.asEvent)
	}
	*addContext { |...args, kwargs|
		var event;
		args[0].isKindOf(Event).if {
			event = args[0]
		} {
			event = (when: args[0] ? 0) ++ kwargs.asEvent
		};
		^current.addContext(event)
	}
	*play { |from, fromEvent, fromSection|
		^current.play(cursor.debug("CURSOR") ? from ? 0 => _.postln, fromEvent, fromSection)
	}
	*clear { ^current.clear }
	*clearContext { ^current.clearContext }
	*setupContext { ^current.setupContext }
	*size { ^current.size }
	*do { |func| ^current.do(func) }
	*addRoute { |key, type| ^current.addRoute(key, type) }
	*preview_ { |val| ^current.preview_(val) }
	*preview { ^current.preview }
	*addFunc_ { |val| ^current.addFunc_(val) }
	*env { ^current.env }
	*context { ^current.context }
	*context_ { |list| ^current.context_(list) }
	*previewPrep { ^current.previewPrep }
	*previewPrep_ { |val| ^current.previewPrep_(val) }
	*voices { ^current.voices }
	*scopedEvents { ^current.scopedEvents }

	init { |defType|
		events = List[];
		context = List[];
		defaultType = defType;
		routes = ();
		env = ();
	}

	addRoute { |key, type|
		routes[key] = type;
	}

	scopedVoice { |v|
		(scope.notNil and: { v.notNil }).if {
			^(scope.asString ++ "_" ++ v.asString).asSymbol
		};
		^v
	}

	projectEvent { |ev|
		var proj = ev;
		scope.notNil.if {
			proj = ev.copy.put(\voice, this.scopedVoice(ev[\voice] ? \default))
		};
		voiceSpace.notNil.if {
			(proj === ev).if { proj = ev.copy };
			proj.proto = (voiceSpace: voiceSpace)
		};
		^proj
	}

	scopedEvents { ^events.collect { |e| this.projectEvent(e) } }

	voices {
		var seen = Set[];
		events.do { |e|
			e[\voice] !? { |v| seen.add(this.scopedVoice(v)) }
		};
		^seen.asArray
	}

	add { |...args, kwargs|
		var event, previewAt, when = args[0];
		args[1].isKindOf(Pattern).if { ^this.addPattern(when ? 0, args[1]) };
		when.isKindOf(Array).if {
			var whens = when;
			var n = whens.size;
			var base = (when: whens) ++ kwargs.asEvent;
			var previewAts = this.previewAtFor(whens);
			^n.collect { |i|
				var ev = this.sliceAxis(base, i, n);
				this.dispatch(ev, { |e| this.gateWithPreviewAt(e, previewAts[i]) });
				ev
			}
		};
		when.isKindOf(Event).if {
			event = when
		} {
			event = kwargs.asEvent;
			when.notNil.if { event[\when] = when }
		};
		event[\voice].isKindOf(Array).if {
			^this.expandAxis(event[\voice].size, event)
		};
		previewAt = this.previewAtFor(event[\when] ? 0);
		this.dispatch(event, { |e| this.gateWithPreviewAt(e, previewAt) });
		^event
	}

	previewAtFor { |when|
		var now = SystemClock.seconds;
		var ref = when.isKindOf(Array).if { when[0] } { when };
		(now >= batchEndTime).if { batchFirstWhen = ref };
		batchEndTime = now + batchWindow;
		^when.isKindOf(Array).if {
			when.collect { |w| w - batchFirstWhen }
		} {
			when - batchFirstWhen
		}
	}

	expandAxis { |n, base|
		^n.collect { |i| this.add(this.sliceAxis(base, i, n)) }
	}

	sliceAxis { |base, i, n|
		var scratch = ();
		var hasFunc = false;
		var out = ();
		base.keysValuesDo { |k, v|
			case
				{ v.isKindOf(Env) or: { v.isKindOf(Tuple3) } or: { v.isKindOf(Tuple4) } }
					{ scratch[k] = v }
				{ v.isKindOf(Function) and: { v.numArgs == 0 } }
					{ scratch[k] = v; hasFunc = true }
				{ v.isArray }
					{ scratch[k] = v.clipAt(i) }
				{ scratch[k] = v }
		};
		hasFunc.not.if { ^scratch };
		scratch[\x] = i;
		scratch[\n] = n;
		scratch[\whens] = base[\when].asArray;
		{
			var le = LambdaEnvir(scratch);
			le.use { scratch.keysDo { |k| out[k] = le.at(k) } };
		}.value;
		[\x, \n, \whens].do { |k| out.removeAt(k) };
		^out
	}

	addContext { |...args, kwargs|
		var event;
		args[0].isKindOf(Event).if {
			event = args[0]
		} {
			event = (when: args[0] ? 0) ++ kwargs.asEvent
		};
		this.dispatch(event, { |e| context.add(e) });
		^event
	}

	dispatch { |event, sink|
		routes.keysValuesDo { |key, type|
			event[key].notNil.if {
				event.put(\type, type);
				addFunc !? { addFunc.(event, this) };
				sink.(event);
				^this
			}
		};
		autoExpand.if {
			event.select { |v, k| routes[k].isNil }.values
				.any { |i| i.rank > 0 }.if {
				event.asPairs.flop.collect { |i| i.asEvent }
					.do { |e| this.dispatch(e, sink) };
				^this
			};
		};
		event.put(\type, event[\newType] ? defaultType);
		addFunc !? { addFunc.(event, this) };
		sink.(event);
		^this
	}

	gate { |event|
		this.gateWithPreviewAt(event, 0)
	}

	addPattern { |when=0, pattern, n, maxWhen=300, name|
		var stream = pattern.asStream;
		var t = when;
		var i = 0;
		block { |break|
			loop {
				var event, previewAt;
				(n.notNil and: { i >= n }).if { break.value };
				(t > maxWhen).if { break.value };
				event = stream.next(());
				event.isNil.if { break.value };
				event.put(\when, t);
				name !? { event.put(\name, name) };
				previewAt = this.previewAtFor(t);
				this.gateWithPreviewAt(event, previewAt);
				t = t + (event[\dur] ? 1);
				i = i + 1;
			}
		};
		^this
	}

	solo_ { |val| solo = val.notNil.if { val.asArray.as(Set) } }
	mute_ { |val| mute = val.notNil.if { val.asArray.as(Set) } }

	shouldPlay { |event|
		var name = event[\name];
		solo.notNil.if {
			name.isNil.if { ^false };
			^solo.any { |s| name.asString.contains(s.asString) }
		};
		(mute.notNil and: { name.notNil }).if {
			^mute.any { |s| name.asString.contains(s.asString) }.not
		};
		^true
	}

	gateWithPreviewAt { |event, previewAt|
		events.add(event);
		(preview.notNil and: { this.shouldPlay(event) }).if {
			var projected = this.projectEvent(event);
			var bd = beatDur ? TempoClock.default.beatDur;
			previewPrep !? { previewPrep.(projected, this) };
			(projected[\type] == \audioItemTempoFollow).if {
				var tempoEnv = this.tempoEnv(this.scopedEvents);
				var actions = (projected[\tempoFollowMode] == \env).if {
					AudioItem.tempoFollowEnvActions(projected, this, tempoEnv, batchFirstWhen)
				} {
					AudioItem.tempoFollowActions(projected, this, tempoEnv, batchFirstWhen)
				};
				actions.do { |pair|
					SystemClock.sched(pair[0], { pair[1].value; nil })
				}
			} {
				SystemClock.sched(
					previewAt * bd,
					{ projected.play; nil }
				)
			}
		}
	}

	preview_ { |val|
		var wasOff = preview.isNil;
		preview = val;
		(wasOff and: { val.notNil }).if { this.setupContext }
	}

	setupContext {
		context.do { |e| this.projectEvent(e).copy.put(\when, 0).play }
	}

	// evts defaults to this list's own events; VoiceSpace passes its filtered
	// (scoped + shouldPlay) set so the tempo derivation matches what it plays.
	extractTempo { |evts|
		var tl = List[];
		(evts ? events).do { |ev|
			ev[\tempoTrack] !? { |v| tl.add([ev[\when] ? 0, v]) }
		};
		tl.sort({ |a, b| a[0] < b[0] });
		^tl
	}

	timelineToEnv { |timeline, initial|
		var levels = [initial];
		var times = [];
		var curves = [];
		var curBeat = 0, curLevel = initial;
		timeline.do { |pair|
			var beat = pair[0];
			var val = pair[1];
			var dt = beat - curBeat;
			(dt > 0).if {
				levels = levels.add(curLevel);
				times = times.add(dt);
				curves = curves.add(\step);
			};
			case
				{ val.isNumber } {
					levels = levels.add(val);
					times = times.add(0);
					curves = curves.add(\step);
					curLevel = val;
					curBeat = beat;
				}
				{ val.isKindOf(Tuple3) } {
					var resolved = val.at1.value;
					levels = levels.add(resolved);
					times = times.add(val.at2);
					curves = curves.add(val.at3);
					curLevel = resolved;
					curBeat = beat + val.at2;
				}
				{ val.isKindOf(Env) } {
					levels = levels.add(val.levels[0]);
					times = times.add(0);
					curves = curves.add(\step);
					val.times.do { |t, i|
						levels = levels.add(val.levels[i+1]);
						times = times.add(t);
						curves = curves.add(val.curves.isArray.if { val.curves.wrapAt(i) } { val.curves });
					};
					curLevel = val.levels.last;
					curBeat = beat + val.times.sum;
				};
		};
		while { (times.size > 0) and: { times[0] == 0 } } {
			levels = levels.drop(1);
			times = times.drop(1);
			curves = curves.drop(1);
		};
		(times.size == 0).if {
			levels = [levels[0], levels[0]];
			times = [0];
			curves = [\step];
		};
		^Env(levels, times, curves)
	}

	// \tempoTrack values are dimensionless tempo MULTIPLIERS (identity = 1) on the
	// base tempo, NOT absolute beatDurs — so a recorded tempoMap and a \tempoTrack
	// automation compose. Identity is 1 (regions with no \tempoTrack keep the base
	// tempo). For a list with no tempoMap and beatDur 1 (the ParamSpace path), a
	// multiplier equals the old absolute sec/beat numerically.
	tempoEnv { |evts|
		var tl = this.extractTempo(evts);
		^(tl.size > 0).if { this.timelineToEnv(tl, 1) }
	}

	// Base wall-seconds elapsed across the beat interval [a, b], BEFORE any
	// \tempoTrack multiplier: the recorded tempoMap's delta if present, else flat
	// beatDur. t0 cancels in the delta, so this is offset-free (and the play-time
	// secondsAt(t) - secondsAt(from) subtraction stays identical to the old map).
	baseWallDelta { |a, b|
		tempoMap.notNil.if { ^tempoMap.timeAt(b) - tempoMap.timeAt(a) };
		^(b - a) * (beatDur ? TempoClock.default.beatDur)
	}

	// Pointwise compose of the \tempoTrack multiplier with the base tempo:
	//   wall(beat) = INTEGRAL over [0, beat] of baseSecPerBeat(x) * m(x) dx.
	// A flat multiplier of 1 reproduces the base map exactly; 2 plays it twice as
	// slow while preserving the base map's accel/rit SHAPE.
	// One-time integral of the tempoEnv: cumulative wall-seconds at every segment
	// boundary. Each segment's contribution (the exact trapezoid for a flat base, or
	// the sub-sampled ramp for a tempoMap base) is computed ONCE here instead of being
	// re-derived from beat 0 on every beatToWall call. O(segments) build; beatToWall is
	// then O(1) + one partial segment per event.
	prBuildWallCache { |tempoEnv|
		var levels = tempoEnv.levels, times = tempoEnv.times, curves = tempoEnv.curves;
		var cur = 0, sum = 0;
		var starts = [0], cum = [0];
		times.size.do { |i|
			var cv = curves.isArray.if { curves.wrapAt(i) } { curves };
			var segEnd = cur + times[i];
			sum = sum + (cv == \step).if {
				levels[i] * this.baseWallDelta(cur, segEnd)
			} {
				this.prIntegrateRamp(levels[i], levels[i+1], cur, times[i], cur, segEnd)
			};
			cur = segEnd;
			starts = starts.add(cur);
			cum = cum.add(sum);
		};
		prWallEnv = tempoEnv;
		prWallStarts = starts; prWallCum = cum;
		prWallLevels = levels; prWallTimes = times; prWallCurves = curves;
	}

	beatToWall { |beat, tempoEnv|
		var seg, segStart, cv;
		tempoEnv.isNil.if { ^this.baseWallDelta(0, beat) };
		(prWallEnv !== tempoEnv).if { this.prBuildWallCache(tempoEnv) };
		(beat <= 0).if { ^0 };
		// Segment whose half-open span contains beat (or the flat tail past the last one).
		seg = prWallTimes.size;
		block { |break|
			prWallTimes.size.do { |k|
				(beat <= prWallStarts[k + 1]).if { seg = k; break.value };
			};
		};
		(seg < prWallTimes.size).if {
			segStart = prWallStarts[seg];
			cv = prWallCurves.isArray.if { prWallCurves.wrapAt(seg) } { prWallCurves };
			^prWallCum[seg] + (cv == \step).if {
				prWallLevels[seg] * this.baseWallDelta(segStart, beat)
			} {
				this.prIntegrateRamp(
					prWallLevels[seg], prWallLevels[seg + 1],
					segStart, prWallTimes[seg], segStart, beat)
			};
		};
		// Past the final boundary: flat extrapolation at the last multiplier.
		^prWallCum.last + (prWallLevels.last * this.baseWallDelta(prWallStarts.last, beat))
	}

	// INTEGRAL over [a, b] of m(x) * baseSecPerBeat(x) dx, where m ramps linearly
	// from mA (at segStart) to mB (at segStart + segLen). With a flat base this is
	// the exact trapezoid in m; a nonlinear tempoMap base is sub-sampled (~16
	// steps/beat, m read at segment midpoints) since m * nonlinear-base has no
	// closed form.
	prIntegrateRamp { |mA, mB, segStart, segLen, a, b|
		var k, x0, sum = 0;
		var mAt = { |x| mA + ((mB - mA) * (x - segStart) / segLen) };
		tempoMap.isNil.if {
			^(mAt.(a) + mAt.(b)) / 2 * this.baseWallDelta(a, b)
		};
		k = (16 * (b - a)).ceil max: 1;
		x0 = a;
		k.do { |j|
			var x1 = a + ((b - a) * (j + 1) / k);
			sum = sum + (mAt.((x0 + x1) / 2) * this.baseWallDelta(x0, x1));
			x0 = x1;
		};
		^sum
	}

	play { |from=0, fromEvent, fromSection|
		var tempoEnv, secondsAt;
		from = from ? 0;
		fromEvent !? {
			var ev = events[fromEvent];
			ev.notNil.if { from = (ev[\when] ? 0) + from }
		};
		fromSection !? {
			(defaultType == \seg).if {
				var hit = events.detect { |e| e[\section] == fromSection };
				hit.notNil.if { from = (hit[\when] ? 0) + from }
			} {
				"EventList.play: fromSection ignored — defaultType is %".format(defaultType).warn
			}
		};
		voiceSpace.notNil.if { ^voiceSpace.playFrom(this, from) };
		playFn.notNil.if { ^playFn.(this, from) };
		tempoEnv = this.tempoEnv;
		secondsAt = { |beat| this.beatToWall(beat, tempoEnv) };
		this.scopedEvents.do { |e|
			var t = e.when ? 0;
			(this.shouldPlay(e) and: { e[\tempoTrack].isNil }).if {
				(e[\type] == \audioItemTempoFollow).if {
					var actions = (e[\tempoFollowMode] == \env).if {
						AudioItem.tempoFollowEnvActions(e, this, tempoEnv, from)
					} {
						AudioItem.tempoFollowActions(e, this, tempoEnv, from)
					};
					actions.do { |pair|
						SystemClock.sched(pair[0], { pair[1].value; nil })
					}
				} {
					(t >= from).if {
						SystemClock.sched(secondsAt.(t) - secondsAt.(from), { e.play; nil })
					}
				}
			}
		}
	}

	clear {
		events = List[];
		preview = nil;
	}

	clearContext { context = List[] }

	size { ^events.size }

	do { |func| events.do(func) }

	at { |index| ^events[index] }
}

// Sugar: \bass.add(0, freq: 999, ...) → EventList.current.add tagged with name: \bass.
// Mirrors EventList *add's three branches (scalar/Array/Event when) since SC has no
// way to splat kwargs through to another method.
+ Symbol {
	add { |...args, kwargs|
		var when = args[0];
		var list = EventList.current;
		args[1].isKindOf(Pattern).if { ^list.addPattern(when ? 0, args[1], name: this) };
		kwargs = kwargs ++ [\name, this];
		when.isKindOf(Event).if {
			when[\name] = this;
			^list.add(when)
		};
		when.isKindOf(Array).if {
			var whens = when;
			var n = whens.size;
			var base = (when: whens) ++ kwargs.asEvent;
			var previewAts = list.previewAtFor(whens);
			^n.collect { |i|
				var ev = list.sliceAxis(base, i, n);
				list.dispatch(ev, { |e| list.gateWithPreviewAt(e, previewAts[i]) });
				ev
			}
		};
		^list.add((when: when ? 0) ++ kwargs.asEvent)
	}

	addPattern { |when=0, pattern, n, maxWhen=300|
		^EventList.current.addPattern(when, pattern, n, maxWhen, this)
	}
}
