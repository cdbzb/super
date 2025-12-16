MPV {
	*play {|path start end audio=true fullscreen=false|
		"mpv" + audio.if{""}{"--no-audio"} + fullscreen.if{"--fs "}{" "} ++ "--start=% --end=% %".format(start, end, path) => _.unixCmd
	}
}

Yoeminrak {
    classvar <video;
	classvar <sections, <secDur;
	classvar <>particleVidOffset = 20;
    classvar <>env;
    classvar <>song;
    classvar <> muted;

    *initClass {
        Class.initClassTree(aClass:Bus);
        Class.initClassTree(aClass:Env);
        Class.initClassTree(aClass:SinOsc);
		env = Environment.new;
        song = MultiLevelIdentityDictionary();
		ServerTree.add({"pkill mpv".unixCmd});
        video = (
       particles: "'/Users/michael/tank/Hyojin/Video Sync/Media/여민락_2025__yeomillak-2025 (720p).mp4'",
       live:  "'/Users/michael/tank/Hyojin/Video Sync/Media/1015_여민락_실연_full (720p).mp4'";
        );
		sections =   [
   	       -2.7, //0  forward arms up and down
   	       -1.3, //1 the same
   	       0, //2 to the right - crouch
   	       -3, //3 to the left and crouch
   	      -2.75 , //4 to the rear 
   	      -3.5, //5 spin and to the front
   	      -4, //6
   	      -8, //7
   	      -14, //8
   	      -23, //9
   	      -34, //10
   	      -44, //11
   	      -56, //12
   	      -67, //13
   	      -81, //14
   	      -94, //15
   	      -76, //15
   	   ].collect{|i x| x * 52 + 6 + i };
	   secDur = sections.differentiate.drop(1);
       this.makeDrumEventTypes;
       this.makeStringEventType;
	   this.makeNoteEventType;
	   this.makeRestEventType;
       env.use {
           ~pitch = Bus.control(Server.default, 5).setn([0,0,0,0,0]);
           ~ornament =  Bus.control(Server.default, 5).setn([0,0,0,0,0]);
           ~bendUpFunc = {|dur=1|
			   ~b.free; ~b = { Env([0,0,1,0],[dur-0.5,0.5,0]).kr(0, 1).dup(5) => Out.kr(env[\ornament],_)}.play
           };
           ~wiggle = {
               ~b.free; ~b = { SinOsc.ar(5, 0, 0.2).dup(5) => Out.kr(env[\ornament], _)}.play;
           };
		   ~synthFunc2 = {|freqLag=3 knum=2 width=(0.5.midiratio)| {
			   // [ Gendy2,Gendy1, Gendy3 ]
			   // [Gendy1]
			   // .collect
			   // {
			   // |i|
			   var freqLag = \freqLag.kr(freqLag);
               var knum=NamedControl.kr(\knum,#[2,2,2,2,2]);
               var width=NamedControl.kr(\width,#[1.05,1.05,1.05,1.05,1.05]);
			   var chord=NamedControl.kr(\chord, #[1, 2, 3, 5, 6].df(\c));
               chord.collect { |i x|
                   [ Gendy1, Gendy2, Gendy3 ].collect {|ugen|
                       ugen.arWidth(
                           initCPs:12,
                           ampdist:0,
                           // knum:SinOsc.ar(0.02, 0,  6).abs + 2.1,
                           // knum:\knum.kr(knum),
                           knum:knum[x].poll,
                           freq: 
                           i * ~pitch.kr[x].midiratio
                           .lag2({ 0.5.rand} + freqLag * (freqLag > 0))
                           *  ~ornament.kr[x].midiratio,
                           width:width[x]
                       ) / 3
                   } => SelectX.ar(\select.kr(1), _)
               }
			   * [2, 2, 2, 1, 0.5]
			   * Env.asr(0.5,releaseTime:5).kr(doneAction:0, gate:
				   NamedControl.kr(\myGate, [1, 1, 1, 1, 1])
			   )
			   => Splay.ar(_)
		   }.play };
		   ~synthFunc = {|freqLag=3 knum=2 width=(0.5.midiratio)| {
			   // [ Gendy2,Gendy1, Gendy3 ]
			   // [Gendy1]
			   // .collect
			   // {
			   // |i|
			   var freqLag = \freqLag.kr(freqLag);
			   Gendy1.arWidth(
				   initCPs:12,
				   ampdist:0,
				   // knum:SinOsc.ar(0.02, 0,  6).abs + 2.1,
				   // knum:\knum.kr(knum),
				   knum:NamedControl.kr(\knum,#[2,2,2,2,2]),
				   freq: 
				   [1, 2, 3, 5, 6].df(\c) *
				   ~pitch.kr().midiratio
				   .lag2(
					   { 0.5.rand}.dup(5) + freqLag 
					   * (freqLag > 0) // use freqLag 0 to turn off
				   )
				   // .midiratio 
				   *  ~ornament.kr.midiratio,
				   width:\width.kr(width),
			   ) / 3
			   // }// => Mix.ar(_)
			   * [2, 2, 2, 1, 0.5]
			   * Env.asr(0.5,releaseTime:5).kr(doneAction:0, gate:
				   NamedControl.kr(\myGate, [1, 1, 1, 1, 1])
			   )
			   => Splay.ar(_)
		   }.play };
       }
    }
    *playVid { |vid sec  audio=true fullscreen=false length=1 start=0 end=5| 
		var path = (vid==0).if{video.at(\live)}{video.at(\particles)};
		sec.notNil.if {
			start = sections[sec] + (vid * particleVidOffset);
			end = sections[sec + length] + (vid * particleVidOffset)
		};
		 MPV.play(path, start, end, audio, fullscreen)
	}
    *addEventType { |name func|
		Event.addEventType(name, { ~dur = ~dur * secDur[~section ? 0] / 20 => _.postln} ++ func  )
    }
    *makeStringEventType {
        Yoeminrak.addEventType(\yoeString2, {  //multi-voice version from Claude
            // make array if single num
            var freq = 5.collect {|i|~freq.asArray.wrapAt(i)} ;
            var gates = 5.collect {|i| 
                var f = ~freq.asArray.wrapAt(i);
                if(f == "r", { 0 }, { 1 })
            };
            var pitches = 5.collect {|i|
                var f = ~freq.asArray.wrapAt(i);
                if((f == "r") || (f == "-"), { env[\pitch].getnSynchronous(5)[i] }, { f })
            };
			var go = { |newPitch time=1 curve| 
				{
					Env([env[\pitch].kr => Latch.kr(_,1), newPitch], time, curve).kr(2,gate:1)
					=> Out.kr(env[\pitch].index, _)
				}.play 
			};

            //retrigger if resting
            ( env[\synth].isPlaying.not or: env[\resting] ).if{
                env.use{~synth=~synthFunc2.(~freqLag, ~knum,~width).register; ~resting = false};

            };

            // env[\pitch].setn(pitches);
            env[\synth].set(\freqLag, ~freqLag ? 2);
			try{
				go.(pitches, ~time ? 0.1 => _.postln, ~curve);
			};
            // env[\synth].setn(\myGate, gates);
            (~freq.asString == "r" ).if {
                env[\synth].setn(\myGate, [0,0,0,0,0]);
            } {
                env[\synth].setn(\myGate, [1,1,1,1,1]);
            }
            ;
            ~ornament !? _.(~dur);
            env[\synth].setn(\knum, ~knum);
            env[\synth].setn(\chord, ~chord);
            env[\synth].setn(\select, ~select);
            env[\synth].setn(\width, ~width ? 1.05);
        });
        Yoeminrak.addEventType(\yoeString, {  //multi-voice version from Claude
            // make array if single num
            var freq = 5.collect {|i|~freq.asArray.wrapAt(i)} ;
            var gates = 5.collect {|i| 
                var f = ~freq.asArray.wrapAt(i);
                if(f == "r", { 0 }, { 1 })
            };
            var pitches = 5.collect {|i|
                var f = ~freq.asArray.wrapAt(i);
                if((f == "r") || (f == "-"), { env[\pitch].getnSynchronous(5)[i] }, { f })
            };
			var go = { |newPitch time=1 curve| 
				{
					Env([env[\pitch].kr => Latch.kr(_,1), newPitch], time, curve).kr(2,gate:1).poll 
					=> Out.kr(env[\pitch].index, _)
				}.play 
			};

            //retrigger if resting
            ( env[\synth].isPlaying.not or: env[\resting] ).if{
                env.use{~synth=~synthFunc.(~freqLag, ~knum,~width).register; ~resting = false};

            };

            // env[\pitch].setn(pitches);
            env[\synth].set(\freqLag, ~freqLag ? 2);
			try{
				go.(pitches, ~time ? 0.1 => _.postln, ~curve);
			};
            // env[\synth].setn(\myGate, gates);
            (~freq.asString == "r" ).if {
                env[\synth].setn(\myGate, [0,0,0,0,0]);
            } {
                env[\synth].setn(\myGate, [1,1,1,1,1]);
            }
            ;
            ~ornament !? _.(~dur);
            env[\synth].setn(\knum, ~knum);
            env[\synth].setn(\width, ~width ? 1.05);
        });
    }
	*makeRestEventType {
        Event.addEventType(\yoeRest,{
            ~dur = (~dur ? 1) * Yoeminrak.secDur[ ~section ? 0 ] / 20;
            ~type = \rest;
            currentEnvironment.play
        })
    }
	*makeNoteEventType {
		Event.addEventType(type:\yoeNote, func:{
            ~dur = (~dur ? 1) * Yoeminrak.secDur[ ~section ? 0 ] / 20;
            ~type = ~freq.isKindOf(Number).if {\note.postln}{\rest.postln};
            currentEnvironment.play;
        }, parentEvent:nil)
	}
	*makeDrumEventTypes { |funcArray|
        funcArray = funcArray ? [
               { 
                   ~amp = 1;
                   ~out = { Effect.bus({ |i| FreeVerb.ar(i, 1,1) * 8 }) };
				   ~type = \note;
                   currentEnvironment.play;
                   // (
                       // freq: env[\pitch].getSynchronous * 2/6,
                       // freq: ~freq ,
                   // ).play ;
                   },{
                       { MembraneCircle.ar(excitation: Impulse.ar(0) => {|i| i  => Decay.ar(_, 0.3) * PinkNoise.ar(1) }, tension:SinOsc.ar(LFNoise0.ar().range(4,[ 5, 6 ])) /100 + 0.001, loss:0.9999) * XLine.kr (0.3,00001,9) => LeakDC.ar(_)}.play;
                   },{
                       (
                           instrument:\cymbalsDS, amp: [ 0.02, 0.021 ], out:Effect.bus({|i| FreeVerb.ar(i, 1, 1) * [3,2]})
                       ).play
                   },{
                       (instrument:[ \stringyy, \harpGendy ],freq:~freq, amp: 0.3, out: Effect.bus({|i| FreeVerb.ar(i, 1, 1) },)).play ;
                   }
	       ];
		funcArray.do {|i x|
			this.addEventType( "yoeDrum" ++ x => _.asSymbol, i)
		};
	}
    *drumPbind{ |start=0 end=15|
			^[
				type: [0, 1, 0, 1, 2, 3].collect{|i| "yoeDrum"++i => _.asSymbol} => _.q(16),
				dur: [1, 5, 4, 4, 1, 5].q(16),
				section: (start..end).stutter(6).q
			].p
    }
    *drumArray {|section|

			^[
				type: 
				[
                    [0, 1, 0, 1, 2, 3].collect{|i| "yoeDrum"++i => _.asSymbol}
                    ,[\remove,\yoeRest!4,\yoeRest!3,\yoeRest!3,\remove,\yoeRest!5]
                ].lace(12).reject(_==\remove).flat
				,
				dur: 1,
				section: section ? 0
			]
    }
    *playSection {|sec=0|
        // song.at(sec)
        Yoeminrak.song[sec].keys.reject {|key| (muted ? [] ).any {|i| key.asString.contains(i)}} .do {|i| Yoeminrak.song.at(sec, i).q.play}
    }
	*playSong {|sec=0|
		song[sec].keys.do {|key|
			song[sec][key].q.play
		}
	}
}
+ Array {
    jgb_slots { |section key|
        var slots = (type:\yoeRest) ! 20;
        this.flop.collect(_.asEvent).do {|e| slots.put(e.beat, e)};
        Yoeminrak.song.put(section ? 0, (key ? \current), slots);
        ^slots
    }

    jgb {
		^this.flop.collect { |i| 
			(i.flop.size > 1).if {
				i.flop.collect { |subArray|
					subArray.asEvent.put(\dur,1/3).asKeyValuePairs
				}
			} {
				i ++ [dur:1] =>_.bubble
			}}.flatten
			.deepCollect(2, {|i| i.isKindOf(Ref).if{i.value}{i}})
			.collect {|i x| i ++ [beat: x] => _.asEvent}
    }
    jgbq {
        ^this.jgb.q
    }
    jgbp { |section=0 key|
        Yoeminrak.song.put(section, key.asSymbol, this.jgb)
    }
    tracker {
        var columns = this[0].size;
        ^[this[0],this[1].clump(columns).flop].lace
    }
}
+ Pattern {
    jgb {
        ^Prout({ |ev|
            var stream = this.asStream;
            var event;
            while {
                event = stream.next(ev);
                event.notNil;
            } {
                var freq = event[\freq];
                var originalDur = event[\dur] ? 1;
                if(freq.isArray and: { freq.isKindOf(Ref).not }) {
                    var n = freq.size;
                    n.do { |i|
                        var newEvent = event.copy;
                        newEvent.keysValuesDo { |k, v|
                            if(v.isArray and: { v.size == n } and: { v.isKindOf(Ref).not }) {
                                newEvent[k] = v[i];
                            };
                        };
                        newEvent[\dur] = originalDur / n;
                        ev = newEvent.yield;
                    };
                } {
                    if(freq.isKindOf(Ref)) { event[\freq] = freq.value };
                    ev = event.yield;
                };
            };
        });
    }
}
