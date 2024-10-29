// MicroKeys id=1898415352;

MicroKeys {
	var <>array,<>keys,<>range, <>namedList, <tuningDeltas, tuningFunction, <heldNotes, <damperDown = false, <down;
	classvar <all;

	classvar tuningFunction;
	*initClass{
		Event.addEventType(\mk, {
			var syn = ~mk.prFunc.(~amp * 127, ~midinote); 
			fork{ ~sustain.wait; syn.release } // add s.latency to wait?
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

	init { |name func|
		\INIT.postln;
		namedList = NamedList.new;
		tuningFunction = { |tuning| { |e| e.num = e.num + tuningDeltas.wrapAt(e.num); e }};
		namedList.add( \event, {|v n c r| (vel: v/127, num: n, chan: c, src: r, raw: n)});
		// this.synth_(func ? I.d);
		this.synth_( func !? _.asDefName ? I.d);
		keys = 0 ! 128;
		heldNotes = Set[];
		all.add(name -> this)
	}

	synth_ { |funcOrDefname|
		funcOrDefname.isKindOf(Symbol).if{
			namedList.add( \synth,
				{ |e|
					Synth(funcOrDefname.postln, [\freq, e.num.midicps, \amp, e.vel, \num, e.num])
					=> this.register(_, e.raw)
				}
			)
		}{
			namedList.add( \synth,
				{ |e| 
					(mk: this, e:e).use{ funcOrDefname.valueEnvir } 
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

	prFunc {
		^namedList.array.reverse.inject(I.d, _ <> _)
	}

	activate {
		MIDIdef.noteOn(\microOn, this.prFunc , noteNum:range);
		MIDIdef.noteOff(\microOff, {|vel, num| damperDown.postln; ( damperDown == false ).if{ keys[num].release }{ heldNotes.add(keys[num]) }});
		MIDIdef.cc(\microDamper, {|num| (num == 127).if{ damperDown = true.postln }{ damperDown = false.postln; heldNotes.do(_.release); heldNotes = Set[] } }, 64);
		MIDIdef.polytouch(\microPoly, {|val num| keys[num].set(\poly, val)});
	}

	deactivate {
		[\microOn, \microOff, \microDamper, \microPoly].do{|i| MIDIdef(i).free}
	}

	free {
		this.deactivate; //remove MIDIdefs
		CC.all[this].do{|i| i.bus.free; i.free}; //remove CC busses and CCs
		this.free 
	}
}

MonoKeys : MicroKeys {
	*new {|synthFunc|
		^super.new.init(synthFunc)
	}
	activate {
		var monosynth;
		down = List[];
		MIDIdef.noteOn(\microOn, {|v n | 
			monosynth.debug("ms");
			down.debug("down");
			( down.size == 0 ).if{
				monosynth = this.prFunc.(v, n) ;
				down.add(n)
			}{
				monosynth.set(\num, n).set(\vel, v);
				down.add(n);
			} }, noteNum:range);
		MIDIdef.noteOff(\microOff, {|vel num| 
			down.debug("down off");
			(down.size == 1).if{
				monosynth.release;
				down.remove(num) 
			}{ 
				down.remove(num);
				monosynth.set(\num, down.last)  // snap back to previous note
			};


			// damperDown.postln; 
			// (damperDown == false).if{ keys[num].release }{ heldNotes.add(keys[num]) }
		});
		// MIDIdef.cc(\microDamper, {|num| (num == 127).if{ damperDown = true.postln }{ damperDown = false.postln; heldNotes.do(_.release); heldNotes = Set[] } }, 64);
		MIDIdef.polytouch(\microPoly, {|val num| monosynth.set(\poly, val)});
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
 
