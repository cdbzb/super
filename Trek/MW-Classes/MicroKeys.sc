// MicroKeys id=1898415352;

MicroKeys {
	var <>array,<>keys,<>range, <>namedList, tuningDeltas, tuningFunction, <heldNotes, <damperDown;

	classvar tuningFunction;
	*initClass{
		Event.addEventType(\mk, {
			var syn = ~mk.prFunc.(~amp * 120, ~midinote); 
			fork{
				~sustain.wait; 
				syn.release 
			}
		})
	}
	*new { |func|
		^super.new.init(func)
	}
	init { |func|
		namedList = NamedList.new;
		tuningFunction = { |tuning| { |e| e.num = e.num + tuningDeltas.wrapAt(e.num) }};
		namedList.add( \event, {|v n c r| (vel:v/127, num:n, chan:c, src:r, raw:n)});
		this.synth_(func ? I.d);
		keys = 0!128;
		heldNotes = Set.new;
	}
	synth_ {|funcOrDefname|
		funcOrDefname.isKindOf(Symbol).if{
			var synth = funcOrDefname;
			namedList.add(
				\synth,
				{
					|e|
					Synth(synth,[\freq,e.num.midicps,\amp,e.vel])
					=> this.register(_,e.raw)
				};
			);
		}{
			var func = funcOrDefname;
			namedList.add(
				\synth,
				{
					|e|
					func.value(e) => this.register(_,e.raw)
				}
			);
		};
		namedList.dump;
		this.makeMIDIdefs
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
		)
	}
	get{ |key|
		^namedList[key]
	}
	add { |key func addAction target|
		namedList.add( key, func, true, addAction, target)
	}
	split_ {|r| range=r}
	register { |synth num|
		keys[num]=synth;
		^synth
	}
	prFunc {
		^namedList.array.reverse.inject(I.d, _<>_)
	}

	makeMIDIdefs {
		MIDIdef.noteOn(\microOn, this.prFunc , noteNum:range);
		MIDIdef.noteOff(\microOff, {|vel, num| damperDown.postln; ( damperDown == false ).if{ keys[num].release }{ heldNotes.add(keys[num]) }});
		MIDIdef.cc(\damper, {|num| (num == 127).if{ damperDown = true.postln }{ damperDown = false.postln; heldNotes.do(_.release); heldNotes = Set[] } }, 64)
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
 
