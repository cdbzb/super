Yoeminrak.env[\silent] = true;

(
   Yoeminrak.initSong(\negativeOne, -1, tempoEvents:false);
   TempoClock.tempo_(1);
   (beat: 0, newType:\default,instrument:\stringyy,freq:33.df(\c) / [1, 2, 3, 5, 6],width:92,attack:6,release:8,amp:0.1,dur:10, type: \addMe).play;
   // (beat: 0, newType:\default,freq:4.df(\g),instrument:\defaultPorto,dur:8, att:5, type: \addMe).play;
   // events go here — 20 beats spanning ~3.34s (video 0s to sections[0])
   (type:\cycs, songs:[\negativeOne, \zero, \one, \two], keepPlaying:true).play;
   ~preview=true;
   );

(

   Yoeminrak.initSong(\zero, 0, tempoEvents:true);

   {
       var tempi = [0.9373, 0.8748, 0.8623, 0.9498, 0.9873, 0.8623, 0.8998, 0.9498, 0.9873, 1.0122, 1.1247, 1.0372, 1.0622, 1.0747, 0.9123, 1.0497, 0.9748, 1.0747, 1.1372, 1.2372].reciprocal ;
       tempi.do {|i x|
           (beat:x, extra:{TempoClock.tempo_(i)}, type:\addMe).play;
       };
   }.();

   // — addAll events —
   (beat: 0, extra:{
       [ freq: [\a,\c].collect{
           |i| [1, 2, 1, -6, -6, -5, -6,  1.5].df(i)}.flop .q,
           dur: [0.33, 0.67+ 0.67,0.33, 2, 0.34, 1.33, 0.34, 2] * Yoeminrak.secDur[0] / 20 => _.q(inf),
           out: Effect.bus({|i| FreeVerb.ar(i,1,1) *4 }, inputChannels:2),
           pan:1
       ].pp
   }, type:\addMe).play;
   (beat: 6, extra:{
       (
           freq: [1, 3, 5, 7, 11, 13, 15, 17].df('c#'),
           strum: 0.05,
           out: {Effect.bus({|i| FreeVerb.ar(i,1,1) }, inputChannels:2)},
           amp:0.5,
           pan:1
       ).play
   }, type:\addMe).play;
   (beat: 7, extra:{[
       out: Effect.bus({|i| FreeVerb.ar(i,1,1) }),
       freq: [
           [ 7, 6.5, 7,7,6.5].df(\c),
           [ 1, 1.5, 1,1,1.5].df(\c),
       ].flop.q,
       pan: [-1,0.7],
       dur: "e eee ee e ee".beats * Yoeminrak.secDur[0] / 20 / 2 => _.q,
       amp: 0.5
   ].pp}, type:\addMe).play;
   (beat: 10, extra:{
       [ freq: [\a,\c].collect{
           |i| [1.5, 2.5, 1.5, 1, \r].df(i)}.flop .q,
           dur: [1 - 0.66, 2.66 + 0.66,0.33, 1, 1] * Yoeminrak.secDur[0] / 20 => _.q(inf),
           out: Effect.bus({|i| FreeVerb.ar(i,1,1) *4 }, inputChannels:2),
           pan:1
       ].pp
   }, type:\addMe).play;

   // — add20 events (beat = index) —
   (beat: 0, root:  0, knum:{SinOsc.ar(0.02, 0!5).abs.poll * 5 + 2.1}, select:0, type:\addMe).play;
   (beat: 0, root:2, freqLag:1, type:\addMe).play;
   (beat: 0, type:\addMe).play;
   (beat: 1, type:\addMe).play;
   (beat: 2, root: -3, freqLag:3, type:\addMe).play;
   (beat: 3, type:\addMe).play;
   (beat: 4, root:-3, type:\addMe).play;
   (beat: 4, root:-5, freqLag:1, type:\addMe).play;
   (beat: 4, type:\addMe).play;
   (beat: 5, type:\addMe).play;
   (beat: 5, type:\addMe).play;
   (beat: 5, root:-3, type:\addMe).play;
   (beat: 6, root:1, freqLag:3, ampDistParam:0, type:\addMe).play;
   (beat: 7,
       select: {Env.triangle(Yoeminrak.secDur[0]/5).kr(2,1) * 2},
       chord: {var up = [-7,2,3,5,6.5].df('c');Env([up,up, [1, 2, 3, 5, 6].df(\c)], 0.5, \wel).kr(2, 1)},
       // amp: T(4,1),
       root: 1,
       extra: {(freq: -7.df('c#'),instrument:\harp, coef:0.1, amp:0.2).play},
       freqLag:0, type:\addMe).play;
   (beat: 8,
       chord: {var up = [-7,2,3,5,6.5].df('c');Env([up,up, [1, 2, 3, 5, 6].df(\c)], 0.5, \wel).kr(2, 1)},
       root: 1,
       extra: {(freq: -5.df('c#'),instrument:\harp, coef:0.1, amp:0.2).play},
       type:\addMe).play;
   (beat: 9, extra: {(freq: -4.df('c#'),instrument:\harp, coef:0.1, amp:0.2).play}, type:\addMe).play;
   (beat: 10, root:1, extra: {(freq: -3.df('c#'),instrument:\harp,lag:0.05, coef:0.1, amp:0.2).play}, type:\addMe).play;
   (beat: 10, root:3, freqLag:1, type:\addMe).play;
   (beat: 10, type:\addMe).play;
   (beat: 11, type:\addMe).play;
   (beat: 12, type:\addMe).play;
   (beat: 13, type:\addMe).play;
   // (beat: 13, root:T(1, 2.5, \lin), type:\addMe).play;
   (beat: 13, type:\addMe).play;
   (beat: 13, root:1, freqLag:3, type:\addMe).play;
   (beat: 14, root:T(0, 3, \lin), select: {LFTri.kr(0.1).range(0,0.25)}, chord:T([1, 3, 5, 6, 12].df(\c),2, \lin), type:\addMe).play;
   (beat: 15, select:0, release:3, type:\addMe).play;
   (beat: 16, ampScale:T(0.3,6,\lin), extra:{(freq: 1.df('c'),instrument:\harp,lag:-0.05, coef:0.1, amp:0.1).play}, type:\addMe).play;
   (beat: 17, extra:{(freq: -7.df('c'),instrument:\harp,lag:0.05, coef:0.1, amp:0.2).play}, type:\addMe).play;
   (beat: 18, extra:{(freq: -7.df('c'),instrument:\harp,lag:-0.05, coef:0.1, amp:0.1).play}, type:\addMe).play;
   (beat: 19, gates:[0,0,0,0,0], release:8, root: T(-5, 2, 1),
       extra:{(freq: -5.df('c'),instrument:\harp,lag:0.05, coef:0.1, amp:0.1).play},
       type:\addMe).play;

   // [ type:\yoeString3, ornament:{LFNoise2.kr(2!5) * Line.kr(1,0,2,doneAction:2)},beat:[2, 4, 5, 7, 8, 10, 11, 12, 14, 15, 17, 19] ].flop.collect{|i| i.asEvent}.do{|e| Yoeminrak.song.zero.add(e)};
   Yoeminrak.addDrum(\zero,[freq:[99,99,105,99]]);
   (type:\cycs, songs:[ \zero, \one ], keepPlaying:true).play;
   ~preview=true;
   );

 (
     Yoeminrak.initSong(\one, 1, tempoEvents:true);
 	 (beat: 0,chord: [1,2, 3, 5, 6].df(\c), type:\addMe, knum:6).play;
	 (beat: 0, newType:\yoeDrum0, freq:99, amp:1, type:\addMe ).play;

 	 (beat: 0.3,chord: [1,2, 3, 5, 6].df(\d), type:\addMe).play;
	 (beat: 0.5,harp: false, gates:[1,0,1,0,1], type:\addMe).play;
	 (beat: 1, newType:\yoeDrum1, freq:99, amp:1, type:\addMe).play;
 	 (beat: 1, chord: T([1,2, 3, 5, 6].df(\A), 1, \lin), type:\addMe).play;
	 (beat: 2,which:0,amp:T([2, 2, 2, 1.2, 1.2], 0.3, \lin), chord: T([-6.5,1, 2, 5, 6].df(\A ), 0.3, \lin), type:\addMe).play;
 	 (beat: 2.66,which:[4], chord: [-6.5,1, 2, 5, 5].df(\A), type:\addMe).play;
	 (beat: 3, chord: [1,2, 3, 5, 6].df('f#', 4), type:\addMe, knum:T(6, 4, \lin)).play;
	 (beat:3.05, harp:false,
         ornament: {[0,0,0,0] ++ Env.perc(0.2,1).kr(2,1) * 19},
		 ampScale:{Env.perc( 0.5,{3.0.rrand(5) }.dup(5) / 2, 0.5).kr(2, 1) + 0.5},
		 
		 durScale:{Env.perc(0.5,{3.0.rrand(5)}.dup(5) / 2, 0.5).kr(2, 1) + 0.5},
		 // ampParam:{Env.triangle(3.0, 0.5).kr(2, 1) + 0.5},
		 durDistParam:{Env.triangle({ 4.0.rrand(5.0) } ! 5 ).kr(2, 1).poll * (-1) + 1},
		 ampDistParam:{Env.triangle(4.0, -1.0).kr(2, 1) + 1},
		 width:{Env.triangle(3.5, 0.5).kr(2, 1) + 1.015 },
		 type:\addMe).play;
	 (beat: 5,which:1, chord: T( [1,-5, 3, 5, 6].df('f#', 4), 0.2, \lin ),knum:T([6, 12, 6, 6, 5], 1, \lin), type:\addMe).play;
 	 (beat: 5.5,chord: [1,-5, 3, 5, 5].df('f#', 4), type:\addMe).play;

	 (beat:6, chord: [1,2, 3, 5, 7].df('f', 4),amp:T([2, 2, 2, 2, 2] /3, 2, \lin), type:\addMe, knum:T(6, 2, \lin)).play;
	 (beat:8);
 	 (beat:7, chord: [1,-5, 3, 5, 7].df('f', 4),gates:[1, 1, 1, 0, 1], type:\addMe).play;
	 (beat:9, which:2 ,chord: T([1,-5,2.5 , 5, 7].df('f', 4), 0.5, \lin), type:\addMe).play;

	 (beat: 10, newType:\yoeDrum1, freq:99, amp:1, type:\addMe).play;
	 (beat:10,which:[1, 2,3, 4],chord: T( [1.5,-4.5,2.5 , 6.5, 11.5].df('f', 4), 1, \lin ),gates:[1, 1, 1, 1, 1], type:\addMe).play;
	 // (beat: 12,extra:{(type:\garlands).play},which:[ 1, 0 ], chord: [1.5,-11.5,2.5 , 6.5, 11.5].df('f', 4),gates:[1, 1, 1, 1, 1], type:\addMe).play;
	 (beat: 13,which:4, chord: [1.5,-11.5,2.5 , 6, 11.5].df('f', 4),gates:[1, 1, 1, 1, 1], type:\addMe).play;

	 (beat: 14, newType:\yoeDrum2, freq:99, amp:0.1,  type:\addMe).play;
 	 (beat: 14, chord: [1.5,-11.5,3 , 6, 11.5].df('f', 4),gates:[1, 1, 1, 1, 1], type:\addMe).play;
	 (beat: 15, newType:\yoeDrum3, freq:99, amp:0.1, type:\addMe).play;
	 (beat: 15,chord: T( [1,-11,3 , 6, 11.5].df('f', 4), 0.2, \lin ),gates:[1, 1, 1, 1, 1], type:\addMe).play;
	 (beat: 16, chord: [1.5,-26,3 , 6, 11.5].df('f', 4), type:\addMe).play;
	 // (beat:16.5,chord:[1, 2, 3, 5, 6].df(\c), gates:[0,0,0,0,0], type:\addMe).play;
	 (beat: 18, chord: T([-5,-24, 3, 1, 6].df(\c), 0.2, \lin), type:\addMe, knum:6).play;
	 (beat: 19, chord: T([-5,-21, 3, 1, 6].df(\d), 0.2, \lin), type:\addMe, knum:6).play;
	 // Yoeminrak.addDrum(\one);
	 // Yoeminrak.song.one = Yoeminrak.song.one.collect {|i| i.beat = i.beat + Env([0,3,0],Yoeminrak.secDur[1]/2).at(i.beat); i
	 // };
	 (type:\cycs, songs:[ \one, \two, \three ], keepPlaying:true).play;
     ~preview=true;
 );


 (
    Yoeminrak.initSong(\two, 2, tempoEvents:true);

 (beat: 0,select:1.0,chord: [1,2, 3, 5, 6].df(\c), type:\addMe, knum:6).play;

 (beat: 1/3,chord: [1,2, 3, 5, 6].df(\d), type:\addMe).play;
 // (beat: 0.5,harp: false, gates:[1,0,1,0,1], type:\addMe).play;
 (beat: 1.7,which:[0,4],chord: [1,2, 3, 5, 6].df(\c), type:\addMe, knum:6).play;
 (beat: 2, chord: T([1,2, 3, 5, 6].df(\A), 1, \lin), type:\addMe).play;
 (beat: 3,width:{Env.triangle(1.5).kr+1.015 },which:4,amp:T([2,2,2,2,2]  /3, 1, \lin), chord: T([-7,2, 3, 5, 6.5].df(\A), 0, \lin), type:\addMe).play;
 (beat: 3.5,which:4, chord: T([1,2, 3, 5, 6].df(\A), 0, \lin), type:\addMe).play;
 (beat:3.5, extra:{
     [
         latency:0.08,
         amp:[5, 4, 3, 2, 1].q / 5 * 0.3,
         instrument:\sawSynth,
         freq: [3, 5, [3,5],[3,5],[3,5], [3, 5]].df(\d, 4).q,
         dur:Yoeminrak.secDur[2] / 40 * [2, 1.5, 1, 1, 1].q
     ].pp
 }, type:\addMe).play;
 (beat: 4, which:4, chord: T([1,2, 3, 5, 5].df(\A), 0.2, \lin), type:\addMe).play;
 (beat: 4.7, which:4, chord: T([1,2, 3, 5, 3].df(\A), 0, \lin), type:\addMe).play;
 (beat: 5, which:nil, chord: T( [3,5, 3, 12, 12].df('d', 4), 0.2, \lin ),knum:T([6, 12, 6, 6, 5], 1, \lin), type:\addMe).play;
 (beat: 6, which:[0,1], chord: T( [4.5,6, 4.5, 12, 12].df('d', 4), 0.2, \lin ),knum:T([6, 12, 6, 6, 5], 1, \lin), type:\addMe).play;
 (beat: 6.5, which:[4,3], chord: T( [4.5,6, 4.5, 12.5, 12.5].df('d', 4), 0.2, \lin ),knum:T([6, 12, 6, 6, 5], 1, \lin), type:\addMe).play;

 (beat:7, which:nil, chord: [1,2, 3, 5, 6].df('b-', 4),amp:T([2, 2, 2, 1, 1] /3, 0, \lin), type:\addMe).play;
 (beat:8.7, which:[0,4], chord: [-7,2, 3, 3, 5.5].df('b-', 4),amp:T([2, 2, 2, 1, 1] /3, 0, \lin), type:\addMe).play;
 (beat:9, chord:[-5, 1, 3, 5, 3].df(\c),type:\addMe).play;
 (beat:10, chord:[-5, -7, 3, 5, 3].df(\c),type:\addMe).play;
 (beat:10.5, chord:[-5, -7, 2, 5, 2].df(\c),type:\addMe).play;
 (beat:11, which:nil, chord: [-3,-5,1, 3, 1].df('f' ),amp:T([2, 2, 2, 1, 1] /3, 0, \lin), type:\addMe).play;
 (beat:12, which:nil, chord: [-3,-5,1, 3, 1].df('f', \minor ),amp:T([2, 2, 2, 1, 1] /3, 0, \lin), type:\addMe).play;
 (beat:12.5, which:nil, chord: [-3,-5,-7, 3, -7].df('f', \minor ),amp:T([2, 2, 2, 1, 1] /3, 0, \lin), type:\addMe).play;
 (beat:13, which: nil,chord:[3, 4, 5, 11, 12].df(\d,4, \minor ), type:\addMe).play;
 (beat:15, which: nil,chord:T([1, 2, 3, 5, 6].df(\c), 2, \lin),knum:T( 10, 8,\lin ), type:\addMe).play;
    (beat: 16, newType:\garlands,  type: \addMe).play;
    (beat: 17, newType:\garlands,  type: \addMe).play;
    (beat: 18, newType:\garlands,  type: \addMe).play;
    (beat: 19, newType:\garlands,  type: \addMe).play;
    (beat: 19.8, gates:[0,0,0,0,0],release:1.3,  type: \addMe).play;

 Yoeminrak.addDrum(\two,[freq: [99*5.midiratio,99,99*(1).midiratio]]);
    (type:\cycs, songs:[ \two, \three ],start:Yoeminrak.env[\cursor] ).play;
    ~preview=true;
 // Yoeminrak.playVid(1,2, audio:false)
 );

