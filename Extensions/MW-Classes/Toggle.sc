Toggle {
	var routine,<>state;
	*new { ^super.new.init }
	mapToXTouch {
		|key|
		XTouch.addKey({this.toggle},key.asSymbol)
	}
	init { 
		routine=[1,0].q(inf).asStream;
		state=routine.next;
	}
	toggle {
		^state=routine.next;
	}
}

ToggleControl {
	/*
	a=ToggleControl.new
	XTouch.addKey({a.toggle},\f3)
	c={WhiteNoise.ar(0.1*a.kr)}.play
	*/
	var toggle;
	var <>bus;
	*new {
		^super.new.init;
	}
	init {
		toggle=Toggle.new;
		bus=Bus.control;
	}
	toggle {
		toggle.toggle.postln;
		bus.set(toggle.state);
	}
	kr {
		^bus.kr
	}
}


