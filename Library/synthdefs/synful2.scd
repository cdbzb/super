s.options.memSize_(2**17);
s.reboot;
(
	SynthDef(\vsti,{|in out=0|
		var sig=VSTPlugin.ar(nil,2);
		Out.ar(out,sig)
	}).add;

	~synful2=
	{
		var event=
		( // creates a nodeproxy playing on a private bus - .node and .bus respectively 
			bus: Bus.audio(s,2),
			controller: nil,
			node:nil,
			params:(expression:11),
			expr:NodeProxy.control(s,1)!16, //expr[n].source={} is the jam....
			fs:Array.newClear(16), //used internally by activate
			loops:Array.newClear(16),	
			activate:{|self chan=0 update=0.1| 
				self.expr[chan].source=64;
				self.loops[chan]={ var ch=chan;
					loop({
						self.expr[ch].bus.get({|value| self.fs[ch]=value+1*64});
						self.expression(self.fs[ch],ch);
						update.wait;
					});
				}.fork;
			},
			activateAll:{|self|16.do{|chan|self.activate(chan)}},
			expression:{|self expression channel=0 | self.controller.sendMidi("B0".asHexIfPossible+channel,11,expression)},
			plugin: 'SynfulOrchestra.vst',
			setprog:{|self program bank channel| 
				self.controller.sendMidi("B0".asHexIfPossible+channel,0,bank);//set bank then
				self.controller.sendMidi("C0".asHexIfPossible+channel,program); //set program
			},
			init: { |self| //create node and controller + load plug 
				self.controller=VSTPluginController(Synth(\vsti,[\out,self.bus],target:RootNode(s)));
				//self.node=NodeProxy.audio(s,2).play;
				//self.node.source={In.ar(self.bus.index,2)};
				{
					s.sync;
					self.controller.open("/Library/Audio/Plug-Ins/VST/"++self.plugin,
						action:{
							self.controller.readProgram("/Users/michael/tank/super/SynfulTest.FXP"); 
						});
				}.fork;
			},
			set:{|self args| self.controller.set(args)},
			patches:( flute:73, oboe:68, enghorn:69, clarinet:71, bassoon:70, horn:62, horn4:5, horn8:6, trumpet:56, trombone:57, violin:40, viola:41, cello:42, bass:43, violins:0, violins2:1, violas:2, cellos:3, basses:4),
			banks:( none:0, mute1:2, mute2:3, stopped:4, arco:1, pizz:2, bartok:3, legno:4, trem:5, sulpont:6, tremsulpont:7, harmonics:8, mute:9),
			patch:{| self patch bank=\none channel=0 | self.setprog( self.patches.at(patch),self.banks.at(bank),channel);postln("patch "++self.patches.at(patch)++" bank "++self.banks.at(bank))},
			shuffle:{|self|16.do{
				|chan| self.setprog(self.patches.choose,0,chan);
			};
		}
	);
		{
			event.init;
		}.fork;
		//store event type or proto event(s) under some key
		//event.proto=(type:\midi,midiout:event.controller.midi);
		event;
	};
)
~syn1=~synful2.()
~syn1.bus
a=Monitor.new.play(~syn1.bus.index,2,0,2);
[type:\vsti,note:Pwhite(3,8,88),controller:~syn1.controller].pp
v={var sig=In.ar(~syn1.bus);sig=PlateReverb.ar(sig);ReplaceOut.ar(~syn1.bus,sig)};v.play
~myFree.(~syn1)
s.plotTree

