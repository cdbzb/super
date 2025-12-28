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
    [
   	 (root:  0,  knum:{SinOsc.ar(0.02 , 0!5).abs.poll * 5 + 2.1  }, select:0)
   	 ,
    (root:2, freqLag:1,), ()],
    (),
    (root:  -3,freqLag:3,),
    (),
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
   Yoeminrak.song[\two]=List[];
   Yoeminrak.addDrum(\two);
   [
       [
	   (root:0, knum:6),
           (root:2),
           ()
       ],
       (root: -3),
       (root: -6),
       (),
       (),
       (),

       (root: -7), //6
       (),
       (),
       (),


       (root: -1),
       (),
       (),
       (),


       (
	   extra:{(dur:4,amp:0.2,freq:1.df(\f, [4,3])).play}
       ), //14
       (root: 0, freqLag:0.5, ),
       (root: 2,
	   extra:{(dur:4,amp:0.2,freq:1.df(\d, [4,3])).play}
       ),
       (root: 0,
	   extra:{(dur:4,amp:0.2,freq:1.df(\f, [4,3])).play}
       ),
       (root: 2,
	   extra:{(dur:4,amp:0.2,freq:1.df(\d, [4,3])).play}
       ),
       (gates:[0,0,0,0,0]),
   ].addType(\yoeString3).add20(\two)
   )