// Item(\aaaa).context_("wes").playWarp([1,2,3])
// or
// Item(\aaa).stamp([1,2],\saww).playWarp

// stamps should be dictionary

Item {
	classvar <samplesDir='/Users/michael/tank/super/samples/';
	classvar <>items, <>current, <>latencyCompensation=0;
	var context;
	var <>stamps,<>warpEnvelope,<>name,<>node,<>buffer,<>dir;
	var <>inBus, <>inChans=1, <>sampleRate;
	var <>recordLength, <>bus=1;
	var <>pvBuffer;
	var <>synth;
	classvar <>abort=false;

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
		}).add;
		Event.addEventType(\item,{~item.play(rate:~rate,amp:~amp,out:~out)});
		Event.addEventType(\items,{~items[~index].play(rate:~rate,amp:~amp,out:~out)});
		this.makePlayer;
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
	*open {"open "++Item.samplesDir=> _.unixCmd}

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
	reaper {
		Reaper.open2(this.mostRecent)
	}
	armed { 
		node.isNil.if{^false}
		{^node.isPlaying} 
	}
	// stamp returns warp envelope, stamps returns stamps
	stamp { 
		// arggg but default stamp is not nil!!!!!
		|array key| 
		stamps.isNil.if{stamps=()};
		(
			stamps.notNil.if{
				stamps.at(key)
			} {
				stamps
			}
		).isNil.if{
			stamps.put(key,array);
			this.writeStamps;
			^1
		} {
			var ratios=stamps.at(key)/array;
			^warpEnvelope=Env([ ratios[0] ]++ratios,array,\step)
		}
	}
	writeStamps {  
		stamps.writeArchive(samplesDir++ name +/+ "stamps")
	}
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
		this.armed.if{
			this.record(length:recordLength)
		}{
			this.play(*args)
		} 
	}
	latency {^(latencyCompensation * Server.default.latency;)}
	arm {|s bus chan length=5| 
		var p_node;
		this.current;
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
			// implement monitor with conditionals
			\recording.postln;
			nil;
		}.play.register;
	}
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
		^Synth(\pvplay,[\out,0,\recBuf,pvBuffer,\rate,rate,\window,window,\hop,hop,\fftSize,fftSize])
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
			this.refresh;
			abort=false;
		}{
			'recording done'.postln;
			buffer.write(dir++'/'++Date.getDate.stamp++'.aif', headerFormat: "aiff", sampleFormat: "int24", numFrames: -1, startFrame: 0, leaveOpen: false);
			this.getFFT;
			// clearStamps??
		}
	}
	recordNow {|length|
		'filling buffer'.postln;
		'writing file'.postln;
		node.set(\loop,0,\trigger,1);
		node.onFree({
			this.write
		})
	}
	record {|length|
		'filling buffer'.postln;
		Server.default.bind{
			'writing file'.postln;
			node.set(\loop,0,\trigger,1);
			node.onFree({
				this.write
			})
		}
	}
	stop {//{{{
		node.isNil.not.if{
			//			abort=true;
			node.free
		}; 
		buffer=Buffer.read(Server.default,this.mostRecent)
	}//}}}
	tapeMode { //{{{
		this.armed.if{
			// monitor input
		}{
			// play as per usual
		}
	}//}}}
	*makePlayer {
		[1,2,4,8].do { |i|
			SynthDef("itemPlayer"++i, {
				|bufnum=0,rate=1,startPos=0,trigger=1,loop=0,amp=0.1,out=0|
				var sig;
				//(rate*this.p_sampleRate/server.sampleRate).postln;
				sig=PlayBuf.ar(
					i,
					bufnum,
					rate:rate*BufRateScale.kr(bufnum),
					startPos:startPos,
					trigger:trigger,
					loop:loop,
					doneAction:2
				);
				Out.ar(out,sig*amp)
			} )
			.add
		}

	}
	// warning argument order was changed!!!
	playNow {
		|server out  rate=1 startPos=0 trigger=1 loop=0 amp=1| //{{{
		bus = (out ? bus);
		server ?? {server=Server.default};
		this.armed.if{
			this.recordNow;
		}{
			buffer.isNil.if({ this.refresh });
			synth = Synth("itemPlayer"++inChans,
				[
					bufnum: buffer.bufnum,
					rate: rate,
					startPos: startPos,
					trigger: trigger,
					loop: loop,
					amp: amp,
					out: bus
				]);

				^synth

			}
		} //}}}
	playWarp { |durs key fftSize=4096 hop=0.25 |
		var env = this.stamp(durs,key);
		var bus = Bus.control;
		var syn = this.playFFT (fftSize, hop);
		{ EnvGen.kr(env) }.play(Server.default,bus);
		syn.map(\rate,bus)
	}
	warp { |durs |
		var env = this.stamp(durs);
		var bus = Bus.control;
		//var syn = this.playFFT (fftSize, hop);
		{ EnvGen.kr(env) }.play(Server.default,bus);
		synth.map(\rate,bus)
	}
	play {|server out  rate=1 startPos=0 trigger=1 loop=0 amp=1| //{{{
		bus = (out ? bus);
		server ?? {server=Server.default};
		this.armed.if{
			this.record;
		}{
			buffer.isNil.if({ this.refresh });
			synth = Synth.newPaused("itemPlayer"++inChans,
				[
					bufnum: buffer.bufnum,
					rate: rate,
					startPos: startPos,
					trigger: trigger,
					loop: loop,
					amp: amp,
					out: bus
				]
			);
			Server.default.bind{
				synth.run;
			}
			^synth
		}
	} //}}}
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
		.reject{|i| i[0..5]=="stamps"}
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

Items {
	var <directory,<items,<files;
	*new { |directory| ^super.newCopyArgs(directory).init}
	*list {

		"ls "++Item.samplesDir++"Items" =>_.unixCmd()
	}
	init { 
		directory = directory.asString;
		files=List() 
	}
	refreshItems {
		items = files.collect(directory+/+_ ).collect(Item(_))
	}
	add {
		|...args| 
		args.do({|i| 
			files.includes(i).not.if{
				files.add(i)
			}
		}) ;
		this.refreshItems
	}
	list {
		"ls "++Item.samplesDir++"Items" +/+ directory =>_.unixCmd()
	}
	at { |i|
		var counter = i;
		(counter.class==Integer).if{ 
			^items[counter]
		}{
			counter = files.indexOf(counter);
			^items[counter]
		}
	}
	doesNotUnderstand { |selector ...args |
		var expandedArgs = args.flop;
		^items.collect{|i x| i.perform(selector, *expandedArgs[x]) }
	}
}

