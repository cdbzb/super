MicroKeys {
	var <>array,<>keys, <>namedList, <tuningDeltas, tuningFunction, <heldNotes, <damperDown = false, <>down, <ccs, <storedCCValues, <name, <item, <>active=false;
	var <>synthFunc;
	classvar <all;
	classvar <type=\mk;

	classvar tuningFunction;
	// methods to make "standard" params
	*freq {
		^{|mk| {\freq.kr(900) * (\poly.kr() / 127+ CC.bend(mk: mk).bus.kr => _.midiratio)} }
	}
	doNoteOn { |amp midinote params silent|
		silent.isNil.if{
			this.noteOnFunction.(amp, midinote, nil, nil, params).debug("noteOn")

			=> {|e| this.register(e)} // register method could be moved here
		}
	}
	storeCCValues {
		^storedCCValues = CC.getValues(this.name)
	}
	restoreCCValues {
		^CC.setValues(storedCCValues, this.name)
	}
	*initClass{
		Event.addEventType(\mkOff, {});

		Event.addEventType(\mk2, {
			~instrument =  ~mk.doNoteOn(~amp * 127, ~midinote, ~params).asDefName ;
		});

		Event.addEventType(\mk, {
			var syn;
			~mk.isKindOf(Symbol).if { ~mk = MicroKeys(~mk) };
			Server.default.makeBundle(~latency, { ~mk.doNoteOn(~amp * 127, ~midinote, ~params, ~silent) });
			fork{
				~sustain.().wait;
				//syn could be passed into doNoteOff to solve the overlapping notes issue
				Server.default.makeBundle(~latency, {~mk.doNoteOff(~midinote)})
			}	
		});
		Event.addEventType(\setCC, {
			Server.default.makeBundle(~latency, {var cc = CC(~ctlNum, mk: ~mk); cc.setRaw(~control * cc.rawScale) }) 
		});

		//deprecate
		Event.addEventType(\setBend, {
			Server.default.makeBundle(~latency, { CC(~ctlNum, mk: ~mk).setRaw(~control * 16384) }) 
		});
		Event.addEventType(\setDamper, {
			~mk.isKindOf(Symbol).if { ~mk = MicroKeys(~mk) };
			Server.default.makeBundle(~latency, { ~mk.setDamper(~control) })
		});
		Event.addEventType(\setPoly, {
			~mk.isKindOf(Symbol).if { ~mk = MicroKeys(~mk) };
			( ~mk.keys[~midinote] != 0 ).if {
				 // ~mk.keys[~midinote].().set(\poly, ~polyTouch) 
				 Server.default.bind{
					 ~mk.doPoly( ~polyTouch, ~midinote )
				 }
			}{
				~type = \rest
			}
		});
		all = Dictionary(256)
	}

	*newFrom{ |mk itemName|
		var newName = mk ++ itemName => _.asSymbol;
		var new, old, func ;

		all[newName].notNil.if {
			^all[newName]
		} { 
			old = MicroKeys(mk);
			new = super.new.init(newName) ;
			new.namedList = old.namedList.deepCopy;
			func = old.synthFunc;
			func.isKindOf(Symbol).if{
				new.synth_(func) 
			} {
				(mk: newName).use{ SynthDef(newName, func).add.name };
				new.synth_(newName);
			};
			^new
		}  
	}

	*new { |name func|
		all[name].notNil.if {
			^all[name]
		} { 
			^super.new.init(name, func) 
		}  
	}
	 
	*mono { |...args|
		^MonoKeys(*args)
	}

	init { |aName func|
		name = aName;
		namedList = NamedList.new;
		tuningFunction = { |tuning| { |e| e.num = e.num + tuningDeltas.wrapAt(e.num); e }};
		namedList.add( \event, {|v n c r params| (vel: v/127, num: n, chan: c, src: r, raw: n, params: params) });

		this.synth_( func !? {|i| (mk: name).use{ i.asDefName }} ? I.d);
		
		keys = 0 ! 128;
		heldNotes = Set[];
		all.add(name -> this);
		ccs = List[];
	}

	synth_ { |funcOrDefname params|
		funcOrDefname.isKindOf(Symbol).if{
			synthFunc = funcOrDefname;
			namedList.add( \synth,
				{ |e|
					e.silent.isNil.if {
						e.synths = Synths(
							funcOrDefname, 
							[\freq, e.num.midicps, \amp, e.vel, \num, e.num] 
							++ params 
							++ ( e.params ? () ).asKeyValuePairs
						)
					};
					e
				}
			)
		}{ //otherwise should be a Function
			//needs to return an Event with synth in synth:
			synthFunc = funcOrDefname;
			this.synth_((mk: name).use{ funcOrDefname.asDefName })
		};
		namedList.dump
	}

	tuning_ { |tuning root| //todo add root
		tuningDeltas = Tuning.at(tuning).semitones.collect{|i x| i - x};
		tuning.notNil.if{ namedList.add(
			\tuning, 
			tuningFunction.(tuning),
			addAction: \addBefore,
			otherName: \synth
		) };
		namedList.dump
	}

	velCurve_ { |curvature range|
		namedList.add (
			\velCurve, 
			{
				|e|
				range = range ? [0,1];
				e.vel=Env(range,[1],[curvature]).at(e.vel)
			},
			addAction: \addBefore,
			otherName: \synth
		);
		namedList.dump
	}

	get { |key|
		^namedList[key]
	}

	add { |key func addAction target|
		namedList.add( key, func, true, addAction, target)
	}

	// split_ { |r| range = r }
	range_ { |array| 
	  this.add(\range, {|e| array.includes( e.num ).not.if{e.silent_(true)}; e}, \addAfter, \event);
	}

	register { |event|
		keys[event.raw] = event[\synths].debug("eventSynth");

		// ^e.synth
}

	noteOnFunction {
		// ^namedList.array.reverse.inject(I.d, _ <> _)
		^namedList.array.reverse
		// .collect({|func| {|e| e.notNil.if{ func.(e) } } })


		.inject(I.d, {|i j| try{i <> j} }) //this should return an event with and raw synth or Synths
	}

	setDamper {|num| 
		(num == 127).if{
			damperDown = true.postln 
		}{ 
			damperDown = false.postln; 
			heldNotes.do(_.release); 
			heldNotes = Set[] 
		} 
	}

	doNoteOff {|midinote| 
		name.debug("noteOff");
		damperDown.not.if {keys[midinote].release} {heldNotes.add(keys[midinote])} 
	}

	doPoly {|val num| 
		// set the synth's poly control
		// but what if there is none?
		// in that case we need to set a bus and map that bus to freq?
		keys[num].set(\poly, val)
	}
	record {
		this.recordMe
	}
	monitor {
		active = true;
		// storedCCValues.notNil.if{ this.restoreCCValues };
		CC.all[name].do(_.activate);
		// MIDIdef.noteOn(\microOn, {|val num| this.noteOnFunction.(val, num)}, noteNum:range);
		MIDIdef.noteOn(\microOn ++ name => _.asSymbol,  {|v n| (type: \mk, mk:this, amp: v/127, midinote: n, latency:0, sustain: inf ).play}, );
		// MIDIdef.noteOff(\microOff, {|vel, num| damperDown.postln; ( damperDown == false ).if{ keys[num].release }{ heldNotes.add(keys[num]) }});
		MIDIdef.noteOff(\microOff ++ name => _.asSymbol, {|val num| this.doNoteOff(num) }, );
		MIDIdef.cc(\microDamper ++ name => _.asSymbol,{|num| this.setDamper(num) }, 64);
		MIDIdef.polytouch(\microPoly ++ name => _.asSymbol, {|val num| this.doPoly(val, num)});
	}

	unmonitor {
		active = false;
		[\microOn, \microOff, \microDamper, \microPoly].do{|i| MIDIdef(i ++ name => _.asSymbol).free}
	}

	free {
		this.unmonitor ; //remove MIDIdefs
		CC.all[this.name].do{|i| i.bus.free; i.free}; //remove CC busses and CCs
		this.free 
	}

	split { |array|
		var defNames, cases, paramEvents;
		# defNames, cases, paramEvents = array.flop;
		namedList.add( \chooseDef,
			{|e|
				cases.collect(_.value(e.num)).do{|i x|
					i.if {
						e.def_(defNames.[x]);
						e.splitParams_(paramEvents[x] ? ())
					}
				};
			e.postln
			};
		);
		namedList.addAfter( \synth,
			{ |e|
				Synth(e.def ? \default, [\freq, e.num.midicps, \amp, e.vel, \num, e.num] 
				// ++ params  TODO
				++ ((e.splitParams ? ()) ++ (e.params ? ())).asKeyValuePairs)
				=> this.register(_, e.raw)
			},
			\chooseDef
		);
		namedList.dump;
		// this.test.isNil.if{ "noteOnFunction isNil".warn }{}
		this.test !? (_.release) ?? { "noteOnFunction isNil".warn }
	}
	test {
		^try{ this.noteOnFunction.(40,40) }
	}
	//
	// auto-record items
	//

	recordMe {
		item.isNil.if{ item = MIDIItem.new( Date.getDate.stamp ) };
		item.record(this);
	}
	insertItem {
		var key = $\\ ++ $\\ ++ name;
		var string = "MIDIItem(\\\"%\\\").play(%)".format(item.name, key);

		Nvim.replace(string)
	}

	doesNotUnderstand {|selector ...args|
		namedList.respondsto(selector).if{
			^Message(namedList, selector, args).value
		}
	}
}

