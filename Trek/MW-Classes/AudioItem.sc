AudioItem {
	classvar <>all, <folder, <buffers;
	var <>name, <>buffer, <>path, <>recorder;
	var <>directory, <>takes;
	
	*initClass {
		all = Dictionary.new(512);
		buffers = MultiLevelIdentityDictionary.new;
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
						~recorder.record(~path, Server.default.options.numOutputBusChannels, duration: ~dur)
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

    *new {|name|
        var ret = super.new;

        ret.recorder = Recorder(Server.default);
		ret.name = name;
		//takes version
		ret.directory = folder +/+ name;
		File.exists(ret.directory).if{
			ret.takes = PathName(ret.directory).entries.size
		} {
			File.mkdir(ret.directory);
			ret.takes = 1
		};

		//set path to most recent take
		ret.path = ret.directory +/+ (ret.takes - 1) ++ ".wav";
        // Create buffer if it doesn't exist
        ret.buffer = buffers[name.asSymbol, ret.takes - 1] ?? {
			var newBuf = Buffer();
            buffers.put(name.asSymbol, ret.takes, newBuf);
			newBuf;
        };
        // Load audio file if it exists
        File.exists(ret.path).if{
            ret.buffer.allocRead(ret.path).updateInfo;
        };
		^ret
    }
	*insertNew {|name|
		Nvim.replace("AudioItem(\\\"%\\\")".format(name ++ "_" ++ Date.getDate.stamp))
	}
	*insertEvent {|name|
		Nvim.replace( "(type: \\\\audioItem, name: \\\"%\\\")".format(name ++ "_" ++  Date.getDate.stamp) )
	}
	record {
		|length|
		var path;
		takes = takes + 1;
		path = directory +/+ takes ++ ".wav";
		recorder.prepareForRecord(path);
			Server.default.bind{ 
				recorder.record(
					path,
					Server.default.options.numOutputBusChannels ,
					duration: length
				)
			};
			fork{ length.wait; buffers.put(name, takes, Buffer.read(Server.default, path)).debug("BUFFER") };
			CmdPeriod.doOnce{ buffers.put(name, takes, Buffer.read(Server.default, path)) };
	}
	take { |num|
        ^Take(name, num)
	}

    play {
        ^Take(name, takes).play
    }
}
Take : AudioItem {
    var name, num, buffer;
    *new { |name, num|
        var newTake = super.newCopyArgs;
		var directory = folder +/+ name;
        newTake.buffer = AudioItem.buffers[name.asSymbol][num].notNil.if { 
			 AudioItem.buffers[name.asSymbol][num] 
		} {
			 AudioItem.buffers.put(name.asSymbol, num, Buffer.read(Server.default,directory +/+ num ++ ".wav"));
			 AudioItem.buffers[name.asSymbol][num]
		} 
        ^newTake
    }
	playbuf {| amp out rate startPos |
		^ 
			PlayBuf.ar(
				buffer.numChannels,
				buffer.bufnum,
				rate: rate ? 1,
				startPos: startPos ? 0,
				doneAction:2
			)
			* (amp ? 1)
			=> Out.ar(out ? 0, _);
		
	}
	play { |amp out rate, startPos latency lag|
		// take.notNil.if { buffer = buffers[name][playTake] };

		fork{
			// get time to sync Server for buffer info
			var syncTime = SystemClock.seconds;
			buffer.updateInfo;Server.default.sync;

			Server.default.makeBundle(
				(latency ? 0.2) + (lag ? 0) - (SystemClock.seconds - syncTime),
				{
					{this.playbuf(amp, out, rate, startPos)}.play
				}
			)
		}
	}
}
