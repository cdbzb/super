EventList {
	classvar <all, <>current, <>playFn, <>cursor;
	var <events, <preview, <>defaultType, <routes, <>addFunc, <>previewPrep;
	var <>env, <>context;
	var <>autoExpand = false;
	var <>batchWindow = 0.05, batchEndTime = -1e9, batchFirstWhen = 0;
	var <>scope;

	*initClass {
		all = ();
		Class.initClassTree(Event);
        Event.addEventType(\eventList, {~eventList.isKindOf(EventList).if{~eventList}{EventList(~eventList)}.play(~start)});
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

	*newFrom { |other, name|
		var instance = this.new(name, other.defaultType);
		^instance.copyFrom(other)
	}

	copy {
		var instance = this.class.new(nil, defaultType);
		^instance.copyFrom(this)
	}

	copyFrom { |other|
		events      = other.events.copy;
		context     = other.context.copy;
		routes      = other.routes.copy;
		env         = other.env.copy;
		addFunc     = other.addFunc;
		previewPrep = other.previewPrep;
		autoExpand  = other.autoExpand;
		batchWindow = other.batchWindow;
		^this
	}

	// class-level forwarding for common methods
	*add { |...args, kwargs|
		var when = args[0];
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
		scope.isNil.if { ^ev };
		^ev.copy.put(\voice, this.scopedVoice(ev[\voice] ? \default))
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

	gateWithPreviewAt { |event, previewAt|
		events.add(event);
		preview.notNil.if {
			var projected = this.projectEvent(event);
			previewPrep !? { previewPrep.(projected, this) };
			SystemClock.sched(
				previewAt * TempoClock.default.beatDur,
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
		var beatDur;
		playFn.notNil.if { ^playFn.(this, from) };
		beatDur = TempoClock.default.beatDur;
		this.scopedEvents.do { |e|
			var t = e.when ? 0;
			(t >= from).if {
				SystemClock.sched((t - from) * beatDur, { e.play; nil })
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
