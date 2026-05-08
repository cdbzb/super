EventList {
	classvar <all, <>current, <>playFn, <>cursor;
	var <events, <preview, <>defaultType, <routes, <>addFunc, <>previewPrep;
	var <>env, <>context;
	var <>autoExpand = false;
	var <>batchWindow = 0.05, batchEndTime = -1e9, batchFirstWhen = 0;
	var <>scope, <>voiceSpace;
	var <solo, <mute;
	var <>beatDur;

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
	*play { |from| ^current.play(cursor.debug("CURSOR") ? from ? 0 => _.postln) }
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
			event = (when: when ? 0) ++ kwargs.asEvent
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
			SystemClock.sched(
				previewAt * bd,
				{ projected.play; nil }
			)
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

	play { |from=0|
		var bd;
		from = from ? 0;
		voiceSpace.notNil.if { ^voiceSpace.playFrom(this, from) };
		playFn.notNil.if { ^playFn.(this, from) };
		bd = beatDur ? TempoClock.default.beatDur;
		this.scopedEvents.do { |e|
			var t = e.when ? 0;
			((t >= from) and: { this.shouldPlay(e) }).if {
				SystemClock.sched((t - from) * bd, { e.play; nil })
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

