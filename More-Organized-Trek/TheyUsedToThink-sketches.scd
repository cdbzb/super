(
	~tu=Song(\theyUsed,[
		"they used to think if man could ","f3 f g g a a b ", //0
		"fly, he`d have wings, but he","b3 a g c#4 b3 c#4", //1
		"did fly (boom boom)", "e4 d a3 f#", //2
		"(boom) he discovered he ","c d4 c b3 a b",//3
		'had to.. do you wish that the first',"r r",//4
		'Apollo mission hadn`t reached the',"r r",//5
		'moon... or that we hadnt gone on to Mars ',"r r",//8"
		'and then to the nearest',"r r",//7"
		'star (boom boom) thats like saying you ',"r r",//9"
	]).setupDurs;


//	~recorder.(~tu,3,1)
//	~tu.save;

	SynthDef( \sawzz,//{{{
		{Saw.ar(\freq.kr(400,0.5),0.1)
		* Env.asr(0.1,1,2).kr(2,gate:\gate.kr(1))
		* \amp.kr(0.1)
		=>(CombN.ar(_,1)+Gain.ar(_,3))
		=>Out.ar(1,_)}
	).add;
//}}}
~tu.resources=();
~tu.boom=(start:2,syl:1,lag:0,music://{{{
	{{
		var notes = [11,6,3].degreescps;
		var durs = [0]++(~tu.durs[2].list[2..3]).integrate;// + ~tu.durs[2].list[2] ;
		var a;
		{a=Synth(\sawzz,[\freq,notes[0],\amp,0.1]).dur(4)}.sched(durs[0]+s.latency);
		[1,2].do{|i| {a.set(\freq,notes[i])}.sched(durs[i]+s.latency)}
	}.play}
);//}}}

~durToTime={|collection| 
	([0]++collection).integrate
};

~tu.addGuides("xxx");
~tu.boomBass=Part(3,music:(note:0,octave:3,amp:0.2,dur:~tu.secDur(3)));
//~tu.pbind[2].play
~tu.cursor_(2).play;
)
(
	~im=Song(\ImInControl,[ //{{{
		"I'm (boom) in (boom) con-","g4 a-3 g4 a-3  f4",//0
		"trol, I can order this (boom) but I'm","f4 e- f g- f d- f#3 c4 d- ",//1
		"not","e", //2
	]).setupDurs;//}}}
)
~recorder.(~im,1,1)
~im.save;

Item(\testVoc).record
Item(\testVoc2).stop
Item(\testVoc).play
Item(\testVoctrash).node.isRecording
Item(\testVoctrash).arm
a=Item(\testVoctrash)
a.record
a.stop
a.node.isRecording
a.node
a.arm
a.armed
~im.voc1.music.value
Item(\testVoc).buffer.plot
a=Item(\testVoc)
a.play
b=Buffer.read(s,a.mostRecent)
{PlayBuf.ar(1,b.bufnum)}.play
b
a.mostRecent
a.play
a.mostRecent
~f={|a b| a ** b}
{|...args| ~f.valueArray(args)}.value(2,2)

//Item(\testVoc2).current

//Item.arm

//then play the song (Song.play)
//TODO throw away most recent aaaaand...
//prune (crop take)
//do zz to stop

//Idea: "Item.newFrom(\otherItem)"
//Idea: "Item/cloneAllActive(new-directory) -- sets Item.sampleDir"

(// cool yodel trio (3 speaks){{{
	{{Item(\order).playbuf(rate:5)=>FreeVerb.ar(_,1,0.8)*rrand(2.0,3)}.play(s,1)}.sched(( [1,2,4]+ .x Array.series(4,-1,3) ).flatten);
	{{Item(\order).playbuf(rate:2)=>FreeVerb1.ar(_,2)}.play(s,2)}.sched(([3,5,1]-1 + .x Array.series(3,0,4)).flatten);
	{{Item(\order).playbuf(rate:3)=>FreeVerb1.ar(_,1)}.play(s,3)}.sched(([2,3,1]/2 + .x Array.series(5,0,2.5)).flatten)
)//}}}
1
s.reboo
a={ var sig= Env.asr(4,1,9).kr(2,gate:\gate.kr(1))* Saw.ar(\freq.kr(400,1)!5+Gendy3.kr(1!5).range(0,1),rrand(0.1!5,0.2))=>Splay.ar(_);sig+FreeVerb2.ar(sig[0],sig[1],4)}.play(s,2)
a.set(\freq,240/2)