MonoKeys : MicroKeys {
	var monosynth;
	classvar <type=\mkMono;
	*new { |name func|
		all[name].notNil.if {
			(all[name].class == MonoKeys).if {
			// reset down notes on reload
				all[name].down_(List[]);
				^all[name]
			}
		} { 
			^super.new.init(name, func) 
		}  
	}
	*initClass {
		MyFree.add({ MicroKeys.all.do{|i| i.down_(List[]) } });
		Event.addEventType(\mkMono, {
			var syn;
			Server.default.makeBundle(~latency, { MicroKeys( ~mk ).doNoteOn(~amp * 127, ~midinote, ~params) });
			fork{
				~sustain.().wait;
				//syn could be passed into doNoteOff to solve the overlapping notes issue
				Server.default.makeBundle(~latency, {MicroKeys( ~mk ).doNoteOff(~midinote)})
			}	
		});
	}
	doNoteOn { |amp midinote params|

			( down.size == 0 ).if{
				monosynth = this.noteOnFunction.(amp, midinote, nil, nil, params) ;
				monosynth.notNil.if {
					down.add(midinote)
				}
			}{
				var event, func = namedList.deepCopy;
				func.removeAt(\synth);
				event = func.reverse.inject(I.d, {|i j| try{i <> j}}).(amp, midinote, nil, nil, params);
				event.notNil.if{
					monosynth.set(
						// \freq, event.num.midicps, 
						\num, event.num, \freq, event.num.midicps, \vel, event.vel, \amp, event.vel);
						down.add(midinote); // raw midinote for bookkeeping
				};
						// move this line down here to allow tracking outside the range
						// down.add(midinote); // raw midinote for bookkeeping
						
			} 
	}
	// *new {|synthFunc|
	// 	^super.new.init(synthFunc)
	// }
	monitor {
		down = List[];
		MIDIdef.noteOn(\microOn ++ name => _.asSymbol, {|v n | 
			this.doNoteOn(v, n);
		});
		MIDIdef.noteOff(\microOff ++ name => _.asSymbol, {|vel num| 
			this.doNoteOff(num);
		});
		// MIDIdef.cc(\microDamper, {|num| (num == 127).if{ damperDown = true.postln }{ damperDown = false.postln; heldNotes.do(_.release); heldNotes = Set[] } }, 64);
		MIDIdef.polytouch(\microPoly ++ name => _.asSymbol, {|val num| monosynth.set(\poly, val)});
	}
	doNoteOff{ |num|
		name.debug("noteOff");
			down.debug("down off");
			(down.size <= 1).if{
				monosynth.release;
				down.remove(num) 
			}{ 
				down.remove(num);
				monosynth.set(\num, down.last)  // snap back to previous note
			};
	}
}
/*
MicroKeys({|e|Synth(\default,[\freq,e.num.midicps,\pan,e.vel*2-1])}).tuning_(\partch).play
(
a=MicroKeys().tuning_(\pythagorean).simplePlay(\stringyy);
a=MicroKeys().tuning_(\partch).range_((60..128)).simplePlay(\default)
)

a=MicroKeys().tuning_(\partch).velCurve_(2).simplePlay(\default)
a=MicroKeys().tuning_(\kirnberger).velCurve(2).simplePlay(\default)
a=MicroKeys().tuning_(\sept2).velCurve_(2,[0.1,0.1]).simplePlay(\default)

Env.new([0,1],[1],[-1.5]).at(0.5)
Tuning
*/
 
