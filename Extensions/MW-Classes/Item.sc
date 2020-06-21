Item {
	classvar <samplesDir='/Users/michael/tank/super/samples/';
	classvar <>items, <>current;
	var <>name,<>node,<>buffer,dir;
	var <>inBus=0, <>inChans=1, <>sampleRate;
	var <>recordLength, <>bus=1;

	*initClass {
		items=();
		samplesDir='/Users/michael/tank/super/samples/'
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
	*samplesDir_ {|newDir|
		(newDir[newDir.size-1]!=$/).if{newDir=newDir++'/'};//{{{
		samplesDir=newDir
	}//}}}
	init { | n |
		name = n;//{{{
		items.at(name).isNil.if{
			items.put(n,this);
			File.mkdir(samplesDir++name);
			dir=samplesDir++name++"/";
			buffer=Buffer.read(Server.default,this.mostRecent);
		}{
			^items.at(n).refresh
		}
	}
//}}}
	armed { node.isNil.if{^false}{^node.isRecording} }
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
	arm  {|s bus chan length=3| 
		var p_node;//{{{
		recordLength=length;
		inBus=(bus ? inBus); inChans=(chan ? inChans);
		s ?? {s=Server.default};
		p_node=RecNodeProxy.audio(s,1)
		.source_({SoundIn.ar(inBus,inChans)})
		.open(dir++'/'++Date.getDate.stamp++'.aif')
		.record;
		node=p_node
	}//}}}
	monitor {
		{SoundIn.ar()}.play(Server.default,bus)
//		node.play(bus,addAction:\addToTail);
	}
	record {|length| //{{{
		node.unpause;
		CmdPeriod.add(this.node);
		{this.stop}.sched(length ? recordLength);
	}//}}}
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
	play {|server out  rate=1 startPos=0 trigger=1 loop=0| //{{{
		bus = (out ? bus);
		server ?? {server=Server.default};
		this.armed.if{
			this.record;
		}{
			buffer.isNil.if(this.refresh);

			^{
				arg out;
				var sig;
				(rate*this.p_sampleRate/server.sampleRate).postln;
				sig=PlayBuf.ar(
					inChans, 
					buffer.bufnum,
					rate:rate,///this.p_sampleRate*server.sampleRate,
					startPos:startPos,
					trigger:trigger,
					loop:loop);
					Out.ar(bus,sig)
				}.play;
		}
	}//}}}
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
			rate:rate*this.p_sampleRate/Server.default.sampleRate,
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
		}.sort.reverse[0]
		++ ".aif"
	}//}}}

}
