EventList {
	classvar <all, <>current;
	var <events, <>preview, <>defaultType, <routes, <>addFunc;
	var <>env;

	*initClass {
		all = ();
	}

	*new { |name, defaultType|
		var instance = super.new.init(defaultType);
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
	*play { |from=0| ^current.play(from) }
	*clear { ^current.clear }
	*size { ^current.size }
	*do { |func| ^current.do(func) }
	*addRoute { |key, type| ^current.addRoute(key, type) }
	*preview_ { |val| ^current.preview_(val) }
	*preview { ^current.preview }
	*addFunc_ { |val| ^current.addFunc_(val) }
	*env { ^current.env }

	init { |defType|
		events = List[];
		defaultType = defType;
		routes = ();
		env = ();
	}

	addRoute { |key, type|
		routes[key] = type;
	}

	add { |...args, kwargs|
		var event;
		// add(event) or add(when, key: val, ...)
		args[0].isKindOf(Event).if {
			event = args[0]
		} {
			event = (when: args[0] ? 0) ++ kwargs.asEvent
		};
		// check routed keys first
		routes.keysValuesDo { |key, type|
			event[key].notNil.if {
				event.put(\type, type);
				this.gate(event);
				^event
			}
		};
		// array expansion (skip routed keys)
		event.select { |v, k| routes[k].isNil }.values
			.any { |i| i.rank > 0 }.if {
			event.asPairs.flop.collect { |i| i.asEvent }
				.do { |e| this.add(e) };
			^event
		};
		// default type
		event.put(\type, event[\newType] ? defaultType);
		// optional transform
		addFunc !? { addFunc.(event, this) };
		this.gate(event);
		^event
	}

	gate { |event|
		preview.notNil.if { event.put(\when, 0).play } { events.add(event) }
	}

	play { |from=0|
		events.do { |e|
			((e.when ? 0) >= from).if {
				TempoClock.sched((e.when ? 0) - from, {
					e.copy.put(\when, 0).play; nil
				})
			}
		}
	}

	clear {
		events = List[];
		preview = nil;
	}

	size { ^events.size }

	do { |func| events.do(func) }

	at { |index| ^events[index] }
}
