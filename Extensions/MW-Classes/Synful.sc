Synful {
	var <syn,<controller,<condition ;
	var plugin;
	var expr;
	var <patches,<banks; 
	classvar defaultProgram = "/Users/michael/tank/super/SynfulTest.FXP";
	*initClass{

		\addingEvent.postln;
		Event.addEventType(\synful,{
			~channel.isNil.if{~channel=0};
			~type=\vst_midi;
			~vst=~instance.controller;
			~patch.notNil.if{ ~instance.patch(~patch,~bank,~channel)};
			~chan=~channel;
			~expression.notNil.if{~instance.expression(~expression,~channel,~expressionLag)};
			currentEnvironment.play
		})
	} 
	*new {^super.new.init()}
	init {  
		syn = Synth(\vsti2,target:RootNode(Server.default));
		controller = VSTPluginController(syn);
		//condition = Condition.new();
                condition = CondVar.new();
		plugin = 'SynfulOrchestra.vst';
		expr = 0.5 ! 16;
		patches = ( flute:73, oboe:68, enghorn:69, clarinet:71, bassoon:70, horn:62, horn4:5, horn8:6, trumpet:56, trombone:57, violin:40, viola:41, cello:42, bass:43, violins:0, violins2:1, violas:2, cellos:3, basses:4);
		banks = ( none:1, mute1:2, mute2:3, stopped:4, arco:1, pizz:2, bartok:3, legno:4, trem:5, sulpont:6, tremsulpont:7, harmonics:8, mute:9);
                  ~vstRegistry ?? {~vstRegistry=List.new}; //should be an object
                  ~vstRegistry.add(controller);
                  {
                    Server.default.sync;
                    controller.open("/Library/Audio/Plug-Ins/VST/"++plugin,
                      action:{
                        //condition.test_(true).signal;
                        condition.signalOne;
                        controller.readProgram(defaultProgram); 
                      }
                    );
                  }.fork;
	}
	patch {| patch bank=\none channel=0 |
		this.setprog( 
			patches.at(patch),
			bank.isNumber.if(bank,banks.at(bank)),
			channel
		);
		postln("patch "++patches.at(patch)++" bank "++banks.at(bank)++" chan "++channel)}

	setprog {|program bank channel| 
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
/*
y=Synful()
y.patch(\horn,0,channel:4)
y.shuffle
y.expression(1,4)
(type:\synful,channel:1,note:1,instance:y,patch:\violin,bank:\arco).play
(type:\synful,instance:y,note:1,channel:0,patch:\violas,bank:\arco).play
[type:\synful,instance:y,note:Pwhite(-10.0,10,inf),expression:Pstutter(4,Pwhite(0.1,1)),expressionLag:2,legato:1.2,channel:4.rand,patch:[\flute, \violas,\clarinet].choose,bank:\trem].p.play
(note:1,type:\synful,dur:40,instance:y,patch:\violin,bank:\arco,channel:3).play
y.expression(0.6,0,5)
y.line(1,0,5)
y.env(Env.triangle(10))
y
(
e = Env.triangle(10).asStream;
fork{
	loop{
		0.01.wait;
		y.expression(e.next*128,0);
	}
}
)
s.meter
y.controller
*/
