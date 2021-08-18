//[Laboratory]
(
Song(\thousand,[]).current;
["(Thalassa is looking at her reflection in a metallic surface) (Scott comes in with a small doo-dad.)","r",[ 5,1 ]].addLine;
P(\reflection,start:\reflection,music:{|p b e|
	{
		var line = LFBrownNoise1.kr(LFBrownNoise1.kr((3..6)/4.5).range(13,16)).range(700,900);
		([line,1200-line]*.x ( (11..14) / 12 ))//.postln
		.collect{|i|
			SinOsc.ar(i) 
			=> CombC.ar(_,3,SinOsc.ar(0.1).range(1,3),15)
			=> CombC.ar(_,3,SinOsc.ar(0.1.rand).range(0.1,3),15)
		} => Splay.ar(_)
		=> FreeVerb.ar(_,0.8,0.5)
		
		*0.1
		*Env([0,0,1,1,0],[4,7,5,8]).kr(gate:1,doneAction:2)
	}.play(s,0)
});
["/*MULHALL:*/ Thank you. Have you prepared the negaton hydracoils for the drawing Sargon supplied?","r"].addLine;
["/*SCOTT:*/ For all the good it'll do you. It's a fancy name, but","r"].addLine;
["how will something that looks like a drop of jelly make this thing work?","r"].addLine;
["You'll need microgears and a","r"].addLine;
["pulley that does what a muscle does.","r"].addLine;
["/*MULHALL:*/ That would be highly inefficient.","r"].addLine;
["/*SCOTT:*/ I tell you, lady, this thing won't work.","r"].addLine;
["/*SPOCK:*/ It will have twice the strength and agility of",[2,3,1].dm(\c)++[3,1].dm(\e)++[-7,1,2].dm(\f,scale:\mixolydian)++[3,5,4,3,4,2,1].dm(\g)].addLine;
P.tune(\twice);
["your body, engineer, and it will",[11,12,11,7,6,5,4,5,6, 3,4,5].dm('c#',scale:\mixolydian)].addLine;
Song.quarters[\engineer]=Song.parseBeats(\engineer,[3,1,2,4,2,2,1,1,2,2,2,2]/4);
P(\bass,start:\engineer,music:{
	[
		freq:[1,-7,-4,-3,-4,-5].df('c#',scale:\mixolydian,octave:4).q,
		dur:[2,2,0.5,0.5,0.5,0.5].q
	].p.play(Song.quarters[\engineer].asTempoClock)
});
P.tune(\engineer);
["last a thousand years.",[2,1,2,3,1,2, 5.5].dm(\c,octave:6)].addLine;
Song.quarters['last a thousand']=Song.parseBeats('last a thousand',[1.5,0.5,0.5,0.5,0.5,0.5,1]);
P.tune(\last);
P(\chord,start:'last a thousand',music:{
	[
		freq: [[1,3,5,7].df('b-'),[5,7,11,13].df('e',octave:5,scale:\mixolydian)].q,
		freqLag:1.5,
		instrument: \stringyy,
		dur:Song.parse('last a thousand',[6,1]) + [-0.2,0.5] =>_.q
	].pm(\stringyy).play
});
P(\bass,start:'last a thousand',music:{
	[
		instrument:\sawSynth,
		midinote:[1,-7,-6,4.5].dm('b-',octave:[2, 3 ]).q,
		dur:[1,1,2,1].q,
	].p.play(Song.quarters['last a thousand'].asTempoClock)
})
["That is, assuming you'll stop wasting your time and allow us to complete it.","r"].addLine;
["(Scott leaves as 'Spock' laughs.)","r"].addLine;
["/*SPOCK:*/ (boom) A thousand-year prison, Thalassa.","r"].addLine;
["And when it wears out we'll build another one, and we'll","r"].addLine;
["lock ourselves into it for another thousand years. And another, and another.","r"].addLine;
["Sargon has closed his mind to a better way.","r"].addLine;
["(boom) With these bodies. (la la la la la la with these bodies)","r"].addLine;
["/*MULHALL:*/ They're not ours, Henoch.","r"].addLine;
["/*SPOCK:*/ When you awoke in this body, Thalassa,","r"].addLine;
["you said how good it was to breathe again,","r"].addLine;
["to have eyes and to see* again*. To feel.","r"].addLine;
["To live and feel again, Thalassa.","r"].addLine;
["Just think how much we can do for mankind.","r"].addLine;
["Are these bodies too much to ask for in return? /*(Would you prefer this? )*/ ","r"].addLine;
// ["/*MULHALL:*/ No. I'm beginning to hate it.","r"].addLine;
["(She rushes out, and 'Spock' smirks.)","r"].addLine;
)