Item(\order3).current;
Item.record
Item.stop;
Item.play
Item(\order).play(s,1)
a=Item.play(s,bus:1);
a=Item(\order).play(s,1)
a.set(\out,1)
a.set(\out,2)
Item(\order).play(s,1)
Item.arm
~im.voc2.play
~im.voc3.play
Item.play(s,1)
l
( // ~im parts
	~im.current;//{{{
	 ~im.resources=();
//Item(\testVoc2).arm;
	//~im.voc2=Part(0,music:{{Item(\testVoc2).recIfArmed(s,0)}.value});
	//~im.voc1slwww=Part(0,music:{{Item(\testVoc).recIfArmed(s,0,0.5)}.value});
	~im.voc1=Part(0,music:{{Item(\testVoc).recIfArmed(s,1)}.value});
	//~im.vocdelay=Part(0,1,music:{{Item(\testVoc).recIfArmed(s,2)}.value});
	~im.voc2=Part(1,0,0,{{Item(\order).recIfArmed(s,1)}.value});
	~im.voc3=Part(1,0,0,{{Item(\order2).recIfArmed(s,1)}.value});
	~im.voc4=Part(1,0,0,{{Item(\order3).recIfArmed(s,2)}.value});
	 //~im.chords.play
	 ~im.chords=(start:0,//lag:s.latency,{{{
		 music:{
			 var chords={|af df| [af,af,df,df]}.([1,3,5,7],[1,3,4,6]);
			 var drs=([0]++~im.durs[0].list).integrate;
			 var evens=[0,2,4].collect(drs[_])++~im.secDur[0];
			 var odds=[1,3,4].collect(drs[_])++ (~im.secDur[0] 
			 //+ ([0]++~im.parse(1,[1!6,1!3])).integrate
			 + ([0]++~im.parse(1,[1!3,1!6])).integrate
			 ;
		 );
				 //freq time lag
			 var bassnotes=[[1,1,4,4,6.5,6],odds,0!5++[0.03]].flop;
			 //2**(1/2)**(-1)

			 {
				 chords.do({|i x| 
					 {Synths(\default,\freq,i.degreescps(root:-4),\amp,0.05).dur(1.5)}
					 .schedL(evens[x])
				 });
				 bassnotes.do({|i| 
					 {Synth(\default,[\freq,[i[0]].degreescps(root:-4,octave:3),\amp,0.7]).dur(2)}
					 .schedL(i[1]+i[2])
				 })
			 }.value
		 }
	 );
	 //~im.chords.play
//}}}
	 ~im.chordBass=( start:0,syl:4,//{{{
		 music:{}
	 );//}}}
//1
	SynthDef(\argybargy,{|freq=400 width=10 out=1| //{{{
		Gendy1.ar(minfreq:freq-width,maxfreq:freq+width)
		=>( CombN.ar(_,0.4,0.11,2)+Gain.ar(_,0 ) )
		* Env.asr(0.05,1,\rel.kr(1.5)).kr(2,gate:\gate.kr(1))
		* \amp.kr(0.1)
		=>Out.ar(out,_)
	}).add;
//}}}
	~im.order1=(start:1,syl:2,music:{|p d| //{{{
		[
			amp:0.03,
			out:1,
			instrument:\argybargy,
			legato:Pseries(3.5,-0.4,inf),
			midinote:(p.tune[1].list[3..6]).q,
			dur:Pfin(4,d.q)
		].pp
	});
//}}}
	 SynthDef(\sawzz,{|out=0| //{{{
		 Saw.ar(\freq.kr(400,0.5)+Rand(4.0!3),\amp.kr(0.1))
		 =>MoogFF.ar(_,\cutoff.kr(800,\fLag.kr(1)),\res.kr(3))
		 * Env.asr(\att.kr(0.2),1,3).kr(2,gate:\gate.kr(1))
		 => Splay.ar(_)
		 =>Out.ar(out,_)
	 }).add;
//}}}
~im.boom1=Part(1,5,music:(//{{{
	out:0,
	att:0.9,
	\cutoff:2222,
	res:1.6,
	instrument:\sawzz,
	amp:0.5,
	degree:0,
	root:6,
	dur:1,
	octave:[4,3],
	amp:0.3)
);//}}}
//2
~im.harpy2=Part(2,music://{{{
	{|p m| p.postln;
		{
			var b={var c = Bus.audio(s,1); {In.ar(c,1)+CombL.ar(In.ar(c,1),1,\del.kr(0.5)+SinOsc.kr(0.1,pi,0.02),6)}.play(s,1);c}.value;
			[
				degree:Prand(Arpeggio([1,3,5,7],9),23)-1,
				amp:0.03,
				root:5,
				out:b.index,
				octave:5,
				dur:Pwhite(0.02,0.03)*3,
				legato:5
			].pp
		}.value
	}
);

//}}}
	 ~im.addGuides("xxx");
	 ~im.waaah2= (start:2, lag:(-0.30), music:{//{{{
		 {
			 Synths(\sawzz,\out,1,\cutoff,1600,\freq,[(1-13),(6-13),1,3,5,7].degreescps(root:5,octave:4)).dur(6)
			 .map(\cutoff,{
				 var b = Bus.control(s);
				 {Env([0000,1400,600],[1,2,3]).kr(2,gate:1)=>Out.kr(b.index,_)}.play;
				 b
			 }.value);
		 }.value
	 };
 );
//}}}
//~im.cursor_(0).play;}}}
)

