(//  Song(\theyUsed) {{{
	~tu=Song(\theyUsed,[
		"they used to think if man could ","f3 f g g a a b ", //0
		"fly, he`d have wings, but he","b3 a g c#4 b3 c#4", //1
		"did fly (boom boom)", "e4 d a3 f#", //2
		"(boom) he discovered he ","c d4 c b3 a b",//3
		'had to.. do you wish that the first',"c5 b4 g#4 e b g# a b",//4
		'Apollo mission hadn`t reached the',"c#5 f# c# e d# b-4 a- b c5",//5
		'moon... or that we hadnt  ',"c#5 b4 a g a b  ",//6
		'gone on to' , "d5 e- b4", //7
		'Mars, and then to the nearest',"a5 g5 g e f g e",//8
		'star (boom boom) thats like saying you ',"b5",//9
	]).setupDurs;

	~monCord="e- f a c#" => ~panNotes.(_);


	~recorder.(~tu,6,1);
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
)//}}}

( //{{{
	\test.postln;
	~im=Song(\ImInControl,[ //{{{
		"I'm (boom) in (boom) con-","g4 a-3 g4 a-3  f4",//0
		"trol, I can order this (boom) but I'm","f4 e- f g- f d- f#3 c4 d- ",//1
		"not be- cause","e d c", //2
		"Doctor McCoy (boom) is ", "g#3 a f# g# f#2 g#3", //3
		"(boom) right in pointing out (boom) the e-nor--","c#3 c#4 d# c# c b-3 d#2 c4 a3 a-", //4
		"-mous da-(__) -nger potential in any","f4 c# b3 f#4 d# a-3 b a# g# a# b",//5
		"(boom) (boom) con-- tact with ","c2 c2 c4 c4 d",//6
		"life and intelligence so fan-","g4 d g f# e d e f#",//7
		"(trill) --tas --tic --ly ad-- va -- --nced as","e3 g#4 f# e d b- c5 b-4 a ",//8
		"this, but I must point out that the possi","b-4 a g# a b d f# g# a b",//9
		"-bilities,the potential, for knowledge and ad-","c#5 a4 e a c#5 d b4 d5 d b4 e5 d",//10/
		"vancement is equally great... ","c#5 b4 g# a c#5 d e g f# e d ",//11
		" (rest) risk, risk is our business (ba -- by)","c3 c5 c c c c# g#4 f# e", //12
		" (boom) thats what a starship is all a-" , "g3 f4 g a d5 c b4 c5 d ",//13
		"bout,that`s (boom) why we`re a- board her","f#4 g5 f4 f5 e d  c b4", //14
		//~recorder.(~im2,13,1)
		"(boom) you can diss-- e-- -- --nt without","c3 b-3 c4 d e f e d e ", //15
		"prejudice (boom) do I","d4 c a3 a2 a3 b", //16
		"hear a negative voice?","c#4 d b3 g e e4", //17
		"engineer stand by to be aboard three receptacles","d4 c# d d5 c# g4 f# e g f# e c# d" //18
	]).setupDurs;//}}}
		//~recorder.(~im2,18,1);

 //~im2.pbind[15..18].q.play;
// ~recorder.(~im2,10,1)
//{{{
 // ~im parts
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
			 //~durations=~im2.durs[13].list
			 //~durations
			 //~im2.pbind[12].play
			 //~recorder.(~im2,14,1)
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
		 Saw.ar(\freq.kr(400,0.5)+Rand(-4,4.0!3),\amp.kr(0.1))
		 //Saw.ar(\freq.kr(400,0.5)+Rand(4.0!3),\amp.kr(0.1))
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
			 Synths(\sawzz,\out,1,\cutoff,1600,\freq,[(1-13),(6-13),1,3,5,7].degreescps(root:5,octave:4)).dur(5)
			 .map(\cutoff,{
				 var b = Bus.control(s);
				 //{Env([0000,1400,600],[1,2,3]).kr(2,gate:1)=>Out.kr(b.index,_)}.play;
				 {Env([0000,1400,600],[1,0,2]).kr(2,gate:1)=>Out.kr(b.index,_)}.play;
				 b
			 }.value);
		 }.value
	 };
 );
