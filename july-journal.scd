(
~osc = 0.03;
[10, 100, 100].do { |top|
	~osc = SinOsc.ar(~osc).range(1, top);
};
//{osc}.play
)
{ SinOsc.ar(~osc+400) }.play
(note:1).play

{TempoClock.beatInBar}.vcalue
(// illusion !!
a = {
	// Exponentially-spaced steps
	// 300, 300 * 1.00277, 300 * (1.00277^2), 300 * (1.00277^3) etc.
	var sig = SinOsc.ar((4 ** Array.series(200, 0, 0.02)) * 300).sum;
	(sig * 0.02).dup
}.play;
)

(
a = {
	// Exponentially-spaced steps
	// 300, 300 * 1.00277, 300 * (1.00277^2), 300 * (1.00277^3) etc.
	var sig = SinOsc.ar((4 ** Array.series(200, 0, 0.002)) * 300).sum;
	(sig * 0.02).dup
}.play;
)

(
{var t = Impulse.ar(freq: 0.1, phase: 0)
;var sinosc = {arg freq; (Phasor.ar(trig: t, rate: (freq * SampleDur.ir), start: 0, end: 1, resetPos: 0) * 2 * pi).sin}
;var k = 160
;var b = TRand.ar(lo: 2, hi: 2.25, trig: t)
;var n = TRand.ar(lo: 0.002, hi: 0.02, trig: t)
;var f0 = TRand.ar(lo: 90, hi: 180, trig: t)
;var fMul = b ** Array.series(size: k, start: 0, step: n)
;var e = EnvGen.ar(envelope: Env.perc(attackTime: 1, releaseTime: 10, level: 0.1), gate: t)
;Splay.ar(sinosc.value(f0 * fMul), spread: 1, level: e, center: 0, levelComp: true)}.play
)

(
a=[2,2.1,1.6,2,4] ;
b = a 
=> {|i| [i.dropLast , i.last.bubble]}
=> _.collect({|i| i.quantizeWindow(2)})
=> _.flat;
[dur:a.q / 2,note:Prand([1,[12,15]],inf)].pp;[dur:b.q / 2,note:Prand([4,6,8],inf)].pp
)

[1,2,3,4,5].reshape(3,4)
'J concepts'.help
{|i j| i ++ j} ! [2,3,4]
[1,2,3].slice(0,1)