//try this instead
(
	fork{//{{{  stringyyy !!!
		b={var b=Bus.audio; 
			//vintage.... 
			//{MoogFF.ar(In.ar(b,2),1900*LFBrownNoise2.kr(0.2).range(0.7,1.1),3)}.play(s,0);b}.value;
			//or vocal   !
			{DynKlank.ar(
				Vowel(\u,\bass).blend( Vowel(\a,\bass),
				LFBrownNoise2.kr(0.4).range(0,1)
			) .asKlankRef( [1].degreescps(root:5,octave:3),13,ring:1),
			In.ar(b,2)*0.1
			)}.play(s,1);b
		}.value;

		s.sync;
		a=Synths(\stringyy,\freq,[1,3,5,7].degreescps,\out,b.index);
	};
	{
		a.set(\freq,[1,3,5,6].degreescps(root:(0..-2).choose)) 
	}.sched( 5.collect({50.0.rand} );
	)//}}}
)
// also TODO - formant filter for this
//vimgrep stringyy * -> make a lookup script!!
(
  ~im.waaah3.play
)
(
	{
		[freq:[1,2,3,[9,9.1].choose],dur:[5,2,2,[0.1,8].choose]].flopEvents.do{|i|
			{Synth(\default,[\pan,rrand(-1,1.0),\freq,[i.freq].degreescps(octave:[4,7,8].choose,root:[1,1.1,3,6].choose)]).dur(i.dur)}.sched(3.0.rand)}
	}.sched(all {:x,x<-(1..50),x.isPrime})
)//}}}



~im.current;

Song.current=Song.theyUsed
<Left>
Song
Song.play
Song.new()
SinOsc.ar()
Item.samplesDir
a=Item()
a.arm
a.record
a.stop
a.play
b=Item(\item)
(// cool wibbling{{{
	[0.5,1,4,5].do( {|i| 
		{
			PlayBuf.ar(1,Item(\item).buffer.bufnum,rate:i,loop:1)
			=> Pan2.ar(_,SinOsc.ar([0.2,1,3].choose))
		}.play(s,8)
	});
	{a=In.ar(8,2);
	b=FreeVerb2.ar(a[0],a[1],0.5,0.7);
	DetectSilence.ar(b,doneAction:2);
	b
}
	.play(s,1,addAction:\addToTail);s.plotTree
)//}}}

//TODO rename ite
{PlayBuf.ar(1,Item(\item).buffer.bufnum,rate:0.11)}.play
s.plotTree
a.name