//}}}
//~im.cursor_(0).play;}}}
 // version with alternate first line{{{

	~im2=Song((~im.key++2).asSymbol,~im.song).setupDurs;
	//~im2.durs=~im.durs; // do this first time only!!
	~im2.current; ~im2.resources=();
	~line={|song line| song.song[line*2..line*2+1]};
	~putLine = {|song num line| (num*2+[0,1]).do{|i| song.song.put(i,line[i])}};
	~line.(~im2,0); //-> [ I'm (boom) in (boom) con-, g4 a-3 g4 a-3  f4 ]
	~putLine.(~im2,0,_).( ['(boom) Im (boom) in (boom) con',"a-3 a-4 a-3 a-4 a-3 a-4"]);
	(~im2.song.size/2) .do({|i|~line.(~im2,i.asInteger).postln});

	~bassnotes0=~im2.parse(0,[[1,1],[1,1],[1,1]])++~im2.parse(1,[1]);
	~chords0=~im2.parse(0,[[1,1],[1,1],1],1) ++~im2.parse(1,[1]);

	~im2.bassnotes0=(start:0,music: [amp:0.7,instrument:\default,dur:~bassnotes0.q,legato:[1,1,1,2].q,degree:[0,0,0,3].q,root:-4,octave:[3]].p);
	~im2.chords0=(start:0,syl:0,music:[amp:0.05,legato:[1,1,1,2].q,degree:[1,3,5,7]-1,root:-4,dur:~chords0.q].p);

	all {:x,
		x<-~im.resources.keys, var y=~im.resources.at(x),
		x.asString.contains("voc").not, //mute vocals
		y.class==Part, y.start>=1,
		::	y.parent=~im2;
			~im2.resources.add(x->y);
			x.postln
		};
		
		SynthDef(\pulseBass,{ //{{{
			Pulse.ar(\freq.kr(400,0.3),0.3)=>Mix.ar(_)//=>MoogLadder.ar(_,800,1)//=>MoogFF.ar(_,1900,0.5) 
			//=>CombN.ar(_)//++Gain.ar(_)
			//=>FreeVerb.ar(_,1,1)
			* Env.adsr(0.01,0.05,0.6,\rel.kr(0.5)).kr(0,gate:\gate.kr(0)) 
			* \amp.kr(0.03)
			=>RLPF.ar(_,\freq.kr*62,2)
			=>Out.ar(\out.kr(1),_)
		}).add;
//}}}

		~im2.drMcoyBass3=(start:3,music:{fork{
			//~im2.pbind[3].play;
			a=Synth(\pulseBass,[freq:40,gate:0,amp:0.1]);
			b=~im2.durs[3].asStream;
			s.latency.wait;
			a.set(*[freq:[2].degreescps(root:6,octave:2),gate:1]).dur(0.4); b.nextN(2).sum.wait;
			a.set(*[freq:[1].degreescps(root:6,octave:2),gate:1]); b.next.wait;
			a.set(*[freq:[2].degreescps(root:6,octave:2)]).dur(0.3); b.next.wait;
			a.set(*[freq:[1].degreescps(root:6,octave:2),gate:1]).dur(0.2); (b.nextN(2).sum-0.1).wait;
			a.set(*[freq:[5].degreescps(root:6,octave:1),gate:1]).dur(2);
			//a.set(*[freq:[9].degreescps(root:6,octave:2)]).dur(0.3);
		}});//}}}
//}}}


		~im2.drMcoyBass3=(start:3,music:{fork{
			//~im2.pbind[3].play;
			a=Synth(\pulseBass,[freq:40,gate:0,amp:0.1]);
			b=~im2.durs[3].asStream;
			s.latency.wait;
			a.set(*[freq:[2].degreescps(root:6,octave:2),gate:1]).dur(0.4); b.nextN(2).sum.wait;
			a.set(*[freq:[1].degreescps(root:6,octave:2),gate:1]); b.next.wait;
			a.set(*[freq:[2].degreescps(root:6,octave:2)]).dur(0.3); b.next.wait;
			a.set(*[freq:[1].degreescps(root:6,octave:2),gate:1]).dur(0.2); (b.nextN(2).sum-0.1).wait;
			a.set(*[freq:[5].degreescps(root:6,octave:1),gate:1]).dur(2);
			//a.set(*[freq:[9].degreescps(root:6,octave:2)]).dur(0.3);
		}});//}}}
