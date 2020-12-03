(
	SynthDef(\vsti2,{|in |
		var sig=VSTPlugin.ar(nil,2);
		Out.ar(\out.kr(0),sig)
	}).add;

	~synful3=
	{
		var event=
		( 
			bus: Bus.audio(s,2),
			controller: nil,
			condition:Condition.new(),
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
				self.syn = Synth(\vsti2,target:RootNode(s));
				self.controller=VSTPluginController(self.syn);
				~vstRegistry ?? {~vstRegistry=List.new};
				~vstRegistry.add(self.controller);
				{
					s.sync;
					self.controller.open("/Library/Audio/Plug-Ins/VST/"++self.plugin,
						action:{
							self.condition.test_(true).signal;
							self.controller.readProgram("/Users/michael/tank/super/SynfulTest.FXP"); 
						});
				}.fork;
			},
			set:{|self args| self.controller.set(args)},
			setOut:{|self out| self.syn.set(\out,out)},
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

compiling class library...
	Found 850 primitives.
	Compiling directory '/Applications/SuperCollider.app/Contents/Resources/SCClassLibrary'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/Extensions'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/Automation'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/JITLibExtensions'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/Vowel'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/panola'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/Freesound'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/FreeAfter'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/wslib'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/SynthDefPool'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/say'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/MathLib'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/VectorSpace'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/Unit-Lib'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/BatLib'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/SpeakersCorner'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/AmbIEM'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/AllGui'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/FileLog'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/Hilbert'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/XML'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/atk-sc3'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/Ctk'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/ixiViews'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/SFPlayer'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/ScoreClock'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/ZArchive'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/KDTree'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/Modality-toolkit'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/FPLib'
	Compiling directory '/Users/michael/.local/share/SuperCollider/downloaded-quarks/autogui'
	Compiling directory '/Users/michael/.local/share/SuperCollider/downloaded-quarks/Scintillator'
	numentries = 2880081 / 70350680 = 0.041
	12653 method selectors, 5560 classes
	method table size 59792920 bytes, big table size 562805440
	Number of Symbols 30706
	Byte Code Size 1398884
	compiled 1332 files in 1.73 seconds
Info: 21 methods are currently overwritten by extensions. To see which, execute:
MethodOverride.printAll
compile done
localhost : setting clientID to 0.
internal : setting clientID to 0.
WARNING: Called from Meta_GlobalPathDict:initClass, method Meta_String:scDir is deprecated and will be removed. Use Meta_Platform:resourceDir instead.
The definition of 'Meta_String:scDir' is to be found here: '/Applications/SuperCollider.app/Contents/Resources/SCClassLibrary/deprecated/3.11/deprecated-3.11.sc'
2020-12-02 08:08:25.730 defaults[35041:3144468] 
The domain/default pair of (com.apple.speech.voice.prefs, SelectedVoiceName) does not exist
Class tree inited in 0.37 seconds
WARNING: server 'localhost' not running.
/Users/michael/tank/super/Library/functions/Schafer.scd
ERROR: syntax error, unexpected CLASSNAME, expecting $end
  in interpreted text
  line 1 char 15:
  let SessionLoad = 1
      ^^^^^^^^^^^
  let s:so_save = &so | let s:siso_save = &siso | set so=0 siso=0
-----------------------------------
ERROR: Command line parse failed
/Users/michael/tank/super/Library/functions/Session.vim
Startup File Loaded
/Users/michael/tank/super/Library/functions/clicktrack.scd
/Users/michael/tank/super/Library/functions/convo.scd
/Users/michael/tank/super/Library/functions/load.scd
/Users/michael/tank/super/Library/functions/prep.scd
WARNING: Called from Function:prTry, method Object:asInt is deprecated and will be removed.
The definition of 'Object:asInt' is to be found here: '/Applications/SuperCollider.app/Contents/Resources/SCClassLibrary/deprecated/3.11/deprecated-3.11.sc'
PATH: /Users/michael/tank/super/Library/functions/server-options.scd
/Users/michael/tank/super/Library/functions/server-options.scd
server 'localhost' already booting
/Users/michael/tank/super/Library/functions/trek.scd
ERROR: syntax error, unexpected CLASSNAME, expecting $end
  in interpreted text
  line 1 char 15:
  let SessionLoad = 1
      ^^^^^^^^^^^
  let s:so_save = &so | let s:siso_save = &siso | set so=0 siso=0
-----------------------------------
ERROR: Command line parse failed
/Users/michael/tank/super/Library/synthdefs/Session.vim
/Users/michael/tank/super/Library/synthdefs/clk.scd
/Users/michael/tank/super/Library/synthdefs/pianoteq.scd
/Users/michael/tank/super/Library/synthdefs/reedy.scd
/Users/michael/tank/super/Library/synthdefs/synful.scd
/Users/michael/tank/super/Library/synthdefs/synful2.scd
/Users/michael/tank/super/Library/synthdefs/synful3.scd
functions: 
	prep: 	a Function
	prepStereo: 	a Function
	clicktrack: 	a Function
	reverb: 
		true_stereo: 	a Function
		mono: 	a Function
		single_stereo: 	a Function
synthdefs: 
	clk: 	a SynthDef
Ctk init class runs
Cleaning up 133 temporary SynthDefs...
WARNING: Called from Meta_BarMap:formatEvent, method Object:asInt is deprecated and will be removed.
The definition of 'Object:asInt' is to be found here: '/Applications/SuperCollider.app/Contents/Resources/SCClassLibrary/deprecated/3.11/deprecated-3.11.sc'
WARNING: Extension in '/Users/michael/.local/share/SuperCollider/downloaded-quarks/autogui/Classes/synthDefStorageExt.sc' overwrites SynthDef:build in main class library.
WARNING: Extension in '/Users/michael/.local/share/SuperCollider/downloaded-quarks/autogui/Classes/ArrayWarp.sc' overwrites ControlSpec:constrain in main class library.
WARNING: Extension in '/Users/michael/.local/share/SuperCollider/downloaded-quarks/autogui/Classes/ArrayWarp.sc' overwrites ControlSpec:map in main class library.
Intentional overwrites must be put in a 'SystemOverwrites' subfolder.
*** Welcome to SuperCollider 3.11.1. *** For help type cmd-d.
MIDI Sources:
	MIDIEndPoint("IAC Driver", "Bus 1", 1222620153)
	MIDIEndPoint("IAC Driver", "IAC Bus 2", 5356331)
	MIDIEndPoint("IAC Driver", "IAC Bus 3", -649347929)
	MIDIEndPoint("IAC Driver", "IAC Bus 4", 719229864)
	MIDIEndPoint("CASIO USB-MIDI", "CASIO USB-MIDI", 602392681)
	MIDIEndPoint("X-Touch", "INT", 1779843049)
	MIDIEndPoint("X-Touch", "EXT", -181842512)
	MIDIEndPoint("RME ARC", "RME ARC", 335163963)
	MIDIEndPoint("ipMIDI", "Port 1", -1157686251)
MIDI Destinations:
	MIDIEndPoint("IAC Driver", "Bus 1", -1513577802)
	MIDIEndPoint("IAC Driver", "IAC Bus 2", -723420066)
	MIDIEndPoint("IAC Driver", "IAC Bus 3", -715708506)
	MIDIEndPoint
	MIDIEndPoint("IAC Driver", "Bus 1", 1222620153)
	MIDIEndPoint("IAC Driver", "IAC Bus 2", 5356331)
	MIDIEndPoint("IAC Driver", "IAC Bus 3", -649347929)
	MIDIEndPoint("IAC Driver", "IAC Bus 4", 719229864)
	MIDIEndPoint("CASIO USB-MIDI", "CASIO USB-MIDI", 602392681)
	MIDIEndPoint("X-Touch", "INT", 1779843049)
	MIDIEndPoint("X-Touch", "EXT", -181842512)
	MIDIEndPoint("RME ARC", "RME ARC", 335163963)
	MIDIEndPoint("ipMIDI", "Port 1", -1157686251)
MIDI Destinations:
	MIDIEndPoint("IAC Driver", "Bus 1", -1513577802)
	MIDIEndPoint("IAC Driver", "IAC Bus 2", -723420066)
	MIDIEndPoint("IAC Driver", "IAC Bus 3", -715708506)
	MIDIEndPoint("IAC Driver", "IAC Bus 4", 1256206411)
	MIDIEndPoint("CASIO USB-MIDI", "CASIO USB-MIDI", 1981760746)
	MIDIEndPoint("X-Touch", "INT", -1972777358)
	MIDIEndPoint("X-Touch", "EXT", -922613860)
	MIDIEndPoint("RME ARC", "RME ARC", -1510553930)
	MIDIEndPoint("ipMIDI", "Port 1", -1157686271)
Booting server 'localhost' on address 127.0.0.1:57110.
ERROR: API version mismatch: /Users/michael/Library/Application Support/SuperCollider/Extensions/KBVerb/untitled folder/FaustKBVerb.scx
    This plugin is not compatible with SuperCollider >=3.9.0
    The plugin has not been loaded; please find or compile a newer version.
    (Plugin's API version: 2. Expected: 3)
ERROR: API version mismatch: /Users/michael/Library/Application Support/SuperCollider/Extensions/KBVerb/untitled folder/KBVerb.scx
    This plugin is not compatible with SuperCollider >=3.9.0
    The plugin has not been loaded; please find or compile a newer version.
    (Plugin's API version: 2. Expected: 3)
VSTPlugin 0.4.1
objc[35191]: Class CocoaEditorWindow is implemented in both /Users/michael/Library/Application Support/SuperCollider/Extensions/VSTPlugin/plugins/VSTPlugin.scx (0x1093e0570) and /Users/michael/Library/Application Support/SuperCollider/Extensions/VSTPlugin/plugins/VSTPlugin_supernova.scx (0x10947a570). One of the two will be used. Which one is undefined.
objc[35191]: Class EventLoopProxy is implemented in both /Users/michael/Library/Application Support/SuperCollider/Extensions/VSTPlugin/plugins/VSTPlugin.scx (0x1093e0598) and /Users/michael/Library/Application Support/SuperCollider/Extensions/VSTPlugin/plugins/VSTPlugin_supernova.scx (0x10947a598). One of the two will be used. Which one is undefined.
Found 0 LADSPA plugins
Number of Devices: 6
   0 : "Built-in Output"
   1 : "HDMI"
   2 : "Unknown USB Audio Device"
   3 : "Merging RA"
   4 : "Premiere Pro 6.0"
   5 : "Digiface USB (23953833)"
"Digiface USB (23953833)" Input Device
   Streams: 4
      0  channels 8
      1  channels 8
      2  channels 8
      3  channels 8
"Digiface USB (23953833)" Output Device
   Streams: 5
      0  channels 8
      1  channels 8
      2  channels 8
      3  channels 8
      4  channels 2
SC_AudioDriver: sample rate = 48000.000000, driver's block size = 512
SuperCollider 3 server ready.
Requested notification messages from server 'localhost'
localhost: server process's maxLogins (1) matches with my options.
localhost: keeping clientID (0) as confirmed by server process.
Shared memory server interface initialized
StageLimiter active
-> a Function
-> a Function
ERROR: Message 'dumpInterfacr' not understood.
RECEIVER:
   nil
ARGS:
PATH: /Users/michael/tank/super/Library/synthdefs/reedy.scd
CALL STACK:
	DoesNotUnderstandError:reportError
		arg this = <instance of DoesNotUnderstandError>
	Nil:handleError
		arg this = nil
		arg error = <instance of DoesNotUnderstandError>
	Thread:handleError
		arg this = <instance of Thread>
		arg error = <instance of DoesNotUnderstandError>
	Object:throw
		arg this = <instance of DoesNotUnderstandError>
	Object:doesNotUnderstand
		arg this = nil
		arg selector = 'dumpInterfacr'
		arg args = [*0]
	Interpreter:interpretPrintCmdLine
		arg this = <instance of Interpreter>
		var res = nil
		var func = <instance of Function>
		var code = "g.dumpInterfacr"
		var doc = <instance of Document>
		var ideClass = nil
	Process:interpretPrintCmdLine
		arg this = <instance of Main>
^^ The preceding error dump is for ERROR: Message 'dumpInterfacr' not understood.
RECEIVER: nil
ERROR: Message 'dumpInterface' not understood.
RECEIVER:
   nil
ARGS:
PATH: /Users/michael/tank/super/Library/synthdefs/reedy.scd
CALL STACK:
	DoesNotUnderstandError:reportError
		arg this = <instance of DoesNotUnderstandError>
	Nil:handleError
		arg this = nil
		arg error = <instance of DoesNotUnderstandError>
	Thread:handleError
		arg this = <instance of Thread>
		arg error = <instance of DoesNotUnderstandError>
	Object:throw
		arg this = <instance of DoesNotUnderstandError>
	Object:doesNotUnderstand
		arg this = nil
		arg selector = 'dumpInterface'
		arg args = [*0]
	Interpreter:interpretPrintCmdLine
		arg this = <instance of Interpreter>
		var res = nil
		var func = <instance of Function>
		var code = "g.dumpInterface"
		var doc = <instance of Document>
		var ideClass = nil
	Process:interpretPrintCmdLine
		arg this = <instance of Main>
^^ The preceding error dump is for ERROR: Message 'dumpInterface' not understood.
RECEIVER: nil
ERROR: Message 'dumpArgs' not understood.
RECEIVER:
   nil
ARGS:
PATH: /Users/michael/tank/super/Library/synthdefs/reedy.scd
CALL STACK:
	DoesNotUnderstandError:reportError
		arg this = <instance of DoesNotUnderstandError>
	Nil:handleError
		arg this = nil
		arg error = <instance of DoesNotUnderstandError>
	Thread:handleError
		arg this = <instance of Thread>
		arg error = <instance of DoesNotUnderstandError>
	Object:throw
		arg this = <instance of DoesNotUnderstandError>
	Object:doesNotUnderstand
		arg this = nil
		arg selector = 'dumpArgs'
		arg args = [*0]
	Interpreter:interpretPrintCmdLine
		arg this = <instance of Interpreter>
		var res = nil
		var func = <instance of Function>
		var code = "g.dumpArgs"
		var doc = <instance of Document>
		var ideClass = nil
	Process:interpretPrintCmdLine
		arg this = <instance of Main>
^^ The preceding error dump is for ERROR: Message 'dumpArgs' not understood.
RECEIVER: nil
SCDoc: Indexing help-files...
SCDoc: Indexed 3097 documents in 2.75 seconds
-> SymbolArray[ freq, group, tolerance, lowest ]
-> SymbolArray[ freq, group, tolerance, lowest ]
ERROR: syntax error, unexpected NAME, expecting ';' or ','
  in interpreted text
  line 19 char 19:
  	    topEnvironment.use{~gong.(*args)}
       ^^^^^^^^^^^^^^
      })
-----------------------------------
ERROR: Command line parse failed
-> nil
-> Event
ERROR: Message 'asTarget' not understood.
RECEIVER:
Instance of Function {    (0x7fd25679f5c8, gc=B4, fmt=00, flg=00, set=02)
  instance variables [2]
    def : instance of FunctionDef - closed
    context : Frame (0x7fd257341658) of Interpreter:functionCompileContext
}
ARGS:
PATH: /Users/michael/tank/super/Library/synthdefs/reedy.scd
PROTECTED CALL STACK:
	Meta_MethodError:new	0x7fd257b43ac0
		arg this = DoesNotUnderstandError
		arg what = nil
		arg receiver = a Function
	Meta_DoesNotUnderstandError:new	0x7fd257b45a80
		arg this = DoesNotUnderstandError
		arg receiver = a Function
		arg selector = asTarget
		arg args = [  ]
	Object:doesNotUnderstand	0x7fd255f7dfc0
		arg this = a Function
		arg selector = asTarget
		arg args = nil
	Function:play	0x7fd25a223ac0
		arg this = a Function
		arg target = a Function
		arg outbus = 0
		arg fadeTime = 0.02
		arg addAction = addToHead
		arg args = nil
		var def = nil
		var synth = nil
		var server = nil
		var bytes = nil
		var synthMsg = nil
	a FunctionDef	0x7fd25940d7c0
		sourceCode = "<an open Function>"
	Function:prTry	0x7fd257f0cb00
		arg this = a Function
		var result = nil
		var thread = a Thread
		var next = a Function
		var wasInProtectedFunc = true
	Function:protect	0x7fd257f0c080
		arg this = a Function
		arg handler = a Function
		var result = nil
	Environment:use	0x7fd25940d340
		arg this = Environment[ (synful2 -> a Function), (moveNumberBuffersToRemote -> a Function), (setBusIR -> a Function), (concatSongs -> a Function), (remote -> a Function), 
  (playNumbersAtOnce -> a Function), (prepAlexa -> a Function), (recorder -> a Function), (hack -> a Function), (vsti -> a Function), 
  (gong -> a Function), (makeNodes -> a Function), (myFree -> a Function), (trek -> ( 'dursFile': /Users/michael/tank/super/theExtreme3, 'save': a Function )), (noteList -> a Function), 
  (numberBuffers -> [ nil, ni...etc...
		arg function = a Function
		var result = nil
		var saveEnvir = ( 'floor': 300, 'type': tuningGong, 'server': localhost )
	a FunctionDef	0x7fd259448000
		sourceCode = "#{
					var tempo, server, eventTypes, parentType;
					parentType = ~parentTypes[~type];
					parentType !? { currentEnvironment.parent = parentType };
					server = ~server = ~server ? Server.default;
					~finish.value(currentEnvironment);
					tempo = ~tempo;
					tempo !? { thisThread.clock.tempo = tempo };
					if(currentEnvironment.isRest.not) {
						eventTypes = ~eventTypes;
						(eventTypes[~type] ?? { eventTypes[\\note] }).value(server)
					};
					~callback.value(current...etc..."
		var tempo = nil
		var server = localhost
		var eventTypes = ( 'fadeBus': a Function, 'freeAllocWrite': a Function, 'tree': a Function, 'vst_set': a Function, 
  'on': a Function, 'vsti': a Function, 'load': a Function, 'freeBuffer': a Function, 'group': a Function, 
  'reedy': a Function, 'freeAllocRead': a Function, 'allocWrite': a Function, 'cue': a Function, 'grain': a Function, 
  'Synth': a Function, 'vst_midi': a Function, 'freeAllocWriteID': a Function, 'alloc': a Function, 'rest': a Function, 
  'sine2': a Function, 'sine1': a Function, 'midi': a Function, '...etc...
		var parentType = nil
	a FunctionDef	0x7fd25940d7c0
		sourceCode = "<an open Function>"
	Function:prTry	0x7fd257f0cb00
		arg this = a Function
		var result = nil
		var thread = a Thread
		var next = nil
		var wasInProtectedFunc = false
	
CALL STACK:
	DoesNotUnderstandError:reportError
		arg this = <instance of DoesNotUnderstandError>
	Nil:handleError
		arg this = nil
		arg error = <instance of DoesNotUnderstandError>
	Thread:handleError
		arg this = <instance of Thread>
		arg error = <instance of DoesNotUnderstandError>
	Object:throw
		arg this = <instance of DoesNotUnderstandError>
	Function:protect
		arg this = <instance of Function>
		arg handler = <instance of Function>
		var result = <instance of DoesNotUnderstandError>
	Environment:use
		arg this = <instance of Event>
		arg function = <instance of Function>
		var result = nil
		var saveEnvir = <instance of Environment>
	Event:play
		arg this = <instance of Event>
	Interpreter:interpretPrintCmdLine
		arg this = <instance of Interpreter>
		var res = nil
		var func = <instance of Function>
		var code = "(type:\tuningGong,floor:300)..."
		var doc = <instance of Document>
		var ideClass = nil
	Process:interpretPrintCmdLine
		arg this = <instance of Main>
^^ The preceding error dump is for ERROR: Message 'asTarget' not understood.
RECEIVER: a Function
ERROR: Message 'asTarget' not understood.
RECEIVER:
Instance of Function {    (0x7fd25679f5c8, gc=B8, fmt=00, flg=00, set=02)
  instance variables [2]
    def : instance of FunctionDef - closed
    context : Frame (0x7fd257341658) of Interpreter:functionCompileContext
}
ARGS:
PATH: /Users/michael/tank/super/Library/synthdefs/reedy.scd
PROTECTED CALL STACK:
	Meta_MethodError:new	0x7fd257b43ac0
		arg this = DoesNotUnderstandError
		arg what = nil
		arg receiver = a Function
	Meta_DoesNotUnderstandError:new	0x7fd257b45a80
		arg this = DoesNotUnderstandError
		arg receiver = a Function
		arg selector = asTarget
		arg args = [  ]
	Object:doesNotUnderstand	0x7fd255f7dfc0
		arg this = a Function
		arg selector = asTarget
		arg args = nil
	Function:play	0x7fd25a223ac0
		arg this = a Function
		arg target = a Function
		arg outbus = 0
		arg fadeTime = 0.02
		arg addAction = addToHead
		arg args = nil
		var def = nil
		var synth = nil
		var server = nil
		var bytes = nil
		var synthMsg = nil
	a FunctionDef	0x7fd25940d7c0
		sourceCode = "<an open Function>"
	Function:prTry	0x7fd257f0cb00
		arg this = a Function
		var result = nil
		var thread = a Thread
		var next = a Function
		var wasInProtectedFunc = true
	Function:protect	0x7fd257f0c080
		arg this = a Function
		arg handler = a Function
		var result = nil
	Environment:use	0x7fd25940d340
		arg this = Environment[ (synful2 -> a Function), (moveNumberBuffersToRemote -> a Function), (setBusIR -> a Function), (concatSongs -> a Function), (remote -> a Function), 
  (playNumbersAtOnce -> a Function), (prepAlexa -> a Function), (recorder -> a Function), (hack -> a Function), (vsti -> a Function), 
  (gong -> a Function), (makeNodes -> a Function), (myFree -> a Function), (trek -> ( 'dursFile': /Users/michael/tank/super/theExtreme3, 'save': a Function )), (noteList -> a Function), 
  (numberBuffers -> [ nil, ni...etc...
		arg function = a Function
		var result = nil
		var saveEnvir = ( 'floor': 300, 'server': localhost, 'type': tuningGong )
	a FunctionDef	0x7fd259448000
		sourceCode = "#{
					var tempo, server, eventTypes, parentType;
					parentType = ~parentTypes[~type];
					parentType !? { currentEnvironment.parent = parentType };
					server = ~server = ~server ? Server.default;
					~finish.value(currentEnvironment);
					tempo = ~tempo;
					tempo !? { thisThread.clock.tempo = tempo };
					if(currentEnvironment.isRest.not) {
						eventTypes = ~eventTypes;
						(eventTypes[~type] ?? { eventTypes[\\note] }).value(server)
					};
					~callback.value(current...etc..."
		var tempo = nil
		var server = localhost
		var eventTypes = ( 'fadeBus': a Function, 'freeAllocWrite': a Function, 'tree': a Function, 'vst_set': a Function, 
  'on': a Function, 'vsti': a Function, 'load': a Function, 'freeBuffer': a Function, 'group': a Function, 
  'reedy': a Function, 'freeAllocRead': a Function, 'allocWrite': a Function, 'cue': a Function, 'grain': a Function, 
  'Synth': a Function, 'vst_midi': a Function, 'freeAllocWriteID': a Function, 'alloc': a Function, 'rest': a Function, 
  'sine2': a Function, 'sine1': a Function, 'midi': a Function, '...etc...
		var parentType = nil
	a FunctionDef	0x7fd25940d7c0
		sourceCode = "<an open Function>"
	Function:prTry	0x7fd257f0cb00
		arg this = a Function
		var result = nil
		var thread = a Thread
		var next = nil
		var wasInProtectedFunc = false
	
CALL STACK:
	DoesNotUnderstandError:reportError
		arg this = <instance of DoesNotUnderstandError>
	Nil:handleError
		arg this = nil
		arg error = <instance of DoesNotUnderstandError>
	Thread:handleError
		arg this = <instance of Thread>
		arg error = <instance of DoesNotUnderstandError>
	Object:throw
		arg this = <instance of DoesNotUnderstandError>
	Function:protect
		arg this = <instance of Function>
		arg handler = <instance of Function>
		var result = <instance of DoesNotUnderstandError>
	Environment:use
		arg this = <instance of Event>
		arg function = <instance of Function>
		var result = nil
		var saveEnvir = <instance of Environment>
	Event:play
		arg this = <instance of Event>
	Interpreter:interpretPrintCmdLine
		arg this = <instance of Interpreter>
		var res = nil
		var func = <instance of Function>
		var code = "(type:\tuningGong,floor:300,..."
		var doc = <instance of Document>
		var ideClass = nil
	Process:interpretPrintCmdLine
		arg this = <instance of Main>
^^ The preceding error dump is for ERROR: Message 'asTarget' not understood.
RECEIVER: a Function
-> nil
-> Group(1001)
ERROR: Non Boolean in test.
RECEIVER:
Instance of BinaryOpFunction {    (0x7fd2211a4888, gc=B4, fmt=00, flg=00, set=02)
  instance variables [4]
    selector : Symbol '<'
    a : instance of BinaryOpFunction (0x7fd2211a4968, size=4, set=2)
    b : nil
    adverb : nil
}
PATH: /Users/michael/tank/super/Library/synthdefs/reedy.scd
PROTECTED CALL STACK:
	Meta_MethodError:new	0x7fd257b43ac0
		arg this = MustBeBooleanError
		arg what = nil
		arg receiver = a BinaryOpFunction
	Object:mustBeBoolean	0x7fd255f7f640
		arg this = a BinaryOpFunction
	a FunctionDef	0x7fd24701df38
		sourceCode = "<an open Function>"
		arg i = 7427
	a FunctionDef	0x7fd2591b5300
		sourceCode = "<an open Function>"
		arg elem = 7427
		arg i = 0
	ArrayedCollection:do	0x7fd259205200
		arg this = [ 7427, 16626, 18871, 12100, 5224, 14469, 433, 12794, 15888, 10195, 11481, 3708, 5660, 18957, 2143, 18960, 10543, 14727, 12899, 14550, 12062, 16937, 4533, 3744, 15013, 3084, 2923, 3109, 1691, 8665, 11857, 1712, 15328, 4170, 2583, 4314, 11126, 15957, 13230, 4262, 727, 4253, 18921, 7403, 7462, 2817, 15410, 10960, 9899, 2418, 17945, 17187, 16757, 12097, 2438, 5019, 4408, 4713, 1845, 8639, 6782, 3002, 17803, 16149, 18926, 11365, 8522, 4428, 12003, 11749, 11764, 3961, 10435, 7137, 5183, 15800, 15714, 544, 12529,...etc...
		arg function = a Function
		var i = 0
	Collection:collectAs	0x7fd2591b4f40
		arg this = [ 7427, 16626, 18871, 12100, 5224, 14469, 433, 12794, 15888, 10195, 11481, 3708, 5660, 18957, 2143, 18960, 10543, 14727, 12899, 14550, 12062, 16937, 4533, 3744, 15013, 3084, 2923, 3109, 1691, 8665, 11857, 1712, 15328, 4170, 2583, 4314, 11126, 15957, 13230, 4262, 727, 4253, 18921, 7403, 7462, 2817, 15410, 10960, 9899, 2418, 17945, 17187, 16757, 12097, 2438, 5019, 4408, 4713, 1845, 8639, 6782, 3002, 17803, 16149, 18926, 11365, 8522, 4428, 12003, 11749, 11764, 3961, 10435, 7137, 5183, 15800, 15714, 544, 12529,...etc...
		arg function = a Function
		arg class = Array
		var res = [  ]
	a FunctionDef	0x7fd246d3e388
		sourceCode = "<an open Function>"
		var even = [ 7427, 16626, 18871, 12100, 5224, 14469, 433, 12794, 15888, 10195, 11481, 3708, 5660, 18957, 2143, 18960, 10543, 14727, 12899, 14550, 12062, 16937, 4533, 3744, 15013, 3084, 2923, 3109, 1691, 8665, 11857, 1712, 15328, 4170, 2583, 4314, 11126, 15957, 13230, 4262, 727, 4253, 18921, 7403, 7462, 2817, 15410, 10960, 9899, 2418, 17945, 17187, 16757, 12097, 2438, 5019, 4408, 4713, 1845, 8639, 6782, 3002, 17803, 16149, 18926, 11365, 8522, 4428, 12003, 11749, 11764, 3961, 10435, 7137, 5183, 15800, 15714, 544, 12529,...etc...
		var near = a Function
		var nearHarmonic = a Function
		var blend = nil
	SynthDef:buildUgenGraph	0x7fd259f562c0
		arg this = a SynthDef
		arg func = a Function
		arg rates = nil
		arg prependArgs = [  ]
		var result = nil
		var saveControlNames = [ ControlName  P 0 i_out scalar 0 ]
	a FunctionDef	0x7fd258e255c0
		sourceCode = "<an open Function>"
		arg i_out = an OutputProxy
		var result = nil
		var rate = nil
		var env = nil
	SynthDef:buildUgenGraph	0x7fd259f562c0
		arg this = a SynthDef
		arg func = a Function
		arg rates = nil
		arg prependArgs = [  ]
		var result = nil
		var saveControlNames = nil
	a FunctionDef	0x7fd259f546c0
		sourceCode = "<an open Function>"
	Function:prTry	0x7fd257f0cb00
		arg this = a Function
		var result = nil
		var thread = a Thread
		var next = a Function
		var wasInProtectedFunc = true
	Function:protect	0x7fd257f0c080
		arg this = a Function
		arg handler = a Function
		var result = nil
	SynthDef:build	0x7fd259f54540
		arg this = a SynthDef
		arg ugenGraphFunc = a Function
		arg rates = nil
		arg prependArgs = nil
	Function:play	0x7fd25a223ac0
		arg this = a Function
		arg target = Group(1001)
		arg outbus = 0
		arg fadeTime = 0.02
		arg addAction = addToHead
		arg args = nil
		var def = nil
		var synth = nil
		var server = localhost
		var bytes = nil
		var synthMsg = nil
	a FunctionDef	0x7fd25940d7c0
		sourceCode = "<an open Function>"
	Function:prTry	0x7fd257f0cb00
		arg this = a Function
		var result = nil
		var thread = a Thread
		var next = a Function
		var wasInProtectedFunc = true
	Function:protect	0x7fd257f0c080
		arg this = a Function
		arg handler = a Function
		var result = nil
	Environment:use	0x7fd25940d340
		arg this = Environment[ (synful2 -> a Function), (moveNumberBuffersToRemote -> a Function), (setBusIR -> a Function), (concatSongs -> a Function), (remote -> a Function), 
  (playNumbersAtOnce -> a Function), (prepAlexa -> a Function), (recorder -> a Function), (hack -> a Function), (vsti -> a Function), 
  (gong -> a Function), (makeNodes -> a Function), (myFree -> a Function), (trek -> ( 'dursFile': /Users/michael/tank/super/theExtreme3, 'save': a Function )), (noteList -> a Function), 
  (numberBuffers -> [ nil, ni...etc...
		arg function = a Function
		var result = nil
		var saveEnvir = ( 'floor': 300, 'server': localhost, 'group': Group(1001), 'type': tuningGong )
	a FunctionDef	0x7fd259448000
		sourceCode = "#{
					var tempo, server, eventTypes, parentType;
					parentType = ~parentTypes[~type];
					parentType !? { currentEnvironment.parent = parentType };
					server = ~server = ~server ? Server.default;
					~finish.value(currentEnvironment);
					tempo = ~tempo;
					tempo !? { thisThread.clock.tempo = tempo };
					if(currentEnvironment.isRest.not) {
						eventTypes = ~eventTypes;
						(eventTypes[~type] ?? { eventTypes[\\note] }).value(server)
					};
					~callback.value(current...etc..."
		var tempo = nil
		var server = localhost
		var eventTypes = ( 'fadeBus': a Function, 'freeAllocWrite': a Function, 'tree': a Function, 'vst_set': a Function, 
  'on': a Function, 'vsti': a Function, 'load': a Function, 'freeBuffer': a Function, 'group': a Function, 
  'reedy': a Function, 'freeAllocRead': a Function, 'allocWrite': a Function, 'cue': a Function, 'grain': a Function, 
  'Synth': a Function, 'vst_midi': a Function, 'freeAllocWriteID': a Function, 'alloc': a Function, 'rest': a Function, 
  'sine2': a Function, 'sine1': a Function, 'midi': a Function, '...etc...
		var parentType = nil
	a FunctionDef	0x7fd25940d7c0
		sourceCode = "<an open Function>"
	Function:prTry	0x7fd257f0cb00
		arg this = a Function
		var result = nil
		var thread = a Thread
		var next = nil
		var wasInProtectedFunc = false
	
CALL STACK:
	MethodError:reportError
		arg this = <instance of MustBeBooleanError>
	Nil:handleError
		arg this = nil
		arg error = <instance of MustBeBooleanError>
	Thread:handleError
		arg this = <instance of Thread>
		arg error = <instance of MustBeBooleanError>
	Object:throw
		arg this = <instance of MustBeBooleanError>
	Function:protect
		arg this = <instance of Function>
		arg handler = <instance of Function>
		var result = <instance of MustBeBooleanError>
	Environment:use
		arg this = <instance of Event>
		arg function = <instance of Function>
		var result = nil
		var saveEnvir = <instance of Environment>
	Event:play
		arg this = <instance of Event>
	Interpreter:interpretPrintCmdLine
		arg this = <instance of Interpreter>
		var res = nil
		var func = <instance of Function>
		var code = "(type:\tuningGong,floor:300,..."
		var doc = <instance of Document>
		var ideClass = nil
	Process:interpretPrintCmdLine
		arg this = <instance of Main>
^^ The preceding error dump is for ERROR: Non Boolean in test.
RECEIVER: a BinaryOpFunction
WARNING: SynthDef temp__1 too big for sending. Retrying via synthdef file
-> Synth('temp__1' : 1002)
-> Event
[ a Function, Group(1001), nil, 300 ]
ERROR: Non Boolean in test.
RECEIVER:
Instance of BinaryOpFunction {    (0x7fd221121458, gc=CC, fmt=00, flg=00, set=02)
  instance variables [4]
    selector : Symbol '<'
    a : instance of BinaryOpFunction (0x7fd221121308, size=4, set=2)
    b : nil
    adverb : nil
}
PATH: /Users/michael/tank/super/Library/synthdefs/reedy.scd
PROTECTED CALL STACK:
	Meta_MethodError:new	0x7fd257b43ac0
		arg this = MustBeBooleanError
		arg what = nil
		arg receiver = a BinaryOpFunction
	Object:mustBeBoolean	0x7fd255f7f640
		arg this = a BinaryOpFunction
	a FunctionDef	0x7fd2460a9f88
		sourceCode = "<an open Function>"
		arg i = 1198
	a FunctionDef	0x7fd2591b5300
		sourceCode = "<an open Function>"
		arg elem = 1198
		arg i = 0
	ArrayedCollection:do	0x7fd259205200
		arg this = [ 1198, 10079, 15992, 1683, 4544, 16181, 4943, 6170, 16817, 6371, 16772, 19579, 2901, 734, 8785, 8600, 11572, 6533, 5585, 19276, 8501, 6186, 6120, 8855, 8167, 13815, 1090, 3575, 7174, 13270, 16162, 15528, 14342, 3447, 18660, 9930, 3488, 6995, 11806, 3777, 360, 19140, 2934, 15127, 2981, 7991, 15572, 19868, 8602, 15881, 11351, 19067, 7219, 9036, 15655, 6540, 4664, 6514, 6854, 2561, 10900, 7192, 8861, 10434, 14132, 19457, 14177, 9775, 14352, 5714, 11090, 7308, 5335, 12246, 15329, 3090, 12281, 11431, 2478, 7206...etc...
		arg function = a Function
		var i = 0
	Collection:collectAs	0x7fd2591b4f40
		arg this = [ 1198, 10079, 15992, 1683, 4544, 16181, 4943, 6170, 16817, 6371, 16772, 19579, 2901, 734, 8785, 8600, 11572, 6533, 5585, 19276, 8501, 6186, 6120, 8855, 8167, 13815, 1090, 3575, 7174, 13270, 16162, 15528, 14342, 3447, 18660, 9930, 3488, 6995, 11806, 3777, 360, 19140, 2934, 15127, 2981, 7991, 15572, 19868, 8602, 15881, 11351, 19067, 7219, 9036, 15655, 6540, 4664, 6514, 6854, 2561, 10900, 7192, 8861, 10434, 14132, 19457, 14177, 9775, 14352, 5714, 11090, 7308, 5335, 12246, 15329, 3090, 12281, 11431, 2478, 7206...etc...
		arg function = a Function
		arg class = Array
		var res = [  ]
	a FunctionDef	0x7fd2461927d8
		sourceCode = "<an open Function>"
		var even = [ 1198, 10079, 15992, 1683, 4544, 16181, 4943, 6170, 16817, 6371, 16772, 19579, 2901, 734, 8785, 8600, 11572, 6533, 5585, 19276, 8501, 6186, 6120, 8855, 8167, 13815, 1090, 3575, 7174, 13270, 16162, 15528, 14342, 3447, 18660, 9930, 3488, 6995, 11806, 3777, 360, 19140, 2934, 15127, 2981, 7991, 15572, 19868, 8602, 15881, 11351, 19067, 7219, 9036, 15655, 6540, 4664, 6514, 6854, 2561, 10900, 7192, 8861, 10434, 14132, 19457, 14177, 9775, 14352, 5714, 11090, 7308, 5335, 12246, 15329, 3090, 12281, 11431, 2478, 7206...etc...
		var near = a Function
		var nearHarmonic = a Function
		var blend = nil
	SynthDef:buildUgenGraph	0x7fd259f562c0
		arg this = a SynthDef
		arg func = a Function
		arg rates = nil
		arg prependArgs = [  ]
		var result = nil
		var saveControlNames = [ ControlName  P 0 i_out scalar 0 ]
	a FunctionDef	0x7fd258e255c0
		sourceCode = "<an open Function>"
		arg i_out = an OutputProxy
		var result = nil
		var rate = nil
		var env = nil
	SynthDef:buildUgenGraph	0x7fd259f562c0
		arg this = a SynthDef
		arg func = a Function
		arg rates = nil
		arg prependArgs = [  ]
		var result = nil
		var saveControlNames = nil
	a FunctionDef	0x7fd259f546c0
		sourceCode = "<an open Function>"
	Function:prTry	0x7fd257f0cb00
		arg this = a Function
		var result = nil
		var thread = a Thread
		var next = a Function
		var wasInProtectedFunc = true
	Function:protect	0x7fd257f0c080
		arg this = a Function
		arg handler = a Function
		var result = nil
	SynthDef:build	0x7fd259f54540
		arg this = a SynthDef
		arg ugenGraphFunc = a Function
		arg rates = nil
		arg prependArgs = nil
	Function:play	0x7fd25a223ac0
		arg this = a Function
		arg target = Group(1001)
		arg outbus = 0
		arg fadeTime = 0.02
		arg addAction = addToHead
		arg args = nil
		var def = nil
		var synth = nil
		var server = localhost
		var bytes = nil
		var synthMsg = nil
	a FunctionDef	0x7fd25940d7c0
		sourceCode = "<an open Function>"
	Function:prTry	0x7fd257f0cb00
		arg this = a Function
		var result = nil
		var thread = a Thread
		var next = a Function
		var wasInProtectedFunc = true
	Function:protect	0x7fd257f0c080
		arg this = a Function
		arg handler = a Function
		var result = nil
	Environment:use	0x7fd25940d340
		arg this = Environment[ (synful2 -> a Function), (moveNumberBuffersToRemote -> a Function), (setBusIR -> a Function), (concatSongs -> a Function), (remote -> a Function), 
  (playNumbersAtOnce -> a Function), (prepAlexa -> a Function), (recorder -> a Function), (hack -> a Function), (vsti -> a Function), 
  (gong -> a Function), (makeNodes -> a Function), (myFree -> a Function), (trek -> ( 'dursFile': /Users/michael/tank/super/theExtreme3, 'save': a Function )), (noteList -> a Function), 
  (numberBuffers -> [ nil, ni...etc...
		arg function = a Function
		var result = nil
		var saveEnvir = ( 'floor': 300, 'server': localhost, 'group': Group(1001), 'type': tuningGong )
	a FunctionDef	0x7fd259448000
		sourceCode = "#{
					var tempo, server, eventTypes, parentType;
					parentType = ~parentTypes[~type];
					parentType !? { currentEnvironment.parent = parentType };
					server = ~server = ~server ? Server.default;
					~finish.value(currentEnvironment);
					tempo = ~tempo;
					tempo !? { thisThread.clock.tempo = tempo };
					if(currentEnvironment.isRest.not) {
						eventTypes = ~eventTypes;
						(eventTypes[~type] ?? { eventTypes[\\note] }).value(server)
					};
					~callback.value(current...etc..."
		var tempo = nil
		var server = localhost
		var eventTypes = ( 'fadeBus': a Function, 'freeAllocWrite': a Function, 'tree': a Function, 'vst_set': a Function, 
  'on': a Function, 'vsti': a Function, 'load': a Function, 'freeBuffer': a Function, 'group': a Function, 
  'reedy': a Function, 'freeAllocRead': a Function, 'allocWrite': a Function, 'cue': a Function, 'grain': a Function, 
  'Synth': a Function, 'vst_midi': a Function, 'freeAllocWriteID': a Function, 'alloc': a Function, 'rest': a Function, 
  'sine2': a Function, 'sine1': a Function, 'midi': a Function, '...etc...
		var parentType = nil
	a FunctionDef	0x7fd25940d7c0
		sourceCode = "<an open Function>"
	Function:prTry	0x7fd257f0cb00
		arg this = a Function
		var result = nil
		var thread = a Thread
		var next = nil
		var wasInProtectedFunc = false
	
CALL STACK:
	MethodError:reportError
		arg this = <instance of MustBeBooleanError>
	Nil:handleError
		arg this = nil
		arg error = <instance of MustBeBooleanError>
	Thread:handleError
		arg this = <instance of Thread>
		arg error = <instance of MustBeBooleanError>
	Object:throw
		arg this = <instance of MustBeBooleanError>
	Function:protect
		arg this = <instance of Function>
		arg handler = <instance of Function>
		var result = <instance of MustBeBooleanError>
	Environment:use
		arg this = <instance of Event>
		arg function = <instance of Function>
		var result = nil
		var saveEnvir = <instance of Environment>
	Event:play
		arg this = <instance of Event>
	Interpreter:interpretPrintCmdLine
		arg this = <instance of Interpreter>
		var res = nil
		var func = <instance of Function>
		var code = "(type:\tuningGong,floor:300,..."
		var doc = <instance of Document>
		var ideClass = nil
	Process:interpretPrintCmdLine
		arg this = <instance of Main>
^^ The preceding error dump is for ERROR: Non Boolean in test.
RECEIVER: a BinaryOpFunction
[ a Function, Group(1001), nil, nil ]
ERROR: Message 'rrand' not understood.
RECEIVER:
   nil
ARGS:
   Integer 20000
PATH: /Users/michael/tank/super/Library/synthdefs/reedy.scd
PROTECTED CALL STACK:
	Meta_MethodError:new	0x7fd257b43ac0
		arg this = DoesNotUnderstandError
		arg what = nil
		arg receiver = nil
	Meta_DoesNotUnderstandError:new	0x7fd257b45a80
		arg this = DoesNotUnderstandError
		arg receiver = nil
		arg selector = rrand
		arg args = [ 20000 ]
	Object:doesNotUnderstand	0x7fd255f7dfc0
		arg this = nil
		arg selector = rrand
		arg args = nil
	Meta_SequenceableCollection:rand	0x7fd2591f0a80
		arg this = Array
		arg size = 100
		arg minVal = nil
		arg maxVal = 20000
		var i = 0
		var obj = [  ]
	a FunctionDef	0x7fd2461927d8
		sourceCode = "<an open Function>"
		var even = nil
		var near = nil
		var nearHarmonic = nil
		var blend = nil
	SynthDef:buildUgenGraph	0x7fd259f562c0
		arg this = a SynthDef
		arg func = a Function
		arg rates = nil
		arg prependArgs = [  ]
		var result = nil
		var saveControlNames = [ ControlName  P 0 i_out scalar 0 ]
	a FunctionDef	0x7fd258e255c0
		sourceCode = "<an open Function>"
		arg i_out = an OutputProxy
		var result = nil
		var rate = nil
		var env = nil
	SynthDef:buildUgenGraph	0x7fd259f562c0
		arg this = a SynthDef
		arg func = a Function
		arg rates = nil
		arg prependArgs = [  ]
		var result = nil
		var saveControlNames = nil
	a FunctionDef	0x7fd259f546c0
		sourceCode = "<an open Function>"
	Function:prTry	0x7fd257f0cb00
		arg this = a Function
		var result = nil
		var thread = a Thread
		var next = a Function
		var wasInProtectedFunc = true
	Function:protect	0x7fd257f0c080
		arg this = a Function
		arg handler = a Function
		var result = nil
	SynthDef:build	0x7fd259f54540
		arg this = a SynthDef
		arg ugenGraphFunc = a Function
		arg rates = nil
		arg prependArgs = nil
	Function:play	0x7fd25a223ac0
		arg this = a Function
		arg target = Group(1001)
		arg outbus = 0
		arg fadeTime = 0.02
		arg addAction = addToHead
		arg args = nil
		var def = nil
		var synth = nil
		var server = localhost
		var bytes = nil
		var synthMsg = nil
	a FunctionDef	0x7fd25940d7c0
		sourceCode = "<an open Function>"
	Function:prTry	0x7fd257f0cb00
		arg this = a Function
		var result = nil
		var thread = a Thread
		var next = a Function
		var wasInProtectedFunc = true
	Function:protect	0x7fd257f0c080
		arg this = a Function
		arg handler = a Function
		var result = nil
	Environment:use	0x7fd25940d340
		arg this = Environment[ (synful2 -> a Function), (moveNumberBuffersToRemote -> a Function), (setBusIR -> a Function), (concatSongs -> a Function), (remote -> a Function), 
  (playNumbersAtOnce -> a Function), (prepAlexa -> a Function), (recorder -> a Function), (hack -> a Function), (vsti -> a Function), 
  (gong -> a Function), (makeNodes -> a Function), (myFree -> a Function), (trek -> ( 'dursFile': /Users/michael/tank/super/theExtreme3, 'save': a Function )), (noteList -> a Function), 
  (numberBuffers -> [ nil, ni...etc...
		arg function = a Function
		var result = nil
		var saveEnvir = ( 'group': Group(1001), 'type': tuningGong, 'server': localhost )
	a FunctionDef	0x7fd259448000
		sourceCode = "#{
					var tempo, server, eventTypes, parentType;
					parentType = ~parentTypes[~type];
					parentType !? { currentEnvironment.parent = parentType };
					server = ~server = ~server ? Server.default;
					~finish.value(currentEnvironment);
					tempo = ~tempo;
					tempo !? { thisThread.clock.tempo = tempo };
					if(currentEnvironment.isRest.not) {
						eventTypes = ~eventTypes;
						(eventTypes[~type] ?? { eventTypes[\\note] }).value(server)
					};
					~callback.value(current...etc..."
		var tempo = nil
		var server = localhost
		var eventTypes = ( 'fadeBus': a Function, 'freeAllocWrite': a Function, 'tree': a Function, 'vst_set': a Function, 
  'on': a Function, 'vsti': a Function, 'load': a Function, 'freeBuffer': a Function, 'group': a Function, 
  'reedy': a Function, 'freeAllocRead': a Function, 'allocWrite': a Function, 'cue': a Function, 'grain': a Function, 
  'Synth': a Function, 'vst_midi': a Function, 'freeAllocWriteID': a Function, 'alloc': a Function, 'rest': a Function, 
  'sine2': a Function, 'sine1': a Function, 'midi': a Function, '...etc...
		var parentType = nil
	a FunctionDef	0x7fd25940d7c0
		sourceCode = "<an open Function>"
	Function:prTry	0x7fd257f0cb00
		arg this = a Function
		var result = nil
		var thread = a Thread
		var next = nil
		var wasInProtectedFunc = false
	
CALL STACK:
	DoesNotUnderstandError:reportError
		arg this = <instance of DoesNotUnderstandError>
	Nil:handleError
		arg this = nil
		arg error = <instance of DoesNotUnderstandError>
	Thread:handleError
		arg this = <instance of Thread>
		arg error = <instance of DoesNotUnderstandError>
	Object:throw
		arg this = <instance of DoesNotUnderstandError>
	Function:protect
		arg this = <instance of Function>
		arg handler = <instance of Function>
		var result = <instance of DoesNotUnderstandError>
	Environment:use
		arg this = <instance of Event>
		arg function = <instance of Function>
		var result = nil
		var saveEnvir = <instance of Environment>
	Event:play
		arg this = <instance of Event>
	Interpreter:interpretPrintCmdLine
		arg this = <instance of Interpreter>
		var res = nil
		var func = <instance of Function>
		var code = "(type:\tuningGong,group:g).play"
		var doc = <instance of Document>
		var ideClass = nil
	Process:interpretPrintCmdLine
		arg this = <instance of Main>
^^ The preceding error dump is for ERROR: Message 'rrand' not understood.
RECEIVER: nil
compiling class library...
	Found 850 primitives.
	Compiling directory '/Applications/SuperCollider.app/Contents/Resources/SCClassLibrary'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/Extensions'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/Automation'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/JITLibExtensions'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/Vowel'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/panola'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/Freesound'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/FreeAfter'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/wslib'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/SynthDefPool'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/say'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/MathLib'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/VectorSpace'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/Unit-Lib'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/BatLib'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/SpeakersCorner'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/AmbIEM'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/AllGui'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/FileLog'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/Hilbert'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/XML'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/atk-sc3'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/Ctk'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/ixiViews'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/SFPlayer'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/ScoreClock'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/ZArchive'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/KDTree'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/Modality-toolkit'
	Compiling directory '/Users/michael/Library/Application Support/SuperCollider/downloaded-quarks/FPLib'
	Compiling directory '/Users/michael/.local/share/SuperCollider/downloaded-quarks/autogui'
	Compiling directory '/Users/michael/.local/share/SuperCollider/downloaded-quarks/Scintillator'
	numentries = 2880081 / 70350680 = 0.041
	12653 method selectors, 5560 classes
	method table size 59792920 bytes, big table size 562805440
	Number of Symbols 30706
	Byte Code Size 1398884
	compiled 1332 files in 2.29 seconds
Info: 21 methods are currently overwritten by extensions. To see which, execute:
MethodOverride.printAll
compile done
localhost : setting clientID to 0.
internal : setting clientID to 0.
WARNING: Called from Meta_GlobalPathDict:initClass, method Meta_String:scDir is deprecated and will be removed. Use Meta_Platform:resourceDir instead.
The definition of 'Meta_String:scDir' is to be found here: '/Applications/SuperCollider.app/Contents/Resources/SCClassLibrary/deprecated/3.11/deprecated-3.11.sc'
2020-12-02 11:28:07.570 defaults[36768:3198035] 
The domain/default pair of (com.apple.speech.voice.prefs, SelectedVoiceName) does not exist
Class tree inited in 0.39 seconds
WARNING: server 'localhost' not running.
/Users/michael/tank/super/Library/functions/Schafer.scd
ERROR: syntax error, unexpected CLASSNAME, expecting $end
  in interpreted text
  line 1 char 15:
  let SessionLoad = 1
      ^^^^^^^^^^^
  let s:so_save = &so | let s:siso_save = &siso | set so=0 siso=0
-----------------------------------
ERROR: Command line parse failed
/Users/michael/tank/super/Library/functions/Session.vim
Startup File Loaded
/Users/michael/tank/super/Library/functions/clicktrack.scd
/Users/michael/tank/super/Library/functions/convo.scd
/Users/michael/tank/super/Library/functions/load.scd
/Users/michael/tank/super/Library/functions/prep.scd
WARNING: Called from Function:prTry, method Object:asInt is deprecated and will be removed.
The definition of 'Object:asInt' is to be found here: '/Applications/SuperCollider.app/Contents/Resources/SCClassLibrary/deprecated/3.11/deprecated-3.11.sc'
PATH: /Users/michael/tank/super/Library/functions/server-options.scd
/Users/michael/tank/super/Library/functions/server-options.scd
server 'localhost' already booting
/Users/michael/tank/super/Library/functions/trek.scd
ERROR: syntax error, unexpected CLASSNAME, expecting $end
  in interpreted text
  line 1 char 15:
  let SessionLoad = 1
      ^^^^^^^^^^^
  let s:so_save = &so | let s:siso_save = &siso | set so=0 siso=0
-----------------------------------
ERROR: Command line parse failed
/Users/michael/tank/super/Library/synthdefs/Session.vim
/Users/michael/tank/super/Library/synthdefs/clk.scd
/Users/michael/tank/super/Library/synthdefs/pianoteq.scd
ERROR: syntax error, unexpected '(', expecting $end
  in interpreted text
  line 56 char 1:
  ( //tune up sound - sounds good with gongs...
  ^
  ~tuneUp = { |freq=150 amp=0.2 out=0|
-----------------------------------
ERROR: Command line parse failed
/Users/michael/tank/super/Library/synthdefs/reedy.scd
/Users/michael/tank/super/Library/synthdefs/synful.scd
/Users/michael/tank/super/Library/synthdefs/synful2.scd
ERROR: syntax error, unexpected NAME, expecting $end
  in interpreted text
  line 69 char 9:
  compiling class library...
  ^^^^^^^^^
  	Found 850 primitives.
-----------------------------------
ERROR: Command line parse failed
/Users/michael/tank/super/Library/synthdefs/synful3.scd
functions: 
	prep: 	a Function
	prepStereo: 	a Function
	clicktrack: 	a Function
	reverb: 
		true_stereo: 	a Function
		mono: 	a Function
		single_stereo: 	a Function
synthdefs: 
	clk: 	a SynthDef
Ctk init class runs
Cleaning up 345 temporary SynthDefs...
WARNING: Called from Meta_BarMap:formatEvent, method Object:asInt is deprecated and will be removed.
The definition of 'Object:asInt' is to be found here: '/Applications/SuperCollider.app/Contents/Resources/SCClassLibrary/deprecated/3.11/deprecated-3.11.sc'
WARNING: Extension in '/Users/michael/.local/share/SuperCollider/downloaded-quarks/autogui/Classes/synthDefStorageExt.sc' overwrites SynthDef:build in main class library.
WARNING: Extension in '/Users/michael/.local/share/SuperCollider/downloaded-quarks/autogui/Classes/ArrayWarp.sc' overwrites ControlSpec:constrain in main class library.
WARNING: Extension in '/Users/michael/.local/share/SuperCollider/downloaded-quarks/autogui/Classes/ArrayWarp.sc' overwrites ControlSpec:map in main class library.
Intentional overwrites must be put in a 'SystemOverwrites' subfolder.
*** Welcome to SuperCollider 3.11.1. *** For help type cmd-d.
MIDI Sources:
	MIDIEndPoint("IAC Driver", "Bus 1", 1222620153)
	MIDIEndPoint("IAC Driver", "IAC Bus 2", 5356331)
	MIDIEndPoint("IAC Driver", "IAC Bus 3", -649347929)
	MIDIEndPoint("IAC Driver", "IAC Bus 4", 719229864)
	MIDIEndPoint("CASIO USB-MIDI", "CASIO USB-MIDI", 602392681)
	MIDIEndPoint("X-Touch", "INT", 1779843049)
	MIDIEndPoint("X-Touch", "EXT", -181842512)
	MIDIEndPoint("RME ARC", "RME ARC", 335163963)
	MIDIEndPoint("ipMIDI", "Port 1", -1157686251)
MIDI Destinations:
	MIDIEndPoint("IAC Driver", "Bus 1", -1513577802)
	MIDIEndPoint("IAC Driver", "IAC Bus 2", -723420066)
	MIDIEndPoint("IAC Driver", "IAC Bus 3", -715708506)
	MIDIEndPoint("IAC Driver", "IAC Bus 4", 1256206411)
	MIDIEndPoint(
	MIDIEndPoint("IAC Driver", "Bus 1", 1222620153)
	MIDIEndPoint("IAC Driver", "IAC Bus 2", 5356331)
	MIDIEndPoint("IAC Driver", "IAC Bus 3", -649347929)
	MIDIEndPoint("IAC Driver", "IAC Bus 4", 719229864)
	MIDIEndPoint("CASIO USB-MIDI", "CASIO USB-MIDI", 602392681)
	MIDIEndPoint("X-Touch", "INT", 1779843049)
	MIDIEndPoint("X-Touch", "EXT", -181842512)
	MIDIEndPoint("RME ARC", "RME ARC", 335163963)
	MIDIEndPoint("ipMIDI", "Port 1", -1157686251)
MIDI Destinations:
	MIDIEndPoint("IAC Driver", "Bus 1", -1513577802)
	MIDIEndPoint("IAC Driver", "IAC Bus 2", -723420066)
	MIDIEndPoint("IAC Driver", "IAC Bus 3", -715708506)
	MIDIEndPoint("IAC Driver", "IAC Bus 4", 1256206411)
	MIDIEndPoint("CASIO USB-MIDI", "CASIO USB-MIDI", 1981760746)
	MIDIEndPoint("X-Touch", "INT", -1972777358)
	MIDIEndPoint("X-Touch", "EXT", -922613860)
	MIDIEndPoint("RME ARC", "RME ARC", -1510553930)
	MIDIEndPoint("ipMIDI", "Port 1", -1157686271)
Booting server 'localhost' on address 127.0.0.1:57110.
ERROR: API version mismatch: /Users/michael/Library/Application Support/SuperCollider/Extensions/KBVerb/untitled folder/FaustKBVerb.scx
    This plugin is not compatible with SuperCollider >=3.9.0
    The plugin has not been loaded; please find or compile a newer version.
    (Plugin's API version: 2. Expected: 3)
ERROR: API version mismatch: /Users/michael/Library/Application Support/SuperCollider/Extensions/KBVerb/untitled folder/KBVerb.scx
    This plugin is not compatible with SuperCollider >=3.9.0
    The plugin has not been loaded; please find or compile a newer version.
    (Plugin's API version: 2. Expected: 3)
VSTPlugin 0.4.1
objc[36916]: Class CocoaEditorWindow is implemented in both /Users/michael/Library/Application Support/SuperCollider/Extensions/VSTPlugin/plugins/VSTPlugin.scx (0x112455570) and /Users/michael/Library/Application Support/SuperCollider/Extensions/VSTPlugin/plugins/VSTPlugin_supernova.scx (0x1124ef570). One of the two will be used. Which one is undefined.
objc[36916]: Class EventLoopProxy is implemented in both /Users/michael/Library/Application Support/SuperCollider/Extensions/VSTPlugin/plugins/VSTPlugin.scx (0x112455598) and /Users/michael/Library/Application Support/SuperCollider/Extensions/VSTPlugin/plugins/VSTPlugin_supernova.scx (0x1124ef598). One of the two will be used. Which one is undefined.
Found 0 LADSPA plugins
Number of Devices: 6
   0 : "Built-in Output"
   1 : "HDMI"
   2 : "Unknown USB Audio Device"
   3 : "Merging RA"
   4 : "Premiere Pro 6.0"
   5 : "Digiface USB (23953833)"
"Digiface USB (23953833)" Input Device
   Streams: 4
      0  channels 8
      1  channels 8
      2  channels 8
      3  channels 8
"Digiface USB (23953833)" Output Device
   Streams: 5
      0  channels 8
      1  channels 8
      2  channels 8
      3  channels 8
      4  channels 2
SC_AudioDriver: sample rate = 48000.000000, driver's block size = 512
SuperCollider 3 server ready.
Requested notification messages from server 'localhost'
localhost: server process's maxLogins (1) matches with my options.
localhost: keeping clientID (0) as confirmed by server process.
Shared memory server interface initialized
StageLimiter active
