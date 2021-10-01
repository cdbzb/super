~testLevel = {|i|fork{  rrand(0.5,3).wait;{SinOsc.ar( [9000, 9000  ],0,i) => Mix.ar(_)!2 }.play.dur(5) }};
~testLevel.(0.0015) //L 
~testLevel.(0.0003) //R
~testLevel.(0.01)
s.reboot

(
Window.closeAll;
{ SinOsc.ar( {exprand(1200,18000)}!20 
//* SinOsc.ar(30.reciprocal).exprange(1,12)
,0,0.001 
) 
	=> Mix.ar(_) => Pan2.ar(_,SinOsc.ar(0.5))}.play;
s.meter
)
(note:1).play



{SinOsc.ar(7500,0,0.1)!2}.play
SynthDef(\saw,{Saw.ar(\freq.kr(300),\amp.kr(0.1))* Env.perc(0.05,\release.kr(0.5)).kr(2,gate:\gate.kr(1)) => Pan2.ar(_,\pan.kr(0))=>Out.ar(\out.kr(0)+Rand(0),_)}).add
[instrument:\saw,amp:0.2,out:0,freq: [ Pxrand([7000,8000,6500,9000]*.t[0.5,1],4),Rest(2) ].q(inf),dur:0.4,pan:-1].pp
[instrument:\saw,amp:0.2,pan:Prand([-1,1],inf),out:Effect(FreeVerb.ar(_,0.9,0.9),inputChannels:2).bus.index+Prand([0,1,[0,1]],inf),freq: [ Pxrand([7000,8000,6500,9000]/2,4),Rest(2) ].q(inf),dur:0.4,pan:-1].pp
(
[instrument:\saw,amp:0.2,pan:Prand([-1,1],inf),out:Effect(FreeVerb.ar(_,0.5,0.9),inputChannels:2).bus.index+Prand([0,1,[0,1]],inf),freq: [ Pxrand([6000,7000,8000,6500,9000,10000],6),Rest(2) ].q(inf),dur:0.4,pan:-1].pp;
{In.ar(1)=>{|i| ReplaceOut.ar(1,i*0.2) }}.play(addAction:\addToTail);



)
(
a={
	[
		(dur: 0.2,instrument:\saw,freq:10000,pan:-1,amp:0.3) ,
		(dur: 0.2,instrument:\saw,freq:10000,pan:1,amp:0.1) ,
		(dur: 0.2,instrument:\saw,freq:9000,pan:-1,amp:0.25) ,
		(dur: 0.2,instrument:\saw,freq:9000,pan:1,amp:0.1) ,
		(dur: 0.2,instrument:\saw,freq:6666,pan:-1,amp:0.20) ,
		(dur: 0.2,instrument:\saw,freq:6666,pan:1,amp:0.1) ,
		(dur: 0.2,instrument:\saw,freq:6000,pan:-1,amp:0.17) ,
		(dur: 0.2,instrument:\saw,freq:6000,pan:1,amp:0.1) ,
	].scramble => _.q(3) 
};

fork{
	100.do {
		a.() => Pset(\release,[0.5,0.6,0.7,2].choose,_)=>_.play;
		4.wait;
		a.() => Pmul(\freq,[0.5,1/3, 0.25,1/5 ].choose,_) =>Pmul(\amp,0.3,_) => Pset(\release,[0.5,0.5,2].choose,_)=> _.play;
		4.wait
		
	}
}
)

(
SynthDef(\saw,{Saw.ar(\freq.kr(300),\amp.kr(0.1))* Env.perc(0.05,\release.kr(0.5)).kr(2,gate:\gate.kr(1)) => Pan2.ar(_,\pan.kr(0))=>Out.ar(\out.kr(0)+Rand(0),_)}).add;
s.latency_(0.05);
~notes = 
[
	(dur: 0.2,instrument:\saw,freq:10000,pan:-1,amp:0.3) ,
	(dur: 0.2,instrument:\saw,freq:10000,pan:1,amp:0.1) ,
	(dur: 0.2,instrument:\saw,freq:9000,pan:-1,amp:0.25) ,
	(dur: 0.2,instrument:\saw,freq:9000,pan:1,amp:0.1) ,
	(dur: 0.2,instrument:\saw,freq:6666,pan:-1,amp:0.20) ,
	(dur: 0.2,instrument:\saw,freq:6666,pan:1,amp:0.1) ,
	(dur: 0.2,instrument:\saw,freq:6000,pan:-1,amp:0.17) ,
	(dur: 0.2,instrument:\saw,freq:6000,pan:1,amp:0.1) ,
];
MIDIClient.init;
MIDIIn.connectAll;

	MIDIdef.noteOn(\on, {|vel num| var octave = num/12 =>_.floor; ~notes.wrapAt(num)=>Pmul(\freq,(6-octave).abs.reciprocal,_)=>_.fin(1)=>_.play },  msgNum: nil,  chan: nil,  msgType: nil,  srcID: nil,  argTemplate: nil,  dispatcher: nil)
)

