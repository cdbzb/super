Effect  {
	var <>bus, <>synth, <>pattern, <>def, <>out, <>dur;
	*new {|inPattern def out dur|
		^super.new.init(inPattern, def, out, dur)
	}

	init {|inPattern inDef outChan inDur|
		bus=Bus.audio(Server.default,2);
		pattern=inPattern=>Pset(\out,bus.index,_);
		def=inDef;
		outChan.isNil.if({out=Bus.audio(Server.default,2)},{out=outChan});
		inDur.isNil.if({dur=30},{dur=inDur});
		^this
	}

	play {
		synth=Synth(def.asSymbol,[\in,bus.index,\out,out]);
		pattern.play;
		{dur.wait;synth.free}.fork;
		^synth;
	}
//////
// OK!!!
//
//get the stream from the pattern (.asStream)
// when it returns nil put in the \off event
//
///////

	//Array or?
	set { |...args|
		synth.set(args)
	}

}

// TODO can we just send a function in instead of a defName ?

//(
//	{|in out| In.ar(in,1)=>PlateReverb.ar (_,1,\room.kr(1,19))=>Out.ar(0,_)}=>SynthDef(\verb,_)=>_.add;
//	a=[note:Pwhite(0,12),dur:((0.9!30).rand).q].p=>Effect(_,\verb)
//)
//{a.play;0.05.wait; a.synth.set(\room,0.0)}.fork
FX { 
	var <>bus;

	*new { |synth fx|
		^super.new.init(synth,fx )
	}

	*newN{ |synth fx|
		^super.new.initN(synth,fx);
	}

	init { |synth fx fxArgs numChannels=1|
		bus=Bus.audio(Server.default);
		synth.set(\out,bus.index);
		^Synth(fx,[\in,bus.index]++fxArgs,addAction:\addToTail)
	}

	initN { |synth fx fxArgs numChannels=1|
		bus=Bus.audio(Server.default);
		synth.set(\out,bus.index);
		^Synths(fx,[\in,bus.index]++fxArgs,addAction:\addToTail)
	}

}