//}}}
		//~im2.keys3=(start:4,syl:1,music:{Synths(\sawzz,\att,1.5,\freq,[1,3,5,8].degreescps(root:1,scale:\minor)).dur(3) });
		~im2.keysLow4=(start:4,syl:1,music:{Synth(\sawzz,[\freq,[1].degreescps(octave:4,root:1,scale:\major)]).dur(3)});

///// 4 /////{{{
~im2.bass4=(start:4,music:[octave:[3,4], note:[1,0,4,3].q, dur:~im2.parse(4,[1,[1,1],[1,1,1],1]).q ].p);
~im2.lowBass4=(start:4,music:{
	var a = Synths(\portBass,\amp,0.02,\freq,[1,11].degreescps(octave:2,root:1)).dur(2);
	{a.set(\freq,[1,11].degreescps(octave:2))}.sched(~im2.durs[4].list[0]+0.1)
});//}}}
///// 5 /////{{{
~im2.bass5=(start:5,music:(octave:[3,4]-1,note:5,dur:2));
~im2.bass5ii=(start:5,syl:2,music:(octave:[3,4],note:-3,dur:2));
~im2.bass5iii=(start:5,syl:5,music:(amp:0.2,octave:[3,4],note:-6,dur:2));

//[\key,[\bass5,\bass5ii,\bass5iii],\start,5,\syl,[0,2,5],\music,[(octave:[3,4]-1,note:5,dur:2),(octave:[3,4],note:-3,dur:2),(amp:0.2,octave:[3,4],note:-6,dur:2) ]].flopEvents

~im2.guide5= (start:5,music:Pbindf(~im2.pbind[5],\ctranspose,12,\amp,[0.15,0.05].q(inf)));
~im2.chord5=(start:5,music:(strum:0.03,amp:0.1,degree:[0,2,7,9],octave:4,root:5,dur:1,scale:Scale.minor));
~im2.lowBass5=(start:5,music:(instrument:\sawzz,amp:0.3,note:5,octave:[2,3]));
//~im2.lowBass4=(start:4,music:{var a = (instrument:\sawzz,amp:0.3,note:0,octave:[2,3])});
~im2.passing5=(start:5,music:[instrument:\tri,out:1,octave:[5,4],note:[0,1,2,3].q,dur:~im2.parse(5,[1,1,1,[1,1,1]]).q].p);
~im2.passing5b =(start:5,music://{{{
	[
		out:0,
	instrument:\tri,
	amp:0.2,
	octave:[5],
	note:[Rest(),1,-1,-3].q,
	dur:~im2.parse(5,[1,1,1,[1,1,1]]).q
].p
);//}}}
~im2.chord5II =(start:5,syl:5,music:(out:0,instrument:\tri,note:[6,11,13],dur:1));
~im2.chord5III =(start:5,syl:2,music:(out:1,instrument:\tri,note:[3,6,9],dur:1));//}}}
///// 6 /////{{{
~im2.bompbomp6=(start:6,music://{{{
	[
		amp:0.3,
		instrument:\pulseBBass2,
		note:[0,0,Rest(),2].q,amp:0.3,
		octave:3,
		dur:~im2.parse(6,[1,1,[1,1/2],[1/2,1]]).q
	].p
	);//}}}
