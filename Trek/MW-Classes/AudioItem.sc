
AudioItem{
	classvar <>all, <folder, <buffers;
	*initClass {
		all = Dictionary.new(512); //is this big enough??
        buffers = ();
		Class.initClassTree(Event);
		folder = "~/tank/SC_audiofiles".standardizePath;
		File.exists(folder).not.if{ "mkdir %".format(folder).unixCmd };
		Event.addEventType(\aItem, {
			var buffer = buffers[~name] ? (buffers[~name] = Buffer());
            // var path = 
		})
	}
	*insertNew{|name|
		Nvim.replace( "AudioItem(\\\"%\\\")".format(name ++ "_" ++  Date.getDate.stamp) )
	}
	*new{|name ...args, kwargs|
		var env = kwargs.asEvent;
		var buffer = (
			buffers[name.asSymbol].isNil.if{
				buffers[name.asSymbol] = Buffer()  
			};
			buffers[name.asSymbol]
		);
		File.exists(this.folder +/+ name ++ ".wav").if{
			buffer.allocRead(this.folder +/+ name ++ ".wav").updateInfo
		};
		/* psuedo-code
		File.exists(audio).if {
			get last take number;
			set take number to last take number + 1
		}
		*/
	
		^ env ++
		(
			path: this.folder +/+ name ++ ".wav",
			recorder: Recorder(Server.default),
			buffer:buffer,
			dur: 5,
			// this should use Buffer.cue perhaps
			record: {|self| self.recorder.prepareForRecord(self.path, 1); Server.default.bind{ self.recorder.record(self.path, 8, duration: self.dur)} },
			play: {
                // self.buffer.allocRead( self.path).updateInfo; 
				Server.default.makeBundle(
					(~latency ? 0.2) + (~lag ? 0),
					{
                        {
                            PlayBuf.ar(
                                ~numChannels ? 1,
                                buffer.bufnum,
                                rate: ~rate ? 1,
                                startPos: ~startPos ? 0
                            )
                            * (~amp ? 1)
                            => Out.ar(~out ? 0, _)
                        }.play
					}
				)
			},
		)
	}
	
}
