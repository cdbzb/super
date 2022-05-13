

MakeEnv {
	var time,length=4;
	var size, path, <buffer;

	*new { |time length| ^super.new.init(time, length) }
	init { |time length|
		var s = Server.default;
		size = 1024 * length;
		path = "/tmp" +/+ "env" ++ time ++ ".wav";
		buffer = Buffer.alloc(s,size);
		fork{
			{ BufWr.ar( 
				SoundIn.ar(0) => Amplitude.ar(_), 
				buffer, 
				Line.ar(0,size,length,doneAction:2)
				loop: 0
			);nil}.play;
			length.wait;
			buffer.write(path,"wav","int16");
			buffer.path_(path);
		};
		^this
	}
	*get{ |time|
		^ super.new.prGet(time);

	}
	prGet { |time|
		var s = Server.default;
		path = "/tmp" +/+ "env" ++ time ++ ".wav";
		buffer = Buffer.read(s, path, action: { 
			|b|
			length = b.numFrames / 1024
		});
	^this;
	}
	playbuf { |dur |
		// ouch this math can be simplified! duh
		var rate = dur.isNil.if{1}{ (buffer.numFrames / 1024 /dur) };

		 ^{ PlayBuf.ar(1,buffer, rate: ( BufDur.kr( buffer) / (buffer.numFrames / 1024) ) * rate => _.lag(0.03) ) }
	}

} 