(
   Yoeminrak.initSong(\three, 3, tempoEvents:true);
   (beat: 0, extra:{(instrument:\reedy,amp:1, freq:[-21,-11].df(\b), latency:0).play},which:[1, 2, 3, 4], chord:[-21,-11,-1,1,11].df(\b), type: \addMe).play;
   (beat: 0, newType:\yoeDrum0, amp:1, freq: 99* (4).midiratio , type: \addMe).play;
   (beat:0.05,amp: T([2, 2, 2, 2, 0.5],4, \lin), type:\addMe).play;
   (beat: 1, newType:\yoeDrum1,  type: \addMe).play;
   (beat: 1.6,lag:0.1,which:3, chord:T([-21, -11, -1, -7, 11].df(\b, \mixolydian), 0.2, -8), type: \addMe).play;
    (beat: 2,which:3, chord:T([-21, -11, -1, -5, 11].df(\b, \mixolydian), 0.6, -6), type: \addMe).play;

   (beat: 3-0.05, which: 3, chord: [-21, -11, -1, -5.5, 11].df(\b), type: \addMe).play;
   (beat: 3.05, which: 3, chord: [-21, -11, -1, -5, 11].df(\b), type: \addMe).play;
   (beat: 3.15, which: 3, chord: [-21, -11, -1, -4, 11].df(\b), type: \addMe).play;
   (beat: 3.7, which: 3, chord: [-21, -11, -1, -3, 11].df(\b), type: \addMe).play;
   (beat: 4, which: [ 2,3 ],amp: T([2, 2, 2, 1, 0.5],2,\lin), chord: [-21, -11, -2, -5.5, 11].df(\b), type: \addMe).play;
   // (beat: 4.1,gates:[0,0,0,0,0],release:4, type: \addMe).play;
   ~threeEndOct=2;
   (beat: 6,strum:0.04, chord: [1,2,3,5,6].df(\G)*~threeEndOct, type: \addMe).play;
   (beat: 6, newType: \yoeDrum0, freq: 99 * -5.midiratio * 2, amp:0.2,type: \addMe).play;
   (beat: 6.3,strum:0.04, chord: [1,2,3,5,6].df(\A) * ~threeEndOct, type: \addMe).play;
   (beat: 6.8, which:4,strum:0.04, chord: [1,2,3,5.5,5.5].df(\A) * ~threeEndOct, type: \addMe).play;
   (beat: 7, chord: [1, 2, 3, -5, 6].df(\G) * ~threeEndOct, type: \addMe).play;
   (beat: 8.7,which:4, chord: [1, 2, 3, -5.5, 5.5].df(\G) * ~threeEndOct, type: \addMe).play;
   (beat: 9, which:[0,3,4],strum:0,chord: [-7, 2, 3, -6.5, 6.5].df(\G) * ~threeEndOct, type: \addMe).play;
   (beat: 9.3, which:[0,3,4],strum:0,chord: [-7, 2, 3, -6.5, 6.5].df(\G) * ~threeEndOct, type: \addMe).play;
   (beat: 9.45, which:[0,4],strum:0,chord: [1, 2, 3, -5, 6].df(\G) * ~threeEndOct, type: \addMe).play;

   (beat: 10,strum:0.04, chord: [1,2,3,5,6].df(\G) * ~threeEndOct, type: \addMe).play;
   (beat: 10, newType: \yoeDrum1,type: \addMe).play;
   (beat: 10.3,strum:0.04, chord: [1,2,3,5,6].df(\A) * ~threeEndOct, type: \addMe).play;
   (beat: 11.8, which:4,strum:0.04, chord: [1,2,3,5.5,5.5].df(\A) * ~threeEndOct, type: \addMe).play;
   (beat: 12,extra:{(freq:1.df(\e, 3), amp:1).play}, chord: [1, -6, 3, -5, 6].df(\G) * ~threeEndOct, type: \addMe).play;
   (beat: 13,extra:{(freq:1.df('e-', 3), amp:1).play}, chord: [1, 2, 3, 11, 6].df('E-') * ~threeEndOct, type: \addMe).play;
   (beat: 13, extra: {
       [
	   freq: [11, 7, 5, 4, 3, 5.5].df('e-',[4], \mixolydian).q,
	   dur: [1.7,0.3, 1, 0.7, 0.3, 2].q * Yoeminrak.secDur[3] / 20 ,
	   instrument:\reedy, release:3, amp:0.7
       ].pp;
       [
	   freq: [11, 7, 5, 4, 3, 2].df('e-',[3], \mixolydian).q,
	   dur: [1.7,0.3, 1, 0.7, 0.3, 2].q * Yoeminrak.secDur[3] / 20 ,
	   instrument:\wash
       ].pp;
       [
	   freq: [11, 7, 5, 4, 3, 2].df('e-',[4], \mixolydian).q,
	   dur:  Yoeminrak.secDur[3] / 20 ,
	   instrument:\defaultPiano, amp:0.1, modWidth: 0.02, coef:0.2

       ].pp;
       
   },  type: \addMe).play;
   (beat: 14.9,lag:0.1,which:3, chord:T([-21, -11, -1, -7, 11].df('e-', \mixolydian), 0.2, -8), type: \addMe).play;
    (beat: 15,which:3, chord:T([-21, -11, -1, -5, 11].df('e-', \mixolydian), 0.6, -6), type: \addMe).play;

   (beat: 16-0.05, which: 3, chord: [-21, -11, -1, -5.5, 11].df('e-'), type: \addMe).play;
   (beat: 16.05, which: 3, chord: [-21, -11, -1, -5, 11].df('e-'), type: \addMe).play;
   (beat: 16.15, which: 3, chord: [-21, -11, -1, -4, 11].df('e-'), type: \addMe).play;
   (beat: 16.7, which: 3, chord: [-21, -11, -1, -3, 11].df('e-'), type: \addMe).play;
   (beat: 17, which: [ 2,3 ],amp: T([2, 2, 2, 1, 0.5],2,\lin), chord: [-21, -11, -2, -5.5, 11].df('e-'), type: \addMe).play;
   (beat: 14, newType:\yoeDrum2 , type: \addMe).play;
   (beat: 15, newType:\yoeDrum3 , type: \addMe).play;
   (beat: 19.8, gates:[0,0,0,0,0], release:1.2, type: \addMe).play;
   (beat: 19, newType: \garlands, type:\addMe).play;
   (beat: 17,which:2,chord:[-21, -11, -2, -5.5, 11].df('e-'), type: \addMe).play;
   (beat: 18,which:4,chord:[-21, -11, -2, -5.5, 11].df('e-'), type: \addMe).play;
   (beat: 19,which:2,chord:[-21, -11, -2, -5.5, 11].df('e-'), type: \addMe).play;
   (type:\cycs, songs:[ \three, \four ], start:Yoeminrak.env[\cursor]).play;
   // (Yoeminrak.env[\vid] ? false).if {Yoeminrak.playVid(1,5, audio:false)};
   ~preview=true;
   );


 (
    Yoeminrak.initSong(\four, 4, tempoEvents:true);
 // garlands!!

 (beat:2,instrument:\sawSynth, coef:0.1,latency:0.12,type:\addMe, newType:\garlands2,totalDur: 2,freq: [1, 2, 3, 4, 2, 5, 5, 4, 2, 4, 3,1, 11].df('g#').q,amp:0.2, out:Effect.bus({|i| DWGReverbC1C3.ar(i,mix:0.2) },), extraDur:2).play;
 (beat:6,instrument:\sparkTriangle, coef:0.1,latency:0.12,type:\addMe, newType:\garlands2,totalDur: 2,freq: [1, 2, 3, 4, 2, 5, 5, 4, 2, 4, 3,1, 11].df('g#').q,amp:0.1, out:Effect.bus({|i| DWGReverbC1C3.ar(i,mix:0.2) },), extraDur:2).play;
    (beat:3,latency:0.12,type:\addMe,numDivisions:22, newType:\garlands2,totalDur: 3,instrument:\bl,instrument:\reedy,initialDur:0.125 /2,freq: [1, 2, 3, 4, 2, 5, 5, 4, 2, 4, 3,1, 11].reverse.df('f', 4).q(inf),amp:0.1,totalDur:2, out:Effect.bus({|i| DWGReverbC1C3.ar(i,mix:0.2) },), extraDur:2).play;
    (beat:8,latency:0.12,type:\addMe,numDivisions:22, newType:\garlands2,totalDur: 3,instrument:\bl,amp:0.9,initialDur:0.125 /2,freq: [1, 2, 3, 4, 2, 5, 5, 4, 2, 4, 3,1, 11].reverse.df('f', 4).q(inf),totalDur:2, out:Effect.bus({|i| DWGReverbC1C3.ar(i,mix:0.2) },),amp:0.3, extraDur:2).play;
 ///
 (beat: 0,chord: [1,2, 3, 5, 6].df('c#'), type:\addMe, knum:6).play;
 (beat: 3, extra:{
     [
     freq: [ 1, 5, ].df(\f,4).q,
     out: Effect.bus({|i| CombN.ar(i,0.5,0.3,3)/2 * [0,1] + (i * [1,0]) }),
     amp:0.5,
     latency:0,
     instrument:\sawSynthSustain,
     lagTime:1,
     dur: Yoeminrak.secDur[4]/20 //* 3/4
 ].ppm;
    }, type:\addMe ).play;
    // (beat:3, type:\garlands2, freq: Yoeminrak.env[\chord].getnSynchronous.q(inf)).play;
    (beat: 3, extra:{  
	var dur = Yoeminrak.secDur[4]/20 * [1, 1,  0.7, 0.3, 1, 1] => _.q;
	[instrument: \sparkTriangle, freq: [1, 2, 3, 2.5, 4, 3].df('c#',4, \lydian).q,pan:-1, dur: dur, amp:0.2].ppm;
	[instrument: \reedy,freq: [3, 4, 5, 4,   6, 5].df('c#',4, \lydian).q,pan:1, dur: dur, amp:0.5].ppm
    }, type: \addMe).play;
// FIX THIS !!!!!
    (beat: 8, extra:{  
	var dur = Yoeminrak.secDur[4]/20 * [1, 1,  0.3, 0.5,0.3, 1] => _.q;
	[instrument: \reedy, freq: [1, 2, 3, 4, 3, 3.5].df('c#',4, \lydian).q,pan:-1, dur: dur, amp:0.5].ppm;
	[instrument: \sparkTriangle,freq: [3, 4, 5,  6, 5, 5.5].df('c#',4, \lydian).q,pan:1, dur: dur, amp:0.15].ppm
    }, type: \addMe).play;
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
 // (beat: 0.33, chord: [1,2, 3, 5, 6].df('d#'),ornament:{ Env([0,0,-9.7!5],[0.64+0.96, 0.09]*Yoeminrak.secDur[4]/20).kr(2,gate:1)}, type:\addMe, knum:4).play;
 (beat: 0.33, chord: [1,2, 3, 5, 6].df('d#'),ornament: ~quickDip.(1.66,true), type:\addMe, knum:4).play;
 (beat: 1.98,gates:[0,0,0,0,0],release:0.9,  type:\addMe, knum:4).play;
 (beat: 2,chord:[1,2,3,5,6].df('c#'),ornament:{0!5},  type:\addMe, knum:{Env.triangle(5!5).kr(2,1) * 4 + 4}).play;
 (beat: 4.90,gates:[0,0,0,0,0],release:0.9,  type:\addMe, knum:4).play;
 (beat: 5,gates:[1, 1, 1, 1, 1],chord:[1,2,3,5,6].df('c#'),  type:\addMe, knum:4).play;
 (beat: 5.7,chord:[1,2,3,5,6].df('c'),  type:\addMe, knum:4).play;
 (beat: 6, chord: [1,2, 3, 5, 6].df('d#'),ornament:{ Env([0,0,-9.7!5],[0.92, 0.09]*Yoeminrak.secDur[4]/20).kr(2,gate:1)}, type:\addMe, knum:4).play;
 (beat: 7,chord:[1,2,3,5,6].df('c#'),ornament:{0!5},  type:\addMe, knum:5).play;
 (beat: 10,chord:[1,2,3,5,6].df('c#'),ornament:{0!5},  type:\addMe, knum:5).play;
 (beat: 10.33,chord:[1,2,3,5,6].df('d#'),ornament:{0!5},  type:\addMe, knum:5).play;
 (beat: 10.83,which:4,chord:[1,2,3,5,5].df('d#'),ornament:{0!5},  type:\addMe, knum:4).play;
    (beat: 11,chord:T([1,2,3,5,6].df('d'),2, \lin),ornament:{SinOsc.ar(5)!5/3 * Env([0.2, 1, 0], [1.5, 3]).kr(2)},extra:{(
    	amp: 1,
    	freq:[-1, 3, -5,6].df(\d, 4),
	strum:0.06,
	instrument:\harp,
	out: Effect.bus({|i| CombC.ar(i, 0.3,0.2, 5)/4+i => LPF.ar(_, 200) },)
    ) .play},  type:\addMe, knum:T( 3, 2, \lin )).play;
    (beat:11,ornament:{DC.ar(0)!5}, newType:\garlands,totalDur:3, type:\addMe,useConvolution:false, gain:9,useGendy:true,ratio:0.25).play;
    (beat:12,extra:{(freq: [-5, 3].df('f#',4), amp:0.5, latency:0, instrument: \defaultPiano).play}, chord: [1,2,  4,5, 6].df('c#', 5), type:\addMe).play;
    (beat:12.3,which: 4,extra:{(freq:  4.5.df('f#',4), amp:0.5, latency:0, instrument: \defaultPiano).play}, chord: [1,2,  3,5, 5].df('c#', 5), type:\addMe).play;
    (beat:12.7,which:[ 4],extra: {[latency: 0.0, freq:[[3, 3], [2,-2]].df('f#',4).q, amp:0.5, instrument: \defaultPiano,lagTime:0.5, amp:[0.3, 0.4	].q].pm.play},ornament:{0!5},amp:1.5, chord: [1,2,3,4,4].df('c#', 5), type:\addMe).play;
    (beat:13,ornament:{0!5},gates:[1, 0, 1, 0, 1],release:2, chord: T( [1, 2, 3, 5, 6].df('a-', 4), 0.0, \lin ), type:\addMe).play;
    (beat:14, extra:{
	[
	    freq: [3, 4, 6].df(\c, 4).q,
	    amp:2,
	    dur: Yoeminrak.secDur[4]/20/3,
	    latency:0.1
	].ppm;
	(instrument:\reedy,amp:1,release:4, freq: 1.df(\c, 4)).play

    }, chord: [1, 2, 3, 5, 6.6].df(\c),type:\addMe
    ).play;
    (beat:14.3,  chord: [1, 2, 3, 5, 6].df(\c),type:\addMe).play;
    (beat:14.7,  chord: [1, 2, 4, 5, 4].df(\c),type:\addMe).play;
    (beat:15, chord:[1, 1, 3, 6, 6].df(\g, 4), type:\addMe).play;
    (beat:15.7,which:[4], chord:[1, 1, 3, 5, 5].df(\g, 4), type:\addMe).play;
    (beat:16, extra: {
	[
	    freq: [1, 2].df('e-', 4).q,
	    amp:  1,
	    dur:  Yoeminrak.secDur[4]/20,
	    legato:2
	].pp;
    },  chord:    T([1, 2, 3, 5, 6].df('e-'), 0.5, \lin), type:\addMe).play;

    (beat:17, extra: { (type: \garlands).play; }, type:\addMe).play;
    (beat:18, extra: { (type: \garlands, useConvolution:true).play; }, type:\addMe).play;
    (beat:19, gates:[0,0,0,0,0],release:2, type:\addMe).play;

 Yoeminrak.addDrum(\four,[freq: [99*6.midiratio,99,99*(6).midiratio]], 5);
 (type:\cycs, songs:[\four, \five] ).play;
    // (Yoeminrak.env[\vid] ? false).if {Yoeminrak.playVid(1,5, audio:false)};
    ~preview=true;
 );


 (
     Yoeminrak.initSong(\five, 5, tempoEvents:true);

 (beat:2,instrument:\sawSynth, coef:0.1,latency:0.12,type:\addMe, newType:\garlands2,totalDur: 2,freq: [1, 2, 3, 4, 2, 5, 5, 4, 2, 4, 3,1, 11].df('g#').q,amp:0.2, out:Effect.bus({|i| DWGReverbC1C3.ar(i,mix:0.2) },), extraDur:2).play;
 (beat:6,instrument:\sparkTriangle, coef:0.1,latency:0.12,type:\addMe, newType:\garlands2,totalDur: 2,freq: [1, 2, 3, 4, 2, 5, 5, 4, 2, 4, 3,1, 11].df('g#').q,amp:0.1, out:Effect.bus({|i| DWGReverbC1C3.ar(i,mix:0.2) },), extraDur:2).play;
    (beat:3,latency:0.12,type:\addMe,numDivisions:22, newType:\garlands2,totalDur: 3,instrument:\bl,instrument:\reedy,initialDur:0.125 /2,freq: [1, 2, 3, 4, 2, 5, 5, 4, 2, 4, 3,1, 11].reverse.df('f', 4).q(inf),amp:0.1,totalDur:2, out:Effect.bus({|i| DWGReverbC1C3.ar(i,mix:0.2) },), extraDur:2).play;
    (beat:8,latency:0.12,type:\addMe,numDivisions:22, newType:\garlands2,totalDur: 3,instrument:\bl,amp:0.9,initialDur:0.125 /2,freq: [1, 2, 3, 4, 2, 5, 5, 4, 2, 4, 3,1, 11].reverse.df('f', 4).q(inf),totalDur:2, out:Effect.bus({|i| DWGReverbC1C3.ar(i,mix:0.2) },),amp:0.3, extraDur:2).play;
 ///
 (beat: 0,chord: [1,2, 3, 5, 6].df('c#'), type:\addMe, knum:6).play;
 (beat: 3, extra:{[
     freq: [ 1, 5, ].df(\f,4).q,
     out: Effect.bus({|i| CombN.ar(i,0.5,0.3,3)/2 * [0,1] + (i * [1,0]) }),
     amp:0.5,
     latency:0,
     instrument:\sawSynthSustain,
     lagTime:1,
     dur: Yoeminrak.secDur[5]/20 //* 3/4
 ].ppm}, type:\addMe ).play;
    // (beat:3, type:\garlands2, freq: Yoeminrak.env[\chord].getnSynchronous.q(inf)).play;
 (beat: 8, extra:{[
     freq: [1, 5, ].df(\f,4).q,
     lagTime:1,
     latency:0,
     out: Effect.bus({|i| CombN.ar(i,0.5,0.3,3)/2 * [1,0] + (i * [0,1]) }),
     amp:0.5,
     instrument:\sawSynthSustain,
     dur: Yoeminrak.secDur[5]/20 //* 3/4
 ].ppm}, type:\addMe ).play;
 // (beat:0, extra: [dur:Yoeminrak.secDur[3]/20,instrument:\bd_808, amp:2].pp);
 // (beat: 0.33, chord: [1,2, 3, 5, 6].df('d#'), type:\addMe, knum:4).play;
 // (beat: 0.33, chord: [1,2, 3, 5, 6].df('d#'),ornament:{ Env([0,0,-9.7!5],[0.64+0.96, 0.09]*Yoeminrak.secDur[5]/20).kr(2,gate:1)}, type:\addMe, knum:4).play;
 (beat: 0.33, chord: [1,2, 3, 5, 6].df('d#'),ornament: ~quickDip.(1.66, true), type:\addMe, knum:4).play;
 (beat: 1.98,gates:[0,0,0,0,0],release:0.9,  type:\addMe, knum:4).play;
 (beat: 2,chord:[1,2,3,5,6].df('c#'),  type:\addMe, knum:{Env.triangle(5!5).kr(2,1) * 4 + 4}).play;
 (beat: 4.90,gates:[0,0,0,0,0],release:0.9,  type:\addMe, knum:4).play;
 (beat: 5,gates:[1, 1, 1, 1, 1],chord:[1,2,3,5,6].df('c#'),  type:\addMe, knum:4).play;
 (beat: 5.7,chord:[1,2,3,5,6].df('c'),  type:\addMe, knum:4).play;
 (beat: 6, chord: T( [1,2, 3, 5, 6].df('d#'), 0.1, \lin ),ornament:{ Env([0,0,-9.7!5],[0.92, 0.09]*Yoeminrak.secDur[5]/20).kr(2,gate:1)}, type:\addMe, knum:4).play;
 (beat: 7,chord:[1,2,3,5,6].df('c#'),  type:\addMe, knum:5).play;
    (beat: 10, strum: 0.03,chord: [1, 3, 6, 3, 1].df('c#'), type: \addMe).play;
    (beat: 10.25, chord: [1, 3, 6, 3, 1].df('d#'), type: \addMe).play;
    (beat: 10.75,which:2, chord: [1, 3, 5.5, 3, 1].df('d#'), type: \addMe).play;
    (beat: 11, chord: [1, 3, 6, 3, 1].df('c#'), type: \addMe).play;
    (beat: 11.7,strum: 0.02, chord: [1, 3, 6, 3, 1].df('d#'), type: \addMe).play;
    (beat: 12,strum:0.03, chord: [1, 3, 6, 2, 6].df('e'), type: \addMe).play;
    (beat: 12,extra: {[freq:[1, 2, 1, -5, -4].df('c#').q, dur: Yoeminrak.secDur[5]/20*[0.3,0.3,0.4,0.3,0.3].q, amp: 1.3,instrument:\reedy,lagTime:3 ].ppm}, type: \addMe).play;
    (beat: 12.3,strum: 0.05, which: [2, 4], chord: [1, 3, 7, 2, 7].df('e'), type: \addMe).play;
    (beat: 12.6, which: [2, 4], chord: [1, 3, 6, 2, 6].df('e'), type: \addMe).play;
    (beat: 13,extra: {(freq: [1, 3, 7].df(\a,3), instrument: \wash, amp: 0.3).play},strum: 0.05, chord: [1, 2, 3, 5, 6].df('a', 4), type: \addMe).play;
    (beat: 13.4,which: 4, chord: [1, 2, 3, 5, 5].df('a', 4), type: \addMe).play;
    (beat: 14,which: nil, chord: [1, 2, 3, 5, 6].df('d', 5), type: \addMe).play;
    (beat: 14.7,which:4, chord: [1, 2, 3, 5, 6].df('d#', 5), type: \addMe).play;
    (beat: 15,which:4, chord: [1, 2, 3, 5, 6].df('d', 5), type: \addMe).play;
    (beat: 15.7,which: nil,strum:0.05, chord: [1, 2, 3, 5, 6].df('a-', 4), type: \addMe).play;
    (beat: 16,which: nil, chord: T([1, 2, 3, 5, 6].df('d#', 5), 0.5, \lin), type: \addMe).play;
    (beat: 16,extra:{
	[
	    freq: [7, 4, 1, 2].df(\f,4, \mixolydian).q,
	    dur:Yoeminrak.secDur[5]/20,
	    amp:[0.3,1] * 0.7 * 
	    [4,3,2,1,0].normalize
	    => _.q,
	    instrument:[\wash, \reedy ],
	    release:3

	].pp;
	{SinOsc.ar([2.01,1]*Line.ar( 7.df(\f,5, \mixolydian) , 1.df(\f),6)) * Env.perc(1,7).kr(2,gate:1) / [20, 15 ]}.play;
	[
	    type:\garlands,
	    dur: Yoeminrak.secDur[5]/20.dup(2).q
	].pp
    }, chord: [1, 2, 3, 5, 6].df('d#', 5), type: \addMe).play;
    (beat: 19.8,harp:false, gates:[0,0,0,0,0],chord:T([1, 2, 3, 5, 6].df('d#',4), 0.1,\lin), type:\addMe,release:0.3 ).play;

 Yoeminrak.addDrum(\five,[freq: [99*6.midiratio,99,99*(6).midiratio]], 5);
    (type:\cycs, songs:[ \five, \six, \seven, \eight ], keepPlaying:true ).play;
    // (Yoeminrak.env[\vid] ? false).if {Yoeminrak.playVid(1,5, audio:false)};
    ~preview=true;
 );


 (

     Yoeminrak.initSong(\six, 6, tempoEvents:true); 
 // garlands!!

 (beat:2,instrument:\sawSynth, coef:0.1,latency:0.12,type:\addMe, newType:\garlands2,totalDur: 2,freq: [1, 2, 3, 4, 2, 5, 5, 4, 2, 4, 3,1, 11].df('g#').q,amp:0.2, out:Effect.bus({|i| DWGReverbC1C3.ar(i,mix:0.2) },), extraDur:2).play;
 (beat:6,instrument:\sparkTriangle, coef:0.1,latency:0.12,type:\addMe, newType:\garlands2,totalDur: 2,freq: [1, 2, 3, 4, 2, 5, 5, 4, 2, 4, 3,1, 11].df('g#').q,amp:0.1, out:Effect.bus({|i| DWGReverbC1C3.ar(i,mix:0.2) },), extraDur:2).play;
    (beat:3,latency:0.12,type:\addMe,numDivisions:22, newType:\garlands2,totalDur: 3,instrument:\bl,instrument:\reedy,initialDur:0.125 /2,freq: [1, 2, 3, 4, 2, 5, 5, 4, 2, 4, 3,1, 11].reverse.df('f', 4).q(inf),amp:0.1,totalDur:2, out:Effect.bus({|i| DWGReverbC1C3.ar(i,mix:0.2) },), extraDur:2).play;
    (beat:8,latency:0.12,type:\addMe,numDivisions:22, newType:\garlands2,totalDur: 3,instrument:\bl,amp:0.9,initialDur:0.125 /2,freq: [1, 2, 3, 4, 2, 5, 5, 4, 2, 4, 3,1, 11].reverse.df('f', 4).q(inf),totalDur:2, out:Effect.bus({|i| DWGReverbC1C3.ar(i,mix:0.2) },),amp:0.3, extraDur:2).play;
 ///
    (beat: 0,amp:[1, 1, 1, 1, 1]/1,chord: [1,2, 3, 5, 6].df('c#'), type:\addMe, knum:6).play;
 (beat: 3, extra:{[
     freq: [ 1, 5, ].df(\f,4).q,
     out: Effect.bus({|i| CombN.ar(i,0.5,0.3,3)/2 * [0,1] + (i * [1,0]) }),
     amp:0.5,
     latency:0,
     instrument:\sawSynthSustain,
     lagTime:1,
     dur: Yoeminrak.secDur[6]/20 //* 3/4
 ].ppm}, type:\addMe ).play;
    // (beat:3, type:\garlands2, freq: Yoeminrak.env[\chord].getnSynchronous.q(inf)).play;
 (beat: 8, extra:{[
     freq: [1, 5, ].df(\f,4).q,
     lagTime:1,
     latency:0,
     out: Effect.bus({|i| CombN.ar(i,0.5,0.3,3)/2 * [1,0] + (i * [0,1]) }),
     amp:0.5,
     instrument:\sawSynthSustain,
     dur: Yoeminrak.secDur[6]/20 //* 3/4
 ].ppm}, type:\addMe ).play;
 // (beat:0, extra: [dur:Yoeminrak.secDur[3]/20,instrument:\bd_808, amp:2].pp);
 // (beat: 0.33, chord: [1,2, 3, 5, 6].df('d#'), type:\addMe, knum:4).play;
 // (beat: 0.33, chord: [1,2, 3, 5, 6].df('d#'),ornament:{ Env([0,0,-9.7!5],[0.64+0.96, 0.09]*Yoeminrak.secDur[6]/20).kr(2,gate:1)}, type:\addMe, knum:4).play;
 (beat: 0.33, chord: [1,2, 3, 5, 6].df('d#'),ornament: ~quickDip.(1.66, true), type:\addMe, knum:4).play;
 (beat: 1.98,gates:[0,0,0,0,0],release:0.9,  type:\addMe, knum:4).play;
    (beat: 2,amp:[1,1,1,1,1]/3,chord:[1,2,3,5,6].df('c#'),ornament:{0!5},  type:\addMe, knum:{Env.triangle(5!5).kr(2,1) * 4 + 4}).play;
 (beat: 4.90,gates:[0,0,0,0,0],release:0.9,  type:\addMe, knum:4).play;
    (beat: 5,amp:[1, 1, 1, 1, 1]/3,gates:[1, 1, 1, 1, 1],chord:[1,2,3,5,6].df('c#'),  type:\addMe, knum:4).play;
 (beat: 5.7,chord:[1,2,3,5,6].df('c'),  type:\addMe, knum:4).play;
 (beat: 6, chord: T( [1,2, 3, 5, 6].df('d#'), 0.1, \lin ),ornament:{ Env([0,0,-9.7!5],[0.92, 0.09]*Yoeminrak.secDur[6]/20).kr(2,gate:1)}, type:\addMe, knum:4).play;
 (beat: 7,chord:[1,2,3,5,6].df('c#'),ornament:{0!5},  type:\addMe, knum:5).play;

(beat: 10, chord: [1, 2, 3, 5, 6].df('c#'), type: \addMe).play;
(beat: 10.3, chord: [1, 2, 3, 6, 6].df('d#'), type: \addMe).play;
    (beat: 10.75,which:4, chord: [1, 2, 3, 5.5, 5.5].df('d#'), type: \addMe).play;
(beat: 11, chord: [1, 2, 3, 5, 6].df('c#'), type: \addMe).play;
    (beat: 11.3,strum:0.05, chord: [1, 2, 3, 5, 6].df('d#'), type: \addMe).play;
    (beat: 11.7,strum:0.05, chord: [1, 2, 3, 5, 6].df('d'), type: \addMe).play;
    (beat: 12,extra:{
	[
	    instrument:\sparkTriangle,
	    freq: [[1, 3], [2, 4]].df(\A, [5, 4 ]).q,
	    dur: Yoeminrak.secDur[6]/20,
	    amp: [ 0.2, 0.3 ],
	    out: [0,1],
	    depth:0.01
	].ppm
    },strum:0.05,knum:[4, 4, 2, 2, 8], chord: [1, 3, 3, 6, 6].df('A'), type: \addMe).play;
    (beat: 13,strum:0.02,harp:false, chord: T( [2, 4, 3, 6, 6].df('A'), 0.5, \lin ), type: \addMe).play;
    (beat: 13.33,which:4, chord: [2, 4, 3, 7, 7].df('A'), type: \addMe).play;
    (beat: 13.66,which:4, chord: [2, 4, 3, 5, 5].df('A'), type: \addMe).play;

(beat: 14, chord: [1, 2, 3, 5, 6].df('c#'), type: \addMe).play;
(beat: 14.3, chord: [1, 2, 3, 6, 6].df('d#'), type: \addMe).play;
    (beat: 14.75,which:4, chord: [1, 2, 3, 5.5, 5.5].df('d#'), type: \addMe).play;
(beat: 15, chord: [1, 2, 3, 5, 6].df('c'), type: \addMe).play;
(beat: 16, chord: [1, 2, 3, 5, 6].df('d'), type: \addMe).play;
    (beat: 16.3,knum:T(8, 4, \lin),amp:T([1,1,1,1,1]/2, 5, \lin), chord: T( [1, 2, 3, 5, 6].df('c'), 4, \lin ),harp:false, type: \addMe).play;
    (beat: 16.3, newType:\garlands,harp:false, type: \addMe).play;
    (beat: 16.7, newType:\garlands,harp:false, type: \addMe).play;
    (beat: 17, extra: {(freq:-7.df('d'), amp:0.3, instrument:[\harp, \reedy], coef:0.3).play} ,  type: \addMe).play;
    (beat: 18, extra: {(freq:-7.df('c#'), amp:0.2, instrument:[\harp, \reedy], coef:0.3).play} ,  type: \addMe).play;
    (beat: 19, extra: {(freq:-7.df(['c#',\b]), amp:0.1, instrument:[\harp, \reedy], coef:0.3).play} ,  type: \addMe).play;
    (beat: 19.5,gates: [0,0,0,0,0], type: \addMe).play;

 Yoeminrak.addDrum(\six,[freq: [99*6.midiratio,99,99*(6).midiratio]], 5);
    (type:\cycs, songs:[\six, \seven], keepPlaying:true  ).play;
    // (Yoeminrak.env[\vid] ? false).if {Yoeminrak.playVid(1,5, audio:false)};
    ~preview=true;
 );


   // Yoeminrak.song.two.play(13)
   (
       TempoClock.tempo_(1);
       Yoeminrak.initSong(\seven, 7, tempoEvents:true);

   ~middleChords = [
       [5, 7, 13].df(\a, \mixolydian),
       [3, 5, 11].df(\d, 6, \minor),
       [5, 7, 13].df(\a, \mixolydian),
       [3, 5, 11].df(\b, 5, \minor),
       [3, 5, 11].df(\d, 6, \minor),
   ];
   { 
   	   var tempoScale = 1;
   // var tempoScale = 1;
   Yoeminrak.song.drums=List[];Yoeminrak.addDrum(\drums,[freq: [1, 1, 1, 1].df('e-')]);

   //garlands
   [
       1, 2, 3, 4,
       8, 9, 10, 11, 12
   ].do {|i|
       (beat:i ? 0,amp:9, type: \addMe, newType:\garlands).play;
   };
   // strings
   (beat:0, type:\addMe, chord:[2, 7, 2, 7, 2].df('a-', 4), select:1.5, amp: 1.5).play;
   (beat: 0,\newType:\yoeDrum0,freq: 1.df('e-', 4),amp:0.25, type: \addMe).play;
   (beat: 1, type: \addMe,lag:0.15, chord: T( [2, 7, 2, 7, 2].df('c#'), 1.5, \lin )).play;
   (beat:1 , newType:\yoeDrum1, type: \addMe).play;
   (beat: 2, type: \addMe,lag:0.25, chord: T( [2, 11, 2, 11, 2].df('c#',5), 1, \lin )).play;
   (beat: 4, type: \addMe,lag:0.25, chord: T( [3, 11, 3, 11, 3].df('c#',5), 1, \lin )).play;
   (beat: 5, type: \addMe,lag:0.25, chord: T( [1, 4, 1, 4, 1].df('c',5), 0.5, \lin )).play;
   (beat: 6,which:[1 ] ,type: \addMe,lag:0.25, chord: T( [1, 3, 1, 3, 1].df('c',5), 0.5, \lin )).play;
   (beat: 6, newType:\yoeDrum0, freq: 99, amp:0.5, type: \addMe).play;
   (beat: 7,which:[2], type: \addMe,lag:0.25, chord: T( [1, 3, 1, 3, 1].df('d',5), 0.5, \lin )).play;

   // brassy
   (beat:8.1,amp:[2, 2, 2, 1, 1]*1.1,lag:0.1,
       //select:0, strum:0.06,
       knum:T(8, 3, \lin),amp:T(0.8, 3, \exp),
       ampScale:0.5, chord: T( ~middleChords[0][[0,1,2,0,1]]/2, 0.3, \exp ), type:\addMe).play;
   (beat:8.7,lag:0.1, strum: 0.06,ampScale: 0.5, chord: ~middleChords[1][[0,1,2,0,2]]/2, type:\addMe).play;
   (beat:9.1,lag:0.1, strum: 0.06, ampScale: 0.5, chord: ~middleChords[2][[0,1,2,0,2]]/2, type:\addMe).play;

   (beat: 9.75, lag: 0.1, strum: 0.06, ampScale: 0.5, chord: ~middleChords[3][[0,1,2,0,2]]/2, type:\addMe).play;

   (beat: 10,newType:\yoeDrum1, type: \addMe).play;
   (beat: 10.1, lag: 0.2, strum: 0.10,
       knum:T(2, 5, 6),amp:T([2, 2, 2, 1, 1]*1.1, 5, 6),
       ampScale: 0.5, chord: T(~middleChords[4][[0,1,2,0,2]]/2, 0.6,\lin ), type:\addMe).play;

       (beat:11.3, extra:{(type:\garlands2,freq:Pfunc({ Yoeminrak.env[\currentInstance][\chord].asMap * 2}),amp:0.2,initDur:0.3,numDivisions:20, instrument: \wash,rel:2, mono:false, totalDuration: 4 * Yoeminrak.secDur[8] / 20).play}, type:\addMe).play;
   (beat:11.3, extra:{(type:\garlands2,freq:Pfunc({ Yoeminrak.env[\currentInstance][\chord].getnSynchronous.choose * 3 }),amp:0.1,out:Effect.bus({|i|DWGReverbC1C3.ar(i) / 3  },),initDur:0.033,numDivisions:20, instrument: \bl,amp:1, mono:false, totalDuration: 4 * Yoeminrak.secDur[8] / 20).play}, type:\addMe).play;
   (beat: 11.95,harp:false,amp:0.4, ampScale: 0.5, chord: T(~middleChords[4][[0,1,2,0,2]]/4, 0.1,\lin ), type:\addMe).play;
   (beat: 12, lag: 0.2,amp:[2, 2, 2, 1, 0.5], strum: 0.10, ampScale: 0.5, chord: T(~middleChords[4][[0,1,2,0,2]]/2, 0.6,\lin ), type:\addMe).play;
   (beat: 13, lag: 0.2, strum: 0.10, ampScale: 0.5, chord: T([1, 2, 3, 5, 6].df('f#'), 0.6,\lin ), type:\addMe).play;
   (beat:13 ,\newType: \garlands, useGendy:true,amp:1, type: \addMe).play;
   (beat:14 ,\newType: \garlands, useGendy:true,amp:1, type: \addMe).play;
   (beat:15 ,\newType: \garlands, useGendy:true,amp:1, type: \addMe).play;
   (beat: 13.66, lag: 0.2, strum: 0.10, ampScale: 0.5, chord: T([1, 2, 3, 5, 6].df('g#'), 0.6,\lin ), type:\addMe).play;
   (beat: 14,extra:{(instrument:\sawSynth,amp:0.4, freq: 1.df(\b, 3), lag: Yoeminrak.secDur[7]/20).play}, lag: 0.2, strum: 0.10, ampScale: 0.5, chord: T([1, 3, 3, 6, 6].df('b',4), 0.6,\lin ), type:\addMe).play;
   (beat:14 ,newType:\yoeDrum2, type: \addMe).play;
   (beat:15 ,newType:\yoeDrum3,amp:1, type: \addMe).play;
   (beat: 15.66, lag: 0.2, strum: 0.10, ampScale: 0.5, chord: T([1, 2, 3, 5, 6].df('d'), 0.6,\lin ), type:\addMe).play;

   (beat: 16, lag: 0.2, strum: 0.10, ampScale: 0.5, chord: T(~middleChords[4][[0,1,2,0,2]]/2, 0.6,\lin ), type:\addMe).play;
   (beat:16, extra: {
       [
	   freq: [3, 2, 1, 2].df('b-', 4).q,
	   dur: Yoeminrak.secDur[7]/20,
	   amp:1
       ]//.pp
   }, type:\addMe).play;
    (beat: 17.7, lag: 0.2,which:[4], strum: 0.10, ampScale: 0.5, chord: T([1,3, 5.5, 1, 5.5].df(\f), 0.5, \lin), type:\addMe).play;
   // (beat: 18, lag: 0.2, strum: 0.10, ampScale: 0.5, chord: T(~middleChords[4][[0,1,2,0,2]]/2 * 1.midiratio, 0.6,\lin ), type:\addMe).play;
   (beat: 18, lag: 0.2, strum: 0.10, ampScale: 0.5,amp:T( [1, 1, 1, 1, 1], 1, 
   \lin), chord: T([-5, 1, 3, 5, 1].df(\a),1,\lin), type:\addMe).play;
   (beat: 19, lag: 0.2, strum: 0.10,  chord: T([1,3, 6, 1, 6].df('e',5), 0.1, \lin),ampScale:T( 1, 0.5, \lin ), type:\addMe).play;

   (beat:19.67, extra:{[amp:0.4,instrument:\harp,coef:0.5,decaytime:5.9,freq:"3 4 ".df(\d, [4, 5]).q, dur:0.33 * Yoeminrak.secDur[7]/20, out: Effect.bus({|i| CrossoverDistortion.ar(i, smooth:0.95) => Pan2.ar(_,0.8) },)].pp},type:\addMe).play;
   (beat: 19.67, lag: 0.2, strum: 0.10, ampScale: 0.8, chord: T([1,3, 5, 3, 5].df('f#',4), 0.1, \lin), type:\addMe).play;
   // 20

   ~bassline = [
       // freq: [-5, -6, 1, 2, 4, 5, -6, ].df('a-', [2]).q,
       freq: [-5, -6, 1, 2, 4,-4,  -5, -6, -4, -6, -4, -3, -4.5,-6].df('a-', [2]).q,
       instrument: \default,
       amp: 1,
       out: {Effect.bus({|i| CrossoverDistortion.ar(i)/3 + i })},
       dur: Yoeminrak.secDur[7]/20/4
       // * tempoScale 
       * [3, 1, 3, 1,4, 3, 1, 3, 1, 3, 1, 4, 4, 2].q,
   ].pm;
   ~line = [
       freq: [
           \r,
           [5, 7, 2, 15],
           [4, 7, 2, 14],
           [4, 7, 2, 14],
           [3, 7, 2, 13],
           1, 4, 3, 1, 
           -6, 4, 3, /*3*/\r, 4, 2,
           2, 1.5, 2, /*2*/\r, 3, -7,
           /*-7*/\r, -6.5, -7
       ].df('a-').q,
       dur: Yoeminrak.secDur[7]/40 
       // * tempoScale
       * 
       ([0.5,0.75, 0.75] ++ [0.75, 0.75, 0.5, 0.75, 0.75, 0.5].dup(4)).flat
       .q 
       // * tempoScale
       ,
       instrument: [\stringyy, \harp],
       ceof:0.1,
       amp: [1,0.3],
   ].p;
   (beat:0, extra: { Yoeminrak.env.use { ~line.play; ~linePlaying=true} }, type:\addMe).play;
   ~line2= {
   [
   dur: Yoeminrak.secDur[7]/20/3 + Pwhite(0.15,-0.15, inf),
   freq: [\r, 13, 12, 11, 7, 11, 4].df(\d, \minor).q,
   instrument: \sparkTriangle,
   out: {Effect.bus({ |i| i=> CrossoverDistortion.ar(_, smooth:0.9)/20=>Pan2.ar(_, 0.2.rrand(0.9)) })},
   amp:1.9
   ].pm
   };
   ~line2Harp = [
   dur: Yoeminrak.secDur[7]/20/3 + Pwhite(0.15,-0.15, inf),
   freq: [\r, 13, 12, 11, 7, 11, 4].df(\d, \minor).q,
   instrument:\harp, coef:0.1
   ].p;
   (beat:10, extra:{Yoeminrak.env.use{
       // ~line2Harp.play;
       ~line2.().play;~line2.().play}}, type:\addMe).play;
   ~linePlaying = false;
   (1..8).do {|i| 
       (beat:i, extra: { Yoeminrak.env.use {~linePlaying.not.if { ~line.dropTime(i, 8).play; ~linePlaying=true}} }, type:\addMe).play
   };
   // (beat:4, extra: { Yoeminrak.env.use { ~linePlaying.not.if { ~line.dropTime(4).play  ~linePlaying=true}}, type:\addMe).play;

   (beat:0, extra: {Yoeminrak.env.use{  ~bassline.play  }}, type:\addMe).play;
   (beat: 0,extra: {(instrument: \cymbalsDS).play}, type:\addMe ).play;
   // Yoeminrak.playVid(1, 8, audio:false, length:2)
   }.();
   (type:\cycs, songs:[ \seven, \eight ], tempoEvents:true).play;
   ~preview=true;
   );

