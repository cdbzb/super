Waiter {
	*new {|what|
		^Routine(
			{
				5.wait;
				what.postln
			}
		).play
	}
}
+ Pbind {
	asPpar {
		 ^Ppar(patternpairs.flop.collect({|i| Pseed(0,Pbind(*i)) }))
	}
}
+P {
	*wait {
		Waiter( P.tune() )
	}
}
+ SequenceableCollection {
	q{ arg repeats=1;
		^Pseq.new(this,repeats)
	}
}

+ Pbind {
	pad { arg release=10;
		^Pseq.new([this,Pbind.new(\note,Pseq([\r]),\dur,release)])
	}
}

+ String {
	asDrumPat {| beatsPerBar=8 reps=1 beats|
		var b=List.new;
		var a=Array.newFrom(this);
		//a.do({|m| (m=="|"[0]).not.if{b.add(m)}});
		b=a.replace(" "[0],"").replace("|"[0],"");
		b=b.collect{|j| (j=="x"[0]).if({1},{Rest(1)})};
		beats.isNil.not.if{
			beats = beats.stutter(beatsPerBar);
			b = b * beats;
		}
		
		^Pseq(b/beatsPerBar,reps)
	}
}

+ String {
	asStrumPat {|beatsPerBar=8 reps=1|
		var b=List.new;
		var a=Array.newFrom(this);
		a.do({|m| (m=="|"[0]).not.if{b.add(m)}});
		//change line below
		b=b.collect{|j| (j=="x"[0]).if({1},{Rest(1)})};
		^Pseq(b/beatsPerBar,reps)
	}}

+ Array {
 ply {this.do{|x|x.p}}
 wet {|wet| ^this * [wet,(1-wet)]=>_.sum }
}
+ Function {
  wet { |wet| 
    ^ {|i| i * (1-wet) + ( this.(i) * wet )}
  }
}
+ UGen {
	++ {|that|
		^[this,that]
	}
}
+ Object{
	=> {|a adverb|
		^switch (adverb,
			nil, { a.( this ) },
			\first, { a.(this); this },
			\split, { [a.(this), this ] },
			\array, { a.valueArray(this) }
		)
	}
	ooo {|a| ^a.(this)}
	=>| {|a| a.(this)}
	=>+ {|a b| ^a.(this,this)}//a is a fn of 2 vars
        =< {|a| ^[a.(this),this]}
	
	pipe {|...fns|
		^fns.inject({|x| x}, {|acc, el| el<>acc }).(this)
	}
<| { |f|
	^if(f.isKindOf(Function), 
		{ {|i| this.( f.(i) )} },
		{ this.(f) })
}
}
+ Server { 
	plotTreeL {|interval=0.5 x=(-800) y=400 dx=400 dy=800|
		var onClose, window = Window.new(name.asString + "Node Tree",
			Rect(x,y,dx,dy),
			scroll:true
		).front;
		window.view.hasHorizontalScroller_(false).background_(Color.grey(0.9));
		onClose = this.plotTreeView(interval, window.view, { defer {window.close}; });
		window.onClose = {
			onClose.value;
		};
		// {Pipe.new("osascript -e \'activate application \"Kitty.app\"\'", "w").close}.defer(0.1)
	}

	meter { |numIns, numOuts|
		^if( GUI.id == \swing and: { \JSCPeakMeter.asClass.notNil }, {
			\JSCPeakMeter.asClass.meterServer( this );
		}, {
			ServerMeter(this, numIns, numOuts);
			// {Pipe.new("osascript -e \'activate application \"VimR\"\'", "w").close}.defer(0.1)
		});
	}

}
+ File {
	*loadCurrent {
		thisProcess.nowExecutingPath => _.load
	}
}

