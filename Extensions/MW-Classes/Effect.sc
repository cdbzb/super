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

+Object {
	wrapp { ^{this}}
}