(
   Yoeminrak.initSong(\eight,8, tempoEvents: true);
   (beat:0, extra: { (type:\yoeString3) ++ Yoeminrak.terminalState(Yoeminrak.song.seven) => _.play },type:\addMe).play;
   (beat: 0.01, select:0, lag: 0.2, strum: 0.10, ampScale: 0.8,extra:{(type:\yoeDrum0, freq:99*0.midiratio).play}, chord: T([1, 11, 3, 5, 16].df('g', 4), 0.1, \lin), type:\addMe).play;
   (beat: 1  ,extra:{(type:\yoeDrum1).play}, lag: 0.2, strum: 0.10, ampScale: 0.8, chord: T([1,11, 3, 5, 6].df('f#',4), 0.1, \lin), type:\addMe).play;
   (beat:1, extra:{[amp:0.4,instrument:\harp,coef:0.5,decaytime:5.9,freq:"3 4 1 -7".df(\d, [4, 5]).q, dur:0.33 * Yoeminrak.secDur[8]/20, out: Effect.bus({|i| CrossoverDistortion.ar(i, smooth:0.95) => Pan2.ar(_,0.8) },)].pp},type:\addMe).play;
   (beat: 1.33, lag: 0.2, strum: 0.07, ampScale: 0.8, chord: T([1, 11, 3, 5, 6].df('g', 4), 0.1, \lin), type:\addMe).play;
   (beat: 1.7, lag: 0.2, strum: 0.10, ampScale: 0.8, chord: T([1, 11, 3, 5, 6].df('d' ), 0.0, \lin), type:\addMe).play;
   (beat: 2, lag: 0.2, strum: 0.10,extra:{(amp:3,instrument:\defaultPiano,freq:-11.df('c#')).play}, ampScale: 0.5,chord: T([11, 11, 6, 15, 13].df('c#' ), 0.2, \lin), type:\addMe).play;
   (beat:2, type:\addMe, extra:{
       Yoeminrak.env[\reedyGroup] = Group();
       (type:\garlands2,legato:0.1,instrument:\reedy,group:Yoeminrak.env[\reedyGroup],attack:0.3,out: Effect.bus(Pan2.ar(_, -0.5.rrand(0.5))),numDivisions:7, mono:false,totalDur:4, section:9,amp:0.6,freq:[11, 7, 5, 5, 4, 3, 2, 1].df('c#').q, ).play
   }
   ).play;

   // (beat:5.89, extra:{Yoeminrak.env.use{~reedyGroup.debug("PPP").free}}, type:\addMe).play;
   (beat:5.8, harp:false,chord: T([1, 2, 3, 5, 6].df(\c, 4),0.5, \exp),release:0.2,gates:[0,0,0,0,0], type:\addMe).play;
   
   (beat: 6, lag: 0.0,amp:1,ornament:~wiggle, chord: T(
       // [1, 2, 3, 6, 6].df('c#')
       [11, 11, 6, 15, 13].df('c#')
       , 0.2, \lin), strum: 0.10,extra:{
	   (latency:0, instrument:\defaultPiano,amp:0.5,freq:-1.df('c#'),dur:Yoeminrak.secDur[8]/20/3 ).play
       }, ampScale: 0.5,
       // knum:T(6,  0.1, \lin),
       type:\addMe).play;
   (beat: 7, lag: 0.2,
           chord:
           // T([1, 2, 3, 6, 6].df('c#'), 2.4, \lin)
           { 
               Env(
                   // [1, 2, 3, 6.5, 6.5].df('c#').dup ++ [1, 2, 3, 6, 6].df('c#')
                   [11, 11, 5.5, 15.5, 14].df('c#').dup ++ [11, 11, 5, 15, 13].df('c#')
                   .bubble, [0.8, 0.2]).kr(2)
               }, 
               strum: 0.10,extra:{[
		   instrument:\defaultPiano,latency:0,amp:1,freq:[ -17, -1 ].df('c#').q,dur:Yoeminrak.secDur[8]/20/3
               ].pm.play}, ampScale: 0.5,
               // knum:T(6,  0.1, \lin),
               type:\addMe
	   ).play;
               // ~cursor=22;
	       (beat:( 8 - 0.0 ), extra:{[latency:0.1,amp:0.4,instrument:\harp,coef:0.5,decaytime:5.9,freq:"3 4 ".df(\d, [4, 5]).q, dur:0.30 * Yoeminrak.secDur[8]/20, out: Effect.bus({|i| CrossoverDistortion.ar(i, smooth:0.95) => Pan2.ar(_,0.8) },)].pp},type:\addMe).play;
   (beat:8, chord: [1, 3, 6, 1, 3].df('f#', 4),which:[0,2],strum:0.01, type:\addMe).play;
   (beat:8, extra:{(type:\garlands2,freq:Pfunc({ Yoeminrak.env[\currentInstance][\chord].getnSynchronous.choose * 2}),amp:0.2,initDur:1.2,numDivisions:20, instrument: \wash, mono:false, totalDuration: 4 * Yoeminrak.secDur[8] / 20).play}, type:\addMe).play;
   (beat:8.3, chord: [1, 3, 6, 1, 3].df('g', 4),which:[0,2], type:\addMe).play;
   (beat:9,knum:T( 4, 0.2, \lin ), chord: T([1, 3, 6, 1, 6].df(\e,5), 0.2,\lin),which:nil,strum:0.05, type:\addMe).play;
   //maybe swap channels on below garland
   (beat:9, extra:{ (type:\garlands2, instrument: [\harp, \default],totalDur:1, freq:[3, 4, 5, 6, 5, 3, 4, 2].df(\e).q ).play }, type:\addMe).play;

   //garlands
   (beat:10, newType:\garlands, type:\addMe).play;
   // (beat:11, newType:\garlands, type:\addMe).play;
   (beat:12, newType:\garlands, type:\addMe).play;
   // (beat:13, newType:\garlands, type:\addMe).play;

   (beat:10,extra:{(latency:0,freq:99, out: Effect.bus({|i| FreeVerb.ar(i, 1, 1) }), amp:2).play},knum:T( 2, 3, \lin ), chord: T([1, 3, 6, 1, 6].df('c',5), 1.2,\exp),strum:0.05, type:\addMe).play;
   (beat:11, chord: T([1, 3, 6, 1, 6].df('b',4), 0.2,\lin),strum:0.05, type:\addMe).play;
   (beat:11.7, chord: T([1, 3, 6, 1, 6].df('c',5), 0.2,\lin),strum:0.05, type:\addMe).play;
   (beat:12, chord: T([1, 3, 6, 1, 6].df('f',5), 1.5,\lin),strum:0.05, type:\addMe).play;
   (beat:13, chord: T([1, 3, 6, 1, 6].df('e',5), 0.2,\lin),strum:0.05, type:\addMe).play;
   (beat:13.3, chord: T([1, 3, 6, 1, 6].df('d',5), 0.0,\lin),strum:0.05, type:\addMe).play;
   (beat:14, chord: T([1, 3, 6, 1, 6].df('c#',5), 0.0,\lin),strum:0.05, type:\addMe).play;

   (beat: 15, extra:{[latency:0.1,amp:0.4,instrument:\harp,coef:0.5,decaytime:5.9,freq:"3 4 4 ".df(\d, [4, 5]).q, dur:[ 0.30, 0.7, 0.3].q * Yoeminrak.secDur[8]/20, out: Effect.bus({|i| CrossoverDistortion.ar(i, smooth:0.95) => Pan2.ar(_,0.8) },)].pp},type:\addMe).play;
   (beat:15, chord: [1, 3, 6, 1, 3].df('f#', 4),which:[0,2],strum:0.01, type:\addMe).play;
   (beat:15, extra:{(type:\garlands2,freq:Pfunc({ Yoeminrak.env[\currentInstance][\chord].getnSynchronous.choose * 2}),amp:0.2,initDur:1.2,numDivisions:20, instrument: \wash, mono:false, totalDuration: 4 * Yoeminrak.secDur[8] / 20).play}, type:\addMe).play;
   (beat:15.3, chord: [1, 3, 6, 1, 3].df('g', 4),which:[0,2], type:\addMe).play;
   (beat:16, chord: [1, 3, 6, 1, 3].df('g', 4),which:[0,2],strum:0.01, type:\addMe).play;
   (beat:17.7, chord: [1, 3, 6, 1, 3].df('e', 4),which:[0,2], type:\addMe).play;
   (beat:18, chord: T( [1, 3, 6, 1, 3].df('d', 4), 0.8, \lin ),which:[0,2], type:\addMe).play;
   (beat:18, extra:{(type:\garlands).play}, type:\addMe).play;
   (beat:19.7,harp: false, gates:[0,0,0,0,0],release:1.3, chord: T([1, 3, 6, 1, 3].df('f', 2),0.8, \lin),which:[0,2], type:\addMe).play;
   // (beat: 21, type: \addMe,lag:0.15, chord: T( [2, 7, 2, 7, 2].df('c#'), 1.5, \lin )).play;

	       (type:\cyc, song:\eight ).play;
	       ~preview = true;
   );

