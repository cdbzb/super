(
s.waitForBoot { StageLimiter.activate };

~funs=(		//	A Pseudo Class for Song with elastic rhythm			
	// written for trek project
	sections: {|self|self.song.size/2},
	//type:\player,
	parts:(),
	cursor:0,
	lag:0,
	lyrics:{|self| self.song.copySeries(0,2,self.song.size)},
	tune:{
		|self| var array = self.song.copySeries(1,3,self.song.size);
		array.collect({|string| Panola.new(string).midinotePattern})
	},
	setupDurs:{|self| 
		var a;
		Archive.read(self.dursFile);
		"read".postln;
		Archive.at(self.key).isNil.not.if(
			{
				a=Archive.at(self.key);
				self.durs=a++(Pseq([1])!(self.sections-a.size)); //copy and pad
			},{
				self.durs=Pseq([1])!self.sections
			}
		)
	},
	pbind:{|self | (0..self.sections-1).collect{|i| Pbind(\dur,self.durs[i],\midinote,self.tune[i])}},
	secDur:{|self | (0..self.sections-1).collect{|i| self.durs[i].list.sum} },
	secLoc:{|self| [0]++self.sections.asInt.collect({|i| self.secDur[0..i].sum}) },
	durTill:{|self sec till | self.durs[sec].list[0..till].sum}, //in a given section
	pbindFrom:{|self from=3| var list=self.pbind[from.asInt..(self.sections-1).asInt].postln;Pseq(list).postln},
	when: {|self| self.secDur[self.start]}, //for sections
	ply:{|self| self.parts.do({|i|i.parent=self; i.p});},
	play:{~infrastructure.();~ply.(currentEnvironment)},
	player:{|self|(type:\player,song:self)},
	p:{|self|(self.start<self.cursor).not.if{ var offset;
		self.syl.isNil.if({offset=0;"offset 0".postln},{offset=self.durTill(self.start,self.syl)});
		offset=offset+self.lag;
		TempoClock.sched(
			(self.secLoc[self.start]-self.secLoc[self.cursor])+offset,
			{s.bind{self.music.play}}
			//{self.music.play}
		)
	};self}, //for sections
	durTillEnd: {|self| var x=0; (self.cursor..(self.sections-1)).do{|i| x=x+self.secDur[i] };x},
	dur: {|self| var x=0; (self.cursor..(self.sections-1)).do{|i| x=x+self.secDur[i] };x},
	delta: {|self| var x=0; (self.cursor..(self.sections-1)).do{|i| x=x+self.secDur[i] };x},
	parse:	{|self phrase array start=0| //array of rhythms {{{
		var counter = 0;
		var beatNum = array.flatten.collect{|m i| array.flatten.[0..i].sum};
		beatNum = beatNum.collect{|i|(i-0.001).floor};
		array.collect{ |item|
			item.isArray.not.if(
				{
					var b=beatNum[counter];
					counter=counter+1;
					item*self.durs[phrase].list[b+start]
				},
				{
					var subArray=item.collect{|i x| 
						var b = beatNum[counter+x];
						i*self.durs[phrase].list[b+start]
					}; 
					counter=counter+item.size; 
					subArray.sum;
				}
			);
		}
	}; 
);
~trek=(	// specific proto for trek song:specifies file for durs		{{{2
	dursFile:"/Users/michael/tank/super/theExtreme3",
	durs:nil,
	save:{|self| Archive.global.put(self.key,self.durs); Archive.write(self.dursFile);'saved '.post;self.dursFile.postln},
);

// event recorder		{{{2
// function to allow "re-performance" of rhythms
// takes an song-Event of proto ~funs a range of lines to perform and a number of lines before to use as cues
~recorder= {
	|song  rnge=#[0,1] cueSecs=1 |
	var synth,recorder,a;
	var range = Array.with(rnge).flatten;
	var seq = (range[0]..range.clipAt(1))
	.collect({|i|song.tune[i].list}).flatten;
	seq.postln;
	~stepper={ |seq|
		SynthDef(\stepper, { |t_trigger=0|
			var note = Demand.kr(t_trigger + KeyState.kr(38)-0.1,0, Dseq.new(seq.midicps));
			var sig=SinOsc.ar(note,0,EnvGen.kr(
				Env.perc(0.01,1,0.1)
				,gate:t_trigger + KeyState.kr(38)-0.1));
				Out.ar(1,sig);
			});
		};
	~stepper.(seq).add;
	recorder=( // function returns this pseudo-object and calls makeWindow on it
		range:range,
		time:Main.elapsedTime,
		item:List.new,
		cue:{
			|self|
			var range=(self.range[0]-(cueSecs-1)-1..self.range[0]-1);
			("range"++range).postln;
			(self.range[0]>0).if(
				{var seq = range.collect({|i|song.pbind[i]});
				Pseq(seq);},
				//{song.pbind[nextTune-1]},
				(type:\rest)
			)
		},
		captureLoop:{
			|self char|
			Routine ({
				loop {
					self.item = self.item.add(Main.elapsedTime-self.time); 
					synth.set(\t_trigger,1);
					self.time=Main.elapsedTime; 
					char = 0.yield; 
				}
			})
		},
		window:nil,
		makeWindow: {
			|self| var w=Window.new.alwaysOnTop_(true).front.alwaysOnTop_(true);
			var b=Button.new(w.view,Rect(60,10,100,100))
			.states_(["1",Color.black,Color.white])
			.action = {self.doOver;"do over".postln};
			var c=Button.new(w.view,Rect(160,10,100,100))
			.states_(["1",Color.black,Color.white])
			.action = { var a = self.ret;a.postln};
			var d=Button.new(w.view,Rect(260,10,100,100))
			.states_(["1",Color.black,Color.white])
			.action = {self.nextt;"next".postln};
			var e=Button.new(w.view,Rect(260,300,100,100))
			.states_(["1",Color.black,Color.white])
			.action = {song.save};
			var v=w.view;
			////////// MIDI FUNCTION //////////
			//							XTouch.addKey({
			//								Pipe("osascript -e 'tell application \"System Events\" to keystroke \"j\"'","w")
			//							},\f8);
			self.window=w;
			StaticText(b,Rect(0,0,100,100)).string_("Do over").align_(\center);
			StaticText(c,Rect(0,0,100,100)).string_("Return").align_(\center);
			StaticText(d,Rect(0,0,100,100)).string_("next").align_(\center);
			StaticText(e,Rect(0,0,100,100)).string_("save").align_(\center);
			EZText.new(v,Rect(0,110,300,50	),label:"range",initVal:self.range,);
			v.keyDownAction={ |view char|
				self.captureLoop.(b); 
				switch(char,
					$d , {self.doOver},
					$n , {self.nextt},
					$r , {self.ret},
					$s , {song.save},
					$w , {self.window.close;t.free},
					$q , {self.window.close;t.free}
				)
			};
			self.item=[];
			fork{s.sync; synth=Synth(\stepper); a=synth };
			w.onClose_({synth.free});
			self.cue.play ;
			self.range.do({|i|song.lyrics[i].postln});
			self
		},
		doOver:{|self| self.item=[];self.cue.play;synth.free;synth=Synth(\stepper)},
		nextt:{|self| 
			self.range=(self.range+(self.range.clipAt(1)-self.range[0]+1));
			self.range.do({|i x| (i>(song.sections-1)).if {self.range[x]=(song.sections-1).asInt}}); // check if range too high
			(self.range++" "++song.sections).postln;
			self.window.close;
			{
				var newSeq=self.range.collect({|i|song.tune[i].list}).flatten;
				~stepper.(newSeq).add;
				s.sync;
				t.free;self.makeWindow
			}.fork(AppClock)
		},
		ret: {|self|
			var recorded =self.item.round(0.001)[1..(self.item.size)];
			recorded.postln;
			( self.range[0]..self.range.clipAt(1) ).do({|i|
				var returnChunk=List.new;
				var elements=song.tune[i].list.size;
				elements.do(
					{|i|
						if(recorded.size>0)
						{returnChunk.add(recorded.removeAt(0)) }
					}
				);
				(returnChunk[0].isNil.not).if{song.durs[i]=Pseq(returnChunk)} ;
			});
			//~xtreme.durs[nextTune]= Pseq(recorded);
		};
		).makeWindow;
		fork{
			s.sync;
			'registering midifunc'.postln;
			MIDIFunc.noteOn({
				recorder.captureLoop.();
				synth.set(\t_trigger,1);
				synth.postln}
			)}
}; 

~concatSongs={ |song1 song2| 
	( //should I give this parent:~funs ??
		//parent:~funs
		songs:[song1,song2],
		sections:{|f| f.songs.inject(0,{|a i| a+i.sections})},
		cursor:0,
		locate:{|f song sec|
			var ret;
			sec.postln;
			sec.isNil.if(
				{ret=song}
				,
				{ret=(f.songs[sec-1].sections)+song}
			);
			f.cursor=ret;
		},
		play:{
			if ( ~cursor>~songs[0].sections,
			{
				~songs[1].cursor=~songs[1].cursor+~cursor;
				~songs[1].ply
			},
			{
				~songs[1].cursor=0;
				~songs[0].cursor=~cursor;
				{
					~songs[0].ply;
					~songs[0].durTillEnd.wait;
					~songs[1].ply
				}.fork
			}
		)
	}
)
}; 
// functions to get Panola notes{{{2
~panNotes={|string| Panola.new(string).midinotePattern.list};
~panList={|string| Panola.new(string).midinotePattern.list.flatten};
~noteList={|list| list.collect({|x|~panNotes.(x)}).flatten };
Event.addEventType(\player,{~dur=~song.durTillEnd;~song.ply});
SynthDef(\recc,{|buf bus=0|DiskOut.ar(buf,In.ar(bus))}).add;
~rec = {|name in=0 len=4 | 
	var b=Buffer.alloc(s,2**16);
	b.write(File.getcwd++"/media/"++name++".wav","WAV","int24",0,0,true);
	b.bufnum.postln;
	Synth.tail(nil,\recc,[\buf,b,\bus,in]);
	SystemClock.sched(len,{b.close} );
};

~myFree={ 
	|vsti|
	s.freeMyDefaultGroup;
	fork{
		//s.latency.wait;
		TempoClock.all.do(_.clear);
		SystemClock.do(_.clear);
	};
	// Alga.parGroups[s] = AlgaParGroup(s.defaultGroup);
	~vstRegistry.do{|i| 16.do{|x| i.midi.allNotesOff(x)}};
	try{ Song.resources.select{|i| i.isKindOf(Node)}.do(_.release)};
	Trek.transitionGroup.release;
	// g=Group.new
}; 

~justTheTune={ |key function syl range| 
	P( 
		(key++"Tune").asSymbol, key, music: {  
			var drop, length;
			var pbind = Song.currentSong.pbind[key] ;
			range.notNil.if{
				drop = range[0];
				length = range[1] - range[0] + 1;
				pbind=pbind.drop(drop) ;
				pbind=pbind.fin(length) ;
				(drop > 0).if{ syl = drop - 1 };
			};
			function.isNil.if{function={|i|i}};
			function.value(pbind).play;
		}, syl:syl ).value}; 

~vocoderPattern = { |pattern item effect out=0 bypass=0 rate=1 amp=0.1 dry=0 inputEffect loop=0 stretch| 
	var environment = ();
	environment.use {
		~modulator=Bus.audio(s,1);
		~verb=Bus.audio(s,2);
		~carrier=Bus.audio(s,1);
		pattern <> (out:~carrier.index) => _.play;
		Item(item).armed.if{ 
			bypass=1 ;
			Item(item).play;
			\recording.postln
		};
		( bypass==0 ).if {
			Item(item);
			{
				Item(item).playbuf(loop:loop,rate:rate) 
				=> ( inputEffect ? {|i|i} )
			}.play(s,~modulator.index);
		}{
			{SoundIn.ar()}.play(s,~modulator.index) ;
		};

		effect.isNil.not.if{
			~synthOut= ~verb.index 
		}{
			~synthOut= out
		};

		~synth=Synth.new(\busVersion, [
			\carrier,~carrier.index,
			\modulator,~modulator.index,
			//	\modulator,4,
			//	\fftsize,4096,
			\hop,0.25,
			\out,~synthOut,
			//	\out,Effect(FreeVerb.ar(_,0.1,1),inputChannels:1).bus.index,
			//\modBuf, Item(\order).buffer , 
			//default for smooth is *negative* 0.92
			//positive numbers and zero are both interesting
			\smoothCarrier,-0.92 ,
			\pan,[ -1 ].choose,
			\amp,amp,
			\dry,dry
		]);
				while ( {~synth.isPlaying},{1.wait} );
				\freeing_Bus.postln;
				~carrier.free; ~modulator.free;
			};
			(effect.isNil.not).if{
				~effect={ In.ar(~verb.index,2) => effect } =>_.play(s,out,addAction:\addToTail);
			};
	environment;
	};

)
