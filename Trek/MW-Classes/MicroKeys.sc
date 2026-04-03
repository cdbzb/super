MicroKeys {
	var <>array,<>keys, <>namedList, <>tuningDeltas, tuningFunction, <heldNotes, <damperDown = false, <>down, <>downChannel,  <>storedCCValues, <name, <item, <>active=false, <>sounding;
    //state of these will only change during monitoring
    classvar <>ccs;
	//when monitoring is enabled we set these to be the same as the classvar
	var instanceCCs;
	var <>synthFunc;
    var <>species;
	// MonoKeys-specific variables
	var <monosynth, <>constantVel=false;
	// Current channel tracking for MPE detection
	var <currentChannel;
	var <>polyFunc;
	var <>modMap;
	var <>modState;
	classvar <all, <current;
	classvar <type=\mk;
	classvar <>excludeSrcIDs;
	var tuningFunction;
	// methods to make "standard" params
	*freq {
		^{|mk| {\freq.kr(900) * (\poly.kr() / 127+ CC.bend(mk: mk).bus.kr => _.midiratio)} }
	}
	doNoteOn { |amp midinote params silent channel=0|
		case 
		{ species == \poly } {
			silent.isNil.if{
				down.add(midinote);
				this.noteOnFunction.(amp, midinote, channel, nil, params).debug("noteOn")

				=> {|e| this.register(e)} // register method could be moved here
			}
		}
		{ species == \mono } {
			( down.size == 0 ).if{
				var synths = this.noteOnFunction.(amp, midinote, nil, nil, params).synths;
				monosynth = modMap.notNil.if {
					modState.copy.putAll((
						synth: synths, num: midinote, vel: amp/127
					))
				}{ synths };
				monosynth.notNil.if {
					modMap.notNil.if { this.applyMods(monosynth) };
					down.add(midinote);
                    downChannel.put(midinote, channel);
					currentChannel = channel; // Track the current channel
				}
			}{
				var event, func = namedList.deepCopy;
				func.removeAt(\synth);
				event = func.reverse.inject(I.d, {|i j| try{i <> j}}).(amp, midinote, nil, nil, params);
				event.notNil.if{
					modMap.notNil.if {
						monosynth[\num] = event.num;
						monosynth[\vel] = event.vel;
						this.applyMods(monosynth);
					}{
						monosynth.set(
							\num, event.num, \freq, event.num.midicps,
						);
						constantVel.not.if {
							monosynth.set(\vel, event.vel, \amp, event.vel )
						};
					};
					down.add(midinote); // raw midinote for bookkeeping
                    downChannel.put(midinote, channel);
					currentChannel = channel; // Update current channel
				};
						// move this line down here to allow tracking outside the range
						// down.add(midinote); // raw midinote for bookkeeping
						
			}
		};
	}
	storeCCValues {
		^storedCCValues = CC.getValues(this.name)
	}
	restoreCCValues {
		^CC.setValues(storedCCValues, this.name)
	}
	*initClass{
        ccs = ();
		excludeSrcIDs = Set[-496537509]; // RME ARC

		MyFree.add({ MicroKeys.all.do{|i| i.down_(List[]) } });
		
		Event.addEventType(\mkOff, {
			~mk.isKindOf(Symbol).if { ~mk = MicroKeys(~mk) };
			~mk.notNil.if {
				Server.default.makeBundle(~latency, { ~mk.doNoteOff(~midinote, channel: ~channel) })
			}
		});

		Event.addEventType(\mk2, {
			~instrument =  ~mk.doNoteOn(~amp * 127, ~midinote, ~params).asDefName ;
		});

		Event.addEventType(\mk, {
			var syn;
			~mk.isKindOf(Symbol).if { ~mk = MicroKeys(~mk) };
			Server.default.makeBundle(~latency, { ~mk.doNoteOn(~amp * 127, ~midinote, ~params, ~silent, ~channel) });
			fork{
				~sustain.().wait;
				//syn could be passed into doNoteOff to solve the overlapping notes issue
				Server.default.makeBundle(~latency, {~mk.doNoteOff(~midinote, channel: ~channel)})
			}	
		});
		Event.addEventType(\setCC, {
			Server.default.makeBundle(~latency, 
                // {var cc = CC(~ctlNum, mk: ~mk); cc.setRaw(~control * cc.rawScale) }
                { 
					var mk = ~mk.isKindOf(Symbol).if{ MicroKeys(~mk) }{ ~mk };
					[~mk, mk, ~control, ~ctlNum].postln;
					mk.doCC(~control, ~ctlNum, ~channel)
				} //TODO change 127 for bend
            ) 
		});

		//deprecate
		// Event.addEventType(\setBend, {
		// 	Server.default.makeBundle(~latency, { CC(~ctlNum, mk: ~mk).setRaw(~control * 16384) }) 
		// });
		Event.addEventType(\setDamper, {
			~mk.isKindOf(Symbol).if { ~mk = MicroKeys(~mk) };
			Server.default.makeBundle(~latency, { ~mk.setDamper(~control) })
		});
		Event.addEventType(\setPoly, {
			~mk.isKindOf(Symbol).if { ~mk = MicroKeys(~mk) };
			( ~mk.keys[~midinote] != 0 ).if {
				 // ~mk.keys[~midinote].().set(\poly, ~polyTouch) 
				 Server.default.bind{
					 ~mk.doPoly( ~polyTouch, ~midinote )
				 }
			}{
				~type = \rest
			}
		});
        Event.addEventType(\setCC74, {
            ~mk.isKindOf(Symbol).if { ~mk = MicroKeys(~mk) };
            Server.default.makeBundle(~latency, { ~mk.doCC74(~control * 127, ~channel ? 1) })
        });

        Event.addEventType(\setPressure, {
            ~mk.isKindOf(Symbol).if { ~mk = MicroKeys(~mk) };
            Server.default.makeBundle(~latency, { ~mk.doPressure(~control * 127 , ~channel ? 1) })
        });
        Event.addEventType(\setBend, {
            ~mk.isKindOf(Symbol).if { ~mk = MicroKeys(~mk) };
            Server.default.makeBundle(~latency, { ~mk.doBend(~control * 16384, ~channel ? 1) })
        });
        Event.addEventType(\microKeys, {
            var mk = MicroKeys(~name ? ~synthFunc ? \default, ~synthFunc, ~params, ~species ? \poly);
            ((~species.notNil) && (mk.species != ~species)).if {
                mk = (~species == \mono).if{ mk.mono }{ mk.poly }
            };
            ~synthFunc.notNil.if { mk.synth_(~synthFunc) };
            ~modMap.notNil.if { mk.modMap = ~modMap };
            ~tuning.notNil.if { mk.tuning_(~tuning) };
            ~velCurve.notNil.if { mk.velCurve_(~velCurve) };
            ~range.notNil.if { mk.range_(~range) };
            ~mk = mk;
        });
        all = Dictionary(256)
	}
	*newFrom { |mk itemName|
		var newName = mk ++ itemName => _.asSymbol;
		var new, old, func ;
		all[newName].notNil.if {
			^all[newName]
		} { 
			old = MicroKeys(mk);
			// old = MicroKeys.all[mk];
			// new = super.new.init(newName) ;
			new = old.class.new(newName, species: old.species);
			new.namedList = old.namedList.deepCopy;
			new.tuningDeltas = old.tuningDeltas;
			new.storedCCValues = old.storedCCValues;
			new.modMap = old.modMap;
			new.modState = old.modState.copy;
			func = old.synthFunc;
			func.isKindOf(Symbol).if{
				new.synth_(func) 
			} {
				(mk: newName).use{ SynthDef(newName, func).add.name };
				new.synth_(newName);
			};
			^new
		}  
	}
	*new { |name func params species=\poly|
		name.isKindOf(Function).if {
			func = name;
			name = func.cs.hash.asSymbol;
		};
		all[name].notNil.if {
			^all[name]
		} {
			^super.new.init(name, func, params, species)
		}
	}
	*mono { |name func params|
		^this.new(name, func, params, \mono)
	}
	init { |aName func params argSpecies=\poly|
		name = aName;
		species = argSpecies;
		namedList = NamedList.new;
		tuningDeltas = 0 ! 128; // Initialize tuningDeltas
		tuningFunction = { |tuning| { |e| e.num = e.num + tuningDeltas.wrapAt(e.num); e }};
        //scale vel and set raw to n
        //should I alternatively set raw to c?
        //...because raw is used by register to determine storage
		namedList.add( \event, {|v n c r params| (vel: v/127, num: n, chan: c, src: r, raw: n, params: params) });

		this.synth_(func ? name, params);
		// this.synth_(
		// 	func !? {|i| (mk: name).use{ i.asDefName }} ? I.d);
			
		
		// Initialize keys based on species
		case 
		{ species == \mono } {
			keys = 0 ! 128;
			down = List[];
			downChannel = ();
			currentChannel = nil;
		}
		{ species == \poly } {
			keys = List[] ! 128;
			sounding = Set[];
			down = List[];
		};
		
		heldNotes = Set[];
		polyFunc = {|k v| k.set(\poly, v)};
		modState = (bend: 0, poly: 0, pressure: 0, expr: 0);

		all.add(name -> this);
		instanceCCs = ()
	}
	synth_ { |funcOrDefname params|
		funcOrDefname.isKindOf(Symbol).if{
			synthFunc = synthFunc ? funcOrDefname;
			namedList.add( \synth,
				{ |e|
					e.silent.isNil.if {
						e.synths = Synths(
							funcOrDefname, 
							[\freq, e.num.midicps, \amp, e.vel, \num, e.num] 
							++ params 
							++ ( e.params ? () ).asKeyValuePairs
						)
					};
					e
				}
			)
		}{ //otherwise should be a Function
			//needs to return an Event with synth in synth:
			synthFunc = funcOrDefname;
			this.synth_((mk: name).use{ funcOrDefname.asDefName })
		};
		namedList.dump
	}
	tuning_ { |tuning root| //todo add root
		tuningDeltas = Tuning.at(tuning).semitones.collect{|i x| i - x};
		tuning.notNil.if{ namedList.add(
			\tuning, 
			tuningFunction.(tuning),
			addAction: \addBefore,
			otherName: \synth
		) };
		namedList.dump
	}
	velCurve_ { |env|
		namedList.add (
			\velCurve, 
			{ |e| e.vel=env.at(e.vel ? 0) },
			addAction: \addAfter,
			otherName: \event
		);
		namedList.dump
	}
	get { |key|
		^namedList[key]
	}
	add { |key func addAction target|
		namedList.add(key, func, true, addAction, target)
	}
    addFunc {|key func| 
        namedList.addBefore(key, func, \synth);
        namedList.dump
    }
	removeFunc { |key|
		namedList.removeAt(key);
        namedList.dump
	}
	current { current = this }
	asEvent {
		^(type: \microKeys, name: name, synthFunc: synthFunc, species: species,
			modMap: modMap)
	}

	// split_ { |r| range = r }
	range_ { |array| 
	  this.add(\range, {|e| array.includes( e.num ).not.if{e.silent_(true)}; e}, \addAfter, \event);
	}
	register { |event|
        var channel = event[\chan];
        //check for MPE
        var notMPE = (channel.isNil or: try{ channel == 0});
		var index = notMPE.if{
				event.raw
			}{
				channel
			};
		var voice = modMap.notNil.if {
			modState.copy.putAll((
				mk: this, synth: event[\synths],
				num: event[\num], vel: event[\vel]
			))
		}{
			event[\synths]
		};
		keys[index].add(voice);
		modMap.notNil.if { this.applyMods(voice) };
		event[\synths].synths.do {|i|
			sounding.add(i);
			i.onFree({ sounding.remove(i)})
		};
	}
	noteOnFunction {
		// ^namedList.array.reverse.inject(I.d, _ <> _)
		^namedList.array.reverse
		// .collect({|func| {|e| e.notNil.if{ func.(e) } } })
		.inject(I.d, {|i j| i <> j  }) //this should return an event with and raw synth or Synths
	}
	setDamper {|num| 
		(num == 127).if{
			damperDown = true.postln 
		}{ 
			damperDown = false.postln; 
			heldNotes.do(_.release); 
			heldNotes = Set[] 
		} 
	}
	doNoteOff {|midinote latency=0 channel=1| 
		name.debug("noteOff");
		case 
		{ species == \poly } {
			down.remove(midinote);
			damperDown.not.if {
				Server.default.makeBundle(
					latency + 0.02, //TODO this should check to see if the note is sounding instead of 0.02 fudge factor
					{ try {
						var index = (channel.isNil or: (channel == 0)).if {midinote}{channel};
						var voice = keys[index].removeAt(0);
						modMap.notNil.if { voice[\synth].release }{ voice.release }
					} }
				)
			} { heldNotes.add(keys[midinote]) }
		}
		{ species == \mono } {
			down.debug("down off");
			(down.size <= 1).if{
				modMap.notNil.if { monosynth[\synth].release }{ monosynth.release };
				down.remove(midinote);
                downChannel.put(midinote, nil);
				currentChannel = nil; // Clear current channel when no notes playing
			}{ 
				down.remove(midinote);
                downChannel.put(midinote, nil);
                //update channel to previous
                currentChannel = downChannel[down.last];
				modMap.notNil.if {
					monosynth[\num] = down.last;
					this.applyMods(monosynth);
				}{
					monosynth.set(\num, down.last, \freq, down.last.midicps)  // snap back to previous note
				}
			};
		};
	}
	applyMods { |voice|
		modMap.keysValuesDo {|param, func|
			voice[\synth].set(param, voice.use { func.() })
		}
	}
	updateVoices { |key, val, chan|
		var keyIndex;
		chan = chan ? 1;
		keyIndex = ((chan == 0) || (chan == 1)).if{ 0 }{ chan };
		((chan == 0) || (chan == 1)).if {
			128.do{|i|
				keys[i].do{|voice|
					voice[key] = val;
					this.applyMods(voice);
				}
			}
		} {
			keys[keyIndex].do{|voice|
				voice[key] = val;
				this.applyMods(voice);
			}
		}
	}
	doPoly {|val num|
		var normVal = val / 127.0;
		modState[\poly] = normVal;
		case
		{ species == \poly } {
			modMap.notNil.if {
				keys[num].do{|voice|
					voice[\poly] = normVal;
					this.applyMods(voice);
				}
			}{
				polyFunc.(keys[num][0], val, num)
			}
		}
		{ species == \mono } {
			modMap.notNil.if {
				monosynth[\poly] = normVal;
				this.applyMods(monosynth);
			}{
				polyFunc.(monosynth, val, num)
			}
		};
	}
	record {
		this.recordMe
	}
doCC {|val cc chan=1|

	cc = cc.asSymbol;
    //sets for all ccs inc damper and expression — val is 0-1
    ccs.put(cc, val);

    [\0, \74, \64].includes(cc).if {^nil};

    modMap.notNil.if {
        var ccKey = ("cc" ++ cc).asSymbol;
        modState[ccKey] = val;
        this.updateVoices(ccKey, val, chan)
    };
    case
    { species == \poly } {
        sounding.do{|synth| synth.isPlaying.if { synth.set(cc, val) } }
    }
    { species == \mono } {
        modMap.notNil.if {
            monosynth[\synth].set(cc, val)
        }{
            monosynth.set(cc, val)
        };
    };
}
doCC74 {|val chan=1|
    var normVal = val / 127.0;
    modState[\expr] = normVal;
    case
    { species == \poly } {
        modMap.notNil.if {
            this.updateVoices(\expr, normVal, chan)
        } {
            var keyIndex = ((chan == 0) || (chan == 1)).if{ 0 }{ chan };
            ((chan == 0) || (chan == 1)).if {
                keys.do{|keyList| keyList.do{|synth| synth.set(\expr, normVal) } }
            } {
                keys[keyIndex].do{|synth| synth.set(\expr, normVal) }
            }
        }
    }
    { species == \mono } {
        modMap.notNil.if {
            monosynth[\expr] = normVal;
            this.applyMods(monosynth);
        }{
            monosynth.set(\expr, normVal)
        }
    };
}
doPressure {|val chan=1|
    var normVal = val / 127.0;
    modState[\pressure] = normVal;
    case
    { species == \poly } {
        modMap.notNil.if {
            this.updateVoices(\pressure, normVal, chan)
        } {
            var keyIndex = ((chan == 0) || (chan == 1)).if{ 0 }{ chan };
            ((chan == 0) || (chan == 1)).if {
                keys.do{|keyList| keyList.do{|synth| synth.set(\pressure, normVal) } }
            } {
                keys[keyIndex].do{|synth| synth.set(\pressure, normVal) }
            }
        }
    }
    { species == \mono } {
        ((chan == 0) || ((down.size > 0) && (chan == currentChannel))).if {
            modMap.notNil.if {
                monosynth[\pressure] = normVal;
                this.applyMods(monosynth);
            }{
                monosynth.set(\pressure, normVal)
            }
        }
    };
}
doBend {|val chan=1|
    var bendValue = (val - 8192) / 8192.0; // normalize bend from -1 to 1
    modState[\bend] = bendValue;
    case
    { species == \poly } {
        modMap.notNil.if {
            this.updateVoices(\bend, bendValue, chan)
        } {
            var keyIndex = ((chan == 0) || (chan == 1)).if{ 0 }{ chan };
            ((chan == 0) || (chan == 1)).if {
                keys.do{|keyList| keyList.do{|synth| synth.set(\bend, bendValue) } }
            } {
                keys[keyIndex].do{|synth| synth.set(\bend, bendValue) }
            }
        }
    }
    { species == \mono } {
        modMap.notNil.if {
            monosynth[\bend] = bendValue;
            this.applyMods(monosynth);
        }{
            monosynth.set(\bend, bendValue)
        }
    };
}
monitor { |offLatency = 0.02|
	CmdPeriod.add(this);
	active = true;
	current = this;
	// storedCCValues.notNil.if{ this.restoreCCValues };
	CC.all[name].do(_.activate);

	//set to current state when monitoring begins
	instanceCCs = ccs;
	// seed modState with current physical CC values
	modMap.notNil.if {
		ccs.keysValuesDo{|k v| modState[("cc" ++ k).asSymbol] = v }
	};
	//if we are monitoring a cc we set these
    MIDIdef.cc(\setClassCCs, {|v n c src| excludeSrcIDs.includes(src).not.if{ ccs.put(n.asSymbol, v / 127.0) } });
	MIDIdef.cc(\microCC ++ name => _.asSymbol, {|val num chan src| excludeSrcIDs.includes(src).not.if{ this.doCC(val / 127.0, num, chan) } } );
	case 
	{ species == \poly } {
		// MIDIdef.noteOn(\microOn, {|val num| this.noteOnFunction.(val, num)}, noteNum:range);
		//we need to set all the ccs for each note-on
		//so adding ccs asArray to params 
		//TODO - should this not be doNoteOn ??
		MIDIdef.noteOn(\microOn ++ name => _.asSymbol,  {|v n c| (
			type: \mk,
			mk:this,
			// amp: v/127,
			amp: v/127,
			params: ccs,
			midinote: n,
			latency:0,
			sustain: inf,
			channel:c
		).postln.play}, );
		// MIDIdef.noteOff(\microOff, {|vel, num| damperDown.postln; ( damperDown == false ).if{ keys[num].release }{ heldNotes.add(keys[num]) }});
		MIDIdef.noteOff(\microOff ++ name => _.asSymbol, {|val num chan| this.doNoteOff(num, offLatency, chan) }, );
		MIDIdef.cc(\microDamper ++ name => _.asSymbol,{|num| this.setDamper(num) }, 64);
		// Add CC 74 handling
		MIDIdef.cc(\microCC74 ++ name => _.asSymbol, {|val num chan| this.doCC74(val, chan) }, 74);

		// Add bend handling
		MIDIdef.bend(\microBend ++ name => _.asSymbol, {|val chan| this.doBend(val, chan) });
		MIDIdef.touch(\microTouch ++ name => _.asSymbol, {|val chan| this.doPressure(val, chan) });
		MIDIdef.polytouch(\microPoly ++ name => _.asSymbol, {|val num| this.doPoly(val, num)});
	}
	{ species == \mono } {
		down = List[];
		MIDIdef.noteOn(\microOn ++ name => _.asSymbol, {|v n c| 
			// this.doNoteOn(v/127, n, channel:c);
			this.doNoteOn(v, n, channel:c);
		});
		MIDIdef.noteOff(\microOff ++ name => _.asSymbol, {|vel num c| 
			this.doNoteOff(num, channel:c);
		});
		// MIDIdef.cc(\microDamper, {|num| (num == 127).if{ damperDown = true.postln }{ damperDown = false.postln; heldNotes.do(_.release); heldNotes = Set[] } }, 64);
		MIDIdef.polytouch(\microPoly ++ name => _.asSymbol, {|val num| monosynth.set(\poly, val)});
		//MPE
		MIDIdef.cc(\microCC74 ++ name => _.asSymbol, {|val num chan| this.doCC74(val, chan) }, 74);

		// Add bend handling
		///aaaak  should denominator be 16384
		MIDIdef.bend(\microBend ++ name => _.asSymbol, {|val chan| monosynth.set(\bend, val - 8192 /8192) });
		MIDIdef.touch(\microTouch ++ name => _.asSymbol, {|val chan|  this.doPressure(val, chan) });
	};
}
	unmonitor {
		active = false;
		[\microOn, \microOff, \microDamper, \microPoly].do{|i| MIDIdef(i ++ name => _.asSymbol).free}
	}
	cmdPeriod {
		this.unmonitor;
		case
		{ species == \poly } {
			keys = List[] ! 128;
			sounding = Set[];
			down = List[];
		}
		{ species == \mono } {
			keys = 0 ! 128;
			down = List[];
			downChannel = ();
			currentChannel = nil;
			monosynth = nil;
		};
		modState = (bend: 0, poly: 0, pressure: 0, expr: 0);
	}
	free {
		this.unmonitor ; //remove MIDIdefs
		CC.all[this.name].do{|i| i.bus.free; i.free}; //remove CC busses and CCs
		this.free 
	}
	split { |array|
		var defNames, cases, paramEvents;
		# defNames, cases, paramEvents = array.flop;
		namedList.add( \chooseDef,
			{|e|
				cases.collect(_.value(e.num)).do{|i x|
					i.if {
						e.def_(defNames.[x]);
						e.splitParams_(paramEvents[x] ? ())
					}
				};
			e.postln
			};
		);
		namedList.addAfter( \synth,
			{ |e|
				Synth(e.def ? \default, [\freq, e.num.midicps, \amp, e.vel, \num, e.num] 
				// ++ params  TODO
				++ ((e.splitParams ? ()) ++ (e.params ? ())).asKeyValuePairs)
				=> this.register(_)
			},
			\chooseDef
		);
		namedList.dump;
		// this.test.isNil.if{ "noteOnFunction isNil".warn }{}
		this.test !? (_.release) ?? { "noteOnFunction isNil".warn }
	}
	test {
		^try{ this.noteOnFunction.(40,40) }
	}
	//
	// auto-record items
	//

	recordMe {
		item.isNil.if{ item = MIDIItem.new( Date.getDate.stamp ) };
		item.record(this);
		^item
	}
	insertItem {
		var key = $\\ ++ $\\ ++ name;
		var string = "MIDIItem(\\\"%\\\").play(%)".format(item.name, key);
		Nvim.replace(string)
	}
	mono {
		var newInstance;
		// Remove the current instance from all dictionary temporarily
		all.removeAt(name);
		// Create new instance with mono species
		newInstance = this.class.new(name, synthFunc, species: \mono);
		// Copy over any additional state that might be needed
		newInstance.namedList = namedList.deepCopy;
		newInstance.tuningDeltas = tuningDeltas;
		newInstance.storedCCValues = storedCCValues;
		^newInstance;
	}
	poly {
		var newInstance;
		// Remove the current instance from all dictionary temporarily
		all.removeAt(name);
		// Create new instance with poly species
		newInstance = this.class.new(name, synthFunc, species: \poly);
		// Copy over any additional state that might be needed
		newInstance.namedList = namedList.deepCopy;
		newInstance.tuningDeltas = tuningDeltas;
		newInstance.storedCCValues = storedCCValues;
		^newInstance;

	}
	doesNotUnderstand {|selector ...args|
		namedList.respondsto(selector).if{
			^Message(namedList, selector, args).value
		}
	}
}

+ Symbol {
	monitor {
		MicroKeys(this).monitor
	}
}
/*
MicroKeys({|e|Synth(\default,[\freq,e.num.midicps,\pan,e.vel*2-1])}).tuning_(\partch).play
(
a=MicroKeys().tuning_(\pythagorean).simplePlay(\stringyy);
a=MicroKeys().tuning_(\partch).range_((60..128)).simplePlay(\default)
)

a=MicroKeys().tuning_(\partch).velCurve_(2).simplePlay(\default)
a=MicroKeys().tuning_(\kirnberger).velCurve(2).simplePlay(\default)
a=MicroKeys().tuning_(\sept2).velCurve_(2,[0.1,0.1]).simplePlay(\default)

Env.new([0,1],[1],[-1.5]).at(0.5)
Tuning
*/
 

