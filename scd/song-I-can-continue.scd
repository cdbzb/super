s.boot;

t=TempoClock.new(1);
(
~bassline=Pbind(*[
	degree:(Pseq([8,8,7,7,6])-1),
	dur: Pseq.new(([3,1,3,1,3])/4)++1,
	octave:3,
	tempo:0.8
]);
//~bassline.play(t)



~tune= Pbind(*[
	degree:Pseq([\r,3,1,3,2,0,1,2,1,5-7])-1,
	dur:Pseq([1/4],8)++(Pseq([1/2,1/4])*4/4),
	octave:6
]);
//~tune.play(t);


Ppar([~tune,~bassline]).play
)

(
~tune2= Pbind(*[
	degree:Pseq([\r,8,7,6,6,5])-1,
	dur:Pseq([1/4],4)++(Pseq([2,1])/2/2),
	octave:5
]);


~bass2= Pbind(*[
	degree:Pseq([4, 8]),
	dur:Pseq([2,3/2])/2,
	octave:3
]);


Ppar([~tune2,~bass2]).play(t)


	Pseq([
		Ppar([~tune,~bassline]),
		Ppar([~tune2,~bass2])
	]).play(t)
)
