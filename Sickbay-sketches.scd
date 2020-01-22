"~/tank/super/More-Organized-Trek/Songs/Sickbay-song.scd".standardizePath.load;
~sickBay.play
m=Monitor.new.play(2,1,1,1)

(// nothingOfImportance{{{
	{
		(
			[
				~sickBay.pbind[5],
				~sickBay.plucks5=(start:5,music:[
					degree:[Rest(),3,1,5-7,[3,6]-7].q-1,
					root:6,
					dur: ~sickBay.parse(5,[[1,1,1,1],1,0.66,[0.34,1],[1,1]]).q,
					octave:4,
					amp:0.3
				].p),
				~sickBay.padBass5=(start:5,music:
					[
					degree:[\r,[1,5+7,3+14],[6-7,6,6+4,6+7]].q-1, //idea write 1 5' 3''
					root:6,
					octave:[2,3],
					instrument:\wash,
					out:[1,1,2].q,
					amp:0.2,
					att:2,
					dur:~sickBay.parse(5,[[1,1,1,1],[1,1,1],[1,1]]).q
				].p
			)
			]=>Ppar(_,1)
		).play
	}.fork
)//}}}

~sickBay.thalassaVerb.release(3)

~sickBay.plucks.play
~sickBay.cursor_(1).play
~sickBay.doorOpen.play
~sickBay.doorOpen.music
~sickBay.thalassaVerb.free
s.plotTree
~sickBay.padBass5.p
~sickBay.padBass5.music
(//some stills{{{
	~stills.set('sargonsFormula',2291.43)
	~stills.set('sargonWhatIsIt',2285.76)
	~stills.set('nothingOfImportance',2287.18)
	~stills.preview('sargonWhatIsIt')
	~stills.preview('nothingOfImportance')
	~stills.preview('sargonsFormula')
///////markers
	Reaper.go(38*60+2.81) //waiting
	Reaper.go(
		38*60+8.58
	)//Sargon what's wrong??
	Reaper.go(37*60+54.30)//door open

)//}}}
( //	some \wash examples	{{{
	///fire a bunch of the first one a second apart
(instrument:\wash,degree:[1,3,5,7]-1,octave:[3,4],pan:0,out:2,att:6,rel:8,amp:0.2).play;
(instrument:\wash,degree:[1,3,5,7]-2,octave:[3,4],pan:0,out:2,att:6,rel:4,amp:0.2).play
)
(//gesture   
	{
		b=(instrument:\wash,degree:[1,3,5,7]-2,pan:0,out:2,att:8,rel:6,amp:0.1).play;
		a=(instrument:\wash,degree:[1,3,5,7]-2,pan:0,out:2,att:6,rel:4,amp:0.2).play;
		3.wait;
		(type:\set,id:a[\id],degree:[1,2,6,9]-2,pan:0,out:2,att:6,rel:4,amp:0.2).play;
		3.wait;

		(type:\set,id:b[\id],degree:[1,3,5,7]-4,pan:0,out:2,att:6,rel:4,amp:0.2).play;
		2.5.wait;
		(type:\set,id:b[\id],degree:[1,3,4,6]-4,pan:0,out:2,att:6,rel:4,amp:0.2).play;
	}.fork
)//}}}
( //ideas for functions to route and replace Pfx{{{
	~routeFun={ |pattern function out=0|
		var privateBus=Bus.audio.index;
		privateBus.postln;
		function.play(privateBus,out);
		pattern=>Pset(\out,privateBus,_)
	};
	~route={ |pattern out=0|
		var privateBus=Bus.audio.index;
		privateBus.postln;
		{In.ar(privateBus)=>PlateReverb.ar(_,1)=>Out.ar(out,_)}.play;
		pattern=>Pset(\out,privateBus,_)
	};
	a=[degree:[1,3,5,3,4,6,5,4].q].p;
	//~route.(a,1).play;
	//b={|in out| In.ar(in)=>FreeVerb.ar(_,1,0.9)=>Out.ar(out,_)};
	~route.(a,1).play
)//}}}
//oldskool{{{
	4.do{{Saw.ar(400+LFNoise0.kr(5).range(-300,400))=>(PlateReverb.ar(_)+(RHPF.ar(_,900+SinOsc.kr(8,mul:100),9)))=>MoogFF.ar(_,LFBrownNoise1.kr(3).range(400,5000),rq:19).distort=>Out.ar([0,2],_)}.play}
//}}}

(
	{
		10.do{
			6.do{{ Env.triangle(18.rand).kr(2,gate:1)* Saw.ar((2*rrand(25,45)).midicps,0.1)=>MoogFF.ar(_,SinOsc.ar(0.3.rand).range(800,1900))}.play(s,1) };
			6.wait;
		}
	}.fork
)


