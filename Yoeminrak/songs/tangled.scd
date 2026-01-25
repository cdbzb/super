(
   Yoeminrak.song.bar = List[];
   // Yoeminrak.resetBusses;
   // Yoeminrak.addDrum(\bar, [freq:99]);
   Yoeminrak.song.bar.addAll( 
    [
        (
            type: \piano, beat:0,
            play: {
                [ freq: [\a,\c].collect{
                    // |i| [0, 2, -6].df(i)}.flop .q,
                    |i| [1, 2, 1, -6, -6, -5, -6,  1.5].df(i)}.flop .q,
                    dur: [0.33, 0.67+ 0.67,0.33, 2, 0.34, 1.33, 0.34, 2] * Yoeminrak.secDur[0] / 20 => _.q(inf),
   		    out: Effect.bus({|i| FreeVerb.ar(i,1,1) *4 }, inputChannels:2),
   		    pan:1
                ].pp
            }
        ),(
            type: \piano, beat:7,
            play: {[
                out: Effect.bus({|i| FreeVerb.ar(i,1,1) }),
                freq: [
                    [ 7, 6.5, 7,7,6.5].df(\c),
                    [ 1, 1.5, 1,1,1.5].df(\c),
                ].flop.q,
                pan: [-1,0.7],
                dur: "e eee ee e ee".beats * Yoeminrak.secDur[0] / 20 / 2 => _.q,
                amp: 0.5
            ].pp
        }        
    ), (
        type:\piano, beat:6, play: {
            (
                freq: [1, 3, 5, 7, 11, 13, 15, 17].df('c#'),
                strum: 0.05,
		out: {Effect.bus({|i| FreeVerb.ar(i,1,1) }, inputChannels:2)},
		amp:0.5,
		pan:1
            ).play
        }
    ),(
            type: \piano, beat:10,
            play: {
                [ freq: [\a,\c].collect{
                    // |i| [0, 2, -6].df(i)}.flop .q,
                    |i| [1.5, 2.5, 1.5, 1, \r].df(i)}.flop .q,
                    dur: [1 - 0.66, 2.66 + 0.66,0.33, 1, 1] * Yoeminrak.secDur[0] / 20 => _.q(inf),
   		    out: Effect.bus({|i| FreeVerb.ar(i,1,1) *4 }, inputChannels:2),
   		    pan:1
                ].pp
            }
        )
    ]
   );
   [
    [ // beat 1
   	 (root:  0,  knum:{SinOsc.ar(0.02 , 0!5).abs.poll * 5 + 2.1  }, select:0)
   	 ,
    (root:2, freqLag:1,), ()
    ],
    (), // beat 2
    (root:  -3,freqLag:3,), //beat 3
    (), // beat 4
    [ (root:-3), (root:-5, freqLag:1), (), ],
    [ (), (), (root:-3) ],

    (root:1,freqLag:3, ampDistParam:0), //6
    (
    	select: {Env.triangle(Yoeminrak.secDur[0]/5).kr(2,1) * 2},
    	chord: {var up = [-7,2,3,5,6.5].df('c');Env([up,up, [1, 2, 3, 5, 6].df(\c)], 0.5, \wel).kr(2, 1)},
   	// amp: T(4,1),
    	root: 1,
    	extra: {
   	    (freq: -7.df('c#'),instrument:\harp, coef:0.1, amp:0.2).play;
   	},
    	freqLag:0
    ), (
    	chord: {var up = [-7,2,3,5,6.5].df('c');Env([up,up, [1, 2, 3, 5, 6].df(\c)], 0.5, \wel).kr(2, 1)}, root: 1,
    	extra: {(freq: -5.df('c#'),instrument:\harp, coef:0.1, amp:0.2).play}
    ), (
   	 extra: {(freq: -4.df('c#'),instrument:\harp, coef:0.1, amp:0.2).play}
    ),

   [
     (root:1, extra: {(freq: -3.df('c#'),instrument:\harp,lag:0.05, coef:0.1, amp:0.2).play}),   //10
     (root:3, freqLag:1),
     ()
   ],
   (),
    (),
    [(),
    // (root:T(1, 2.5, \lin)),
    (),
    (root:1, freqLag:3) ,
   ],

    (root:T(0, 3, \lin), select: {LFTri.kr(0.1).range(0,0.25)}, chord:T([1, 3, 5, 6, 12].df(\c),2, \lin)) //14
    ,
    (select:0, release:3),
    (ampScale:T(0.3,6,\lin),extra:{(freq: 1.df('c'),instrument:\harp,lag:-0.05, coef:0.1, amp:0.1).play}  ),
    (extra:{(freq: -7.df('c'),instrument:\harp,lag:0.05, coef:0.1, amp:0.2).play}),
    (extra:{(freq: -7.df('c'),instrument:\harp,lag:-0.05, coef:0.1, amp:0.1).play}),
    (gates:[0,0,0,0,0], release:8, root: T(-5, 2, 1) ,
  extra:{(freq: -5.df('c'),instrument:\harp,lag:0.05, coef:0.1, amp:0.1).play} ),
    //
    // [
    //     (root:0, freqLag:0, select:0),
    //     (root:2, freqLag:2),()
    // ],
    // (),
    // (),
    // (\release:8),
    //
    // (root: 1),
    // (ornament:{Saw.ar(0.23).unipolar * 3}, freqLag:0, root:0)
   ]
   // .collect {|i| i.isKindOf(Event).if{i ++ (type:\yoeString3)}{i.collect (_++(type:\yoeString3))}}
   .addType(\yoeString3)
   .add20(\bar)
   ;
   // [ type:\yoeString3, ornament:{LFNoise2.kr(2!5) * Line.kr(1,0,2,doneAction:2)},beat:[2, 4, 5, 7, 8, 10, 11, 12, 14, 15, 17, 19] ].flop.collect{|i| i.asEvent}.do{|e| Yoeminrak.song.bar.add(e)};
   Yoeminrak.addDrum(\bar, [freq:[99,99,105,99]]);
   Yoeminrak.addEventType(\plink, { (lag:~lag,freq:~freq,instrument:\harp,coef:0.1,decaytime:40, amp:~amp, out: Effect.bus({|i| Pan2.ar(i, -1.rrand(1)) },)).play});
   ~plink = [
    amp: Prand([0,0.1, ]* 0.1, inf),
    beat: 
    {0.5.bilinrand}.dup(31) => {|i| i - i.mean} + 1 =>_ .integrate => _.q 
    ,
    amp:[0].q ++ [0.2].q(inf) * Pgauss(1,0.2, inf),
    // rests: MuteFirst(),
    type:\plink,
    freq: Pfunc{ Yoeminrak.env[\root].getSynchronous.midiratio * [ 1, 2, 3, 5, 6 ].choose.df(\c)  => _.postln },
   ]
   .p
   // .asStream.nextN(20,())
   // => {|i| i.do {|j|Yoeminrak.song.bar.add(j ? (beat:1000))}}
   );