(
       Yoeminrak.initSong(\nine, 9, tempoEvents:true);

   ~line10 = [
       freq: [
           \r,
           [5, 7, 2, 15],
           [4, 7, 2, 14],
           [4, 7, 2, 14],
           [3, 7, 2, 13],
   	   1, 
           4, 2.5, 1, 
   	   -4, 2, 3, 
   	   2, 1.5, -6
       ].df('a-').q,
       dur: Yoeminrak.secDur[9]/40 
       // * tempoScale
       * 
       ([0.5,0.75, 0.75] ++ [0.75, 0.75, 0.5, 0.75, 0.75, 0.5].dup(2)).flat
       .q 
       // * tempoScale
       ,
       instrument: [\stringyy, \harp],
       ceof:0.1,
       amp: [1,0.3],
       laninecy:0
   ].p;
   ~lineNote = { |freq|
       {
           (
               freq: freq,
               instrument: [\stringyy, \harp],
               ceof:0.1,
               amp: [1,0.3],
	       laninecy:0
           ).play
       }
   };
   (beat: 0,strum:0.05,knum:5, extra:{(freq:1.df('e-',[3,4]), amp:0.5).play}, chord: [1, 2, 3, 5, 6].df('e-'), type: \addMe).play;
   (beat: 0, newType:\yoeDrum0, freq: 99*( 3 + 5 ).midiratio, type: \addMe).play;
   (beat: 0.32, extra:~lineNote.(5.df('a-'))  , type: \addMe).play;
   (beat: 0.625, extra:~lineNote.(4.df('a-')) ++ {(freq:2.df('e-', [3,4]), amp:0.5).play} , type: \addMe).play;
   (beat: 1,strum:0.05, extra:~lineNote.(4.df('a-')) ++ {(freq:4.df('e-', [3, 4]), amp:0.5, ).play} ,knum:T(4, 2, \lin),chord:T([1, 2, 3, 5, 6].df('a-'), 1, \lin), type: \addMe).play;
   (beat: 1, newType:\yoeDrum1, type: \addMe).play;
   (beat: 1.37, extra:~lineNote.(3.df('a-')) , type: \addMe).play;
   (beat: 1.7, extra:~lineNote.(1.df('a-')) , type: \addMe).play;
   (beat:1.71, gates:[0,0,0,0,0], type:\addMe).play;
   (beat: 2,extra:~lineNote.(4.df('a-')), chord: [1, 3, 1, 3, 1].df(\e), type: \addMe).play;
   (beat: 2.375,extra:~lineNote.(2.5.df('a-')), chord: [1.5, 3, 1.5, 3, 1.5].df(\e), type: \addMe).play;
   (beat: 2.75,extra:~lineNote.(1.df('a-')), type: \addMe).play;
   (beat: 3,extra:~lineNote.(-4.df('a-')) ++ {(freq:1.df('c#', 4), amp:1, instrument:\reedy).play},  type: \addMe).play;
   (beat: 3.37,extra:~lineNote.(7.df('c',5, \mixolydian)), type: \addMe).play;
   (beat: 3.7,extra:~lineNote.(11.df('c',5, \mixolydian)), type: \addMe).play;
   (beat: 4, which:0,extra:~lineNote.(7.df(\c,5, \mixolydian)) ++ {(instrument:\reedy, freq: 1.df(\c, 3), amp:1).play}, chord: [1, 2, 5, 3, 6].df(), type: \addMe).play;
   (beat: 4.35,extra:~lineNote.(6.df(\c,5, \mixolydian)),  type: \addMe).play;
   (beat: 4.65,extra:~lineNote.(4.df(\c,5, \mixolydian)),  type: \addMe).play;


   (beat:5, chord: [1, 3, 6, 1, 3].df('f#', 4),which:[0,2],strum:0.01, type:\addMe).play;
   (beat: 5, extra:{[laninecy:0.1,amp:0.4,instrument:\harp,coef:0.5,decaytime:5.9,freq:"3 4 4 ".df(\d, [4, 5]).q, dur:[ 0.30, 0.7, 0.3].q * Yoeminrak.secDur[9]/20, out: Effect.bus({|i| CrossoverDistortion.ar(i, smooth:0.95) => Pan2.ar(_,0.8) },)].pp},type:\addMe).play;
   (beat:5, extra:{(type:\garlands2,freq:Pfunc({ Yoeminrak.env[\currentInstance][\chord].getnSynchronous.choose * 2}),amp:0.2,initDur:1.2,numDivisions:20, instrument: \wash, mono:false, totalDuration: 4 * Yoeminrak.secDur[9] / 20).play}, type:\addMe).play;
   (beat:5.3, chord: [1, 3, 6, 1, 3].df('g', 4),which:[0,2], type:\addMe).play;
   (beat:6, chord: [1, 3, 6, 1, 3].df('g', 4),which:[0,2],strum:0.01, type:\addMe).play;
   (beat: 6, newType: \yoeDrum0, freq: 99*7.midiratio, type: \addMe).play;
   (beat:7.7, chord: [1, 3, 6, -1, -3].df('e', 5),strum:0.05, type:\addMe).play;
   (beat:8,strum:0.05, chord: T( [1, 3, 6, -1, -3].df('f', 5), 0.8, \lin ), type:\addMe).play;
   (beat:8, extra:{(type:\garlands, ratio:0.5,gain:4).play}, type:\addMe).play;
   (beat:8, extra:{(type:\garlands, gain:2).play}, type:\addMe).play;
   // (beat: 0, chord: [1, 2, 3, 5, 6].df(\c), type: \addMe).play;

   (beat: 10, chord: [1, 2, 3, 5, 6].df(\c),strum:0.04, type: \addMe).play;
   (beat: 10, newType: \yoeDrum1, type: \addMe).play;
   (beat: 11, chord: [1, 2, 3, 5, 6].df(\B),strum:0.04, type: \addMe).play;
   (beat: 11.7, chord: [1, 2, 3, 5, 6].df(\c),strum:0.04, type: \addMe).play;
   (beat: 12,extra:{(type:\garlands2, tune:[5,6,11,6,5,11,5].dr.q, freq:Pfunc{|e| e.tune * e.chord.asMap}, instrument:\reedyTune, amp:0.5).play}, chord: T([1, 2, 3, 5, 6].df(\g), 0.4, \lin),strum:0.08, type: \addMe).play;
   (beat: 14,strum:0.04, chord: T( [1, 3, 6, 5, 2].df(\B), 0.4, \lin ), type: \addMe).play;
   (beat: 14, newType:\yoeDrum2, type: \addMe).play;
   // (beat: 14, chord: T( [1, 3, 6, 5, 2].df(\B), 0.4, \lin ), type: \addMe).play;
   (beat: 14.7,harp:false,release:0.6,gates:[0,0,0,0,0], chord: T( [1, 3, 6, 5, 2].df(\B), 0.4, \lin ), type: \addMe).play;
   (beat: 15,which:0, chord: T( [1, 3, 6, 5, 2].df(\B), 0, \lin ), type: \addMe).play;
   (beat: 15, newType:\yoeDrum3, type: \addMe).play;
   (beat: 15.7,which:nil,strum:0.05, chord: T( [1, 3, 6, 5, 2].df('c#'), 0, \lin ), type: \addMe).play;
   // (beat: 16,which:nil,strum:0.03, chord: T( [1, 2, 3, 5, 6].df('e'), 0.2, \lin ), type: \addMe).play;
   (beat: 16,extra:{(type:\garlands2, tune:[5,6,11,6,5,11,5].dr.q, freq:Pfunc{|e| e.tune * e.chord.asMap}, instrument:\reedyTune, amp:0.5).play}, chord: T([1, 2, 3, 5, 6].df(\e), 0.4, \lin),strum:0.08, type: \addMe).play;
   (beat: 17, chord: T([1, 2, 3, 5, 6].df('d#'), 1.4, \lin),strum:0.08, type: \addMe).play;
   (beat: 18,which:0, chord: T([1, 2, 3, 5, 6].df('d#'), 0.69, \lin),strum:0.08, type: \addMe).play;
   (beat: 18.7,which:0, chord: T([1, 2, 3, 5, 6].df('B'), 0, \lin),strum:0.08, type: \addMe).play;
   ~preview=true;
       (type:\cyc, song:\nine ).play;
   );

