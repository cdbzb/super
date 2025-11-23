MPV {
	*play {|path start end audio=true|
		"mpv" + audio.if{""}{"--no-audio"} + "--start=% --end=% %".format(start, end, path) => _.unixCmd
	}
}

Yoeminrak {
    classvar <video;
	classvar <sections;
	classvar particleVidOffset = 20;

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
    }
    *playVid { |vid sec start=0 end=5 audio=true| 
		var path = (vid==0).if{video.at(\live)}{video.at(\particles)};
		sec.notNil.if {
			start = sections[sec] + (vid * particleVidOffset);
			end = sections[sec + 1] + (vid * particleVidOffset)
		};
		// var path = (vid == 0).if {\video}{\live} => video.at(_) ;
		 MPV.play(path, start, end, audio)
	}

}
