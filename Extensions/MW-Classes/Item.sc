Item {
	classvar <samplesDir='/Users/michael/tank/super/samples/';
	classvar <>items, <>current, <>latencyCompensation=0;
	var <>stamps,<>warpEnvelope,<>name,<>node,<>buffer,<>dir;
	var <>inBus, <>inChans=1, <>sampleRate;
	var <>recordLength, <>bus=1;
	var <>pvBuffer;
	classvar <>abort;

	*initClass {
		items=();
		samplesDir='/Users/michael/tank/super/samples/';
		SynthDef("pvrec", { |recBuf=1 soundBufnum=2 fftSize=2048 hop= 0.5 window=1|
			var in, chain, bufnum;
			bufnum = LocalBuf.new(fftSize);
			Line.kr(1, 1, BufDur.kr(soundBufnum), doneAction: 2);
			in = PlayBuf.ar(1, soundBufnum, 1, loop: 0);
			//in = PlayBuf.ar(1, soundBufnum, BufRateScale.kr(soundBufnum), loop: 0);
			// note the window type and overlaps... this is important for resynth parameters
			chain = FFT(bufnum, in, hop, window);
			chain = PV_RecordBuf(chain, recBuf, 0, 1, 0, hop, window);
			// no ouput ... simply save the analysis to recBuf
		}).add;
		SynthDef("pvplay", { | out=0, recBuf=1, rate=1 fftSize=2048 hop= 0.5 window = 1|
			var in, chain, bufnum;
			bufnum = LocalBuf.new(fftSize);
			chain = PV_PlayBuf(bufnum, recBuf, rate, 0, 1, 1, 0.25, 1);
			Out.ar(out, IFFT(chain, window).dup);
		}).and;
	}
	//only clones the mostRecent - sets samplesDir
	*new {| name="item" | 
		items.at(name).isNil.not.if{//{{{
			^items.at(name)
		}{
			^super.new.init(name)
		}
	}//}}}
	*clone {|newDir|
		(newDir[newDir.size-1]!=$/).if{newDir=newDir++'/'};//{{{
		try{File.mkdir(newDir)};
		items.do{|item|
			File.mkdir(newDir++"/"++item.name);
			File.copy(item.mostRecent,newDir++'/'++item.name++'/'++Date.getDate.stamp++'.aif');
			samplesDir=newDir
		}
	}//}}}
	*play { |...args| ^current.play(*args) }
	// let's add a length argument here 
	// also add Item.stop to the xtouch function 
	*record { |...args| current.record(*args) }
	*stop { current.stop }
	*arm { |...args| current.arm(*args) }
	*armSection { |...args| current.armSection(*args) }
	*samplesDir_ {|newDir|
		(newDir[newDir.size-1]!=$/).if{newDir=newDir++'/'};//{{{
		samplesDir=newDir
	}//}}}
	*list {|options = "-tr"| "ls " ++ options ++ " " ++ samplesDir => _.unixCmd}
	init { | n |
		name = n;//{{{
		dir=samplesDir++name++"/";
		items.at(name).isNil.if{
			items.put(n,this);
			File.exists(samplesDir ++ name).not.if { 
				File.mkdir(samplesDir++name) 
			}{ 
				"using existing directory".postln ;
				buffer=Buffer.read(Server.default,this.mostRecent);
				File.exists(samplesDir ++ name ++ "/stamps").if{
					stamps=Object.readArchive(samplesDir++name++"/stamps")
				}	
			};
		}{
			^items.at(n).refresh
		}
	}
//}}}
	armed { node.isNil.if{^false}
	{^node.isPlaying} 
}
// stamp returns warp envelope, stamps returns stamps
	stamp {
		|array| stamps.isNil.if{
			stamps=array;this.writeStamps;
			^1
		} {

			var ratios=stamps/array;
			^warpEnvelope=Env([ ratios[0] ]++ratios,array,\step)
		}
	}
	writeStamps {stamps.writeArchive(samplesDir++ name ++"/"++"stamps")}
	clearStamps {
		stamps=nil;  
		( "rm "++samplesDir++ name.asString.escapeChar($ ) ++"/"++"stamps" ).unixCmd
	}
	newFrom{|name|
		var i = Item(name);//{{{
		//try{File.mkdir(samplesDir++newName)};
		File.copy(i.mostRecent,dir++'/'++Date.getDate.stamp++'.aif')
		}//}}}
	recIfArmed { |...args|
		this.armed.if{//{{{
			this.record(length:recordLength)
		}{
			this.play(*args)
		} 
	}//}}}
	latency {^(latencyCompensation * Server.default.latency;)}
	arm {|s bus chan length| 
		var p_node;
		length.isNil.not.if{recordLength=length};
		buffer=Buffer.alloc(Server.default,recordLength*Server.default.sampleRate);
		bus.isNil.if {
			inBus.isNil.if{
				inBus=Server.default.options.numOutputBusChannels
			} 
		} {
			inBus = bus
		};
		inChans=(chan ? inChans);

		^node= {
			RecordBuf.ar(
				In.ar(inBus,inChans),buffer,recLevel:1,preLevel:0,
//				run:0,
				loop:\loop.kr(1),
				trigger:\trigger.kr(-1),
				doneAction: 2
			);
		}.play;
	}

// old method
//	arm {|s bus chan length| 
//		var p_node;//{{{
//		length.isNil.not.if{recordLength=length};
//		inBus=(bus ? inBus); inChans=(chan ? inChans);
//		s ?? {s=Server.default};
//		p_node=RecNodeProxy.audio(s,1)
//		.source_({
//			In.ar(inBus,inChans)
//			//=>DelayN.ar(_,this.latency,this.latency)
//		//WhiteNoise.ar(0.2)
//	})
//		.open(dir++'/'++Date.getDate.stamp++'.aif')
//		.record;
//		node=p_node
//	} //}}}

	allocatePVBuffer {|fftSize=2048 hop=0.5|
		var file = SoundFile(this.mostRecent);
		file.openRead;
		^Buffer.alloc(Server.default,file.duration.calcPVRecSize(fftSize,hop));
//		file.close
	}

	getFFT {|fftSize=2048 hop= 0.5 window = 0|
		pvBuffer = this.allocatePVBuffer(fftSize,hop,window);
		Synth(\pvrec,[\recBuf,pvBuffer,\soundBufnum,buffer.bufnum,\fftSize,fftSize,\hop,hop,\window,window]);
		^pvBuffer
	}
	playFFT {|fftSize=2048 rate=1 window=0 hop=0.5|
		Synth(\pvplay,[\out,0,\recBuf,pvBuffer,\rate,rate,\window,window,\hop,hop,\fftSize,fftSize])
	}

	armSection {|s bus channel padding=0.2|
		var length = Song.secDur[name] + padding;
		this.arm(s,bus,channel,length)
	}
	monitor { |target addAction|
		target.isNil.if{target=Server.default}
		{SoundIn.ar()}.play(target,bus,addAction: addAction)
//		node.play(bus,addAction:\addToTail);
	}
	write {
		abort.if{
			'recording aborted'.postln;
			node.free;
			this.refresh;
			abort=false;
		}{
			'recording done'.postln;
			buffer.write(dir++'/'++Date.getDate.stamp++'.aif', headerFormat: "aiff", sampleFormat: "int24", numFrames: -1, startFrame: 0, leaveOpen: false,)
		}
	}
	record {|length|
		Server.default.bind{
			node.set(\loop,0,\trigger,1);
			node.onFree({
				this.write
			})
		}
	}
	//old method
	//record {|length| //{{{
	//	node.unpause;
	//	CmdPeriod.add(this.node);
	//	{this.stop}.sched(length ? recordLength,clock:SystemClock);
	//}//}}}
	stop {//{{{
		node.isNil.not.if{node.close}; 
		buffer=Buffer.read(Server.default,this.mostRecent)
	}//}}}
	tapeMode { //{{{
		this.armed.if{
			// monitor input
		}{
			// play as per usual
		}
	}//}}}

	// warning argument order was changed!!!
	play {|server out  rate=1 startPos=0 trigger=1 loop=0 amp=1| //{{{
		bus = (out ? bus);
		server ?? {server=Server.default};
		this.armed.if{
			this.record;
		}{
			buffer.isNil.if({ this.refresh });

			^Server.default.bind{
				{
				arg out;
				var sig;
				(rate*this.p_sampleRate/server.sampleRate).postln;
				sig=PlayBuf.ar(
					inChans, 
					buffer.bufnum,
					rate:rate*BufRateScale.kr(buffer.bufnum),///this.p_sampleRate*server.sampleRate,
					startPos:startPos,
					trigger:trigger,
					loop:loop);
					Out.ar(bus,sig*amp)
				}.play;
				
			}
			
	}} //}}}
	prepVocoder {|numberOfBands=20| //{{{
		var s,f;
		s=Server.default;
		f=Buffer.alloc(s,buffer.numFrames/64,numberOfBands);
		{
			PlayBuf.ar(1,buffer.bufnum)
			=> Vocoder.control(_,numberOfBands-1)
			=> RecordBuf.kr(_,f.bufnum,loop:0,doneAction:2)
		}.play;
		^f;
	}//}}}
	p_sampleRate { ^SoundFile(this.mostRecent).sampleRate }
	current { current=this; }
	refresh {
		buffer=Buffer.read(Server.default,this.mostRecent);
		recordLength=buffer.numFrames;
	}
	playbufMon {|...args| //{{{
		this.armed.if{^SoundIn.ar(inBus)}
		{^this.playbuf(*args)}
	}//}}}
	playbuf { |rate=1 startPos=0 trigger=1 loop=0 doneAction=2|
		^PlayBuf.ar(//{{{
			inChans, 
			buffer.bufnum,
			rate:rate*BufRateScale.kr(buffer.bufnum),//this.p_sampleRate/Server.default.sampleRate,
			startPos:startPos,
			trigger:trigger,
			loop:loop,
			doneAction:doneAction
		)
	}//}}}
	takes { ^SoundFile.collect(dir++name.asString++"/*")}
	mostRecent { 
		^dir//{{{
		++ PathName(dir.asString++"/").files.collect{|i|
			i.fileNameWithoutExtension
		}
		.reject{|i| i=="stamps"}
		.sort.reverse[0]
		++ ".aif"
	}//}}}

	*test {
		~b=Bus.audio();
		//Item(\latencyTest);
		//Item.latencyCompensation_(0);
		Item(\latencyTest).arm(length:5,bus:~b.index);
		fork{
			0.5.wait;
			Item(\latencyTest).play;
			[note:Pseries(1,2,5)+4.rand,out:~b.index].pp;
			6.wait;
				Item(\latencyTest).play;
				[note:Pseries(1,1,5)-4,out:0].pp;

		}

	}
	*replay {
				Item(\latencyTest).play;
				[note:Pseries(1,1,5)-4,out:0].pp;
	}
}