(
    // Yoeminrak.playVid(vid:1, sec:3, audio:false, fullscreen:false, start:0, end:5);
	 Yoeminrak.song.foo=List[];
	 // Yoeminrak.resetBusses;
 a = [
	 type:\yoeString3,
	 knum:4,
	 // knum:Pseries(4,0.51,15),
	 select:0.5,
	 freqLag:2.6,
	 chord: [
		 [-4, -6, 1, 5, 11].df(\c),
		 [-4, -6, 2, 5, 12].df(\c),
		 T( [-5, -7, 2, 6, 13].df(\c), 1,\lin ),
		 [-5, -7, 3, 6, 13].df(\c),
		 T( [-6, 1, 3].df(\c, ), 1,\lin ),
		 [-6, 1, 4].df(),
		 T( [-7, 2, 4, 11, 12].df(), 1, \lin ),
		 [-7, 2, 5].df(),
		 T( [-5, 1, 4, 6.5, 14].df(), 2, \lin ),
		 [-5, 1, 3, 13].df(),
		 T( [-4, -5, 2, 6, 12].df(), 2, \lin ),
		 [-3, -5, 1, 12, 11].df(),
	 ].q,
	 width:1.03,
	 // ampDistParam:Pwhite(0,6,inf),
	 // durDistParam:Pwhite(0,6,inf),
	 // ampScale:Pwhite(0,1.0,inf),
	 // durScale:Pwhite(0,1.0, inf),
	 // ampDist:Pwhite(0,1.0, inf),
	 // durDist:Pwhite(0,1.0, inf)
	 // dur: Yoeminrak.secDur[3] / 20 / 3
 ].p.eventsWithBeats(10)
 => Yoeminrak.song.foo.addAll(_);
 Yoeminrak.drumPbind.patternpairs ++ [freq:[ 99 * -2.midiratio, 99, 99 * -7.midiratio ].q(inf)] => _.p =>_.eventsWithBeats(6) => Yoeminrak.song.foo.addAll(_);
);

 (
 Yoeminrak.song.two = List[];
 Event.addEventType(\addMe, {
     var env,env2;
	 env = currentEnvironment.copy;
     env.type = \yoeString3;
	 env.section = 1;
     // (env.chord.class == Array and: (env.beat>0)).if {env.chord = T(env.chord, , \lin).postln};
     Yoeminrak.song.two.add(env);
     // env.play;
     env.harp.isNil.if {
	 env2 = currentEnvironment.copy;
	 env2.type = \default;
	 env2.freq = {env.chord.notNil.if{"NOTNIL".postln;  env.chord.isKindOf(Tuple3).if {"TUPE".postln;env2.chord.at1}{"NOT_TUP".postln;env2.chord}[env2.which ? [0,1,2,3,4] => _.postln]  }};
	 env2.instrument = \harp;
	 env2.coef = 0.1;
	 env2.latency= 0.025;
     env2.strum = 0.1;
	 // (env.chord.class == Array and: (env.beat>0)).if {env.chord = T(env.chord, , \lin).postln};
	 Yoeminrak.song.two.add(env2);
     // env2.play
     };
 });
 	 (beat: 0,chord: [1,2, 3, 5, 6].df(\c), type:\addMe, knum:6).play;

 	 (beat: 1/3,chord: [1,2, 3, 5, 6].df(\d), type:\addMe).play;
	 (beat: 0.5,harp: false, gates:[1,0,1,0,1], type:\addMe).play;
 	 (beat: 1, chord: T([1,2, 3, 5, 6].df(\A), 1, \lin), type:\addMe).play;
	 (beat: 2,which:0,amp:T([2, 2, 2, 1.2, 1.2], 0.3, \lin), chord: T([-6.5,1, 2, 5, 6].df(\A ), 0.3, \lin), type:\addMe).play;
 	 (beat: 2.66,which:[4], chord: [-6.5,1, 2, 5, 5].df(\A), type:\addMe).play;
	 (beat: 3, chord: [1,2, 3, 5, 6].df('f#', 4), type:\addMe, knum:T(6, 1, \lin)).play;
	 (beat:3.05, harp:false,
         ornament: {[0,0,0,0] ++ Env.perc(0.2,1).kr(2,1) * 19},
		 ampScale:{Env.perc( 0.5,{3.0.rrand(5) }.dup(5) / 2, 0.5).kr(2, 1) + 0.5},
		 
		 durScale:{Env.perc(0.5,{3.0.rrand(5)}.dup(5) / 2, 0.5).kr(2, 1) + 0.5},
		 // ampParam:{Env.triangle(3.0, 0.5).kr(2, 1) + 0.5},
		 durDistParam:{Env.triangle({ 4.0.rrand(5.0) } ! 5 ).kr(2, 1).poll * (-1) + 1},
		 ampDistParam:{Env.triangle(4.0, -1.0).kr(2, 1) + 1},
		 width:{Env.triangle(3.5, 0.5).kr(2, 1) + 1.015 },
		 type:\addMe).play
	 (beat: 5,which:1, chord: T( [1,-5, 3, 5, 6].df('f#', 4), 0.2, \lin ),knum:T([6, 12, 6, 6, 5], 1, \lin), type:\addMe).play;
 	 (beat: 5.5,chord: [1,-5, 3, 5, 5].df('f#', 4), type:\addMe).play;

	 (beat:6, chord: [1,2, 3, 5, 7].df('f', 4),amp:T([2, 2, 2, 2, 2] /3, 2, \lin), type:\addMe, knum:T(6, 2, \lin)).play;
	 (beat:8);
 	 (beat:7, chord: [1,-5, 3, 5, 7].df('f', 4),gates:[1, 1, 1, 0, 1], type:\addMe).play;
	 (beat:9, which:2 ,chord: T([1,-5,2.5 , 5, 7].df('f', 4), 0.5, \lin), type:\addMe).play;

 	 (beat:10,chord: T( [1.5,-4.5,2.5 , 6.5, 11.5].df('f', 4), 1, \lin ),gates:[1, 1, 1, 1, 1], type:\addMe).play;
	 (beat: 12,which:1, chord: [1.5,-11.5,2.5 , 6.5, 11.5].df('f', 4),gates:[1, 1, 1, 1, 1], type:\addMe).play;
	 (beat: 13,which:4, chord: [1.5,-11.5,2.5 , 6, 11.5].df('f', 4),gates:[1, 1, 1, 1, 1], type:\addMe).play;

 	 (beat: 14, chord: [1.5,-11.5,3 , 6, 11.5].df('f', 4),gates:[1, 1, 1, 1, 1], type:\addMe).play;
	 (beat: 15,chord: T( [1,-11,3 , 6, 11.5].df('f', 4), 0.2, \lin ),gates:[1, 1, 1, 1, 1], type:\addMe).play;
	 (beat: 16, chord: [1.5,-26,3 , 6, 11.5].df('f', 4),gates:[1, 1, 1, 1, 1], type:\addMe).play;
	 (beat: 18, chord: [1,-24, 3, 5, 6].df(\c), type:\addMe, knum:6).play;
	 (beat: 19, chord: [1,-21, 3, 5, 6].df(\d), type:\addMe, knum:6).play;
	 Yoeminrak.addDrum(\two);
	 (type:\cyc, song:\two, ).play;
     Yoeminrak.playVid(1,1, audio:false)
 );


 (
 Yoeminrak.song.five= List[];
 Event.addEventType(\addMe, {
     var env,env2, env3, getChordFreq;
     getChordFreq = { |e, filter|
         e.chord.notNil.if {
             var c = e.chord.isKindOf(Tuple3).if { e.chord.at1 }{ e.chord };
             c[e.which ? [0,1,2,3,4]] => ( filter ? I.d ) 
         }
     };
     env = currentEnvironment.copy;
     env.type = ~newType ? \yoeString3;
     env.section = 3;
     Yoeminrak.song.five.add(env);

     Yoeminrak.env[\preview].notNil.if { env.play };
     (env.harp.isNil and: env.chord.notNil).if {
         env2 = currentEnvironment.copy;
         env2.freq = { getChordFreq.value(env2) };
         env2.use {
             ~type = \default;
             ~instrument = \harp;
             ~coef = 0.1;
             ~latency= 0.025;
             ~strum = 0.1;
             ~amp = 0.1;
         };
         Yoeminrak.song.five.add(env2);
         Yoeminrak.env[\preview].notNil.if { env2.play };
		//
         env3 = currentEnvironment.copy;
	 // note this will follow the same "which" as the harp!!
         env3.freq = { getChordFreq.value(env3, {|i| i / 2}) };
         env3.use {
             ~type = \default;
             ~instrument = \stringyy;
             ~amp=1;
             ~latency= 0.025;
         };
         Yoeminrak.song.five.add(env3);
     };
 });
 Yoeminrak.env[\preview] = nil;
 // garlands!!

 (beat:2,instrument:\sawSynth, coef:0.1,latency:0.12,type:\addMe, newType:\garlands2,totalDur: 2,freq: [1, 2, 3, 4, 2, 5, 5, 4, 2, 4, 3,1, 11].df('g#').q,amp:0.2, out:Effect.bus({|i| DWGReverbC1C3.ar(i,mix:0.2) },), extraDur:2).play;
 (beat:6,instrument:\sparkTriangle, coef:0.1,latency:0.12,type:\addMe, newType:\garlands2,totalDur: 2,freq: [1, 2, 3, 4, 2, 5, 5, 4, 2, 4, 3,1, 11].df('g#').q,amp:0.1, out:Effect.bus({|i| DWGReverbC1C3.ar(i,mix:0.2) },), extraDur:2).play;
 (beat:3,latency:0.12,type:\addMe,numDivisions:22, newType:\garlands2,totalDur: 3,instrument:\bl,amp:0.9,initialDur:0.125 /2,freq: [1, 2, 3, 4, 2, 5, 5, 4, 2, 4, 3,1, 11].reverse.df('f#', 4).q(inf),amp:0.1, out:Effect.bus({|i| DWGReverbC1C3.ar(i,mix:0.2) },), extraDur:2).play;
 ///
 (beat: 0,chord: [1,2, 3, 5, 6].df('c#'), type:\addMe, knum:6).play;
 (beat: 3, extra:{[
     freq: [ 1, 5, ].df(\f,4).q,
     out: Effect.bus({|i| CombN.ar(i,0.5,0.3,3)/2 * [0,1] + (i * [1,0]) }),
     amp:0.5,
     latency:0,
     instrument:\sawSynthSustain,
     lagTime:1,
     dur: Yoeminrak.secDur[4]/20 //* 3/4
 ].ppm}, type:\addMe ).play;
 (beat: 8, extra:{[
     freq: [1, 5, ].df(\f,4).q,
     lagTime:1,
     latency:0,
     out: Effect.bus({|i| CombN.ar(i,0.5,0.3,3)/2 * [1,0] + (i * [0,1]) }),
     amp:0.5,
     instrument:\sawSynthSustain,
     dur: Yoeminrak.secDur[4]/20 //* 3/4
 ].ppm}, type:\addMe ).play;
 // (beat:0, extra: [dur:Yoeminrak.secDur[3]/20,instrument:\bd_808, amp:2].pp);
 // (beat: 0.33, chord: [1,2, 3, 5, 6].df('d#'), type:\addMe, knum:4).play;
 (beat: 0.33, chord: [1,2, 3, 5, 6].df('d#'),ornament:{ Env([0,0,-9.7!5],[0.64+0.96, 0.09]*Yoeminrak.secDur[3]/20).kr(2,gate:1)}, type:\addMe, knum:4).play;
 (beat: 1.98,gates:[0,0,0,0,0],release:0.9,  type:\addMe, knum:4).play;
 (beat: 2,chord:[1,2,3,5,6].df('c#'),ornament:{0!5},  type:\addMe, knum:{Env.triangle(5!5).kr(2,1) * 4 + 4}).play;
 (beat: 4.90,gates:[0,0,0,0,0],release:0.9,  type:\addMe, knum:4).play;
 (beat: 5,gates:[1, 1, 1, 1, 1],chord:[1,2,3,5,6].df('c#'),  type:\addMe, knum:4).play;
 (beat: 5.7,chord:[1,2,3,5,6].df('c'),  type:\addMe, knum:4).play;
 (beat: 6, chord: [1,2, 3, 5, 6].df('d#'),ornament:{ Env([0,0,-9.7!5],[0.92, 0.09]*Yoeminrak.secDur[4]/20).kr(2,gate:1)}, type:\addMe, knum:4).play;
 (beat: 7,chord:[1,2,3,5,6].df('c#'),ornament:{0!5},  type:\addMe, knum:5).play;
 (beat: 10,chord:[1,2,3,5,6].df('c#'),ornament:{0!5},  type:\addMe, knum:5).play;
 (beat: 10.33,chord:[1,2,3,5,6].df('d#'),ornament:{0!5},  type:\addMe, knum:5).play;
 (beat: 10.83,which:4,chord:[1,2,3,5,5].df('d#'),ornament:{0!5},  type:\addMe, knum:5).play;
 (beat: 11,chord:[1,2,3,5,6].df('d'),ornament:{0!5},  type:\addMe, knum:5).play;
 (beat:11, newType:\garlands, type:\addMe).play;

 Yoeminrak.addDrum(\five,[freq: [99*6.midiratio,99,99*(6).midiratio]]);
 (type:\cyc, song:\five,start:0 ).play;
 Yoeminrak.playVid(1,3, audio:false)
 );


