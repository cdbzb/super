RecEnv {
	var name,length=4, arm;
	var size, <path, <buffer;
	var <durs, <newDurs, <array;
	var s;
	var <ratios;
	classvar defaultPath = "/Users/michael/tank/super/Envelopes";

	*initClass{
		File.exists(defaultPath).not.if{File.mkdir(defaultPath)};
	}
	*new { |name durs length arm | ^super.new.init(name, durs,  length, arm) }
	init { |name d length arm |
		s = Server.default;
		path = path ? defaultPath +/+ name;
		arm = arm ? false;
		size = 1024 * length;
		arm.not.if {  // if not armed check and see if exists otherwise record
			File.exists(path).if{
				var saved = Object.readArchive(path); \exists.postln;
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
				};
			} {
				arm = true;
				durs = d;
			};
		} {
			this.record
		}
		^this
	}

	record {
			fork{
				buffer = Buffer.doAlloc(s,size).wait;
				buffer=buffer.();
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
			};
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
		^{ PlayBuf.ar(1,buffer.bufnum,rate:scale, doneAction:doneAction) }
	}

} 
