AAS_Strum { // piano	TODO put it on a node
	var <syn,<>controller,<condition ;
	var plugin;
	var <patches,<banks; 
	classvar strums,stru,struShort;


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

	*new {^super.new.init()}
	*dump { stru.cs.postln;struShort.cs.postln }
	init {  
		syn = Synth(\vsti2,target:RootNode(Server.default));
		controller = VSTPluginController(syn);
		condition = CondVar.new();
		plugin = 'Strum GS-2.vst';

		/*
		~vstRegistry ?? {~vstRegistry=List.new}; //should be an object
		~vstRegistry.add(controller);
		*/
		{
			Server.default.sync;
			controller.open("/Library/Audio/Plug-Ins/VST/"++plugin,
				action:{
					//condition.test_(true).signal;
					condition.signalOne;
					//controller.readProgram(defaultProgram); 
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
						//condition.test_(true).signal;
						condition.signalOne;
						//controller.readProgram(defaultProgram); 
					}
				);
			}
			
		} )
	}
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
	//Event.addEventType(\vsti,play,(parent:()));


	/*
	~vsti={|plug bus target|
		VSTPluginController(Synth(\vsti,[\out,bus],target:target)).open(plug)
	};

	~vstiN=
	{ |plug|
		var b=Bus.audio(s,2);
		var n=NodeProxy.audio.play
		.source_({In.ar(b,2)});
		var c=~vsti.(plug,b);
		(//guitar
			node:n,
			controller:c
		)
	};

	~guitar=
	{
		var b=Bus.audio(s,2);
		var n=NodeProxy.audio.play
		.source_({In.ar(b,2)});
		var c=~vsti.('Strum GS-2.vst',b);
		(//guitar
			node:n,
			controller:c
		)
	}
*/
	//a=~vst.('Pianoteq 5')
	//(type:vsti,controller.a)


 }
