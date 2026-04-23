EventList {
	classvar <all, <>current, <>playFn;
	var <events, <preview, <>defaultType, <routes, <>addFunc, <>previewPrep;
	var <>env, <>context;
	var <>autoExpand = true;
	var <>batchWindow = 0.05, batchEndTime = -1e9, batchFirstWhen = 0;

	*initClass {
		all = ();
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
		};
		^instance
	}

	*at { |name| ^all[name] }

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
	*play { |from=0| ^current.play(from) }
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
		var ev = ();
		base.keysValuesDo { |k, v|
			case
				{ v.isKindOf(Env) or: { v.isKindOf(Tuple3) } or: { v.isKindOf(Tuple4) } }
					{ ev[k] = v }
				{ v.isArray }
					{ ev[k] = v.clipAt(i) }
				{ ev[k] = v }
		};
		^ev
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
			previewPrep !? { previewPrep.(event, this) };
			SystemClock.sched(
				previewAt * TempoClock.default.beatDur,
				{ event.play; nil }
			)
		}
	}

	preview_ { |val|
		var wasOff = preview.isNil;
		preview = val;
		(wasOff and: { val.notNil }).if { this.setupContext }
	}

	setupContext {
		context.do { |e| e.copy.put(\when, 0).play }
	}

	play { |from=0|
		var beatDur;
		playFn.notNil.if { ^playFn.(this, from) };
		beatDur = TempoClock.default.beatDur;
		events.do { |e|
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
