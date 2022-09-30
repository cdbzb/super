Rec {  // a little media item that knows the durations of an associated Song section
	var <length, <armed, <section;
	var size, <path, <buffer;
	var <durs, <newDurs, <array;
	var s, <tail;
	var <ratios;
	var defaultPath,sampleRate; //set by subClasses

	*new { |name, section tail = 2 defaultPath sampleRate | ^super.new.init(name, section, tail, defaultPath, sampleRate )}


	init { | name sec t defaultPath aSampleRate |

		var d = Song.durs[sec].list;
		name = sec ++ "-" ++ name;
		section = sec;
		s = Server.default;
		defaultPath +/+ Song.current => {|i| File.exists(i).not.if{ File.mkdir(i)}};
		path = path ? ( defaultPath +/+ Song.current +/+ name );
		armed = false;
		sampleRate = aSampleRate;
		length = d.sum;
		tail = t;
		size = sampleRate * (  length + tail );
		File.exists(path).if{
			var saved = Object.readArchive(path); \exists.postln;
			buffer = Buffer.read(s, path ++ ".wav" );
			saved.durs.isNil.if{
				durs = d 
			} {
				durs = saved.durs; 
				newDurs = d;
			}

		} 	
	}

	updateDurs {
		durs = Song.durs[section].list;
		this.writeArchive(path);
	}
	
	arm { armed = true; this.updateDurs }
	
	record {
			fork{
				buffer = Buffer.doAlloc(s,size).wait;
				buffer=buffer.();
				"recording".postln;
				{ BufWr.ar( 
					this.inputUgen,
					buffer, 
					Line.ar(0, size,length + tail, doneAction:2)
					loop: 0
				);nil}.play;
				0.1 + length + tail => _.wait;
				armed = false;
				buffer.write(path++".wav", "wav", "int16"); //epos sampleRate 
				"buffer written".postln;
				durs = Song.durs[section].list;
				this.writeArchive(path);

			};
	}

	durs_ { | array |
		durs.isNil.if{ durs = array }{ newDurs = array };
		this.writeArchive(path)
	}

	play {
		armed.if{
			this.record;
			^this.inputUgen
		}{
			^this.playbuf
		}
	}

	inputUgen {
		this.subclassResponsibility(thisMethod);
	}

	playbuf{ |doneAction=0|
		var scale;
		newDurs = newDurs ? durs;
		ratios = newDurs/durs =>_.reciprocal *(sampleRate /s.sampleRate);
		scale = ratios.dq.demand(newDurs);
		^{ PlayBuf.ar(1,buffer.bufnum,rate:scale, doneAction:doneAction) }
	}

} 

RecEnv : Rec {
	classvar defaultPath = "/Users/michael/tank/super/Envelopes";
	*initClass {
		File.exists(defaultPath).not.if{File.mkdir(defaultPath)};
	}
	*new {|name section tail| ^super.new(name,section,tail, defaultPath, 1024)}
	inputUgen { ^{SoundIn.ar(0) => Amplitude.ar(_)} }
}

RecIn : Rec {

	classvar defaultPath = "/Users/michael/tank/super/samples2";
	*initClass {
		File.exists(defaultPath).not.if{File.mkdir(defaultPath)};
	}
	*new {|name section tail| ^super.new(name,section,tail, defaultPath,48000)}
	inputUgen { ^{SoundIn.ar(0)} }
}
