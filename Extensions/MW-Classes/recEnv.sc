Rec {  // a little media item that knows the durations of an associated Song section
	var <length, <armed, <section;
	var size, <path, <buffer, <saved;
	var <durs, <newDurs, <array;
	var s, <tail;
	var <ratios;
	var directory,sampleRate; //set by subClasses
	classvar <>masterArmed = false;

	*new { | part tail = 2 directory sampleRate | ^super.new.init(part, tail, directory, sampleRate )}

	init { | part t directory aSampleRate |

		var d = Song.durs[part.start].list;
		var name = part.key ++ "_" ++ part.parent.lyrics[part.start].hash.abs;
		section = part.start;
		s = Server.default;
		directory +/+ Song.current => {|i| File.exists(i).not.if{ File.mkdir(i)}};
		path = path ? ( directory +/+ Song.current +/+ name );
		armed = false;
		sampleRate = aSampleRate;
		length = d.sum;
		tail = t;
		size = sampleRate * (  length + tail );
		File.exists(path).if{
			saved = Object.readArchive(path); \exists.postln;
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
	
	arm { armed = true;  }
	*record {masterArmed = true}
	
	record {
			fork{
				this.updateDurs;
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
				this.writeFiles;
				"buffer written".postln;
				durs = Song.durs[section].list;
				this.writeArchive(path);

			};
	}

	writeFiles {
		this.subclassResponsibility(thisMethod);
	}

	durs_ { | array |
		durs.isNil.if{ durs = array }{ newDurs = array };
		this.writeArchive(path)
	}

	play {
		( armed and: masterArmed ).if{
			this.record;
			masterArmed = false;
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
	classvar armed;
	*initClass { File.exists(directory).not.if{File.mkdir(directory)}; }
	*new {|part tail=0| ^super.new(part ,tail, directory, 1024)}
	writeFiles { buffer.write(path++".wav", "wav", "int16");} //epos sampleRate 
	inputUgen { ^{SoundIn.ar(0) => Amplitude.ar(_)} }
}

RecOnsets {
	var <>armed=false, path, name, <section, tail, <saved, s, <list;
	classvar directory = "/Users/michael/tank/super/Onsets";
	classvar <>masterArmed;
	*initClass { File.exists(directory).not.if{File.mkdir(directory)}; }
	*new {|part tail=0| ^super.new.init(part,tail)}
	*record {masterArmed = true}
	init { |part t|

		var name = part.key ++ "_" ++ part.parent.lyrics[part.start].hash.abs;
		section = part.start;
		// name = sec ++ "-" ++ n;
		// section = sec;
		s = Server.default;
		directory +/+ Song.current => {|i| File.exists(i).not.if{ File.mkdir(i)}};
		path = directory +/+ Song.current +/+ name;
		armed = false;
		tail = t ? 0;
		File.exists(path).if{
			var saved = Object.readArchive(path); \exists.postln;
			list = saved.list;
		};
		try{ this.list.asArray.registerD }
	}
	play{
		^( armed and: masterArmed ).if{
			'recording!'.postln;
			this.record.play;
			masterArmed = false;
			[1]
		}{
			list warpTo: Song.durs[section]
		}
	}
	arm {armed = true}
	record {
		var o;
		var string = '/'++name;
		\rreeccoorrd.postln;
		list = List[];
		o = OSCFunc({list.add(TempoClock.seconds).postln},string);
		fork{ 
			(Song.secDur[section]+ tail).wait; o.free; 
			list = list.differentiate .drop(1).asArray 
			++ ( Song.secDur[section]-list.differentiate.drop(1).sum ) ; //time remaining is section
			// list = list.asBeats(section).round(0.001).reject{|i|i.isStrictlyPositive.not};
			list = TempoMap.fromDurs(Song.durs[section]).dursToBeats(list).round(0.001).reject{|i| i.isStrictlyPositive.not};
			this.writeArchive(path);
			this.list.asArray.registerD // add warpTo here!!!
		};
		^{
			var trig = 
			Impulse.ar(0) => Decay.ar(_,0.1) * WhiteNoise.ar(0.1)
			+ SoundIn.ar(0)
			=> Coyote.kr(_,fastMul:0.65);
			trig => SendReply.kr(_,string);
		};
	}
}

RecKey : RecOnsets {
	// var <>armed=false, path, name, <section, tail, <saved, s, <list;
	classvar directory = "/Users/michael/tank/super/Onsets";
	// classvar <>masterArmed;
	*initClass { File.exists(directory).not.if{File.mkdir(directory)}; masterArmed = false }
	*new {|part tail=0| ^super.new(part,tail)}
	*record {masterArmed = true}
	play{
		^( armed and: masterArmed ).if{
			'recording!'.postln;
			this.record.play;
			masterArmed = false;
			[1]
		}{
			list warpTo: Song.durs[section]
		}
	}
	record {
		var o;
		var string = '/'++name;
		\rreeccoorrd.postln;
		list = List[];
		o = OSCFunc({list.add(TempoClock.seconds).postln},string);
		fork{ 
			(Song.secDur[section]+ tail).wait; o.free; 
			list = list.differentiate .drop(1).asArray 
			++ ( Song.secDur[section]-list.differentiate.drop(1).sum ) ; //time remaining is section
			// list = list.asBeats(section).round(0.001).reject{|i|i.isStrictlyPositive.not};
			list = TempoMap.fromDurs(Song.durs[section]).dursToBeats(list).round(0.001).reject{|i| i.isStrictlyPositive.not};
			this.writeArchive(path);
			this.list.asArray.registerD // add warpTo here!!!
		};
		^{
			var trig = 
			Impulse.kr(0) +
			KeyState.kr(56, -0.1,1, lag:0)
			+KeyState.kr(60, -0.1,1, lag:0);
			trig => SendReply.kr(_,string);
		};
	}
}

RecIn : Rec {

	classvar directory = "/Users/michael/tank/super/samples2";
	var <>fftBuffer, <fftSize=2048, <hop=0.5, <window=1;
	*initClass {
		File.exists(directory).not.if{File.mkdir(directory)};
		SynthDef("pvIn", { arg recBuf=1, length=4, hop=0.5, window=0;
			var in, chain, bufnum;
			bufnum = LocalBuf.new(\fftSize.ir, 1);
			Line.kr(1, 1, length, doneAction: 2);
			in = SoundIn.ar(0);
			// note the window type and overlaps... this is important for resynth parameters
			chain = FFT(bufnum, in, hop, window);
			chain = PV_RecordBuf(chain, recBuf, 0, 1, 0, hop, window);
			// no ouput ... simply save the analysis to recBuf
			nil
		}).add;
	}
	*new {|name section tail fftSize hop window| ^super.new(name, section, tail, directory, 48000 ).subclassInit(fftSize, hop, window)}
	subclassInit { |fsize h w|
		fftSize = fsize; hop = h; window = w;
		saved.notNil.if{
			fftBuffer = Buffer.read(s,path++"-fft.wav")	
		}{
			fork{ fftBuffer = this.allocatePVBuffer.wait.() }
		}
	}
	writeFiles {
		buffer.write(path++".wav", "wav", "int16"); //epos sampleRate 
		fftBuffer.write(path++"-fft.wav", "wav", "float32");
	}
	inputUgen { ^{SoundIn.ar(0)} }
	playFFT { | function |
		armed.if{
			this.record;
			^this.inputUgen
		}{
			^this.pr_playFFT(function)
		}
	}
	playRaw {|rate=1 loop=0 doneAction=2| ^{ PlayBuf.ar (1,buffer.bufnum,rate:rate, doneAction:doneAction,loop:loop)} }
	allocatePVBuffer {
		^Buffer.doAlloc(s,( length + tail ).calcPVRecSize(fftSize,hop).asInteger, 1 );
	}
	record{ 
		fork{
			fftBuffer = this.allocatePVBuffer(hop,window).wait.();
			Synth(\pvIn,[\recBuf,fftBuffer.bufnum,length:(length+tail),\fftSize,fftSize,\hop,hop]);
			super.record;
		}
	}
	fftChain {
		^{
			var in, chain, bufnum;
			bufnum = LocalBuf.new(fftSize);
			chain = PV_PlayBuf(bufnum, fftBuffer, this.scale, 0, 0);
		}
	}
	pr_playFFT{ | function |
		^{
			var in, chain, bufnum;
			function = function ? {|i| i};

			PV_PlayBuf(LocalBuf.new(fftSize), fftBuffer, this.scale, 0, 0)
			=> function
			=> IFFT(_, window);
		}
	}

}

+ Function{

	triggerMe {|func|
			^ (this => Coyote.kr(_,fastMul:0.65) => Demand.kr(_,0,func))
	}
		
} 
