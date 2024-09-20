// MicroKeys id=1898415352;

MicroKeys {
	var <>array,<>keys,<>func,<>range, <>namedList, tuningDeltas, tuningFunction;

	classvar tuningFunction;
	*new { |func|
		^super.new.init(func)
	}
	init { |f|
		namedList = NamedList.new;
		tuningFunction = { |tuning| { |e| e.num = e.num + tuningDeltas.wrapAt(e.num) }};
		namedList.add( \event, {|v n c r| (vel:v/127, num:n, chan:c, src:r, raw:n)});
		namedList.add( \synth, I.d);
		keys = 0!128;
		func=f
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
	setSynth { |synth | 
		namedList.add(
			\synth,
			{
				|e|
				Synth(synth,[\freq,e.num.midicps,\amp,e.vel])
				=> this.register(_,e.raw)
			}
		);
		this.makeMIDIdefs
	}
	play {
		namedList.add(
			\synth,
			{
				|e|
				func.value(e) => this.register(_,e.raw)
			}
		);
		this.makeMIDIdefs
	}
	split_ {|r| range=r}
	register { |synth num|
		keys[num]=synth;
	}

	makeMIDIdefs {
		MIDIdef.noteOn(\microOn, namedList.array.reverse.inject(I.d, _<>_), noteNum:range);
		MIDIdef.noteOff(\microOff, {|vel, num| keys[num].release})
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
 
