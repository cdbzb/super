KeyRecorder { 
  var <list,time;
  var window;
  var section;
  var <>cue, clickSynth;
  *new {|section cue| ^super.new.init(section,cue); }
  *initClass {
	  Class.initClassTree(SynthDescLib);
	  SynthDef(\fourClicks, { | dur = 1|
		  TDuty.ar(dur.dup(4).dq) => Decay.ar(_,0.2)
		  * WhiteNoise.ar(0.1) 
		  => Out.ar(\out.kr(0),_)
		  }).add.tag(\click);
		    }
  init {|s c|
    var v;
    section = s;
    cue = c ? {};
    window = Window.new.front.alwaysOnTop_(true);
    v = window.view;
    //time = Main.elapsedTime;
    //time = SystemClock.seconds;
    v.keyDownAction = { |view char|
      ( "dcrwq".includes(char) ).not.if{list = list.add(SystemClock.seconds).postln}; 
      switch(char,
	      Char.space, {this.playCue},
        $d , { list=List.new },
	$c , {this.countoff},
        //$n , {nextt},
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
		  this.playCue;
		  list.add(SystemClock.seconds + Server.default.latency).postln
	  }
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
	  out = section.notNil.if{ out.asBeats(section).round(0.001).reject{|i|i.isStrictlyPositive.not}}{out.round(0.001)};
	  "vim.fn.setreg('d',{\"%\"})".format(out.asString) // register 'd' for Durs
	  => SCNvim.luaeval(_);
	  ^out
  }
}
