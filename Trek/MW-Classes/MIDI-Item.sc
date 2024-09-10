MIDIItem {
	classvar <>folder;
	var <notes, <name;
	var stamp;
	var restFirst;

	*initClass {
		folder = this.filenameSymbol.asString.dirname.dirname +/+ "MIDI-items";
		File.exists(folder).not.if{ "mkdir %".format(folder).unixCmd }
	}
	*new {|name restFirst = false|
		folder.asPathName.entries.collect(_.fileName).includesEqual(name).if{^Object.readArchive(folder +/+ name)}
		{^super.new.init(name, restFirst)}
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
	init { |n r|
		restFirst = r;
		name = n;
		notes = List.new;
	}
	record{ |restFirst=false synthFunc latencyCompensation|
		var synths = (0..128);
		var partialNotes = (0..128);
		var start;
		latencyCompensation = latencyCompensation ? Server.default.latency;
		stamp = Date.getDate.stamp;
		synthFunc = synthFunc ? {|v n c s| Synth(\stringyy, [\amp, v/128, \freq, n.midicps])};
		start = SystemClock.seconds;
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
	asPbind {
		^[\midinote, \dur, \legato].collect{|key| [key, notes.collect(_.at(key)).q]}.flatten.p 
	}

}
