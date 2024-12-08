MicroKeys {
	var <>array,<>keys,<>range, <>namedList, <tuningDeltas, tuningFunction, <heldNotes, <damperDown = false, <>down, <ccs, <storedCCValues, <name;
	classvar <all;
	classvar <type=\mk;

	classvar tuningFunction;
	doNoteOn { |amp midinote params|
			 this.noteOnFunction.(amp, midinote, nil, nil, params); 
	}
	storeCCValues {
		^storedCCValues = CC.getValues(this)
	}
	restoreCCValues {
		^CC.setValues(storedCCValues, this)
	}
	*initClass{
		Event.addEventType(\mkOff, {});

		Event.addEventType(\mk2, {
			~instrument =  ~mk.doNoteOn(~amp * 127, ~midinote, ~params).asDefName ;
		});
		Event.addEventType(\mk, {
			var syn;
			Server.default.makeBundle(~latency, { ~mk.doNoteOn(~amp * 127, ~midinote, ~params) });
			fork{
				~sustain.().wait;
				//syn could be passed into doNoteOff to solve the overlapping notes issue
				Server.default.makeBundle(~latency, {~mk.doNoteOff(~midinote)})
			}	
		});
		Event.addEventType(\setCC, {
			Server.default.makeBundle(~latency, { CC(~ctlNum, mk: ~mk).setRaw(~control * 127) }) 
		});
		Event.addEventType(\setBend, {
			Server.default.makeBundle(~latency, { CC(~ctlNum, mk: ~mk).setRaw(~control) }) 
		});
		Event.addEventType(\setDamper, {
			Server.default.makeBundle(~latency, { ~mk.setDamper(~control) })
		});
		Event.addEventType(\setPoly, {
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
		namedList.add( \event, {|v n c r params| (vel: v/127, num: n, chan: c, src: r, raw: n, params:params) });

		// this.synth_(func ? I.d);
		this.synth_( func !? _.asDefName ? I.d);
		keys = 0 ! 128;
		heldNotes = Set[];
		all.add(name -> this);
		ccs = List[];
	}

	synth_ { |funcOrDefname params|
		funcOrDefname.isKindOf(Symbol).if{
			namedList.add( \synth,
				{ |e|
					e.notNil.if  {
						Synths(funcOrDefname, [\freq, e.num.midicps, \amp, e.vel, \num, e.num] ++ params ++ ( e.params ? () ).asKeyValuePairs)
						=> this.register(_, e.raw)
					}
				}
			)
		}{
			namedList.add( \synth,
				{ |e| 
					((mk: this, e:e) ++ e.params).use{ funcOrDefname.valueEnvir } 
					=> this.register(_, e.raw) 
				} 
			)
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

	split_ { |r| range = r }


	register { |synth num|
		keys[num] = synth;
		^synth
}

	noteOnFunction {
		^namedList.array.reverse.inject(I.d, _ <> _)
	}

	setDamper {|num| 
		(num == 127).if{
			damperDown = true.postln 
		}{ 
			damperDown = false.postln; heldNotes.do(_.release); heldNotes = Set[] 
		} 
	}

	doNoteOff {|midinote| 
		damperDown.not.if {keys[midinote].release} {heldNotes.add(keys[midinote])} 
	}

	doPoly {|val num| 
		// set the synth's poly control
		// but what if there is none?
		// in that case we need to set a bus and map that bus to freq?
		keys[num].set(\poly, val)
	}
	activate {
		storedCCValues.notNil.if{ this.restoreCCValues };
		// MIDIdef.noteOn(\microOn, {|val num| this.noteOnFunction.(val, num)}, noteNum:range);
		MIDIdef.noteOn(\microOn,  {|v n| (type: \mk, mk:this, amp: v/127, midinote: n, latency:0, sustain: inf ).play}, noteNum:range);
		// MIDIdef.noteOff(\microOff, {|vel, num| damperDown.postln; ( damperDown == false ).if{ keys[num].release }{ heldNotes.add(keys[num]) }});
		MIDIdef.noteOff(\microOff, {|val num| this.doNoteOff(num) });
		MIDIdef.cc(\microDamper,{|num| this.setDamper(num) }, 64);
		MIDIdef.polytouch(\microPoly, {|val num| this.doPoly(val, num)});
	}

	deactivate {
		[\microOn, \microOff, \microDamper, \microPoly].do{|i| MIDIdef(i).free}
	}

	free {
		this.deactivate; //remove MIDIdefs
		CC.all[this].do{|i| i.bus.free; i.free}; //remove CC busses and CCs
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
			// reset down notes on reload
			all[name].down_(List[]);
			^all[name]
		} { 
			^super.new.init(name, func) 
		}  
	}
	 
	doNoteOn { |amp midinote params|
			 // ~mk.noteOnFunction.(~amp * 127, ~midinote, nil, nil, ~params); 
			down;
			( down.size == 0 ).if{
				monosynth = this.noteOnFunction.(amp * 127, midinote, nil, nil, params) ;
				down.add(midinote)
			}{
				monosynth.set(\num, midinote).set(\vel, amp);
				down.add(midinote);
			} 
	}
	// *new {|synthFunc|
	// 	^super.new.init(synthFunc)
	// }
	activate {
		down = List[];
		MIDIdef.noteOn(\microOn, {|v n | 
			down;
			( down.size == 0 ).if{
				monosynth = this.noteOnFunction.(v, n) ;
				down.add(n)
			}{
				monosynth.set(\num, n).set(\vel, v);
				down.add(n);
			} 
		}, noteNum:range);
		MIDIdef.noteOff(\microOff, {|vel num| 
			this.doNoteOff(num);
			// damperDown.postln; 
			// (damperDown == false).if{ keys[num].release }{ heldNotes.add(keys[num]) }
		});
		// MIDIdef.cc(\microDamper, {|num| (num == 127).if{ damperDown = true.postln }{ damperDown = false.postln; heldNotes.do(_.release); heldNotes = Set[] } }, 64);
		MIDIdef.polytouch(\microPoly, {|val num| monosynth.set(\poly, val)});
	}
	doNoteOff{ |num|
			down.debug("down off");
			(down.size == 1).if{
				monosynth.release;
				down.remove(num) 
			}{ 
				down.remove(num);
				monosynth.set(\num, down.last)  // snap back to previous note
			};
	}
}
/*
TODO: Migrate to MIDIdef and make layers and splits

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
 