// Yoeminrak.song.two.play(13)
(
   { // var tempoScale = 2;
   var tempoScale = 1;
   Yoeminrak.song.drums=List[];Yoeminrak.addDrum(section:\drums,);
   // (type:\cyc, song:\drums, sec:8).play;
   (type:\yoeString3, chord:[1, 2, 3, 5, 6].df('a-'), select:2).play;
   [
   freq: [-5, -6, -5, -6, 1, 2, 1, 2, 4, 5, 4, 5, -6, -6, -6, -7].df('a-', [3]).q,
   instrument:\default,
   amp:1,
   out: Effect.bus({|i| CrossoverDistortion.ar(i)/2 },),
   dur: Yoeminrak.secDur[8]/20/4 * tempoScale,

   // amp:0.6,
   // type:\yoeString3

   ].ppm;
   [
   freq: [\r, 5, 4, 4, 3, 1, 4, 3, 1, 3, 2 ].df('a-').q,
   dur: Yoeminrak.secDur[8]/40 * [0.5,0.75, 0.75, 
   0.75, 0.75, 0.5, 0.75, 0.75, 0.5, 1.5, 0.5
   // 0.70, 0.70, 0.59, 0.66, 0.67, 0.66
   ].q * tempoScale,
   instrument: [\stringyy, \harp],
   ceof:0.1,
   amp: [1,0.3],
   ].pp;
   (instrument: \cymbalsDS).play;
   Yoeminrak.playVid(1, 8, audio:false)
   }.()
   );