XMIDIController {
	*initClass {
		fork{
			MIDIClient.init;
			MIDIIn.connectAll;
		}
	}
}

KS : XMIDIController {
	classvar id;
	classvar <playFunc;
	classvar <synths, <active;
	classvar <busses;
	*initClass {
		ServerTree.add(
			{
				MIDIFunc.cc( {|val| if(val > 0) {Song.play}}, 41, nil, id );
				MIDIFunc.cc( {|val| if(val > 0) {MyFree()}}, 42, nil, id )
			}
		);

		busses = ();
	}
	*id { ^ id ? (id = MIDIIn.findPort("Keystage", "KBD\/CTRL").uid ) }
	*cc {|name|
		^In.kr(busses.at(name))
	}
	*addBus {|name cc|
		busses.put(name, Bus.control);
		MIDIdef.cc(\KS ++ name, { |v| busses.at(name).setSynchronous(v / 128) }, cc)
	}
	*keyBus {
		busses.put(\keys, Bus.control);
		MIDIdef.noteOn(\KS ++ "keys", { |v n| busses.at(\keys).setSynchronous(n) })
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
	classvar <all, <active; 
	var <number, <>spec, <>mk, <>val=0.5, <bus, <ctl ;
	var <down, <rawScale;

	*initClass{
		all = ();
		active = Set[];
	}
	*newMK { |number spec|
		^{|mk|
			CC(number, spec, mk)
		}.valueEnvir;
	}
	*new {|number spec mk rawScale=127 default| 
		mk = mk ? currentEnvironment[\mk] ? \default;

		all[mk].notNil.if {
			all[mk][number].notNil.if {
				var a = all[mk][number]; 
				a.spec = spec ? a.spec; 
				^a 
			}
		};

		^super.new.init(number, spec, mk, rawScale, default)
	}

	*getValues {|mkInstance|
		var res = ();
		(all[mkInstance ? \default] ? () ).asKeyValuePairs.pairsDo{|i j| res.put(i, j.val)};
		^res
	}

	*setValues {|e mk| 
		e.keys.do{|i| CC(i, mk: mk).val = (e[i]); CC(i, mk: mk).set(e[i]) }
		
	}
	set { |i|
		val = i; bus.set(spec.map(i))
	}
    control { |default|
        ^{ CC(number, mk:~mk).val_(default).bus.set(default).kr }
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
			// ControlSpec(0.5, 2,\exp, default: 1)
			ControlSpec(-1, 1, default: 0) //use midiratio or linexp to scale
		), mk, rawScale: 16384, default:0.5 )
	}

	*keys {|mk|
		^CC(\keys,mk)
	}

	*monoGate {|mk|
		^CC(\monoGate, mk)
	}

	init { |n s m rs default|
		number = n; spec = s ? ControlSpec(); mk = m ? \default; rawScale = rs;
		all[mk] = all[mk] ? (); all[mk][number] = all[mk][number] ? this;
		// (mk != \default ).if { MicroKeys.ccs.add(this) };  // TODO: fix tracking
		// all[number]= all[number] ? (); all[number][mk] = all[number][mk] ? this;
		bus = Bus.control;
		val = default ? 0;
		bus.set(spec.map(val));
		down = List[];
		// this.makeDef(number)
	}

	activate {
		this.makeDef(number);
		active = active.add(this);
		active.post; number.debug("added")
	}

	makeDef { |number|

		var defSymbol = {|symbol| symbol ++ number ++ mk => _.asSymbol};

		^switch(number)
		{ \bend } {
			MIDIdef.bend(defSymbol.(\CC), {|n| this.setRaw(n)});
		} 
		{ \keys } {
			MIDIdef.noteOn(
				defSymbol.('CC-on')
				, 
				{|v n| down.add(n);val = n; bus.set(val) }
			);
			MIDIdef.noteOff(
				defSymbol.('CC-off'),
				{|v n| down.remove(n);val = (down.size > 0).if{ down.last }{ n }; bus.set(val) }
			) 
		}
		{ \monoGate } {
			MIDIdef.noteOn(
				defSymbol.('CC-monogateOn'),
				{|vel num| \down ++ down => _.postln; down.add(num); val = 1; bus.set(val)  });
			MIDIdef.noteOff(
				defSymbol.('CC-monogateOff'),
				{|vel num|  down.remove(num); (down.size < 1).if { val = 0; bus.set(val)}  })
		}
		{
			MIDIdef.cc(
				defSymbol.(\CC),
				{|n| this.setRaw(n)}, number);
		}
	}

	setRaw {|num| // to 127
		// val = spec.map(num / rawScale);
		// bus.setSynchronous(val)
		val = num/rawScale;
		bus.setSynchronous(spec.map(val))
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
