RecEnv {
	var time,length=4;
	var size, <path, <buffer;
	var <durs, <newDurs, <array;
	var <ratios;

	*new { |time durs length=4 | ^super.new.init(time, durs,  length) }
	init { |time d length |
		var s = Server.default;
		size = 1024 * length;
		path = "/tmp" +/+ "env" ++ time; // ++ ".wav";
		File.exists(path).if{
			var saved = Object.readArchive(path);
			\exists.postln;
			buffer = Buffer.read(s, path ++ ".wav" );
			d.notNil.if{
				saved.durs.isNil.if{
					durs = d 
				} {
					durs = saved.durs; 
					newDurs = d;
				}
				
			} {
				durs = saved.durs; 
			}
		} {
			buffer = Buffer.alloc(s,size);
			fork{
				"recording".postln;
				{ BufWr.ar( 
					SoundIn.ar(0) => Amplitude.ar(_), 
					buffer, 
					Line.ar(0,size,length,doneAction:2)
					loop: 0
				);nil}.play;
				0.1 + length => _.wait;
				buffer.write(path++".wav", "wav", "int16"); //epos sampleRate 
				"buffer written".postln;
				this.writeArchive(path);
				durs = d;
			};
		}
		^this
	}

	durs_ { | array |
		durs.isNil.if{ durs = array }{ newDurs = array };
		this.writeArchive(path)
	}

	playbuf{ |doneAction=0|
		var scale;
		newDurs = newDurs ? durs;
		ratios = newDurs/durs =>_.reciprocal *(1024/44800);
		scale = ratios.dq.demand(newDurs);
		^{ PlayBuf.ar(1,buffer.bufnum,rate:scale.poll, doneAction:doneAction) }
	}

} 