(
       Yoeminrak.initSong(\ten, 10, tempoEvents:true);

   (beat:0, extra: { (type:\yoeString3) ++ Yoeminrak.terminalState(Yoeminrak.song.nine) => _.play },type:\addMe).play;
   (beat: 0.01, select:0, lag: 0.2, strum: 0.10, ampScale: 0.8,extra:{(type:\yoeDrum0, freq:99*0.midiratio).play}, chord: T([1, 11, 3, 5, 16].df('c' ), 0.1, \lin), type:\addMe).play;
   (beat: 1  ,extra:{(type:\yoeDrum1).play}, lag: 0.2, strum: 0.10, ampScale: 0.8, chord: T([1,11, 3, 5, 6].df('f#',4), 0.1, \lin), type:\addMe).play;
   (beat:1, extra:{[amp:0.4,instrument:\harp,coef:0.5,decaytime:5.9,freq:"3 4 1 -7".df(\d, [4, 5]).q, dur:0.33 * Yoeminrak.secDur[10]/20, out: Effect.bus({|i| CrossoverDistortion.ar(i, smooth:0.95) => Pan2.ar(_,0.8) },)].pp},type:\addMe).play;
   (beat: 1.33, lag: 0.2, strum: 0.07, ampScale: 0.8, chord: T([1, 11, 3, 5, 6].df('g', 4), 0.1, \lin), type:\addMe).play;
   (beat: 1.7, lag: 0.2, strum: 0.10, ampScale: 0.8, chord: T([1, 11, 3, 5, 6].df('d' ), 0.0, \lin), type:\addMe).play;
   (beat: 2, lag: 0.2, strum: 0.10,extra:{(amp:3,instrument:\defaultPiano,freq:-11.df('b')).play}, ampScale: 0.5,chord: T([11, 11, 6, 15, 13].df('b' ), 0.2, \lin), type:\addMe).play;
   (beat: 2, extra: {
       [
	   freq: [\r, 7, 6, 5].df(\b, 2,\mixolydian).q,
	   dur: Yoeminrak.secDur[10]/20,
	   amp:0.5,
	   instrument:\defaultPiano
       ].pp
   },  type: \addMe).play;
   (beat:2, type:\addMe, extra:{
       Yoeminrak.env[\reedyGroup] = Group();
       (type:\garlands2,legato:0.1,instrument:\reedy,group:Yoeminrak.env[\reedyGroup],attack:0.3,out: Effect.bus(Pan2.ar(_, -0.5.rrand(0.5))),numDivisions:7, mono:false,totalDur:4, section:9,amp:0.6,freq:[11, 7, 5, 5, 4, 3, 2, 1].df('b').q, ).play
   }
   ).play;

   (beat:5.8, harp:false,chord: T([1, 2, 3, 5, 6].df(\c, 4),0.5, \exp),release:0.2,gates:[0,0,0,0,0], type:\addMe).play;
   
   (beat: 6,knum:4, lag: 0.0,amp:1,ornament:~wiggle, chord: T(
       [1, 2, 3, 6, 6].df('B')
       // [11, 11, 6, 15, 13].df('B')
       , 0.2, \lin), strum: 0.10,extra:{
	   (latency:0, instrument:\defaultPiano,amp:0.5,freq:-13.df('b'),dur:Yoeminrak.secDur[8]/20/3 ).play;
	   (type:\yoeDrum0, freq: 99 * -4.midiratio * 2, amp:1).play
       }, ampScale: 0.5,
       // knum:T(6,  0.1, \lin),
       type:\addMe).play;
       (beat: 7.63,which:4, chord: [1,2,3,5,5].df(\B) , type: \addMe).play;
       (beat: 7.7,which:[ 2, 4 ], chord: [1, 2, 3, 5, 6].df(\c), type: \addMe).play;
       (beat: 8,strum:0.03, chord:T([1, 2, 3, 5, 6].df('e-'), 0.5, \lin) , type: \addMe).play;
       (beat: 9, which:[0,3], chord: [1, 2, 3, 5, 6].df(\d) , type: \addMe).play;
       (beat: 9.7, which: [0,3], chord: [1, 2, 3, 5, 6].df('e-') , type: \addMe).play;
   (beat: 9, extra:{[latency:0.0,amp:0.4,instrument:\harp,coef:0.5,decaytime:5.9,freq:"2 2.5 1.5 ".df(\c, [4, 5]).q, dur:[ 0.70, 0.3, 0.3].q * Yoeminrak.secDur[9]/20, out: Effect.bus({|i| CrossoverDistortion.ar(i, smooth:0.95) => Pan2.ar(_,0.8) },)].pp},type:\addMe).play;
       (beat: 10, chord: [1, 2, 3, 5, 6].df('c#'), type: \addMe).play;
       (beat: 10, newType: \yoeDrum1, type: \addMe).play;

       (beat: 11, which:[0,3], chord: [1, 2, 3, 5, 6].df('c#') , type: \addMe).play;
       (beat: 11.7, which: [0,3], chord: [1, 2, 3, 5, 6].df('e-') , type: \addMe).play;
   (beat: 11, extra:{[latency:0.0,amp:0.4,instrument:\harp,coef:0.5,decaytime:5.9,freq:"1.5 2.5 3 ".df(\c, [4, 5]).q, dur:[ 0.70, 0.3, 0.3].q * Yoeminrak.secDur[9]/20, out: Effect.bus({|i| CrossoverDistortion.ar(i, smooth:0.95) => Pan2.ar(_,0.8) },)].pp},type:\addMe).play;
       (beat: 12, chord: [1, 2, 3, 6, 6].df('e'), type: \addMe).play;
       (beat: 12.7, which:4, chord: [1, 2, 3, 5.5, 5.5].df('e'), type: \addMe).play;
       (beat: 13, chord: [1, 2, 3, 5, 6].df('d'), type: \addMe).play;
       (beat: 14, chord: [1, 2, 3, 5, 6].df('c#'), type: \addMe).play;
       (beat: 14.3, chord: [1, 2, 3, 5, 6].df('d#'), type: \addMe).play;
       (beat: 14.9,which:4, chord: [1, 2, 3, 5.5, 5.5].df('d#'), type: \addMe).play;
       (beat: 15,which:4,strum:0.02, chord: [1, 2, 3, 5, 6].df('c#'), type: \addMe).play;
       (beat: 15.15,which:4, chord: [1, 2, 3, 5, 5].df('c#'), type: \addMe).play;
       (beat: 15.3,which:4, chord: [1, 2, 3, 5, 6].df('c'), type: \addMe).play;
       (beat: 16,extra:{ ( freq: 1.df(\g, 3),instrument:\defaultPiano, amp:1).play }, chord: [1, 2, 3, 5, 6].df('c'), type: \addMe).play;
       (beat: 16, newType:\yoeDrum2, type: \addMe).play;
       (beat: 15 , newType: \garlands, type: \addMe).play;
       (beat: 16 , newType: \garlands, type: \addMe).play;
       (beat: 17 , newType: \garlands, type: \addMe).play;
       (beat: 16,extra:{(type:\garlands2, tune:[5,6,11,6,5,11,5].dr.q, freq:Pfunc{|e| e.tune * e.chord.asMap}, instrument:\reedyTune, amp:0.5).play},totalDur:3, type: \addMe).play;
       (beat: 17, newType:\yoeDrum3, type: \addMe).play;
       (beat: 18 , newType: \garlands, type: \addMe).play;
       (beat: 18,extra:{ ( freq: 1.df(\e, 3),instrument:\defaultPiano, amp:1).play }, chord: [1, 2, 3, 5, 6].df('c'), type: \addMe).play;
       (beat: 19, newType:\garlands, type: \addMe).play;
       // (beat: 19,extra:{(instrument:\sawSynth, freq:11.df(\e,3), amp:0.3, latency:0).play},type: \addMe).play;

       (type:\cycs, songs:[ \ten, \eleven ], keepPlaying: true).play;
   ~preview=true;
   );

