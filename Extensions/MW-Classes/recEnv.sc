Rec {  // a little media item that knows the durations of an associated Song section
	var <length, <armed, <section;
	var size, <path, <buffer;
	var <durs, <newDurs, <array;
	var s, <tail;
	var <ratios;
	var directory,sampleRate; //set by subClasses

	*new { |name, section tail = 2 directory sampleRate | ^super.new.init(name, section, tail, directory, sampleRate )}

	init { | name sec t directory aSampleRate |

		var d = Song.durs[sec].list;
		name = sec ++ "-" ++ name;
		section = sec;
		s = Server.default;
		directory +/+ Song.current => {|i| File.exists(i).not.if{ File.mkdir(i)}};
		path = path ? ( directory +/+ Song.current +/+ name );
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

	scale {
		newDurs = newDurs ? durs;
		ratios = newDurs/durs =>_.reciprocal * (sampleRate/s.sampleRate);
		^ratios.dq.demand(newDurs);
	}

	playbuf{ |doneAction=0|
		^{ PlayBuf.ar(1, buffer.bufnum, rate:this.scale, doneAction:doneAction) }
	}

} 

RecEnv : Rec {
	classvar directory = "/Users/michael/tank/super/Envelopes";
	*initClass {
		File.exists(directory).not.if{File.mkdir(directory)};
	}
	*new {|name section tail| ^super.new(name,section,tail, directory, 1024)}
	inputUgen { ^{SoundIn.ar(0) => Amplitude.ar(_)} }
}

RecIn : Rec {

	classvar directory = "/Users/michael/tank/super/samples2";
	var <>fftBuffer, <test;
	*initClass {
		File.exists(directory).not.if{File.mkdir(directory)};
		SynthDef("pvIn", { |recBuf=1 soundBufnum=2 fftSize=2048 hop= 0.5 window=1|
			var in, chain, bufnum;
			bufnum = LocalBuf.new(fftSize);
			//Line.kr(1, 1, BufDur.kr(soundBufnum), doneAction: 2);

			//need to set duration
			in = SoundIn.ar(0) ;
			// note the window type and overlaps... this is important for resynth parameters
			chain = FFT(bufnum, in, hop, window);
			chain = PV_RecordBuf(chain, recBuf, 0, 1, 0, hop, window);
		}).add;
	}
	*new {|name section tail| ^super.new(name, section, tail, directory, 48000).pinit}
	pinit {\initializing.postln; test = 666}
	inputUgen { ^{SoundIn.ar(0)} }
	playRaw {|rate=1 loop=0 doneAction=2| ^{ PlayBuf.ar (1,buffer.bufnum,rate:rate, doneAction:doneAction,loop:loop)} }
	allocatePVBuffer {|fftSize=2048 hop=0.5|
		^Buffer.alloc(s,length.calcPVRecSize(fftSize,hop), 1 );
	}
	record {|fftSize=2048, hop=0.5, window=0|
		fftBuffer = this.allocatePVBuffer(fftSize,hop,window);
		Synth(\pvIn,[fftBuffer,buffer]);
		super.record
	}

	getFFT {|fftSize=2048 hop= 0.5 window = 0|
		fftBuffer = this.allocatePVBuffer(fftSize,hop,window);
		Synth(\pvrec,[\recBuf,fftBuffer,\soundBufnum,buffer.bufnum,\fftSize,fftSize,\hop,hop,\window,window]);
		^fftBuffer
	}

	playFFT{ |out=0, rate=1 fftSize=2048 hop= 0.5 window = 1|
		^{
			var in, chain, bufnum;
			bufnum = LocalBuf.new(fftSize);
			chain = PV_PlayBuf(bufnum, fftBuffer, this.scale, 0, 1, 1, 0.25, 1);
			IFFT(chain, window);
		}

	}
}
