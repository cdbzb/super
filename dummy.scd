(
~test = Song.new(\dummy,[]).current;
	["r",[1,3,5].dm(\c)].addLine;
	["t",[4,3,4,2,3].dm(\c)].addLine;
	["w",[1,3,5].dm(\d)].addLine;
	["y",[6,5,4,3,2].dm(\d)].addLine;
)
~recorder.(~test,[2,3],2)
~test.pbind.array.q.play

( // cool arcade game swoop
{
	{var register = [1.25,1.5,1.666].choose;
		{
		var a, freq, trig;
		a = Dseq([Dshuf([1, 3, 2, 7, 8.5].df(\e), 3)], inf) * 1.rrand(3);

		trig = XLine.kr(1000,0.1,10) => Impulse.ar(_);
		freq = Demand.ar(trig, 0, a);
		[ Saw,Pulse,LFTri,SinOsc ].choose.ar(freq/register) * 0.01 *.t [[0,1],[1,0],[0.6,0.6]].choose
		* Env.linen(0,5,12).kr(2)
		=> FoaEncode.ar(_,FoaEncoderMatrix.newOmni)
		=> FoaTransform.ar(_, 'push',pi/2,0.rrand(2*pi))
		=> Monitors.ambi(_)

	}.play}.sched([0,1,2,0.5,1,1.1,1,1,1].integrate);
}.sched({15.rand}!8=>_.integrate)
)

( //ambi tremolo!
~www = {|freq=300| { Saw.ar(freq) * Env.perc(attackTime: Rand(0.01,3),  releaseTime: Rand(6.0),  level: 1.0,  curve: -4.0).kr(2,gate:1) => FoaEncode.ar(_,FoaEncoderMatrix.newOmni)=> FoaTransform.ar(_,'push',pi/2-3,SinOsc.ar(Rand(10)))=> 
Monitors.ambi(_) /30
//Monitors.decoder = FoaDecoderMatrix.newStereo
}.play};
)

//a cloud of these please!
fork{30.do{200.rrand(100)=>~www.(_);1.0.rand.wait}}
(
{ var d = Dshuf([1,2,3,4,5],1);
var q = [d].dq(inf);
var freq = Demand.kr(Impulse.kr(3),0,q);
SinOsc.ar(freq*100,0,0.1)
}.play
)