(
       Yoeminrak.initSong(\eleven, 11, tempoEvents:true);

       (beat: 0,select:{Line.kr(1, 0, 4)},which:[0,1, 2, 3, 4],knum:T(8, 4, \lin),ampDist:2,amp:1, durDistParam:0, chord: [-21, -11, -1, 1, 11].df(\b), type: \addMe).play;
   (beat: 0, newType:\yoeDrum0, amp:1, freq: 99* (4).midiratio , type: \addMe).play;
   (beat: 0.05, newType:\garlands,ratio:0.5,gain:2, type: \addMe).play;
   (beat: 0.05, newType:\garlands,ratio:1,gain:2, type: \addMe).play;
   (beat: 0.05, newType:\garlands,ratio:0.5,gain:2, type: \addMe).play;
   (beat: 0, newType:\default, instrument:\reedy, freq:-21.df(\b),attack:3, amp:0.4,type: \addMe).play;
   (beat: 0, newType:\default, instrument:\reedy,out:1, freq:-11.df(\b),attack:3, amp:0.4,type: \addMe).play;
   (beat: 0.6, newType:\yoeDrum1,  type: \addMe).play;
   //quiet....
   (beat: 1.7, which: 3,amp:T([1, 1, 1, 1, 0.5] * 2,6,\lin), chord: [-21, -11, -1, -7, 11].df(\b, \mixolydian), type: \addMe).play;
   (beat: 2, which: 3, chord: [-21, -11, -1, -5, 11].df(\b), type: \addMe).play;
   (beat: 3-0.05, which: 3, chord: [-21, -11, -1, -5.5, 11].df(\b), type: \addMe).play;
   (beat: 3.05, which: 3, chord: [-21, -11, -1, -5, 11].df(\b), type: \addMe).play;
   (beat: 3.15, which: 3, chord: [-21, -11, -1, -4, 11].df(\b), type: \addMe).play;
   (beat: 3.7, which: 3, chord: [-21, -11, -1, -3, 11].df(\b), type: \addMe).play;
   (beat: 4, which: [ 2,3 ], chord: [-21, -11, -2, -5.5, 11].df(\b), type: \addMe).play;
   (beat: 5, newType:\default,instrument:\defaultPorto,amp:0.2, freq: [-13, -3 ].df(\b),ratio:0.5,gain:1, type: \addMe).play;
   (beat: 4, newType:\default,instrument:\defaultPiano, out:Effect.bus(FreeVerb.ar(_,0.4,1)),amp:0.3, freq: [-12,-2  ].df(\b),ratio:0.5,gain:1, type: \addMe).play;
   (beat: 5, newType:\default,instrument:\defaultPiano, out:Effect.bus(FreeVerb.ar(_,0.4,1)),amp:0.3, freq: [-13,-3  ].df(\b),ratio:0.5,gain:1, type: \addMe).play;


   (beat: 5.05, newType:\garlands,ratio:0.5,gain:1, type: \addMe).play;
   (beat: 5.05, newType:\garlands,ratio:0.5,gain:1, type: \addMe).play;
   (beat: 5.05, newType:\garlands,ratio:0.5,gain:1, type: \addMe).play;

   (beat: 5.7, which: [ 3 ], chord: [-21, -11, -2, -5, 11].df(\b), type: \addMe).play;
   (beat: 5.8,gates:[0,0,0,0,0],release:1, type: \addMe).play;
   (beat: 6, chord: [1, 2, 3, 5, 6].df('c#'), type: \addMe).play;
   (beat: 6, newType:\yoeDrum0, amp:1, freq: 99 * 1.midiratio,  type: \addMe).play;
   (beat: 7.7,strum:0.04, chord: [1, 2, 3, 5, 6].df('B'), type: \addMe).play;
   (beat: 8,strum:0.06, chord: [1, 2, 3, 5, 6].df('d'), type: \addMe).play;
   (beat: 9,which:[0,4],strum:0.04, chord: [1, 2, 3, 5, 6].df('e'), type: \addMe).play;
   (beat: 9.7,which:[0,4],strum:0.04, chord: [1, 2, 3, 5, 6].df('d'), type: \addMe).play;
   
   (beat: 9, extra:{[latency:0.0,amp:0.4,instrument:\harp,coef:0.5,decaytime:5.9,freq:"3 2 1 ".df(\c, [4, 5]).q, dur:[ 0.70, 0.3, 0.3].q * Yoeminrak.secDur[9]/20, out: Effect.bus({|i| CrossoverDistortion.ar(i, smooth:0.95) => Pan2.ar(_,0.8) },)].pp},type:\addMe).play;
   (beat: 10, newType:\yoeDrum1,  type: \addMe).play;

   (beat: 10,strum:0.06, chord: [1, 2, 3, 5, 6].df('c#'), type: \addMe).play;
   (beat: 10, extra:{
       [
	   freq: [1, -7, -6, -5.5,  ].df('c#', 4).q,
	   dur: Yoeminrak.secDur[11]/20,
	   amp:1
       ].pp
   }, type: \addMe).play;
   (beat: 13.7,which:[3, 4],strum:0.06, chord: [1, 2, 3, 5.5, 5.5].df('c#'), type: \addMe).play;

   (beat: 14,strum:0.06,extra:{(freq:-6.df(\c, 4),amp:0.6).play}, chord: [1, 2, 3, 5, 6].df('B'), type: \addMe).play;
   (beat: 15,strum:0.06,extra:{(freq:-5.df('c#',4),amp:0.5).play}, chord: [1, 2, 3, 5, 6].df('c#'), type: \addMe).play;
   (beat: 15.3,which:4, strum:0.06, chord: [1, 2, 3, 5, 5.5].df('c#'), type: \addMe).play;
   (beat: 15.55,strum:0.03, chord: [1, 2, 3, 5, 6].df('B'), type: \addMe).play;
   (beat: 15.8,which:4, strum:0.06, chord: [1, 2, 3, 5, 5].df('B'), type: \addMe).play;
   (beat: 16.0,strum:0.06,extra:{(instrument:\defaultPiano,freq:-5.df(\c,4),amp:1).play}, chord: [1, 2, 3, 5, 6].df('c'), type: \addMe).play;
   (beat: 17.7,which:4,strum:0.06, chord: [1, 2, 3, 5.5, 5.5].df('c'), type: \addMe).play;
   (beat: 18.0,strum:0.02,extra:{(freq:-5.df(\b,3),amp:1).play}, chord: [1, 2, 3, 5, 6.5].df('c'), type: \addMe).play;
   (beat: 18.5,strum:0.02,extra:{(freq:-5.df(\b,3),amp:1, dur:0.2).play}, chord: [1, 2, 3, 5, 6.5].df('c'), type: \addMe).play;
   (beat: 18.75,which:4,strum:0.02,extra:{(latency:0,freq:-5.df(\c,3),amp:1, instrument:\defaultPiano).play}, chord: [1, 2, 3, 5, 6].df('c'), type: \addMe).play;
   (beat: 18.9, gates:[0,0,0,0,0],release:0.6, type: \addMe).play;

   (type:\cycs, songs:[ \eleven, \twelve ]).play;
   
   ~preview=true;
   );