~im2.snares6=(start:6,music: [//{{{
	instrument:\snare,
	dur:[~im2.durs[6].list.sum/4].q(4)].p
);//}}}
// drums6
~im2.snares6=(start:6,music: [instrument:[\snare,\snare,Rest(),Rest()].q,dur:~im2.parse(6,[1,1,[1,1/2],[1/2,1]]).q].p);
~im2.contactBeep=(start:6,music:[//{{{
	octave:8,
	dur:
	~im2.parse(6,[2/3,2/3,1/4,1/2])
	.q
].p);//}}}
//~im2.hat6=(start:6,music: [instrument:\hihat,pan:0.5,dur:~im2.durs[6].list[0..1].sum/4,degree:Pseq([0],8)].p);
~im2.slide6=(start:6,syl:2,lag:0.2,music:[amp:0.02,root:4,degree:Pseries(30,-1,38),dur:Pwhite(0.01,0.012)*1.85,instrument:\mda,vel:60].p);
~im2.slide6echo=(start:6,syl:2,lag:0.55,music:[amp:0.005,root:4,degree:Pseries(30,-1,38),dur:Pwhite(0.01,0.012)*1.85,instrument:\mda,vel:60].p);//}}}
///// 7 /////{{{
~im2.crash7=(start:7,music:(instrument:\cymbalsDS,dur:5,amp:0.02));
~im2.keys7=(start:7 ,music://{{{
	[
		freq:[[3,11],5,[3,11],[2,7],5,[2,7]].degreescps(root:7).q,
		dur: ~im2.parse(7,[1,1,1,[1,1],[1,1/2],[1/2,1]]).q
	].p
);//}}}
~im2.bass7=(start:7,music://{{{
	[
		instrument:\pulseBBass2,
		amp:0.3,
		degree:[1,1,5,5].q-1,
		octave:[3,4],
		root:7,
		dur:~im2.parse(7,[[1,1],1,[1,1,1,1/2],[1/2,1]]).q
	].p
); //}}}
//}}}
///// 8 ///// {{{
~im2.kltrill8=	(start:8,music:{{StkClarinet.ar(441/480*[1,3].degreescps(root:4,octave:5)*Pulse.kr(LFBrownNoise2.kr([0.5,0.51],mul:0.5,add:6)).range(1,2.midiratio),breathpressure:20,vibgain:10,vibfreq:64)*0.04}.play(s,2).dur(1) });
//~im2.pbind[7].play;
~im2.bass8=(start:8,music:[note:[Rest(),8,6,4,2,0,-1].q,octave:3,dur: ~im2.parse(8,[1,1,1,1,1,[1,1,1,1]]).q++[2].q ].p);

~im2.lick8=(start:8,syl:4,music://{{{
	[
		out:3,
		freq:
		([0,10]+.x[6,5,3,2,1])

		.degreescps(root:3,octave:4).q,dur:
	~im2.parse(8,[1,1,1,1],5).q++([1].q)

].p
);//}}}
//}}}
/// 9 /////// {{{
~im2.chord9=(start:9,music:(strum:0.07,freq:[2,4,5,7].degreescps(root:4)));
~im2.chord9=(start:9,music:(dur: 2,strum:0.05,freq:[5,12,14,17,23].degreescps(root:-1)));
~im2.chord9b=(start:9,syl:0,music:(strum:0.07,freq:[3,5,6.5,10].degreescps(root:-1)));
~im2.bass9=(start:9,music:(note:6,octave:[2]+1,amp:0.1,dur:4));
//~im2.bass9b=(start:9,syl:0,music:(note:-1,octave:[3,2]+1,amp:0.2,dur:4));
~im2.bass9c=(start:9,syl:4,music:(note:4,octave:[3,2],amp:0.2,dur:4));

~im2.tritones9=( //{{{
	start:9,
	music:[ instrument:\stringyy, note:( [-2,-3,-4]+.t[0,6] ).q , dur: ~im2.parse(9,[1,1!4,1]).q].p
); //}}}

~im2.bend9=(start:9,music: {{ //{{{
	var env= Env.new([2.5,2.5,2,2,1.5,1.5].degreescps(octave:7),[1.5,1,5.5,2.5,3]).kr(gate:1);
	Saw.ar(env*[1,2],0.1)=>FreeVerb.ar(_,1,0.9)*0.2 
	* Env.linen(4,1,5).kr(2,gate:1)
}.play});
//}}}

//~im2.voiceleading9=( start:9, music: (//{{{
//		[
//			[
//				octave:[4,5],
//				amp:0.1,
//				dur: ~im2.parse(9,[1,1!4,1]).q,
//				instrument:\stringyy,note:[4,3,2].q
//			].p
//			,
//			[
//				amp:0.2,dur:~im2.parse(9,[1,1!4,1]).q,out:2,instrument:\stringyy,note:1+[13].q
//			].p
//		]=>Ppar(_)
//	)); //}}}

