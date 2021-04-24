// MicroKeys id=1898415352;

MicroKeys {
	var <>array,<>keys,<>func,<>range;

	classvar tuningFunction;
	*initClass {
		tuningFunction = { |tuning|
			{|e| e.num=e.num+Tuning.at(tuning).semitones.collect({|i x|i-x}).wrapAt(e.num) }
		};
	}
	*new { |func|
		^super.new.init(func)
	}
	init { |f|
		array=[ {|v n c r| (vel:v/127,num:n,chan:c,src:r,raw:n)} ];
		keys = 0!128;
		func=f
	}
	tuning_ { |tuning|
		tuning.notNil.if{array.add(tuningFunction.(tuning))};
	}
	velCurve_ { |curvature range|
		array.add {
			|e|
			range = range ? [0,1];
			e.vel=Env(range,[1],[curvature]).at(e.vel)
		}
	}
	simplePlay { |synth, durFunc| 
		array.add(
			{
				|e|
				Synth(synth,[\freq,e.num.midicps,\amp,e.vel])
				=> this.register(_,e.raw);
			}
		);
		this.midiFunc
	}
	play {
		array.add({|e|
			func.value(e) => this.register(_,e.raw)
		}
	);
		this.midiFunc
	}
	split_ {|r| range=r}
	register { |synth num|
		keys[num]=synth;
	}
	midiFunc {
		MIDIFunc.noteOn(array.reverse.inject(I.d,_<>_), noteNum:range);
		MIDIFunc.noteOff({|vel, num| keys[num].release})
	}
}
/*
TODO: Migrate to MIDIdef and make layers and splits

MicroKeys({|e|Synth(\default,[\freq,e.num.midicps,\pan,e.vel*2-1])}).tuning(\partch).play
(
a=MicroKeys().tuning_(\pythagorean).simplePlay(\stringyy);
a=MicroKeys().tuning_(\partch).range_((60..128)).simplePlay(\default)

)

a=MicroKeys().tuning_(\partch).velCurve(2).simplePlay(\default)
a=MicroKeys().tuning_(\kirnberger).velCurve(2).simplePlay(\default)
a=MicroKeys().tuning_(\sept2).velCurve_(2,[0.1,0.1]).simplePlay(\default)

Env.new([0,1],[1],[-1.5]).at(0.5)
Tuning
*/
 
