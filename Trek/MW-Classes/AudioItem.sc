AudioItem {
	classvar <>all, <folder, <buffers;
    classvar <>armed = false;
	var <>name, <>buffer, <>path, <>recorder;
	var <>directory, <>takes;
	
	*initClass {
		all = Dictionary.new(512);
		buffers = MultiLevelIdentityDictionary.new;
		Class.initClassTree(Event);
		folder = "~/tank/SC_audiofiles".standardizePath;
		File.exists(folder).not.if{ "mkdir %".format(folder).unixCmd };
		CmdPeriod.add(this);

		Event.addEventType(\audioItem, {
			var name = ~name ?? { Error("AudioItem requires a name").throw };
			var directory = folder +/+ name;
			var entryCount = File.exists(directory).if {
				PathName(directory).entries.size
			} { 0 };
			var defaultTake = ~record.if { entryCount } { (entryCount - 1).max(0) };
			var takeNum = ~take ?? defaultTake;
			var format = (~format ? \wav).asString;
			var path = ~record.if
				{ directory +/+ takeNum ++ "." ++ format }
				{ AudioItem.takePath(directory, takeNum) };
			var buffer = buffers.at(name.asSymbol, takeNum);
			var recorder = Recorder(Server.default);

			// Create buffer if it doesn't exist
			buffer = buffer ?? {
				buffers.put(name.asSymbol, takeNum, Buffer());
				buffers.at(name.asSymbol, takeNum);
			};

			// Load audio file if it exists
			File.exists(path).if {
				(buffer.numFrames.isNil or: (buffer.numFrames == 0)).if {
					buffer.allocRead(path).updateInfo;
				}
			};
			
			// Set up the event with all the functionality
			currentEnvironment.putAll((
				path: path,
				recorder: recorder,
				buffer: buffer,
				dur: ~dur ? 5,
                record: ~record ? false,
				startPos: ~start ? 0,

			));
            ~record.if{
				armed.not.if {
					"AudioItem not armed! not recording".warn;
					~record = false;
					currentEnvironment.play
				} {
					var nc = ~numChannels ? 1;
					~recorder.recHeaderFormat_(format).recSampleFormat_(AudioItem.sampleFormatFor(format));
					~recorder.prepareForRecord(~path, nc);
					Server.default.bind{
						~recorder.record(~path, ~in ? Server.default.options.numOutputBusChannels, nc, duration: ~dur)
					};
					// invalidate cached buffer so next playback reloads from disk
					buffers.put(name.asSymbol, takeNum, Buffer());
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
                                startPos: ~startPos !? (_ * Server.default.sampleRate) ? 0
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
*cmdPeriod {
	armed = false
}
	// resolve an existing take file regardless of extension (wav/flac); fall back to .wav
	*takePath { |directory, takeNum|
		var matches = (directory +/+ takeNum ++ ".*").pathMatch;
		^matches.notEmpty.if { matches.first } { directory +/+ takeNum ++ ".wav" }
	}

	// flac caps at 24-bit int; otherwise keep the server's float32
	*sampleFormatFor { |format|
		^(format.asString == "flac").if { "int24" } { "float" }
	}

    *new {|name|
        var ret = super.new;

        ret.recorder = Recorder(Server.default);
		ret.name = name;
		//takes version
		ret.directory = folder +/+ name;
		File.exists(ret.directory).if{
			ret.takes = PathName(ret.directory).entries.size;  // Count of existing files
		} {
			File.mkdir(ret.directory);
			ret.takes = 0;  // No files yet, so count is 0
		};

		// Set path to most recent take (takes-1, or 0 if no files exist)
		ret.path = AudioItem.takePath(ret.directory, (ret.takes - 1).max(0));
		
        // Create buffer for the most recent take if it exists
        ret.buffer = buffers[name.asSymbol, (ret.takes - 1).max(0)] ?? {
			var newBuf = Buffer();
            buffers.put(name.asSymbol, (ret.takes - 1).max(0), newBuf);  // Store at correct index
			newBuf;
        };
        // Load audio file if it exists
        File.exists(ret.path).if{
            (ret.buffer.numFrames.isNil or: (ret.buffer.numFrames == 0)).if {
                ret.buffer.allocRead(ret.path).updateInfo;
            };
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
		|length, format = \wav|
		var path;
		path = directory +/+ takes ++ "." ++ format;  // New file at index 'takes'
		recorder.recHeaderFormat_(format.asString).recSampleFormat_(AudioItem.sampleFormatFor(format));
		recorder.prepareForRecord(path);
		Server.default.bind{ 
			recorder.record(
				path,
				Server.default.options.numOutputBusChannels,
				duration: length
			)
		};
		fork{
			length + 0.05 => _.wait;  // time for file to write?
			buffers.put(name, takes, Buffer.read(Server.default, path).debug("BUFFER"));
			takes = takes + 1;  // Increment after successful recording
		};
		CmdPeriod.doOnce{
			fork{
				0.05.wait; //time for file to write?
				buffers.put(name, takes, Buffer.read(Server.default, path));
				takes = takes + 1;  // Also increment here
			}
		};
	}
	take { |num|
        ^Take(name, num)
	}

    play { 
        ^Take(name, takes - 1).play  // Play the most recent take
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
			 AudioItem.buffers.put(name.asSymbol, num, Buffer.read(Server.default, AudioItem.takePath(directory, num)));
			 AudioItem.buffers[name.asSymbol][num]
		} 
        ^newTake
    }
	playbuf {| amp out rate startPos dur |
		^ 
			PlayBuf.ar(
				buffer.numChannels max: 1,
				buffer.bufnum,
				rate: rate ? 1,
				startPos: (startPos ? 0) * SampleRate.ir,
				doneAction:2
			)
			* (amp ? 1)
            * EnvGen.cutoff(dur ? 1000, 0.0)
			=> Out.ar(out ? 0, _);
		
	}
	play { |amp out rate, startPos, latency, lag, dur|
		// take.notNil.if { buffer = buffers[name][playTake] };

		fork{
			// get time to sync Server for buffer info
			var syncTime = SystemClock.seconds;
			buffer.updateInfo;Server.default.sync;

			Server.default.makeBundle(
				(latency ? 0.2) + (lag ? 0) - (SystemClock.seconds - syncTime),
				{
					{this.playbuf(amp, out, rate, startPos, dur )}.play

				}
			)
		}
	}
}
