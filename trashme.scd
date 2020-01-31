s.meter

(
	{[
		Saw.ar(LFBrownNoise0.kr(LFBrownNoise0.kr(0.2).range(1,8)).range(\rangeLo.kr(120),\rangeHi.kr(440)),0.1) * Env.asr(releaseTime:4).kr(gate:\gate.kr(1),doneAction:2)
		,
		FreeVerb.ar(_,1,0.9),
		Phaser2.ar(_,0.5,0.2,0.5),
		Pan2.ar(_,LFBrownNoise0.ar(502).range(-1,1))
	].reduce('=>')}
	.asSynthDef(name:\clazi).add;//play
	(type:\note,instrument:\clazi,rangeLo:[120,420,420],rangeHi:[440,1940,19400], dur:60,sendGate:true).play
)

//idea: snap to semitone?

/////SynthWrapping

( //kool beat
	var lfo ={SinOsc.ar(\rate.kr(4)).range(\lo.kr(0),\hi.kr(1))};
	var verb = {FreeVerb.ar(_,SinOsc.kr(0.2).range(0,1),1)};
	//var verb = {PlateReverb.ar(_,SinOsc.kr(0.2).range(0,1),1)};
	SynthDef(\rty,{
		Pulse.ar(\freq.kr(440)*SynthDef.wrap(lfo))
		* \amp.kr(0.1) 
		* Env.cutoff(0.001).kr(2,gate:\gate.kr(1)) 
		=> SynthDef.wrap(verb)
		=> Out.ar(1,_)}).add;//.play
	[instrument:\rty,legato:0.85,dur:2].pp(quant:1); 
	[instrument:\rty,legato:0.5,freq:500].pp(quant:1);
)

	a=[instrument:\rty,legato:0.9,freq:1250,rate:8,lag:0.5].pp(quant:4);
	a.stop
	{Saw.ar(Saw.ar(Saw(4)*100+1)*500+1,0.1).fold(0.5)}.play(s,1)
(
	SynthDef(\glith,
		{Saw.ar(Saw.ar(4)*500+1,0.1).fold(0.5)=>Out.ar(1,_)}
	).add;
	(instrument:\glith,dur:300).play(quant:4)
)
	"x00x0000xxxx0000".asDrumPat //kick

(
	{Saw.ar(\freq.kr(600),0.1)=>
	(PlateReverb.ar(_,0.2)<!DetectSilence.ar(_))
	* Env.linen(0.3,1,3).kr(2,gate:\gate.kr(1))
	=>Out.ar(\out.ir(1),_)}
	=>SynthDef(\aaa,_)=>(_.add)
)
Synth(\aaa);s.plotTree
Pmono(\aaa,\degree,[ [1,3,4.1,6.1],[1,3,4.1,6] ].q).play
(
	{
		a=(instrument:\aaa,degree:[1,3,4.1,6.1]).play;
		1.5.wait;
		(type:\set,id:a[\id][3],degree:6).play;
	}.fork
)

2.collect{cauchy(2,400)}
////
//Effect(pattern,synthdef) is the same as 
//pattern => Pset(\out,Effect.bus);
//Effect.synth=Synth(synthdef,[\in,Effect.bus,\out,out])
//set method is forwarded to the synth
////

Effect {
	var <>bus, <>synth, <>pattern <>def;
	*new {
		super.new.init(inPattern, inDef, outChan)
	}

	init {
		bus=Bus.audio(s,2);
		pattern=inPattern=>Pset(\out,bus.index);
		def=inDef;
		out.isNil.if({out=Bus.audio(s,2)},{out=outChan})
		^this;
	}

	play {
		Synth(def.asSymbol,[\in,bus.index,\out,out]);
		pattern.play
	}

	//Array or?
	set { |..args|
		synth.set(args)
	}
}

(
	p=[note:[1,2,3].q].p;
	SynthDef(\verbbb,{|in out=0| In.ar(in)=>FreeVerb.ar(_,1,1)=>( Out.ar(out,_) <! DetectSilence.ar(_,doneAction:2) )}).add;
	d=Effect.new(p,\verbbb, out:2, dur:14)
)
e=d.play
e.set(\room,0)
e.free
e
Pfx
d.free
d
d.pattern.play
s.plotTree;d.free;
d.synth
d.bus
d.out
(
	a={|freq|
		LFBrownNoise2.ar(2,add:freq,mul:10)
		=>Saw.ar(_,0.1)=>
		FreeVerb.ar(_,1,1)
		* Env.cutoff(4).kr(2,gate:\gate.kr(1))
		=>Pan2.ar(_,rrand(-1.0,1))
		=>Out.ar(\out.ir(0),_)}
	=>SynthDef(\ttt,_)=>_.add=>_.name
	=>(degree:[1,5,1-7,10].choose,instrument:_,out:[2],dur:10)
	=>Pfin(1,_)
	=>Effect(_,\verbbb,out:2,dur:40)
	//=>(music:_)
	//=> _.play;

	//s.plotTree
)
b=a.play
c=[dur:Pwhite(2,9)+5,dev:Pfunc({a.play})].pp
s.meter
s.meter
c.stop

Pbind
a.pattern.clear;
a.pattern.free
b.free
(
	{
		var pitch=\freq.kr(400);
		Saw.ar(
			LFBrownNoise2.ar(2).range(pitch,pitch+200)
			,0.1)
			* Env.cutoff(6).kr(2,gate:\gate.kr(1))
			=> Out.ar(\out.ir(0),_)
	}=>SynthDef(\aaa,_)=>_.add;
)

(
	//b=Bus.control(s,3);
	b=NodeProxy.control(s,3).fadeTime_(3)
	source={SinOsc.kr(20.reciprocal,(pi!3).rand).range(100,800)};
	a=3.collect{|i|Synth(\aaa,[\out,1,\freq,b.asMap[i]])};
	//a.do{|i x| i.map(\freq,b.index+x)}
)
	[a,b].do(_.release)
	a.release(8)
FunctionList
Function
inject
FunctionDef
(_+1).curried
a={|o p| o+p}.curried
b=a.(9)
b.(8.)
b=(_+_).curried
c=b.(8,9)
[]++1++0
(//sorta musical
	{[]++(Saw.ar(30,0.1).addFunc(Saw.ar(300,0.1)))++MoogFF.ar(_,LFNoise2.kr(2.reciprocal).range(200,1200))=>_.reduce('=>')}.play;
	{[]++(Saw.ar(400,0.1).addFunc(Saw.ar(80,0.1)))++MoogFF.ar(_,LFNoise2.kr(2.reciprocal).range(200,1200))=>_.reduce('=>')}.play
)
reduce