//}}}
//// 10 ////{{{
~im2.bass10=(start:10,music:(note:-3,octave:[3,2],amp:0.2,dur:~im2.parse(10,[1!9])));

~im2.bass10b=(start:10,syl:7,music://{{{
	[
		note:[ -4,-7,-6,-8,  // -8+12 
		].q,
		legato:(0.96!3 ++ 1).q,
		octave:4,amp:0.2,
		dur: ( 
			~im2.parse(10,[1!3,1],8)++ ~im2.parse(11, [1!6 ,1!5]) 
		) .q 
	].p);
//}}}
~im2.pad10=(start:10,music:(instrument:\stringyy,freq:[1,5,13].degreescps(root:-3,octave:3),dur:2));

~im2.pad10b=(start:10,syl:4,music:( instrument:\stringyy,freq:[5,11,13].degreescps(scale:\minor,root:-1,octave:3),dur:2 ));

~im2.figure10=(start:10,syl:4,music: [instrument:\tri,pan:1,freq:[14,12,6,12,14].degreescps(root:-3).q,dur:~im2.parse(10,[1,0.33!3,1].flatten,5).q].p);
//}}}
//// 11 ////{{{
~im2.bass11=(start:11, syl:7, //{{{
	lag: ~im2.parse(11,[0.5],8)[0] + 0.05,
	amp:0.5 ,
	music:{{(dur:2,octave:4,out:1,note:4).play;(dur:2,octave:5,out:1,note:4,instrument:\stringyy).play}.play});//}}}
//}}}
//// 12 ////{{{
~im2.bass12=( start:12,syl:0,music: [ //{{{
	freq:
	(
		[3,3,2,2,1] 
		.degreescps(root:4,octave:4)
		*.t [0.5,1,2]
	) .q,
	dur:
	~im2.parse(12,[3/4,1/4, [1,1,1/3],2/3 ,1],1)
	.q 
].p ); //}}}
~im2.cords12=( start:12,syl:0,music: [ //{{{
		// freq:[1,2] *.x [13,13,13,13,14,11,6.5,5.5].degreescps(root:-4,octave:5).q
		freq:([5,11].degreescps(root:-4)!5).q,
		dur:~im2.parse(12,1!5,1).q
	].p ); //}}}
~im2.cymbal12=(start:12,syl:0,music:(instrument:\cymbalsDS,att:0,amp:0.01));
//}}}

	~im2.bass13=( start:13, music:(degree:4, octave: [2, 3 ], instrument:\stringyy, dur: ~im2.secDur[13]) );
	~im2.bass14=( start:14, music:[degree:[ Rest(),3,4 ].q, octave: [2, 3 ], instrument:\stringyy, dur: ~im2.parse(14,[ 1!2, 1!4, 1!2 ]).q].p );
	~im2.bass15=( start:15, music:(degree:0, octave: [4, 3 ], instrument:\stringyy, dur: ~im2.secDur[13]) );

//~im2.cords12.play;~im2.bass12.play;
//// cursor and guide
~im2.cursor_(10);
~im2.bass16=(start:16,syl:2,music:(
	octave: [3,4],
	degree: 5,
	instrument: \stringyy,
	dur: 
	~im2.parse(16,[[ 1,1,1 ]],3) + ~im2.secDur[17]  
));

SynthDef(\keychord,{
	Pulse.ar(\freq.kr(400))
	* Env.cutoff(2.5).kr(2,gate:\gate.kr(1))
	* 0.015
	=>Out.ar(\out.kr(1),_)
}).add;

~im2.cords18=(start:18,syl:9,music:[//{{{
	instrument: \keychord,
	dur: ( ~im2.parse(18,[[1,1],1],10) + [0,1]).q,
	rel: [1,2].q,
	freq: [[1,3,5],[1,4,6]].degreescps(root:-3).q
].p);//}}}

~im2.bendybase18=(start:18,syl:9,music:(//{{{
	instrument:	\bendbase,
	octave: 3,
	note:  -3 ,
	dur: ~im2.parse(18,[[1,1],1],10).q
));//}}}

