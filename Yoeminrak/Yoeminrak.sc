MPV {
	*play {|path start end audio=true fullscreen=false|
		"mpv" + audio.if{""}{"--no-audio"} + fullscreen.if{"--fs "}{" "} ++ "--start=% --end=% %".format(start, end, path) => _.unixCmd
	}
}

Yoeminrak {
    classvar <video;
	classvar <sections, <secDur;
	classvar <>particleVidOffset = 20;

    *initClass {
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
    }
    *playVid { |vid sec  audio=true fullscreen=false start=0 end=5| 
		var path = (vid==0).if{video.at(\live)}{video.at(\particles)};
		sec.notNil.if {
			start = sections[sec] + (vid * particleVidOffset);
			end = sections[sec + 1] + (vid * particleVidOffset)
		};
		 MPV.play(path, start, end, audio, fullscreen)
	}
    *addEventType { |name func|
		Event.addEventType(name, { ~dur = ~dur * secDur[~section ? 0] / 20 => _.postln} ++ func  )
    }
	*makeDrumEventTypes{ |funcArray|
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

}
+ Array {
    jgb {
        var func = {|string| 
			string.split(Char.space)
			.reject{|i| i.size==0}
			.collect(_.asFloat)}
			;
        ^this.collect {| i| i.isKindOf(String).if {func.(i) } {i}}
    }
}
+ Pattern {
    jgb { |beatDur=1|
        ^Prout({ |ev|
            var stream = this.asStream;
            var event;
            while {
                event = stream.next(ev);
                event.notNil;
            } {
                var deg = event[\degree];
                if(deg.isArray and: { deg.isKindOf(Ref).not }) {
                    var n = deg.size;
                    n.do { |i|
                        var newEvent = event.copy;
                        newEvent.keysValuesDo { |k, v|
                            if(v.isArray and: { v.size == n } and: { v.isKindOf(Ref).not }) {
                                newEvent[k] = v[i];
                            };
                        };
                        newEvent[\dur] = beatDur / n;
                        ev = newEvent.yield;
                    };
                } {
                    if(deg.isKindOf(Ref)) { event[\degree] = deg.value };
                    event[\dur] = beatDur;
                    ev = event.yield;
                };
            };
        });
    }
}
