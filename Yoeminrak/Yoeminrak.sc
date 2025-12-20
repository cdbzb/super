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
    *resetBusses {
        env.use {
            ~root.set(0);
            ~ornament.set(0);
            ~chord.setn( [261.6255653006, 293.66476791741, 329.62755691287, 391.99543598175, 440.0]);
            ~width.setn(1.015 ! 5);
            ~knum.setn(2 ! 5);
            ~select.set(0.0);
            ~ampDist.set(0 ! 5);
            ~durDist.setn(1 ! 5);
            ~ampDistParam.setn(1 ! 5);
            ~durDistParam.setn(1 ! 5);
            ~ampScale.setn(0.5 ! 5);
            ~durScale.setn(0.5 ! 5);
            ~amp.setn([2,2,2,1,0.5]);
        }
    }
	
    *initClass {
        Class.initClassTree(aClass:Bus);
        Class.initClassTree(aClass:Env);
        Class.initClassTree(aClass:SinOsc);
		env = Environment.new;
		song = ();
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
	   Server.default.waitForBoot{
		   env.use {
			   var s = Server.default;
			   CmdPeriod.add({env.use{~playing = nil}});
			   ~know = true;
			   ~root = Bus.control(s, 1).set(0);
			   ~ornament = Bus.control(s, 5).set(0);
			   ~chord = Bus.control(s, 5).setn( [261.6255653006, 293.66476791741, 329.62755691287, 391.99543598175, 440.0]);
			   ~width = Bus.control(s, 5).setn(1.015 ! 5);
			   ~knum = Bus.control(s, 5).setn(2 ! 5);
			   ~select = Bus.control(s, 1).set(0.0);
			   ~ampDist = Bus.control(s, 5).set(0 ! 5);
			   ~durDist = Bus.control(s, 5).setn(1 ! 5);
			   ~ampDistParam = Bus.control(s, 5).setn(1 ! 5);
			   ~durDistParam = Bus.control(s, 5).setn(1 ! 5);
			   ~ampScale = Bus.control(s, 5).setn(0.5 ! 5);
			   ~durScale = Bus.control(s, 5).setn(0.5 ! 5);
			   ~amp = Bus.control(s,5).setn([2,2,2,1,0.5]);
			   // Gendy1.ar(ampdist:1, durdist:1, adparam:1.0, ddparam:1.0, minfreq:440, maxfreq:660, ampscale:0.5, durscale:0.5, initCPs:12, knum:nil, mul:1.0, add:0.0)
			   ~func = {
				   env.use {
					   {
						   var freqLag = \freqLag.kr(3);
						   [Gendy1, Gendy2, Gendy3].collect { |i|
							   i.arWidth(
								   ampdist:~ampDist.kr,
								   adparam:~ampDistParam.kr,
								   durdist:~durDist.kr,
								   ddparam:~durDistParam.kr,
								   durscale:~durScale.kr,
								   ampscale:~ampScale.kr,
								   freq: (~root.kr.lag2(freqLag) + ~ornament.kr).midiratio
								   * ~chord.kr ,
								   width: ~width.kr,
								   knum: ~knum.kr,
							   ) / 3
							   * ~amp.kr
						   } 
						   => SelectX.ar(~select.kr,_)
						   // => _.poll
						   * Env.asr(0.5, 1, \release.kr(2)).kr(0,gate:NamedControl.kr(\gates, [1, 1, 1, 1, 1]))
						   => Splay.ar(_)
					   }.play
				   }
			   };
			   ~go = { 
				   |bus newPitch time=1 curve freqLag=0| 
				   {
					   Env([bus.kr => Latch.kr(_,1), newPitch], time, curve).kr(2,gate:1).lag2(freqLag) 
					   => Out.kr(bus.index,_)
				   }.play 
			   };
		   }
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
	*makeSectionEventType {
		Event.addEventType( \ySec, {
			Yoeminrak.song[~sec]
		})
	}
    *makeStringEventType {
	 Yoeminrak.addEventType(\yoeString3,{
		 (~gates != [0,0,0,0,0]).if {
			 env.use {( ~playing.isNil ).if {~synth = ~func.();~playing=true}};
		 };
		 Server.default.makeBundle(0.2,{
			 ~gates.notNil.if {
				 env[\synth].setn(\gates, ~gates);
				 (~gates == [0,0,0,0,0]).if { env[\playing] = nil };
			 };
			 ~extra !? _.();
			 env[\synth].set(\release, ~release);
			 env[\synth].set(\freqLag, ~freqLag);
			 currentEnvironment.keysValuesDo {|i j|
				 env.use{
					 // ~synth.isPlaying.not.if {~synth = ~func.play.register};
					 // ~release !? ~synth.release(_);
					 env[i] !?
					 {|bus|
						 case
						 { j.isNumber } {"setting".postln; bus.setn(j ! bus.numChannels)} 
						 { j.isKindOf(Function)} { {
							 j
							 => _.poll
							 => Out.kr(bus, _) 
						 }.play }
						 { j.isKindOf(Array) } { bus.setn(j) }
						 { j.isKindOf(Tuple2) } { bus.setAt(j.at1, j.at2) }
						 { j.isKindOf(Tuple3) } { ~go.(bus, j.at1,j.at2, j.at3  ) }
						 { j.isKindOf(Tuple4) } { ~go.(bus, j.at1,j.at2, j.at3, j.at4) }
					 }
				 }
			 }
		 }
     )
	 }
	 );
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
            ~freqLag.notNil.if {env[\synth].set(\freqLag, ~freqLag )};
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
				   // ~type = \note;
                   currentEnvironment.copy.put(\type,\note).play;
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
    *addDrum{|section params|
		song[section].isNil.if{song[section]=List[]};
			[
				type: [0, 1, 0, 1, 2, 3].collect{|i| "yoeDrum"++i => _.asSymbol},
                beat: [0, 1, 6, 10, 14, 15],
			] ++ params
            => _.flop
            => _.collect {|i| i.asEvent}
            => _.do {|i| Yoeminrak.song[section].add(i)}
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
	addType { |type|
		^this.collect{
			|i| i.isKindOf(Event).if{
				i.put(\type, type)
			}{
				i.collect{|j| j.put(\type, type)}
			}
		}
	}
    jgb_slots { |section key|
        var slots = (type:\yoeRest) ! 20;
        this.flop.collect(_.asEvent).do {|e| slots.put(e.beat, e)};
        Yoeminrak.song.put(section ? 0, (key ? \current), slots);
        ^slots
    }

    jgb {
		var events = this.flop.collect { |i| 
			(i.flop.size > 1).if {
				i.flop.collect { |subArray x|
					var event = subArray.asEvent;
					event.put(\dur,1/3);
					event.asKeyValuePairs;
				}
			} {
				i ++ [dur:1] =>_.bubble
			}}.flatten
			.deepCollect(2, {|i| i.isKindOf(Ref).if{i.value}{i}})
			// .collect {|i x| i ++ [beat: x] => _.asEvent};
			.collect (_.asEvent);

			// Now add beat positions by accumulating durations
			var beat = 0;
			^ events.collect { |event|
				var thisEvent = event.put(\beat, beat);
				beat = beat + event[\dur];
				thisEvent
			};

    }
	add20 { |section|
		var counter=0;
		this.do{|i|
			if (i.isKindOf(Array)) {
                "ADD 1/3".postln;
				i.do {|j x|
					j.put(\beat, counter);
					counter = counter + (1/3)
				}
			} {
                "ADD 1".postln;
				i.put(\beat, counter);
				counter = counter + 1;
			}
		};
		Yoeminrak.song[section].isNil.if{ Yoeminrak.song[section]=Set[]};
        Yoeminrak.song[section].addAll(this.flat)
	}
    jgbq {
        ^this.jgb.q
    }
    jgbp { |section key|
		Yoeminrak.song[section].isNil.if {Yoeminrak.song[section] = Set[]};
        this.jgb.do {|i| Yoeminrak.song[section].add(i)};
		^Yoeminrak.song[section]
    }
    tracker {
        var columns = this[0].size;
        ^[this[0],this[1].clump(columns).flop].lace
    }
}
+ SequenceableCollection {
	yPlay { |cursor=0 section=0 solo continue=false|
        // CmdPeriod.run;
		// Yoeminrak.env[\synth].free;
		fork{
            Server.default.sync;
			solo.notNil.if{
				this.select{ |i| i.type.isNil.if{false}{i.type.contains(solo.asString) }}
			}{
				this
			}
			.do {|i|
                if (i.beat >= cursor) {
                    TempoClock.sched(Yoeminrak.secDur[section] / 20 * (i.beat - cursor), {i.copy.play})
                }
            }
        }
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
