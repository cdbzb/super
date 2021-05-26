Filter
a={In.ar(\in.kr(8),1)=>FreeVerb.ar(_,1,1)}.play
Phasor
a={\level.ar(0)=>Out.ar(1,_)}.play

[1,3,[5,6,7,8]].melody


(
[T(1,3,5),T(1,4,6),T(1,3,5),T(2,5,7)].melody.pp;
[[[11,21],[11,21],12,13],[14,24,13,12],[11,21,7,6],[5,15,6,7]].melody++[ctranspose:[-36, -24 ],amp:0.2] =>_.p=>Pn(_,2)=>_.play;
)

`-3
[1,3,5,[`-5,4,6]].deepCollect(3,_.value).subdivide.tieDur
[1,3,5,`-5].deepCollect(3,_.value).subdivide.tieDur
[1,3,[-3, 5 ]].subdivide
// only make refs yield negatives - make negtives positive
// i.class=Ref.if{i.value}{i.abs}
[3,[ `-3,4 ],-1,\r].subdivide
[3,[ `-3,4 ],-1,\r].subdivide .collect({|i|i.isNumber.if{i.abs}{i.value}})
.tieDur
//change tiePitch to accomodate refs and symbols
[3,[ `-3,4 ],-1,\r].flat.reject({|i|  i.isNumber or: (i.class==Symbol) => _.not })
[3,[ `-3,4 ],1,[\r,2],3].melody[3].list
(scale:\minor).pp
//or do this with some kind of classes etc
// like Phrase Object wherein Phrase(note, note, note, tied note, rest)  
/// or just leave it as a method of Array?
// the Phrase version is more flexible in that we could choose dif ways of saying it!
(
Environment.new.use {
	[1, [`1,3], `3,5]!3=>_.flatten ++ ([-6,[`-6,1],`1,3]!2=>_.flatten)
	=>{|i|i.asMelody(2).dm(\c,octave:4)}
	++[
		pan:[1,-1].q(inf),
		out:Effect(FreeVerb.ar(_,1,1),inputChannels:2).bus.index,
		tempo:Pwhite(0.7,0.71).reciprocal,
	]
	=>{|i| i.p.play(~t=TempoClock.new)};
	[\r,\r,\r,[1,2],[3,3],[`3,3],[`3,4],[1,2],3,`3,\r,[1,2],[3,3],[`3,3],[`3,4],[1,-7],-6].asMelody(2).dm(\c,octave:5)++[
		instrument:\sparkTriangle
	]
	=>_.pp(~t)
	//.dm(\c)

}
)
(
//Pfset(nil,[note:[1].q(3)].p,{\done.postln}).play
[note:Pwhite(1,3,5),out:Pfunc{}].p=>Pfset({~effect=Effect(FreeVerb.ar(_,1,1))},_,\done.postln)=>_.play
)
SimpleController
EventStreamPlayer
[note:Pwhite(2,3,4)].pp=>{|i|SimpleController(i).put(\stopped,{\stopped.postln})}
a=[note:Pwhite(2,3,4)].pp=>{|i|SimpleController(i).put(\stopped,~monkey)};
~monkey={666.postln}
a=[note:1].p
a.stretch([1, 0.13 ]).play
0.
Pfset
Pbind
Pattern.play.onFree({})
Pfset({~bus=Bus.audio},[note:Pwhite(2,5,4)].p,{~bus.free}).trace.play
Pfset(nil,[bus:Bus.audio(s),note:Pwhite(2,5,4)].p,{~bus.free}).trace.play
[note:1,bus:Bus.audio(s)].p.patternpairs.asEvent.use{ ~bus }
//LIKE THIS
[note:[1,3,5].q(1),cleanup:`{~bus.free},bus:Bus.audio(s)].p=>{|i| i.trace.play=>{|j| SimpleController(j).put(\stopped,{i.patternpairs.asEvent.use{~cleanup.value.value}})}}
Bus.audio(s)
\interface.help
(
[freq:7.dm.q(3),amp:8,cleanup:{~bus.postln},setup:{~bus=9}]
.asAssociations
=>{|i| Pfset(
	i.asDict.at(\setup),
	i.reject({|i|(i.key==\cleanup) or: (i.key==\setup)}).asPairs.p,
	i.asDict.at(\cleanup))
}=>_.play
)

MIDIClient.init
a=MIDIFunc.noteOn({ |vel num chan source| Synth(\default , [\freq,num.midicps,\amp,vel/100]).dur(1)})
MicroKeys.play({|vel num | Synth(\default,[\freq,num.midicps]).dur(2);num.postln})
MicroKeys.play({|vel num | Synth(\default,[\freq,num.
]).dur(2);num.postln})
Scale.major.asMIDINotes
PerformNearest,ioS
Scale.major.tuning_(\just).degreeToFreq(6,440,5)
midinoteTo
a=Scale(\major);a.tuning_(\just)
a=Scale.major(\just)

60.midicps.cpsoct
60 / 12 - 1 => _.floor
60.midiToKey
61 => {|i| [i/12=>_.floor,i%12]}
Scale.chromatic(\valotti)
9.degreeToKey(a)
Tuning.just
a=Scale.chromatic(\just).semitones.collect({|i x|i-x})

(
MicroKeys.play({
	|vel num | 
	var i = num ;
	Synth(\sparkTriangle,[
		\freq,i => MicroKeys.deviation(\pythagorean) 
		=> _.midicps
	]).dur(2);
	i=>MicroKeys.deviation(\pythagorean)=>_.postln})
)
MicroKeys.deviation(\just).(61)

a={ |vel num | var i = num ; Synth(\sparkTriangle,[ \freq,i => MicroKeys.deviation(\pythagorean) => _.midicps ]).dur(2); i=>MicroKeys.deviation(\pythagorean)=>_.postln}

a=Effect(FreeVerb.ar(_,1,1),out:1).bus.index;
MicroKeys.play2({|v n| Synth(\stringyy,[\out,a,\release,0.1,\freq,n.midicps,\amp,v/128])},\vallotti)

a={SinOsc.ar(Phasor.kr(1,\rate.kr(0.0001),0.5,1)*\freq.kr(400),0.1)}.play
a.run(false)
a.set(\rate,-0.0001);
a.set(\rate,0.0001);
a.run(true)
Synth
MIDIdef.new(\micro,{|v n| Synth(\default,[\freq,n.midicps,\amp,v/100])},msgType:\noteOn)

a=MIDIFunc.noteOn({|v n| Synth(\default,[\freq,n.midicps,\amp,v/100])})
a.remove(a.func)
a.prFunc_({|v n| Synth(\stringyy,[\freq,n*50])})
a={|i j|i+1}
a.([[1,2],[3,4]])
a={|a b c d| [a,b+1,c,d]} 
b={| args| args }
c=b<>a
b={|v n| Synth(\default,[\freq,n*5,\amp,v]).dur(2)}
a={|v n| [v/128,n]}
c={|function| {|args| function.valueArray(args) }}
d={|v n| [v,n.odd.if{n+20}{n}]}
MicroKeys.play(c.(b)<>c.(a)<>d)
//take a functino of four variables and return a function of 1 array
a = { |n| { 16.rand } ! n } <> {|x y| rrand(4, 8) }
b = { |x| x.select(_.odd) } <> a;
b.()
(vel:22,num:65)=>{|e|e.vel=e.vel*4}
a={|v n c r| (vel:v,num:n,chan:c,src:r)};
b= {|e| Synth(\default,[\freq,e.num/2=>_.midicps*3,\amp,e.vel/200]).dur(e.vel/100)}
c={|e|e.num.odd.if{e.vel=0};e}
MicroKeys.play(b<>c<>a)

MicroKeys.play3({|e|Synth([\stringyy, \default ].choose,[\freq,e.num*20,\amp,e.vel/100]).dur(7.rand)},\partch)
    MIDIIn.doNoteOnAction(1, 1, rrand(10,60), 68.rand); // spoof a note on