SynthDef(\bendbase,{ //{{{
	var dur = ~im2.parse(18,[[1,1],1],10);
	var env = Env.new([1,1,2].degreescps(root:-3,octave:3),~im2.parse(18,[[1,1],1],10));
	Saw.ar(EnvGen.ar(env)+[0,0.5],\amp.kr(0.1))
	=>MoogFF.ar(_,\cutoff.kr(4000,2))
	* Env.linen(dur[0],dur[1],3,curve:\sin) .kr(doneAction:0)
	=>TwoTube.ar(_,0.05,0.85,1400,600)
	=>Out.ar(\out.kr(0),_)
	* Env.linen(dur[0],dur[1],3+13,curve:\sin) .kr(doneAction:2)
}).add; //}}}

~im2.baas18=(start:18,music:[//{{{
	instrument: \stringyy,
	octave: [2,3],
	dur: ~im2.parse(18,[[1,1,0.5],[0.5,1,1,1,1,1,1,1],[1,1],1]).q,
	note: [Rest(),2,-3,-1].q
].p);//}}}

SynthDef(\basepluck,{
	{ DWGPlucked2.ar(\freq.kr(400)) * 0.05 }.play



	{ DWGPlucked.ar(c1:0.1,freq:\freq.kr(100,0.01),  amp:0.0005,  gate: 1,  pos: 0.14,  release: 0.1,  mistune: 1.008,  mp: 0.55,  gc: 0.01); }.play 
});

~im2.basedouble18=(start:18,music:Pset(\instrument,\default,~im2.baas18.music));

~im2.run18=(start:18,music:[//{{{
	instrument: \stringyy,
	freq: [Rest()].q++[ 11,7,6,5,4,3,2,4,3 ].degreescps(root:2,octave:4) .q,
	dur: ~im2.parse(18,[[1,1,1],1,1/3,1/3,1/3,1,1,1]) .q,
	pan: -1
].p);//}}}

//~recorder.(~im2,18,1)

~im2.addGuides(".xxxx|.xxxx|xx");
~im2.guide12= ( start:12, syl:0, music:~im2.guide12.music=>Pdrop(1,_));
//~im2.pbind[11..12].q.play
//~im2.durs[11].list.do(_.postln)
//~im2.durs[12].list.do(_.postln)
//}}}
//~recorder.(~im2,12,1)

// DEFS
SynthDef(\stringyy,{ |gate=1| //{{{
	var freq=\freq.kr(400,0.05);
	var width=\width.kr(6);
	//var gate=\gate.kr(0);

	Gendy2.ar(minfreq:freq-width,maxfreq:freq+width)
	=>Mix.ar(_) *0.5
	+Gendy1.ar(minfreq:freq-width,maxfreq:freq+width) 
	* 0.1 * \amp.kr(0.5)
	=>
	(PlateReverb.ar(_,10) ++ (_*0.5))
	=>
	Mix.ar(_)
	* Env.asr(0.5,1,8).kr(2,gate:gate)
	=>Out.ar(\out.kr(0),_)
}).add; //}}}

SynthDef(\mda,{ //{{{
	var sig=MdaPiano.ar(\freq.kr(400),\gate.kr(1)) * \amp.kr(0.1);
	Out.ar(\out.kr(0),sig);
	DetectSilence.ar(sig,0.01)
}).add; //}}}

SynthDef(\portBass,{ //{{{
	Formants.ar(\freq.kr(300,\port.kr(0.2)),Vowel())
	=>FreeVerb.ar(_,0.3,1)
	*\amp.kr(0.1)
	* Env.cutoff(1).kr(2,gate:\gate.kr(1))
	=>Out.ar(\out.kr(1),_)
}).add; //}}}

SynthDef(\tri,{ //{{{
	DPW3Tri.ar(\freq.kr(300)) * \amp.kr(0.1).distort
	* Env.asr(0.05,1,2).kr(2,gate:\gate.kr(1))
	=> FreeVerb.ar(_,0.7,1)
	=>Out.ar (\out.kr(1),_)
}).add; //}}}

SynthDef(\pulseBBass2,{  //{{{
	var freq=\freq.kr(100,0);
	var fenv = Env.perc(0,0.5).range(300,freq*8).kr(0,gate:1);
	var env = Env.linen(0,0.2,0.5).kr(2,gate:1);
	var a = Saw.ar(freq*[0.5,1],\amp.kr(0.15)*[1,0.5]);
	//a[0] // mono
	a
	=>MoogFF.ar(_,fenv,\res.kr(2)) * env 
	=>Out.ar(\out.kr(0),_)
}).add; //}}}