(
	   Yoeminrak.initSong(\twelve, 12, tempoEvents:true);
	   (beat: 0, newType:\yoeDrum0,freq: 99 * -1.midiratio * 2, type: \addMe).play;
   (beat: 0,chord:[1, 2, 3, 5, 6].df(\B), extra: {[amp:0.5, attack:1.5,release:4,instrument:\reedy,latency:0,freq: [6.df(\B), 6.df('c#'), 5.5.df('c#'), 6.df(\B), 5.df(\B), 6.df(\c)].q, dur: Yoeminrak.secDur[12]/20 * [0.3, 1.2, 0.2, 0.25, 0.1, 17.95].q].ppm}, type: \addMe).play;
   (beat: 0.4,strum:0.05, chord: [1,2,3,5,6].df('c#'), type: \addMe).play;

   (beat: 1, newType: \yoeDrum1, type: \addMe).play;
   (beat: 1.5,strum:0.00,which:[3,4], chord: [1, 2, 3, 5.5, 5.5].df('c#'), type: \addMe).play;
   (beat: 1.7,strum:0.03, chord: [1,2,3,5,6].df(\B), type: \addMe).play;
   (beat: 1.95,which:4,strum:0.05, chord: [1,2,3,5,5].df(\B), type: \addMe).play;
   (beat: 2.05, extra: {[amp:0.2,latency:0,att:3,instrument:\sawSynthSustain,freq: [6.df(\c), 6.df(\B), 6.df(\e), 5.df(\e), 6.df(\d)].q, dur: Yoeminrak.secDur[12]/20 * [1.65, 0.3, 1.7, 0.3, 14].q].ppm}, type: \addMe).play;

   (beat: 2.05,which:[0, 2, 4],strum:0.04, chord: [1,2,3,5,6].df(\c), type: \addMe).play;
   (beat: 2.05, newType:\garlands,reverse:true, amp:5, type:\addMe).play;
   (beat: 3.7, chord: [1, 2, 3, 5, 6].df(\B), type: \addMe).play;
   (beat: 4, chord: [1, 2, 3, 5, 6].df(\e), type: \addMe).play;
   (beat: 5.7, which:[4], chord: [1, 2, 3, 5, 5].df(\e), type: \addMe).play;
   (beat: 6, newType:\yoeDrum0, freq: 99 * 2.midiratio,amp:1,  type: \addMe).play;
   (beat: 6, chord: [1, 12, 3, 5, 6].df(\d),amp:[2,1,2,2,1,0.5], type: \addMe).play;
   (beat: 6, extra:{
       [
	   freq: [1, 2, 3, 4.5, [-4, 4 ]].df(\d, 4).q,
	   dur: Yoeminrak.secDur[12]/20 * [1,1,1.7,0.3,1].q,
	   sustain:Yoeminrak.secDur[12]/20,
	   latency:0.1,
	   amp:0.6
       ].pp
   },  type: \addMe).play;
   (beat: 9.7,strum:0.05, chord: [ 1,3, 3, 5, 7].df(\e,\mixolydian), type: \addMe).play;
   (beat: 10,strum:0.05, chord: [1, 2.5, 4, 5.5, 11].df(\e), type: \addMe).play;
   (beat: 10, newType:\yoeDrum1, type: \addMe).play;
   (beat: 11,which:[0,4],knum:4,strum:0.01, chord: [-7, 2.5, 4, 5.5, 11.5].df(\e), type: \addMe).play;
   (beat: 11.15,which:[0,4],knum:4,strum:0.05, chord: T([1, 2.5, 4, 5.5, 11].df(\e), 0.05,\exp), type: \addMe).play;
   (beat: 11.7,which:[4],knum:3,strum:0.05, chord: T([1, 2.5, 4, 5.5, 6.5].df(\e), 0.05,\exp), type: \addMe).play;
   (beat: 12,strum:0.05,knum:2, chord: T([1, 2, 3, 5, 6].df(\e), 0.05,\exp), type: \addMe).play;
   (beat: 12.7,strum:0.05,which:4, chord: T([1, 2, 3, 5, 5].df(\e), 0.05,\exp), type: \addMe).play;
   (beat: 13,which:[0,4],strum:0.01, chord: [1, 2, 3, 5, 6].df(\d), type: \addMe).play;

   (beat: 13, extra:{[latency:0.1,amp:0.4,instrument:\harp,coef:0.5,decaytime:5.9,freq:"1 2 -6 ".df(\d, [4, 5]).q, dur:[ 0.70, 0.35, 0.3].q * Yoeminrak.secDur[12]/20, out: Effect.bus({|i| CrossoverDistortion.ar(i, smooth:0.95) => Pan2.ar(_,0.8) },)].pp},type:\addMe).play;
   (beat: 13, extra:{[latency:0.1,amp:0.4,instrument:\harp,coef:0.5,decaytime:5.9,freq:"1 2 -6 ".df(\A, [4, 5]).q, dur:[ 0.70, 0.35, 0.3].q * Yoeminrak.secDur[12]/20, out: Effect.bus({|i| CrossoverDistortion.ar(i, smooth:0.95) => Pan2.ar(_,0.8) },)].pp},type:\addMe).play;
   (beat: 13.7,which:[0,4],strum:0.01, chord: [1, 2, 3, 5, 6].df(\e), type: \addMe).play;
   (beat: 14,strum:0.05, chord: [1, 2, 3, 5, 6].df(\B), type: \addMe).play;
   (beat: 14, newType: \yoeDrum2 ,amp:0.15, type: \addMe).play;
   (beat: 15, newType: \yoeDrum3 ,amp:0.15,freq:1.df(\B) ,type: \addMe).play;
   (beat: 15.7, lag:0.1,strum:0.01, chord: [1, 2, 3, 5, 6].df('c#'), type: \addMe).play;
   (beat: 15.9, lag:0.1,which:4,strum:0.05, chord: [1, 2, 3, 5.5, 5.5].df('c#'), type: \addMe).play;
   // (beat:16, newType:\garlands2,freq: Pfunc{|e| e.tune * e.chord.asMap},tune: [1, -7, 1, 2, 6, 5, 3, 7].dr.q,amp:1,instrument:\reedyTune,release:3, type:\addMe).play;
   (beat:16.05, newType:\garlands2,freq:Pfunc{|e| e.tune * e.chord.asMap},tune: [1, -7, 1, 2, 6, 5, 3, 7].dr.q ,amp:1,instrument:\reedyTune,release:3, type:\addMe).play;

   (beat:16.05, newType:\garlands2,freq:Pfunc{|e| e.tune * 1.dm(\c)},initDur:0.2,tune: [11, 5, 4, 3, 2, 1, 4, 3, -5].dr.q * 4, amp: 0.1, instrument:\reedyTune,release:3,totalDur:3, type:\addMe).play;
   (beat:16, newType:\garlands,reverse:true, type:\addMe).play;
   (beat:16, extra:{(
	   instrument:\bd_808,
	   amp:1,
	   latency:0.05,
	   out: Effect.bus({|i| DWGReverbC1C3.ar(i) * 2 => TwoTube.ar(_,loss:0.9,d1length:3000,d2length:1131) },)
   ).play}, type:\addMe).play;
   (beat: 16, lag:0.1,strum:0.05, chord: [1, 2, 3, 5, 6].df('c'), type: \addMe).play;

   (beat: 17,which:[0,4],knum:4,strum:0.01, chord: T( [-7, 3,3, 6.5, 6.5].df(\c), 0.0,\lin ), type: \addMe).play;
   (beat: 17.15,which:[0,4],knum:4,strum:0.05, chord: T([1, 1, 3, 6, 6].df(\c), 0.05,\exp), type: \addMe).play;
   (beat: 17.5,which:[4],knum:3,strum:0.05, chord: T([1, 1, 3, 6, 5].df(\c), 0.05,\exp), type: \addMe).play;
   (beat: 17.7,which:nil,strum:0.01, chord: [-5, -6, 1, 1, 3].df(\e), type: \addMe).play;
   (beat: 18,strum:0.05,width:T(1.015, 3,\lin), chord: T([-5, -7, -7, 3, 3].df(\e), 0.5, \lin), type: \addMe).play;
   (beat: 18.7,which:4,strum:0.015, chord: [-5, -7, -7, 2, 2].df(\e), type: \addMe).play;

   (beat: 19, extra:{[latency:0.1,amp:0.4,instrument:\harp,coef:0.5,decaytime:5.9,freq:"1 3 2 ".df(\c, [4, 5]).q, dur:[ 0.70, 0.3, 0.3].q * Yoeminrak.secDur[12]/20, out: Effect.bus({|i| CrossoverDistortion.ar(i, smooth:0.95) => Pan2.ar(_,0.8) },)].pp},type:\addMe).play;
   (beat: 19,strum:0.02,which:[1,4], chord: [1, 2, 3, 5, 6].df(\c), type: \addMe).play;
   (beat: 19.7,strum:0.02,which:[0,4], chord: [1, 2, 3, 5, 6].df(\e), type: \addMe).play;


   (type:\cycs, songs:[ \twelve, \thirteen, \fourteen ], keepPlaying:true).play;
   ~preview=true;
   );

(
	   Yoeminrak.initSong(\thirteen, 13, tempoEvents:true);

	   (beat: 0,strum:0.06,extra:{(freq:-11.df(\d), amp:1, instrument:\reedy, release:5).play}, chord: [1, 12, 3, 5, 6].df(\d), type: \addMe).play;
   (beat: 0, newType:\yoeDrum0,freq:99 * 2.midiratio, type: \addMe).play;
   (beat: 0, extra:{
       [
	   freq: [1, 2, 3, 4.5, [-4, 4 ]].df(\d, 4).q,
	   instrument:\defaultPiano,
	   dur: Yoeminrak.secDur[13]/20 * [0.7,0.3,0.7,0.3,1].q,
	   sustain:Yoeminrak.secDur[12]/20,
	   latency:0.1,
	   amp:0.6
       ].pp
   },  type: \addMe).play;

   (beat: 1.7,strum:0.05,knum:[2, 2, 2, 2, 6], chord: [ 1,3, 3, 5, 7].df(\e,\mixolydian), type: \addMe).play;
   (beat: 2,strum:0.05,extra:{(freq:-11.df(\g), amp:1, instrument:\reedy, release:5).play}, chord: [1, 2.5, 4, 5.5, 11].df(\e), type: \addMe).play;
   (beat: 3, chord:[-4.5, 1, 5, 14, 14].df(\c),harp:false,extra:{
       [
	   freq: [4,3].df(\c).q,
	   dur: [0.1,1].q,
	   instrument:\harp,
	   coef:0.1
       ].ppm;
       [
	   freq: [-4.5,-5].df(\c).q,
	   lag:0.05,
	   dur: [0.1,1].q,
	   instrument:\harp,
	   coef:0.1
       ].ppm
   }, type: \addMe).play;
   (beat: 3.2,strum:0.05, chord: T([-5, 1, 5, 13, 13].df(\c), 0.8, \lin), type: \addMe).play;
   (beat: 3.7,which:[3, 4],strum:0.05, chord: T([-5, 1, 5, 12, 12].df(\c), 0.2, \lin), type: \addMe).play;
   (beat: 4, chord: T([1, 2, 3, 5, 6].df(\e), 0.5, \lin), type: \addMe).play;
   (beat: 4.05, \newType:\garlands,reverse:true,type: \addMe).play;
   (beat: 5,extra:{(instrument:\sawSynth, freq: -1.df(\e), amp:0.25).play}, type: \addMe).play;
   (beat: 5.7,which:4, chord: T([1, 2, 3, 5, 5].df(\e), 0.5, \lin), type: \addMe).play;
   (beat: 6, chord: [1, 2, 3, 5, 6].df(\d), type: \addMe).play;
   (beat: 6, newType:\yoeDrum0, freq:99 * 2.midiratio,amp:1, type: \addMe).play;
   (beat: 7, newType:\garlands,reverse:true, type: \addMe).play;
   (beat: 9, newType:\garlands,reverse:false, type: \addMe).play;
   (beat: 8,strum:0.04,extra:{(instrument:\reedy,amp:0.3,attack:1, freq: [1, 2, 3, 5, 6].df(\E)).play}, chord: [1, 2, 3, 5, 6].df(\d), type: \addMe).play;
   (beat: 9.7,which:4,strum:0.05, chord: [1, 2, 3, 5, 6].df(\e), type: \addMe).play;
   // (beat: 10,strum:0.05, chord: [1, 2, 3, 5, 6].df(\f), type: \addMe).play;
   (beat: 10, newType:\yoeDrum1,type: \addMe).play;
   (beat: 10, extra: {
       [
	   freq: [11, 7, 6, 5, 4].df(\f, 3,\lydian).q,
	   dur: Yoeminrak.secDur[13] /20,
	   amp:0.6
       ].pp
   }, type: \addMe).play;
   (beat: 10, extra:{(type: \garlands2,reverse:true,totalDur:5,numDivisions:5,amp:0.4,initDur:0.6,tune:[11, 7, 6, 5, 4.5].dr.q, instrument:\reedyTune,freq:Pfunc{|e| e.tune*e.chord.asMap}).play},width:1.04, chord: [1, 2, 3, 5, 6].df(\f), type: \addMe).play;
   (beat: 12,strum:0.04, chord: [1, 2, 3, 5, 6].df(\f), width:T(1.015, 2, \lin), type: \addMe).play;
   (beat: 14,strum:0.04, chord: [1, 2, 3, 5, 6].df(\f), type: \addMe).play;
   (beat: 14, newType:\yoeDrum2, type: \addMe).play;
   (beat: 15, newType:\yoeDrum3, type: \addMe).play;
(beat: 15, chord:[-7, 2, 3, 6.5, 6.5].df(\f),harp:false,extra:{
       [
	   freq: [4,3].df(\c).q,
	   dur: [0.15,1].q,
	   instrument:\harp,
	   coef:0.1
       ].ppm;
       [
	   freq: [-6,-7].df(\c).q,
	   lag:0.05,
	   dur: [0.15,1].q,
	   instrument:\harp,
	   coef:0.1
       ].ppm;
       [
	   freq: [-6.5,-7].df(\c,4).q,
	   dur:[0.15,2].q,
	   amp:2,
	   instrument:[ \default, \defaultPiano ].q
	   // instrument:\defaultPiano
       ].pp
   }, type: \addMe).play;
   (beat: 15.2,harp:false,strum:0.04, chord: [1, 2, 3, 6, 6].df(\f), type: \addMe).play;
   (beat: 15.7,which:4,strum:0.04, chord: [1, 2, 3, 5.5, 5.5].df(\f), type: \addMe).play;
   (beat: 16,strum:0.06,extra:{(freq:[-5, 1 ].df(\e,4),instrument:\defaultPiano, amp:0.3).play},which:[0,1,2,4], chord: [1, 2, 3, 5, 6].df(\e), type: \addMe).play;
   (
   	beat: 17.7 - 0.2 ,
   	strum:0.06,
   	which:[4],
	extra: {(instrument:\harp,latency:0.05,freq:1.df(\d), out: Effect.bus({|i| TwoTube.ar(i, 1, 0.9, 1000, 3212) / 2 },)).play},
   	chord: [1, 2, 3, 5, 6].df(\d),
   	type: \addMe
   ).play;
   (
   	beat: 18 - 0.2 ,
   	strum:0.06,
   	which:[0,1,2,4],
   	extra:{(freq:[ 1, -1 ].df(\e,4),instrument:\defaultPiano, amp:0.3).play},
   	chord: [1, 2, 3, 5, 6].df(\c),
   	type: \addMe
   ).play;
   (beat: 19 - 0.1,which:[0,3], extra:{[latency:0.1,amp:0.4,instrument:\harp,coef:0.5,decaytime:5.9,freq:"2 3 1 ".df(\c, [4, 5]).q, dur:[ 0.70, 0.3, 0.3].q * Yoeminrak.secDur[12]/20, out: Effect.bus({|i| CrossoverDistortion.ar(i, smooth:0.95) => Pan2.ar(_,0.8) },)].pp},chord:[1, -1, 3, 5, 6].df(\d),type:\addMe).play;
   (beat: 19.75 - 0.1,which:[0, 3], chord: [1, -1, 3, 5, 6].df(\e), type: \addMe).play;
  
   (type:\cycs, songs:[ \thirteen, \fourteen ], keepPlaying:true).play;
   ~preview=true;
   );

