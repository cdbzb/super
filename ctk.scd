(
a = CtkSynthDef(\noise, {|amp = 0.5| Dust.ar(20) * amp => Out.ar(1,_)});
b=a.note;
b.play
)
b.free
(
~score=CtkScore();
c=CtkProtoNotes(
	SynthDef(\dust,{
		| amp 0.5 |
		Dust.ar(20) * amp 
		* Env.cutoff(5).kr(2,gate:\gate.kr(1))
		=> Out.ar(1,_)
	});
);
c.add(SynthDef(\verb,{
	| in = 8 |
	In.ar(in) 
	=> FreeVerb.ar(_,0.9,0.9)
	=> Out.ar(1,_)
}));
~verb = c[\verb].note.addTo(~score);
~verb.play;
r=[1,3,6,9,12].q.asStream;
b=c[\dust].note(r.next,duration:0.5,target:/*~verb*/1).addTo(~score);
b.play; 
{b.release(3)}.sched(0.1)
)
)
~score.play
r.next
Synth

(
SynthDef(
\breath , {|len=5 freq=333 out=1| Saw.ar(freq,0.1)

*Env.triangle(len).kr(2,gate:\gate.kr(1))


=> Out.ar(out,_)
}
).add;
//Synth(\breath,[\freq,500]); 
[
	degree:Pclump(3,Prand(( 1..19 ),inf)),
	instrument:\breath,
	tempo:Pseg([1,2].reciprocal,50),
	len:5,
	mtranspose:Pseq([0,-5],inf),
	//dur:2.5 * [2,3].q(inf)/5 + Pseg([1,2.5], /*slow*/40),
	dur:4 
	// * [2,3].q(inf)/5 + 
	//legato:2,
].pp
)