{ //Dan Stowall Cymbals{{{
	var lodriver, locutoffenv, hidriver, hicutoffenv, freqs, res, thwack;
	locutoffenv = EnvGen.ar(Env.perc(0.5, 5)) * 20000 + 10;
	lodriver = LPF.ar(WhiteNoise.ar(0.1), locutoffenv);
	hicutoffenv = (EnvGen.ar(Env.perc(1, 3))).range(10000,1);
	hidriver = HPF.ar(WhiteNoise.ar(0.1), hicutoffenv)
	* EnvGen.ar(Env.perc(1, 1, 0.25));
	thwack = EnvGen.ar(Env.perc(\att.kr(0.001),0.0001,1));
	freqs  = {exprand(300, 20000)}.dup(30);
	res	= Ringz.ar(lodriver + hidriver + thwack, freqs).mean;
	((res * 1) + (lodriver * 2) + thwack).dup * \amp.kr(0.1)
	=> ( Out.ar(\out.ir,_) <! DetectSilence.ar(_,doneAction:2))
}=>SynthDef(\cymbalsDS,_)=>_.add //}}}

)

~recorder.(~im2,6,1)
~im2.chord5b.play;~im2.guide5.play;
~im2.passing5.play;
~im2.bass5.play
~im2.guide5.play
~im2.bass5ii.play
~im2.bass5iii.play
Song.cursor
	e Env.linen(dur[0],dur[1],3,curve:\sin) .kr(doneAction:2)
Song.current.cursor_(5)
~im2.pbind[5]<>
.play
~im2.bass4.play; ~im2.pbind[4].play
~im2.chord5=(start:5,music:[root:3,instrument:\sawzz,degree:Arpeggio([1,3,5,8],13),octave:3,dur:[2].q,strum:0.05,out:3].p)
~im2.chord5.play
~im2.cursor_(4)
~recorder.(~im2,5,1)
~im2.save
~im2.at(4)


~im2.keysLow4.play
~im2.drMcoyBass3.play
~im2.cursor=2
~im2.keys3.play
~im2.cursor_(3).play
~im2.keys3.play

~im2.cursor_(0).play
~im.cursor_(0).play
~im2.lyrics.do(_.postln)
~recorder.(~im2,0,1)
~im2.save
Archive.at( ~im2.key.asSymbol)
(pitch:[1,2,3],dur:[4,5,6]).flopEvents
[degree: [1,2,3],dur:[6,7,8]].flopEvents.q.play

(
	[degree: [13,5,11,13,14,7,12,14,14, 5, 7, 14, 13],dur:0.5,legato:1.1,octave:3].flopEvents.collect{|i| (freq:i.degree.degreescps(root:2,octave:i.octave),dur:i.dur)}.q.play;
	[instrument:\sawzz, dur:2,freq: [11,11,7,6].degreescps(root:2,octave:3).q ,octave:[3,4]].pp
)

// also TODO - formant filter for this
// ngyy * -> make a lookup script!!
( // stringyy {{{
{
	//def
		{|gate=1| 
			var freq=\freq.kr(400,0.05);
			var width=\width.kr(6);
			//var gate=\gate.kr(0);

			Gendy2.ar(minfreq:freq-width,maxfreq:freq+width)
			=>Mix.ar(_) *0.5
			+Gendy1.ar(minfreq:freq-width,maxfreq:freq+width) 
			* 0.1
			=>
			(PlateReverb.ar(_,10) ++ (_*0.5))
			=>
			Mix.ar(_)
			* Env.asr(0.5,1,8).kr(2,gate:gate)
			* \amp.kr(1)
			=>Out.ar(\out.kr(0),_)
		}
		=>SynthDef(\stringyy,_)
		=>_.add; 
	};
 fork{  // stringyyy !!!
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
	)
)//}}}

///// EXTRAS
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
	.play(s,1,addAction:\addToTail).dur(12);
	//s.plotTree
)//}}}

