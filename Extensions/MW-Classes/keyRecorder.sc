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
    var v,b,f,d,e,w;
    section = s;
    cue = c ? {};
    window = Window.new.front.alwaysOnTop_(true);
    w=window;
    v = window.view;
    b=Button.new(w.view,Rect(60,10,100,100));
    f=Button.new(w.view,Rect(160,10,100,100));
    d=Button.new(w.view,Rect(260,10,100,100));
    e=Button.new(w.view,Rect(260,300,100,100));
			StaticText(b,Rect(0,0,100,100)).string_("Do over").align_(\center);
			StaticText(f,Rect(0,0,100,100)).string_("Return").align_(\center);
			StaticText(d,Rect(0,0,100,100)).string_("").align_(\center);
			StaticText(e,Rect(0,0,100,100)).string_("").align_(\center);
			EZText.new(v,Rect(0,110,300,50	),label:"range",initVal:"return is in register d",);

			v.keyDownAction = { |view char|
				( "dcrwq".includes(char) ).not.if{list = list.add(SystemClock.seconds).postln}; 
				switch(char,
					Char.space, { this.playCue },
					$C, {this.playCue},
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
	  var suffix = Song.tempoMap[section].isNil.if{".warpTo( b )"}{".warpTo( e.tempoMap )"};
	  out = section.notNil.if{ out.asBeats(section).round(0.001).reject{|i|i.isStrictlyPositive.not}}{out.round(0.001)};
	  "vim.fn.setreg('d',{\"%\"})".format(out.asString ++ suffix) // register 'd' for Durs
	  => SCNvim.luaeval(_);
	  "paste register d to insert".postln
	  ^out
  }
}
