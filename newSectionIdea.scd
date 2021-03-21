(
//refactoring idea!!

//addLine makes a new section and makes it current ....
//adds it to the current song .....
//each part is added to the current section
//needed: semantics for adding anoher song inline!!


//opportunity to use git branch


//idea!! section doesn't "have" a string = section is associated with a string
// what if there is a big dict of lines
~sectionz = Dictionary.new;
~section={ |string="x", array=#[2], array2, array3 |
	(
		lyric: string,
		tune: array2,
		// should durs be GLOBAL per line??
		// NO - per song to permit alternatives - SOLVE THIS
		durs: array,
		parts: array3 ? List.from(array3),
		play:{ 
			play music in current context
		}
	)
}
)

a=~section.("hello!",[1,2],[3,4].dm(\c))
a.part=[note:a.tune.q,dur:a.durs.q].p
~part={
	(
		parent: current Section,
		music: ...
		play: ~parent.playme
	)
}

~parts = {
	//list of parts each associated with thier own secions that can be played or armed together
}

(//song is a list of sections ---- OR SONGS!
	//idea SONG has durs = section durations

~song = { |list|
	(
		sections:list,
		addE: {|e section| e.sections.add(section)},
		durs: {|e| e.sections.collect({|i|i.durs.sum})},
		play:{
			var secLoc = [0] ++ ~sections.collect({|i|i.durs.sum});
			~sections.do({|i x| {i.play }.sched(secLoc[ x ]) }) 
		}
	)
}
)

(
b=~song.(List[a,c]);
d=~song.(List[c,b])
d.addE(c)
d.sections.size
d.play
c=~section.("good bye!",[1.5,2]);
c.part=[note:[-5,8].q,instrument:\stringyy,dur:c.durs.q].p;
b.addE(c);
b.play
)

~csec=Object();

a.play

~currentSong=~song.(List.new());
~addSection = {|string| ~currentSong.addE(~section.(string))};
~addPart={|music| ~part.()}
~addSection.("twidddle dee dee");
~addPart.([note:[1].q].p);
~addSection.("twidddle dee dum");
~currentSong.sections
Rongs.ar
\mkplugins.help
{AnalogBassDrum.ar(Impulse.kr(1))}.play(s,1)
{AnalogSnareDrum.ar(Impulse.kr(1))}.play(s,1)
VarShapeOsc.ar()
{Rongs.ar(Impulse.kr(1),modeNum:2)}.play(s,1)
{ZOsc.ar([100,200,150,240],LFBrownNoise2.kr(1).unipolar*100,LFBrownNoise2.ar(1).unipolar,LFBrownNoise2.ar(1).unipolar*Pulse.ar(1).range(0.34,0.67))=>Mix.ar(_)}.play(s,1)
{VosimOsc.ar(Vibrato.kr(233),shape:0.1))0.1}.play(s,1)
DCompressor.ar()
(
{
	//b=Buffer.cueSoundFile(s,"/Users/michael/tank/Trek/media/02-whisper-181228_1411.wav",numChannels:1);
	//PlayBuf.ar(1,b.bufnum,loop:1)
	Item(\necessary).playbuf
	*8
	=>DCompressor.ar(_,threshold:-60,ratio:18,automakeup:1)
	=>DWGReverbC1C3.ar(_,mix:0.2)


}.play(s,1)
)

(

var array=[
	1,2,[3,4,[3,4],T(11,13)],[ 2,-5 ]
];

var array2 = [[\r,5],[4,3],[\r,4],[3,2]];

var size = {|i, beat=1|  ///////// workx!
	i.collect({|i| 
		if( i.size==0, {
			if (i == \r,{Rest(beat)},{beat})
	},{
			size.(i,i.size.reciprocal*beat)} 
		)}) 
	};

var durs = size.(array).flat.postln;
var pitches = array.flat.collect{|i| if( i.class==Tuple2,{[ i.at1,i.at2 ]},{i} )};
var durs2 = size.(array2).flat;
var pitches2 = array2.flat;

[freq:pitches.df(\a).q,dur:durs.q,instrument:\sawSynthSustain].p=>Pn(_,8)=>_.play;
[freq:pitches2.df(\a,octave:5).q,out:1,amp:0.5,dur:durs2.q,instrument:\stringyy].p=>Pn(_,8)=>_.play;

[
	"x.x.x.x.x.x.x.x.",\hihat,
	"x...x...x...x...",\kick3,
	"....x.......x...",\sn_808,
].dmx=>Ppar(_)=>_.play;

//Item('happyOooh/ooh').arm(length:5)

{
	~voxamps=0.2;
	~effect={|out|
		Effect({|i|
			HPF.ar(i,200)
			=> BHiShelf.ar(_,db:12)
			=> DCompressor.ar(_,ratio:8)
			=> FreeVerb.ar(_,0.1,1)
			//=> Phaser1.ar(_,rate:0.2)
			* ~voxamps
		},out:out).bus.index
	};
	Item('happyOooh/ooh').play(s,rate:1.01,out:~effect.(0));
	Item('happyOooh/ooh').play(s,out:~effect.(1));
}.sched((0,4..20)*2)
)

pass object as argument to method
[1,2,4] => {|i| T(i,i)} => _.bicollect(_+1,I.d) 
Tuple2
e 
~oo = {|selector}
+Object {
	oo 
}