(
	   Yoeminrak.initSong(\fourteen, 14, tempoEvents:true);
   (beat: 0, extra: {(latency:0.1,type:\yoeDrum0,freq:99 * [0,5].midiratio, amp:0.5).play},strum:0.04,chord: [1, 2, 3, 5, 6].df(\c), type: \addMe).play;
   (beat: 0, newType: \yoeDrum0,freq:99,amp:1, type: \addMe).play;
   (beat: 0, extra:{
	   [
		   freq: [11, 7, 6].df(\c,3).q,
		   dur: Yoeminrak.secDur[14]/20,
		   amp:1
	   ].pp
   }, type: \addMe).play;
   (beat: 1.7, which:4, chord: [1, 2, 3, 5, 5].df(\c), type: \addMe).play;
   (beat: 2, which:[0, 1,2,3,4 ], chord: [1, 2, 3, 5, 6].df(\d), type: \addMe).play;
   (beat: 2, extra:{
	   [
		   freq: [1, 2, 3, 4.5, 4.5].df(\d,[ 3, 4 ]).q,
		   dur: Yoeminrak.secDur[14]/20 * [0.7,0.3,0.7,0.3, 1].q,
		   // amp:1,
		   instrument:[\harp, \wash],coef:0.9,rel:1, amp:[0.7,0.3]
	   ].pp
   }, type: \addMe).play;
   (beat: 3.7,strum:0.03, chord: [1, 2, 3, 5, 6].df(\e), type: \addMe).play;
   // (beat: 3.85,which: 4,strum:0.03, chord: [1, 2, 3, 5, 5.5].df(\e), type: \addMe).play;
   (beat: 4,strum:0.03, chord: T( [11, 1, 3, 5, 6].df('c#'), 0.35, \lin ), type: \addMe).play;
   (beat: 5, extra:{
	   [
	   	instrument: [\reedy, \default],
		release:2,
	   	amp:0.5,
	   	freq: [ 1, 1, -7, -6.5, -5.5, -4.5 ].df('f#', 3).q,
		dur: [1, 1, 1, 0.7, 0.3, 1].q * Yoeminrak.secDur[14] /20
	   ].p.play
   },  type: \addMe).play;
   (beat: 6,strum:0.03, chord: [1, 2, 3, 5, 6].df('d'), type: \addMe).play;
   (beat: 6, newType:\yoeDrum0, freq:99 * 2.midiratio,amp:1, type: \addMe).play;
   (beat: 7,strum:0.03, chord: [1, 2, 3, 5, 6].df('f'), type: \addMe).play;
   (beat: 8,strum:0.03, chord: [1, 2, 3, 5, 6].df('e'), type: \addMe).play;
   (beat: 8,which:[0,3], extra:{[latency:0.1,amp:0.4,instrument:\harp,coef:0.5,decaytime:5.9,freq:"3 2, 1 ".df(\c, [4, 5]).q, dur:[ 0.70, 0.3, 0.3].q * Yoeminrak.secDur[12]/20,latency:0.05, out: Effect.bus({|i| CrossoverDistortion.ar(i, smooth:0.95) => Pan2.ar(_,0.8) },)].pp},type:\addMe).play;
   (beat: 8.4,which:4,strum:0.03, chord: [1, 2, 3, 5, 5.5].df('e'), type: \addMe).play;
   (beat: 8.7,which:[0,4],strum:0.03, chord: [1, 2, 3, 5, 6].df('d'), type: \addMe).play;
   (beat: 9,which:[0,4],strum:0.03, chord: [1, 2, 3, 5, 6].df('c'), type: \addMe).play;
   (beat: 9.7,which:4,strum:0.03, chord: [1, 2, 3, 5.5, 5.5].df('c'), type: \addMe).play;
   (beat: 10,strum:0.07, chord: T( [1, 2, 3, 5, 6].df('g'), 0.3, \lin ), type: \addMe).play;
   (
   	beat: 10.05,
	extra: {
		(
			type:\garlands2,
			instrument:\reedyTune,
			tune: [11, 6.5, 11, 5, 6.5, 5, 4, 3, 5,  3, 2].dr.q,
			release:2,
			legato:0.5,
			totalDur: 3,
			freq:Pfunc{|e| e.tune * e.chord.asMap},
			initDur:0.33,
			amp:0.5,
		).play
	},
   	instrument:\defaultPiano,
   	type: \addMe
   ).play;
   (beat: 10, newType:\yoeDrum1, amp:1, type: \addMe).play;
   (beat: 14, newType:\yoeDrum2, type: \addMe).play;
   (beat: 14, chord: [1, 2, 3, 5, 6].df(\f), type: \addMe).play;
   (beat: 15, newType:\yoeDrum3, type: \addMe).play;
(beat: 15, chord:[-7, 2, 3, 6.5, 6.5].df(\f),harp:false,extra:{
       [
	   freq: [4,3].df(\c).q,
	   dur: [0.15,1].q,
	   instrument:\harp,
	   coef:0.1
       ].ppm;
       [
	   freq: [-6,-7].df(\c).q,
	   lag:0.05,
	   dur: [0.15,1].q,
	   instrument:\harp,
	   coef:0.1
       ].ppm;
       [
	   freq: [-6.5,-7].df(\c,4).q,
	   dur:[0.15,2].q,
	   amp:2,
	   instrument:[ \default, \defaultPiano ].q
	   // instrument:\defaultPiano
       ].pp
   }, type: \addMe).play;
   (beat: 15.2,harp:false,strum:0.04, chord: [1, 2, 3, 6, 6].df(\f), type: \addMe).play;
   (beat: 15.7,which:4,strum:0.04, chord: [1, 2, 3, 5.5, 5.5].df(\f), type: \addMe).play;
   (beat: 16,strum:0.06,extra:{(freq:[-5, 1 ].df(\e,4),instrument:\defaultPiano, amp:0.3).play},which:[0,1,2,4], chord: [1, 2, 3, 5, 6].df(\e), type: \addMe).play;
   (beat: 18,strum:0.06,extra:{(freq:[ 1, -1 ].df(\e,4),instrument:\defaultPiano, amp:0.3).play},which:[0,1,2,4], chord: [1, 2, 3, 5, 6].df(\e), type: \addMe).play;
   (beat: 19,which:[0,3], extra:{[latency:0.1,amp:0.4,instrument:\harp,coef:0.5,decaytime:5.9,freq:"2 3 -7 ".df(\c, [4, 5]).q, dur:[ 0.70, 0.3, 0.3].q * Yoeminrak.secDur[12]/20, out: Effect.bus({|i| CrossoverDistortion.ar(i, smooth:0.95) => Pan2.ar(_,0.8) },)].pp},chord:[1, -1, 3, 5, 6].df(\d),type:\addMe).play;

   (type:\cyc, song:\fourteen).play;
   ~preview=true;
   );

(
	   Yoeminrak.initSong(\fifteen, 15, tempoEvents:true);

   (beat: 0,strum:0.07,knum:2,  chord: [1, 2, 3, 6, 6].df('B'), type: \addMe).play;
   (beat:0, extra:{[
   	freq: [6.df(\B).dup, 5.df(\B).dup,[ 3, 6 ].df(\c),[3,5.5].df(\c)].q,
   	dur:Yoeminrak.secDur[15]/20*[3.3,0.4, 0.3,1].q,
   	amp:1,
	instrument:\reedy,
	sustain:0.5,
	release:9,
	gate:[1,0,0,0].q
   ].ppm},type:\addMe).play;
   (beat: 1, newType:\garlands,ratio:2, type: \addMe).play;
   (beat: 2, newType:\garlands,ratio:2, type: \addMe).play;
   (beat: 0, newType:\yoeDrum0, freq: 99 * -1.midiratio, type: \addMe).play;
   (beat: 3.3,strum:0.07,which:[3,4],  chord: [1, 2, 3, 5, 5].df('B'), type: \addMe).play;
   (beat: 3.6,strum:0.07,amp:T([2,2,2,2,1],0.5, \lin),  chord: T([6, 2, 3, 1, 1].df('c'), 0.2, \lin), type: \addMe).play;
   (beat: 4.0,strum:0.07,release:0.5,  chord: T([6, 1, 3, 1,6].df('e'), 0.1, \lin), type: \addMe).play;
   (beat:4.9, gates:[0,0,0,0,0],release:0.5,type:\addMe).play;
   // Yoeminrak.playVid(1,15)
   (beat: 5,strum:0.02,which: 4,  chord: T([1, 2, 3, 6, 6].df('e'), 0.1, \lin), type: \addMe).play;
   (beat: 5.4,strum:0.07,which:4,  chord: T([1, 2, 3, 5.5, 5.5].df('e'), 0.1, \lin), type: \addMe).play;
   (beat: 5.6,strum:0.07,  chord: T([1, 2, 3, 5, 6].df('g'), 0.0, \lin), type: \addMe).play;
   (beat: 6.2,strum:0.08,strings:false,  chord: T([1, 3, 3, 6, 6].df('cc'), 0.4, \lin), type: \addMe).play;
   (beat: 7.9, gates:[0,0,0,0,0],  type: \addMe).play;
   (beat: 8,which:4, chord: T( [1, 2, 3, 6, 6].df(\c), 0.3,\lin ), type: \addMe).play;
   (beat: 8.7,which:[3,4], chord: T( [1, 2, 3, 5.5, 5.5].df(\c), 0.3,\lin ), type: \addMe).play;
   (beat: 9, chord: T([1, 2, 3, 6, 6].df(\g), 0.3, \lin), type: \addMe).play;
   (beat: 9.7, chord: [1, 2, 3, 6, 6].df(\e), type: \addMe).play;
   (beat: 10, newType:\yoeDrum1, type: \addMe).play;
   (beat:10, chord: T([1, 2, 3, 5, 6].df(\B), 0.1, \lin),type:\addMe).play;
   // (beat: 10.1, gates:[0,0,0,0,0] ,release:19, type: \addMe).play;

   (beat: 11.7, chord: T( [1, 2, 3, 5, 6].df(\f), 0.3,\lin ), type: \addMe).play;
   (beat: 12, chord: T([1, 2, 3, 5, 6].df(\cc), 0.3, \lin), type: \addMe).play;
   (beat: 13,which:[0,4], chord: [-17, 1, 3, 5, 6.5].df(\cc), type: \addMe).play;
   (beat: 13.33,which:[0,4], chord: [-1, 1, 3, 5, 6].df(\cc), type: \addMe).play;
   (beat: 14, newType:\yoeDrum2, type: \addMe).play;
   (beat:13.9, gates:[0,0,0,0,0], type:\addMe).play;
   (beat: 14,extra:{
       [
	   freq: [5, 4, -7, [ 1, 3, 6 ]].df(\c, [ 4, 4, 3 ]).q,
	   strum:0.05,
	   amp:[ 1, 0.5 ] ,
	   latency:0,
	   instrument:[\reedy, \sparkTriangle, \harp],
	   sustain:0,release:3,
	   dur: Yoeminrak.secDur[15]/20 * [1, 0.7, 0.3, 1].q
       ].pp
   },knum:3, chord: [1, 2, 3, 5, 6].df(\g), type: \addMe).play;

   (beat: 15, newType:\yoeDrum3, type: \addMe, freq:-1.df(\g)).play;
   (beat: 15, chord: [1, 2, 3, 5, 6].df(\f), type: \addMe).play;
   (beat:15.68, gates:[0,0,0,0,0],type:\addMe).play;
   (beat: 15.7,strum:0.05, chord: T( [1, 2, 3, 5, 6].df(\B), 0.1, \lin ), type: \addMe).play;
   (beat: 16,strum:0.05, chord: [1, 2, 3, 5, 6].df(\c),ornament:~quickDip.(3,15), type: \addMe).play;
   (beat: 17, newType:\garlands, type: \addMe).play;
   (beat: 18.90, gates:[0,0,0,0,0],release:0.3, type: \addMe).play;
   (beat: 19,strum:0.06, chord: [1, 2, 3, 5, 6].df(\c),ornament:{DC.ar(0)!5}, type: \addMe).play;
   (beat: 19, newType:\yoeDrum0,amp:0.2,harp:false, freq:99 * [ 2] , chord: [1, 2, 3, 5, 6].df(\c), type: \addMe).play;
   (beat: 19, extra:{(instrument:\reedy, freq:99 * [1,2], amp:0.4).play}, type: \addMe).play;
   (beat: 20, gates: [0,0,0,0,0],release:14,knum:T(10, 28, \lin), type: \addMe).play;
   // Yoeminrak.song.fifteen = Yoeminrak.song.fifteen.collect {|i| i.beat = i.beat * 0.9 max: 0; i};
   // fork{
   //     0.08.wait;
       (type:\cyc, song:\fifteen, keepPlaying: true ).play;
   // };
   ~preview=true;
   );

[\zero, \one, \two, \three, \four, \five, \six, \seven, \eight, \nine, \ten, \eleven, \twelve, \thirteen, \fourteen, \fifteen].do { |name, i|
       Yoeminrak.song[i] = Yoeminrak.song[name];
   };
   Yoeminrak.song[-1] = Yoeminrak.song[\negativeOne];

fork{
	   0.21.wait;
	   Yoeminrak.env[\silent]=nil;
   }