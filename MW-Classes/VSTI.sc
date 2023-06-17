VSTI {
	var <condition, <syn, <controller ;// <plugin;
	*new { |plugin action| ^super.new.init( plugin, action ) }
	init { | plugin action | 
		\SuperInit.postln;
		condition = CondVar.new();
		syn = Synth(\vsti2,target:RootNode(Server.default));
		controller = VSTPluginController(syn);

		{
			Server.default.sync;
			controller.open("/Library/Audio/Plug-Ins/VST/" ++ plugin,
				action:{
					condition.signalOne;
					action.(syn, controller);
				}
			);
		}.fork;

		CmdPeriod.add( {
			fork{
				0.1.wait;
				syn = Synth(\vsti2,target:RootNode(Server.default));
				controller = VSTPluginController(syn);
				Server.default.sync;
				controller.open("/Library/Audio/Plug-Ins/VST/"++plugin,
					action:{
						condition.signalOne;
						action.(syn, controller);
					}
				);
			}
			
		} )
	}
}

AAS_Strum : VSTI  { 
	//var <syn,<>controller,<condition ;
	classvar strums,stru,struShort;
	classvar <plugin = 'Strum GS-2.vst';


	*initClass{
		stru= [ 'down', 'muted', 'up', 'alt', 'one', 'two', 'muffleD', 'three', 'muffleU', 'four', 'mute', 'five', 'six' ];
		struShort=['d','m','u','a','1','2','f','3','fu','4','x','5','6'];
		strums = Dictionary.new;
		stru.do{|i x| strums.add(i->(x+72))};
		struShort.do{|i x| strums.add(i->(x+72))};
		Class.initClassTree(Event);
		Event.addEventType(\strum,{
			~out !? {~instance.controller.synth.set(\out,~out)};
			~channel.isNil.if{~channel=0};
			~type=\vst_midi;
			~switch !? {~midinote= strums[~switch]};
			~vst=~instance.controller;
			~chan=~channel;
			currentEnvironment.play
		})
			}

	*new { ^super.new(plugin) }
	*dump { stru.cs.postln;struShort.cs.postln }
	
	setPlayMode { | mode |
		case
		{ mode == \strum } {
			(
				type:\vst_set,
				vst:controller,
				params:['Play Mode: Play Mode'],
				'Play Mode: Play Mode':0.6
			).play
		}{ mode == \pick }{
			(
				type:\vst_set,
				vst:controller,
				params:['Play Mode: Play Mode'],
				'Play Mode: Play Mode':0.0
			).play
		}

	}
	setOut{|out|
		controller.synth.set(\out,out)
	}
	////////////////
	/*
	var play =
	{ 
		i=currentEnvironment; 
		all {:x,x<-i.keys,
			i.controller.info.parameters.collect{|i|i.name.asSymbol}.asList.includes(x),
			::i.controller.set(x,i.at(x))
		};
		//(type:\midi,dur:i.dur,midiout:i.controller.midi,midinote:i.midinote,note:i.note,degree:i.degree,amp:i.amp,legato:i.legato).play	
		~type=\vst_midi;
		~vst=i.controller;
		currentEnvironment.play;
	};
 */
 }


Synful : VSTI {
	//var <syn,<controller,<condition ;
	var plugin;
	var expr = #[0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5];
	classvar <patches,<banks; 
	classvar <defaultProgram;
	*initClass{
		defaultProgram = "~/tank/super/SynfulTest.FXP".standardizePath;
		patches = ( flute:73, oboe:68, enghorn:69, clarinet:71, bassoon:70, horn:62, horn4:5, horn8:6, trumpet:56, trombone:57, violin:40, viola:41, cello:42, bass:43, violins:0, violins2:1, violas:2, cellos:3, basses:4);
		banks = ( none:1, mute1:2, mute2:3, stopped:4, arco:1, pizz:2, bartok:3, legno:4, trem:5, sulpont:6, tremsulpont:7, harmonics:8, mute:9);
		Event.addEventType(\synful,{
			~channel = ~channel ? 0;
			~bank.isNil.if{ ~bank = \none };
			~type=\vst_midi;
			~out !? {~instance.controller.synth.set(\out,~out)};
			~vst=~instance.controller;
			~patch !? { ~instance.patch(~patch,~bank,~channel)};
			~chan=~channel;
			~expression !? { ~instance.expression(~expression, ~channel, ~expressionLag) };
			currentEnvironment.play
		})
	} 
	*new {^super.new('SynfulOrchestra.vst', 
		{|syn controller| controller.readProgram(defaultProgram)}
	)}
	patch {| patch bank=\none channel=0 |
		this.setprog( 
			patches.at(patch),
			bank.isNumber.if(bank,banks.at(bank)),
			channel
		);
		postln("patch "++patches.at(patch)++" bank "++banks.at(bank)++" chan "++channel)}

	setprog {|program bank=1 channel=0| 
		controller.sendMidi("B0".asHexIfPossible+channel,0,bank);//set bank then
		controller.sendMidi("C0".asHexIfPossible+channel,program); //set program
	}


	expression {|expression, channel=0, lag | 
		lag.isNil.if{
			controller.sendMidi("B0".asHexIfPossible+channel,11,expression);
		}{
			this.line(expr[channel],expression,lag,channel:channel)
		}	
		
		

	}
	setOut {|out|
		syn.set(\out,out)
	}
	env {|envelope, interval=0.025, channel=0| 
		var env=envelope.asStream;
		var duration = envelope.times.sum;
		fork{
			(duration/interval).do{|i|
				this.expression(env.next*128,channel);
				interval.wait;
			}
		}
	}
	line {| from, to, time, interval=0.025, channel=0| 
		var env=Env([from,to],time).asStream;
		var duration = time;
		fork{
			(duration/interval).do{|i|
				this.expression(env.next*128,channel);
				interval.wait;
			}
		}
	}
}

PF : VSTI {
	classvar plugin = 'Pianoteq 5.vst';  //++self.plugin
	*new{ ^super.new(plugin).attachMIDI.init }
	attachMIDI {
		MIDIClient.init;
		MIDIIn.connectAll;
		MIDIFunc.noteOn({ |vel num| var a=controller.midi;a.noteOn(0,num,vel)},srcID:602392681 );
		MIDIFunc.noteOff({ |vel num| var a=controller.midi;a.noteOff(0,num,vel)},srcID:602392681);

		MIDIFunc.noteOff({ |vel num| var a=controller.midi;a.noteOff(0,num,vel)},srcID: -682393637).permanent_(true);
		MIDIFunc.noteOn({ |vel num| var a=controller.midi;a.noteOn(0,num,vel)},srcID:-682393637).permanent_(true);
	}
}
