ModSin : SinOsc {
	*new {|freq=400, rate=5,width=0.05, amp=0.1|
		^SinOsc.ar( SinOsc.kr (rate,0,width*freq,freq),0,amp)
	}
}

VibSin : SinOsc {
	*new {|freq=400, rate=5, width=0.05, delay=0.6, amp=0.1, onset=0.15, trig=1, rateVar=0.04, widthVar=0.1|
		^SinOsc.ar( Vibrato.kr (freq,rate,width,delay, onset, rateVar, widthVar,trig),mul:amp)
	}
}

Verb : UGen {
	*new { |bus=10, mix=1, room=0.8, damp=0.1|
		^FreeVerb.ar (In.ar(bus),mix,room,damp)
	}
}

Send : UGen {
	*new { |in,bus,  dry=0.5, wet=1|
		^Out.ar([0,1,bus],[in*dry, in*dry, in*wet])
	}
}

//SampleObject : Object { |argb|
//	*new {super.new.init(argb)}
//	init{|b|
//		chicken {
//			^argb
//		}
//}}
//

Song {
    var <array;
	var <>cursor=0;
    *new { |array|
        ^super.newCopyArgs(array)
    }
	lyrics {^array.copySeries(0,2,array.size)}
}

Piano {
	var <controller;
	var <synth;
	var vsti;
	var synthdef;
	var <node,<bus;
	*new{^super.new.init}
	init{
		node=NodeProxy.audio().play;
		bus=Bus.audio(numChannels:2);
		node.source={In.ar(bus.index,2)};
		synthdef=SynthDef(\vsti,{|out=0|
			var sig=VSTPlugin.ar(nil,2);
			Out.ar(bus.index,sig)
		});
		//synth=Synth(\vsti);
		//controller=VSTPluginController(Synth(\vsti,[\out,self.bus]));
		controller=VSTPluginController(synthDef:synthdef);
		controller.open('/Library/Audio/Plug-Ins/VST/Pianoteq 5.vst',info:true)  //++self.plugin
	
	}
}

+ Pbind {
	pad { arg release=10;
		^Pseq.new([this,Pbind.new(\note,Pseq([\r]),\dur,release)])
	}
}

+ String {
	asDrumPat {| beatsPerBar=8 reps=1|
		var b=List.new;
		var a=Array.newFrom(this);
		a.do({|m| (m=="|"[0]).not.if{b.add(m)}});
		b=b.collect{|j| (j=="x"[0]).if({1},{Rest(1)})};
		^Pseq(b/beatsPerBar,reps)
	}
}

//a=SampleObject.new;
//b=SampleObject.new;
//b.chicken

//a=Song([1,2,3,4]);
//a.array;
//a.lyrics;
////a.testt.class;
//a.cursorEl(0)
//a.cursor_(2)
//a.cursor;
//a;
//a.three;
