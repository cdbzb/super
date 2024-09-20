MIDIItem {
	classvar <>folder;
	var <notes, <name;
	var stamp;
	var restFirst;
	var <synthFunc, <synths;

	*initClass {
		folder = this.filenameSymbol.asString.dirname.dirname +/+ "MIDI-items";
		File.exists(folder).not.if{ "mkdir %".format(folder).unixCmd }
	}
	*new {|name restFirst = false synthFunc|
		folder.asPathName.entries.collect(_.fileName).includesEqual(name.asString).if{\reading.postln; ^Object.readArchive(folder +/+ name)}
		{\new.postln; ^super.new.init(name, restFirst, synthFunc)}
	}
	*insertNew{|name|
		Nvim.replaceLineWith( "MIDIItem(\\\"%\\\")".format(name ++ "_" ++  Date.getDate.stamp) )
	}
	*mostRecent {
		^
		folder +/+
		( folder => PathName(_) => _.files => _.collect( { |i| i.fileNameWithoutExtension} ) => _.sort => _.last)
		=> Object.readArchive( _ )
	}
	init { |n r sf|
		restFirst = r;
		name = n;
		notes = List.new;
		synths = (0..128);
		synthFunc = sf;
	}
	monitor {
		synthFunc = synthFunc ? {|v n c s| Synth(\stringyy, [\amp, v/128, \freq, n.midicps])};
		MIDIdef.noteOn(key:\keyStage, func:{|v n c s| 
			synths.put(n, synthFunc.value(v, n, c, s));
		});
		MIDIdef.noteOff(key:\keyStageOff, func:{|v n c s|
			synths[n].release;
		});
	}
	record{ |mono=false restFirst=false latencyCompensation|
		var partialNotes = (0..128);
		var start;
		latencyCompensation = latencyCompensation ? Server.default.latency;
		stamp = Date.getDate.stamp;
		synthFunc = synthFunc ? {|v n c s| Synth(\stringyy, [\amp, v/128, \freq, n.midicps])};
		start = SystemClock.seconds;
		mono.if{
			var released;
			var keyDown = false ! 128, lastNote = 0;
			MIDIdef.noteOn(key:\keyStage, func:{|v n c s| 
				var running = (try{ synths[0].isRunning } == true) ;
				keyDown[n] = true; 
				lastNote.debug("last note ");
				keyDown[lastNote].debug("keyDown[n] ");

				restFirst.if{notes.add((type:\rest, start: start + latencyCompensation, dur: SystemClock.seconds - start - latencyCompensation, midinote:0 )); restFirst=false};
				// if(running and: not(released))  
				if(keyDown[lastNote] and: (lastNote != n)){
					\set.postln;
					synths[0].set(\freq, n.midicps); \set.postln
				}{ 
					\retrigger.postln;
					synths.put(0, synthFunc.value(v, n, c, s).register) 
				};
				partialNotes.put(n, (midinote: n, amp: v/128, start: SystemClock.seconds ));
				released = false;
				lastNote = n
			});
			MIDIdef.noteOff(key:\keyStageOff, func:{|v n c s|
				keyDown[n] = false;
				keyDown[lastNote].not.if{
					synths[0].set(\gate, 0);
				};
				partialNotes[n].dur = SystemClock.seconds - partialNotes[n].start;
				notes.add(partialNotes[n]);
				partialNotes[n] = nil;
			})
		}{
			MIDIdef.noteOn(key:\keyStage, func:{|v n c s| 
				restFirst.if{notes.add((type:\rest, start: start + latencyCompensation, dur: SystemClock.seconds - start - latencyCompensation, midinote:0 )); restFirst=false};
				synths.put(n, synthFunc.value(v, n, c, s));
				partialNotes.put(n, (midinote: n, amp: v/128, start: SystemClock.seconds ));
			});
			MIDIdef.noteOff(key:\keyStageOff, func:{|v n c s|
				synths[n].release;
				partialNotes[n].dur = SystemClock.seconds - partialNotes[n].start;
				notes.add(partialNotes[n]);
				partialNotes[n] = nil;
			});
		};
		MIDIdef.cc(\stop, {|v| (v>0).if{ this.stop }})
	}
	stop {
		MIDIdef(\keyStage).free;
		MIDIdef(\keyStageOff).free;

		notes = notes.sort({|i j| i.start < j.start});

		notes.do({|i x|  //set legato
			var delta = notes.clipAt(x+1).start - i.start;
			(delta == 0).not.if {i.legato = i.dur/delta; i.dur = delta}{i.legato = 1};
		});
	}
	save {
		this.writeArchive( folder +/+ name)
	}
	reset {
		notes = List.new
	}
	asPbind {
		^[\midinote, \dur, \legato].collect{|key| [key, notes.collect(_.at(key)).q]}.flatten.p 
	}

}
