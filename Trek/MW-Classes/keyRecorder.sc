KeyRecorder { 
  var <list,time;
  var window;
  var section;
  var <playMethod;
  var <>cue, clickSynth;
  *new {|section cue playMethod| ^super.new.init(section,cue,playMethod); }
  *initClass {
	  Class.initClassTree(SynthDefLibrary);
	  StartUp.add {
		  SynthDef(\fourClicks, { | dur = 1|
			  TDuty.ar(dur.dup(4).dq) => Decay.ar(_,0.2)
			  * WhiteNoise.ar(0.1) 
			  => Out.ar(\out.kr(0),_)
		  }).add.tag(\click);
	  } 
		    }
  init {
	  |s c p |

	  var v,buttons,f,d,e,w;
	  playMethod = p ? \tune; // alternative is \parts
	  section = s;
	  cue = c ? {};
	  window = Window.new.front.alwaysOnTop_(true);
	  w=window;
	  v = window.view;
	  list = List.new;
	  buttons = 4.collect{
		  |i| 
		  Button.new(w.view,Rect( [60,160,260,260][i],[10,10,10,300][i],100,100 ))
	  };
	  buttons.do{
		  |i x| 
		  StaticText(i, Rect(0,0,100,100)).string_(["Do over","Return","Cue","Quit"][x]).align_(\center)
	  };
	  EZText.new(v,Rect(0,110,300,50	),label:"range",initVal:"return is in register d",);

	  v.keyDownAction = { |view char|
		  ( "dwcq".includes(char) ).not.if{list = list.add(SystemClock.seconds).postln}; //leave $r out we need it for final duration
		  switch(char,
			  //Char.space, { this.playCue },
			  $c, {this.playCueThenSection},
			  $d , { list=List.new },
			  $r , {this.return.postln;list=List.new},
			  //$s , {save},
			  $w , { window.close; this.free },
			  $q , { window.close; this.free }
		  )
	  }
  }

  countoff{ |dur=1| //with-latency version
	  fork{
		  Server.default.bind{
			  Synth(\fourClicks,[\dur,dur]);
		  };
		  dur * 4 => _.wait;
		  this.playTune;
		  list.add(SystemClock.seconds + Server.default.latency).postln
	  }
  }
  playCueThenSection{
	  var sectionBefore = Song.section(section) - 1;
	  var cue, guide;
	  (playMethod == \tune).if{
		  cue = { Song.pbind[sectionBefore].play };
		  guide = { Song.pbind[Song.section(section)].play };
	  }{

		  cue = { Song.at(sectionBefore).do(_.p);Song.secDur[sectionBefore] };
		  guide = { Song.at().do(_.p);Song.secDur[sectionBefore] };
	  };
	  fork{
		  //Song.playSection(Song.section(section)-1); Song.secDur[ Song.section(section)-1 ].wait;

		  // Server.default.prepareForRecord("/tmp/test.wav");
		  // Server.default.sync;
		  cue.();
		  Song.secDur[Song.section(section)-1].wait;
		  list.add(SystemClock.seconds + Server.default.latency).postln;
		  guide.();
		  // Server.default.record(bus: 8);
		  // Server
	  }
  }
  playTune{
	  //Song.playSection(section)
	  Song.at(Song.section(section)).do(_.p)
  }
  makeClickSynth { | array |
	  SynthDef(\arrayClicks, { 
		  TDuty.ar(array.dq) => Decay.ar(_,0.2)
		  * WhiteNoise.ar(0.1) 
		  => Out.ar(\out.kr(0),_)
	  }).add;

  }
  playCue{
	  cue.value
  }
  return { 
	  var out = list.differentiate.drop(1).asArray;
	  var suffix = Song.tempoMap[section].isNil.if{
		  ".warpTo(b).q"
	  }{
		  ".warpTo(e.tempoMap).q"
	  };
	  out = section.notNil.if{ out.asBeats(section).round(0.001).reject{|i|i.isStrictlyPositive.not}}{out.round(0.001)};
	  // out.put(0, out[0] + Server.default.latency);
	  "vim.fn.setreg('d',{\"%\"})".format(out.asString ++ suffix) // register 'd' for Durs
	  => SCNvim.luaeval(_);
	  "paste register d to insert".postln
	  ^out
  }
}
+Object {
	registerD {
	  "vim.fn.setreg('d',{\"%\"})".format(this.asString) // register 'd' for Durs
	  => SCNvim.luaeval(_);
	  "% yanked to register d".format(this.asString).postln
	}
}
