
(
SynthDef(\noizykey,
{
	Phasor.ar(1,2*pi/SampleRate.ir*(\freq.kr(200)),0.01,(2*pi))
	=>tan(_)
	=>sin(_)
	* 0.01
	=> Mix.ar(_)
	=> LeakDC.ar(_)
	* Env.cutoff(\release.kr(0.01)).kr(2,gate:\gate.kr(1))
	=> LPF.ar(_,3900)
	=> Out.ar(\out.kr(1),_)
	//=>MoogFF.ar(_,800,2)
}
).add
)
(
[ instrument:\noizykey,release:Pwhite(1,4),degree:[ 1,3,5,7 ]+[0,0.01],out:[0,1],dur:10,octave:Pwhite(3,5) ].p.play;
[ instrument:\noizykey,degree:[ 1,3,5,7 ].q(inf),out:[0,1],dur:1,legato:1 ].p.play;
[lag:1.39, instrument:\noizykey,degree:[ 1,3,5,7 ].q(inf),out:[0,1],dur:1,legato:1 ].p.play
)
[instrument:\stringyy,out:[0,1].q(inf),degree:[1,2,4.03,8.03, 6.03,12.20 ].q(12),legato:5].p.play;
s.reboot
(

{
	Phasor.ar(1,2*pi/SampleRate.ir*((2*pi-0.2)/(2*pi))*(\freq.kr(200)),0.1,(2*pi)-0.1)
	//=>{|i|1/tan(i)}
	//=>tan(_)
	=>{|i|1/sin(i)}
	=>Limiter.ar(_,1,0.001)
	//=>OnePole.ar(_)
	* \amp.kr(0.1)
	* Env.cutoff(\release.kr(0.1)).kr(2,gate:\gate.kr(1))
	=> Out.ar(\out.kr(0),_)
}
=>SynthDef(\noizykey2,_)=>_.add
//.plot
//.play(s,1)
)
Synth(\noizykey2,[\out,1])


[ out: {|i|EchoNone.ar(i,0.4,0.2,3)}.asBusNumber([0,1]) ,instrument:\noizykey2,degree:[ 1,3,5,7 ].q(inf),dur:1,legato:1,amp:0.02 ].pp;
(

{
	Phasor.ar(1,2*pi/SampleRate.ir
		//*((2*pi-0.2)/(2*pi))
		* \freq.kr(200),
	//	0.1,
		0,
		(2*pi)
		//-0.1
	)
	//=>{|i|1/tan(i)}
	//=>tan(_)
	=>{|i|sin(i)/tan(SinOsc.kr(2)**i+1)}
	=>sin(_)
	//=>Limiter.ar(_,1,0.001)
	=>LPF.ar(_,1000)
	* 0.1
	* \amp.kr(0.1)
	* Env.cutoff(\release.kr(0.1)).kr(2,gate:\gate.kr(1))
	=> Out.ar(\out.kr(1),_)
}
=>SynthDef(\noizykey3,_)=>_.add;
//.plot
//.play(s,1)
Synth(\noizykey3,[\freq,400])
)
[ out:1,instrument:\noizykey3,degree:[ 1,3,5,7 ].q(inf),dur:1,legato:6,amp:0.1 ].pp;
[ out: EchoNone.ar(_,0.4,0.2,3).asBusNumber([0,1]) ,instrument:\noizykey2,degree:[ 1,3,5,7 ].q(inf),dur:1,legato:1,amp:0.02 ].pp;

(//nice moving pad

{
	Phasor.ar(1,2*pi/SampleRate.ir
		* \freq.kr(200),
		0,
		(2*pi)
	)
	//=>{|i|1/tan(i)}
	//=>tan(_)
	=>{|i|sin(i**2)/tanh(i/LFBrownNoise2.ar(\mod.kr(1)).range(1,8))}
	//=>sin(_)
	//=>Limiter.ar(_,1,0.001)
	=>LPF.ar(_,1000)
	=> LeakDC.ar(_)
	* 0.1
	* \amp.kr(0.1)
	* Env.asr(\attack.kr(1),1,\release.kr(0.1)).kr(2,gate:\gate.kr(1))
	=> Out.ar(\out.kr(1),_)
}
=>SynthDef(\noizykey4,_)=>_.add;
//.plot
//.play(s,1)
Synth(\noizykey3,[\freq,400])
)
[attack:8, degree:[1,3,5,7,9],mod:Prand([1,1,100,1000,1],inf),ctranspose:Prand([2,0,-10,0,4],inf),dur:Pwhite(10,30,inf),instrument:\noizykey4,legato:1.5,out:[0,1],tuning:\just,release:10 ].p.play


( // demand rate sequencing
SynthDef(\dd,{ |tune=#[3,4,5,6,1,1,1]|
	var seq = Dseq(tune,inf)+60+Rand(0,12);
	var len = Dseq(tune++12++0.2=>_.flat=>_.scramble,inf)/10;
	var trig = Impulse.ar(\tempo.kr(2));
	var freq = Demand.ar(trig,0,  demandUGens:[seq,len]);
	Saw.ar(freq[0].midicps,0.1)
	=>tan(_*pi*2)
	*0.1
	* Env.perc(0.1,freq[1]).kr(gate:Impulse.kr(\tempo.kr))
	=> Out.ar(\out.kr(0),_)
}).add;
)
Synth(\dd,[\out:[0,1,[0,1]].choose,\tune,{10.rand}!5,\tempo,5.0.rand]) .mapLfo(\tempo,{SinOsc.kr(0.1.rand).range(1,7)})

~root={|i| i}
)
( //autoharp
	fork{
		150.do{
			[
				[1,3,5,11]   ,
				[1,13,5,21]  ,
				[1,13,15,21] ,
				[1,3,15,21]  ,
				[1,15,23,11] ,
			].choose
			=>_.dm([\d, \a, \g ].choose,octave:4)
			=>(out:[0,1,1,0],instrument:\noizykey,midinote:_,strum:rrand(0.01,0.03))
			=>_.play;
		rrand(0.4,0.6).wait

	}})

	[1,3,5,11]+ [0,[0,10,20].choose!3].flat=>{|i| (instrument:\stringyy,midinote:i.dm([\d, \a,\g ].choose))} =>_.play
	(
		fork{ inf.do{
			10 * 
			[
				([1] ++ [1,2,2].scramble) ,
				([2] ++ [1,2,2].scramble) ,
			].choose
			=>_.postln
			//=> _.flat //octaves
			+ [1,3,5,11]
			=> _.dm([\d,\g, \a ].choose,octave:2)
			=> (release:1,instrument:\noizykey4,midinote:_,out:[0,1],dur:3,legato:1) =>_.play;
			3.wait
		} }
	)

