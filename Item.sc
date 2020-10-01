// save after recording pseudo-code {{{

	//b.write("/Users/michael/tank/super/Trek-samples/heart-action.aif")
	//or.....
	(
		~recordme={|name bus=2 chan=1| var node=RecNodeProxy.audio(s,1)
			.source_({SoundIn.ar(bus,chan)})
			.open('/tmp/'++name.asSymbol)
			.record;
			node
	}
)

(
~item=(
		name:'test',
		dir:'/Users/michael/tank/super/samples/',
		arm: {|self name bus=2 chan=1| 
			var node=RecNodeProxy.audio(s,1)
			.source_({SoundIn.ar(bus,chan)})
			.open(self.dir++self.name.asSymbol++Date.getDate.stamp++'.aif')
			.record;
			self.node=node
		},
		record:{|self|self.node.unpause},
		stp:{|self| self.node.close;self.buffer=Buffer.read(s,self.take)},
		play:{|server bus| ~buffer.play(server, bus)},
		takes:{|self| SoundFile.collect(self.dir++"*")},
		mostRecent:{|self| 
			self.dir
			++ PathName(self.dir.asString).files.collect{|i|i.fileNameWithoutExtension}.sort.reverse[0]
			++ ".aif"
		}
	);

)
~item.arm('test2',0)
~item.takes.do(_.play(s,1))
~item.mostRecent

a=~item.takes.collect({|i|PathName.new( i.path )})

~takesFromMostRecent=PathName(~item.dir.asString).files.collect{|i|i.fileNameWithoutExtension}.sort.reverse
b=Buffer.read(s,~item.dir++a[0]++".aif")


~item.takes[1].path
b=Buffer.read(s,~item.takes[1].path)
{PlayBuf.ar(1,b)}.play(s,1)
a=SoundFile.collect(~item.dir.asString)
~item.takes
~item.dir
a=SoundFilei.collect("/Users/michael/tank/super/samples/*")
a=SoundFile.new("Users/michael/tank/super/samples/test200408_140403.aif")
a.path
~item.dir.class
~item.node.close
PathName
~item.takes
{~item.record;3.wait;~item.stp}.fork
Date.getDate.stamp.class
Date.getDate.asSortableString
Date.stamp
load