(// cool yodel trio (3 speaks){{{
	{{Item(\order).playbuf(rate:5)=>FreeVerb.ar(_,1,0.8)*rrand(2.0,3)}.play(s,1)}.sched(( [1,2,4]+ .x Array.series(4,-1,3) ).flatten);
	{{Item(\order).playbuf(rate:2)=>FreeVerb1.ar(_,2)}.play(s,2)}.sched(([3,5,1]-1 + .x Array.series(3,0,4)).flatten);
	{{Item(\order).playbuf(rate:3)=>FreeVerb1.ar(_,1)}.play(s,3)}.sched(([2,3,1]/2 + .x Array.series(5,0,2.5)).flatten)
)//}}}

( //airport{{{
	{
		[freq:[1,2,3,[9,9.1].choose],dur:[5,2,2,[0.1,8].choose]].flopEvents.do{|i|
			{Synth(\default,[\pan,rrand(-1,1.0),\freq,[i.freq].degreescps(octave:[4,7,8].choose,root:[1,1.1,3,6].choose)]).dur(i.dur)}.sched(3.0.rand)}
	}.sched(all {:x,x<-(1..50),x.isPrime} ++[0])
) //}}}

(//Electric Piano{{{
SynthDef(\everythingrhodes,{| out= 0 freq = 440 amp = 0.1 gate=1 lforate = 4.85 lfowidth= 0.5 cutoff= 2000 rq=0.5 pan = 0.0 |

	var pulse, filter, env;
	pulse = Pulse.ar(freq*[1,33.5.midiratio],[0.2,0.1],[0.7,0.3]);
	env = EnvGen.ar(Env.adsr(0.0,1.0,0.8,3.0),gate,doneAction:2);
	//keyboard tracking filter cutoff
	filter = BLowPass4.ar(pulse,(cutoff*(env.squared))+200+freq,rq);
	Out.ar(out,Pan2.ar(Mix(filter)*env*amp,pan));
})
.add
)//}}}

[ instrument:\everythingrhodes,\out,Pwhite(1,3,inf),degree:[1,3,5,7],octave:Pwrand([3,4,5],[1/4,1/2,1/4],inf),amp:Pwhite(0.1,0.2,inf),dur:Prand([1,1,0.5,0.25],inf),root:Pwhite(0,11,inf) ].pp


(
	// make method to display lyrics etc!!!!
	w=Window(bounds:Rect(0,300,300,300)).alwaysOnTop_(true).front;
	//a=StaticText.new(w,Rect(120,10,600,300)).string_(~im2.lyrics).font_(Font("Helvetica",20)).align_(\left);
	~im2.lyrics.size.do{|i|
		StaticText.new(w,Rect(120,25*i,600,300))
		.string_(~im2.lyrics[i])
		.font_(Font("Helvetica",20));

		StaticText.new(w,Rect(100,25*i,600,300))
		.string_(i.asString)
	};
	//{w.close}.defer(5)
)
~im2.lyrics[0]
( // that's what a starship {{{
	~im2.pbind[13]=>Pbindf(_,\instrument,\tri,\out,1,\midinote,~panNotes.("d e f a a g a b").q)=>_.play;
	~im2.pbind[13]=>Pbindf(_,\instrument,\tri,\out,0)=>_.play;
	(instrument:\stringyy,amp:0.3,midinote:~panNotes.("<g2 g1 g3>"),dur:~im2.secDur[13]).play;
	(instrument:\sawzz,amp:0.3,midinote:~panNotes.("<g2 g1 g3>"),dur:~im2.secDur[13]).play; //}}}
)

( //shakers{{{
	{StkShakers.ar(1,LFSaw.kr(4).range(164,0) * 0.1)=>Klank.ar(`[[1300,2330,377,900,4100,3300,3359,8000,2100,2250],nil,0.21!8],_)}.play(s,1) 
	{StkShakers.ar(1,LFSaw.kr(3).range(164,0) * 0.1)=>Klank.ar(`[[130,3300,3771,1900,2100,3300,3359,8000,2100,2250],nil,0.21!8],_)}.play(s,1) 
	{StkBlowHole.ar(249,64,20,64,11,64,1,0,1,1,1)}.play(s,2) 
)//}}}
