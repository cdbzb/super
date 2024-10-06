XMIDIController {
	*initClass
	{

		fork{
			MIDIClient.init;
			MIDIIn.connectAll;
			// StageLimiter.activate;
		}
	}


}

KS : XMIDIController {
	classvar <>id = -679037508;// INT
	classvar <playFunc;
	classvar <synths, <active;
	classvar <busses;

	*initClass {
		ServerTree.add(
			{
				MIDIFunc.cc( {|val| if(val > 0) {Song.play}}, 41, nil, id );
				MIDIFunc.cc( {|val| if(val > 0) {~myFree.()}}, 42, nil, id )
			}
		);
		busses = ();
	}
	*cc {|name|
		^In.kr(busses.at(name))
	}
	*addBus {|name cc|
		busses.put(name, Bus.control);
		MIDIdef.cc(\KS ++ name, { |v| busses.at(name).set(v / 128) }, cc)
	}
	*keyBus {
		busses.put(\keys, Bus.control);
		MIDIdef.noteOn(\KS ++ "keys", { |v n| busses.at(\keys).set(n) })
	}
	*synth { |name|
		MIDIdef.noteOn(key: \keyStageOn, func: {|v n c s|
			synths.put(n, 
				Synth(name, [freq: n.midicps, amp: v/(128 / 0.2)])
			);
		});
		MIDIdef.noteOff(key:\keyStageOff, func:{|v n c s|
			synths[n].set(\gate, 0);
		});
	}
	*func { |synthFunc|
		MIDIdef.noteOn(key: \keyStageOn, func: {|v n c s|
			synths.put(n, synthFunc.value(v, n, c, s));
		});
		MIDIdef.noteOff(key:\keyStageOff, func:{|v n c s|
			synths[n].set(\gate, 0);
		});
	}
}

CC {
	classvar <all; 
	var <number, <>spec, <>mk, <>val=0.5, <bus, <ctl ;
	var <down, <rawScale;

	*initClass{
		all = ()
	}
	*newMK { |number spec|
		^{|mk|
			CC(number, spec, mk)
		}.valueEnvir;
	}
	*new {|number spec mk rawScale=127 default| 
		mk = mk ? \default;
		all[mk].notNil.if {
			all[mk][number].notNil.if {
				var a = all[mk][number]; 
				a.spec = spec ? a.spec; 
				^a 
			}
		} 
		^super.new.init(number, spec, mk, rawScale, default)
	}
	*getValues {|mkInstance|
		var res = ();
		all[mkInstance ? \default].asKeyValuePairs.pairsDo{|i j| res.put(i, j.val)};
		
		^res
	}
	*setValues {|e| 
		e.keys.do{|i| CC(i).val = (e[i]); CC(i).set(e[i]) }
	}
	set { |i|
		val = i; bus.set(spec.map(i))
	}
	asControl {|name default synth|
		ctl = name;
		^NamedControl(name, default, \control, spec: spec)

	}
	mapCtl {|synth|
		MIDIdef.cc(number.asString ++ ctl, {|v| v.postln; synth.set(ctl, v) }, number);
	}
	*bend {|spec mk|
		^CC(\bend, ( spec ? 
			ControlSpec(0.5, 2,\exp, default: 1)
		), mk, rawScale: 16384, default:0.5 )
	}
	*keys {|mk|
		^CC(\keys,mk)
	}
	*monoGate {|mk|
		^CC(\monoGate, mk)
	}
	init { |n s m rs default|
		var buildSymbol = {|symbol| symbol ++ number ++ mk => _.asSymbol};
		number = n; spec = s ? ControlSpec(); mk = m ? \default; rawScale = rs;
		all[mk] = all[mk] ? (); all[mk][number] = all[mk][number] ? this;
		// all[number]= all[number] ? (); all[number][mk] = all[number][mk] ? this;
		bus = Bus.control;
		val = default ? 0;
		bus.set(spec.map(val));
		down = List[];
		switch(number)
		{ \bend } {
			MIDIdef.bend(buildSymbol.(\CC), {|n| this.setRaw(n)});
		} 
		{ \keys } {
			MIDIdef.noteOn(
				buildSymbol.('CC-on')
				, 
				{|v n| down.add(n);val = n; bus.set(val) }
			);
			MIDIdef.noteOff(
				buildSymbol.('CC-off'),
				{|v n| down.remove(n);val = (down.size > 0).if{ down.last }{ n }; bus.set(val) }
			) 
		}
		{ \monoGate } {
			MIDIdef.noteOn(
				buildSymbol.('CC-monogateOn'),
				{|vel num| \down ++ down => _.postln; down.add(num); val = 1; bus.set(val)  });
			MIDIdef.noteOff(
				buildSymbol.('CC-monogateOff'),
				{|vel num|  down.remove(num); (down.size < 1).if { val = 0; bus.set(val)}  })
		}
		{
			MIDIdef.cc(
				buildSymbol.(\CC),
				{|n| this.setRaw(n)}, number);
		}
	}
	setRaw{|num| // to 127
		val = spec.map(num / rawScale);
		bus.set(val)
	}
	map { |name func|
		MIDIdef.cc(name, {func.(spec.map(val))}, number)
	}
	mapSynth{|synth param|
		fork{
			while{ synth.isRunning.not }
			{ 0.001.wait };
			synth.debug("synth").map(param.debug("param"), bus.debug("bus"))
		}

	}
	*array{
		^all.keys.asArray.collect{|k| [k, all[k].val]}.flat.cs
	}
}


+ Synth{
	mapCC{ |param num spec|
		var cc = CC(param, num, spec);
		this.set(param, cc.spec.map(cc.spec.map(cc.val)));
		cc.mapSynth(this, param)
	}
}
