AudioItem {
	classvar <>all, <folder, <buffers;
	
	*initClass {
		all = Dictionary.new(512);
		buffers = ();
		Class.initClassTree(Event);
		folder = "~/tank/SC_audiofiles".standardizePath;
		File.exists(folder).not.if{ "mkdir %".format(folder).unixCmd };

		Event.addEventType(\audioItem, {
			var name = ~name ?? { Error("AudioItem requires a name").throw };
			var buffer = buffers[name.asSymbol];
			var path = folder +/+ name ++ ".wav";
			var recorder = Recorder(Server.default);
			
			// Create buffer if it doesn't exist
			buffer = buffer ?? {
				buffers[name.asSymbol] = Buffer();
				buffers[name.asSymbol];
			};
			// Load audio file if it exists
			File.exists(path).if{
				buffer.allocRead(path).updateInfo;
			};
			
			// Set up the event with all the functionality
			currentEnvironment.putAll((
				path: path,
				recorder: recorder,
				buffer: buffer,
				dur: ~dur ? 5,
                record: ~record ? false,
			));
            ~record.if{
					~recorder.prepareForRecord(~path, 1); 
					Server.default.bind{ 
						~recorder.record(~path, 8, duration: ~dur)
					}
            } {
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
            }
		}, (dur:5)
	);
	}
	
	*insertNew {|name|
		Nvim.replace( "(type: \\\\audioItem, name: \\\"%\\\")".format(name ++ "_" ++  Date.getDate.stamp) )
	}
}
