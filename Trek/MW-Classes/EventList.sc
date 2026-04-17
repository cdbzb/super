EventList {
	classvar <all, <>current;
	var <events, <preview, <>defaultType, <routes, <>addFunc, <>previewPrep;
	var <>env, <>context;

	*initClass {
		all = ();
	}

	*new { |name, defaultType|
		var instance;
		name.notNil.if {
			all[name].notNil.if {
				current = all[name];
				^all[name]
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
		var event;
		args[0].isKindOf(Event).if {
			event = args[0]
		} {
			event = (when: args[0] ? 0) ++ kwargs.asEvent
		};
		^current.add(event)
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
		var event;
		args[0].isKindOf(Event).if {
			event = args[0]
		} {
			event = (when: args[0] ? 0) ++ kwargs.asEvent
		};
		this.dispatch(event, { |e| this.gate(e) });
		^event
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
		event.select { |v, k| routes[k].isNil }.values
			.any { |i| i.rank > 0 }.if {
			event.asPairs.flop.collect { |i| i.asEvent }
				.do { |e| this.dispatch(e, sink) };
			^this
		};
		event.put(\type, event[\newType] ? defaultType);
		addFunc !? { addFunc.(event, this) };
		sink.(event);
		^this
	}

	gate { |event|
		preview.notNil.if {
			previewPrep !? { previewPrep.(event, this) };
			event.play
		} { events.add(event) }
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
		events.do { |e|
			var t = e.when ? 0;
			(t >= from).if {
				TempoClock.sched(t - from, { e.play; nil })
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
