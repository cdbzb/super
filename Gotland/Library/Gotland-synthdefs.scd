
	SynthDef(\triangle,{ |freq len=300 vol=0.005 pan=0.5 bus=0|
		var env=EnvGen.kr(Env.triangle(len));
		var sig = SinOsc.ar(freq,0,env*vol);
		Out.ar(bus,Pan2.ar(sig,pan));
	},[1136,0,16]).add; //long lags


~cloudchord={|array amp=0.5| var notes=Array.newClear(array.size); array.do({|item index| notes[index]=Synth.new(\cloud,[\fr,item,\amp,amp])}); notes};
~tri={|freq len=300 vol=0.005 pan=0.5 bus=0| Synth.new(\triangle,[\freq,freq,\vol, vol,\len,len,\pan,pan,\bus,bus])};

~chords=[[440,500,400,564,604]];
~chord=[440,500,400,564,604];

~playme={ |chord=#[360,460,520,660] len=300 pause=25 vol=1|
	var notes=Array.newClear(chord.size);
	Routine.new({ 
		chord.do({|item index| 
			index.postln;notes[index].postln;
			notes[index]=~tri.(item,len);
			pause.wait;
		});
	}).play;
	notes;
};
 
~fibs={|num|
	var fibs=Array.newClear(num);
	var neww=3,old=2;
	fibs.do({|item index| fibs[index]=old;old=neww;neww=neww+fibs[index]});
	fibs;
};

	SynthDef(\fibs, { arg fr=100, amp=1, num=8, bus=1; var out;  
		fr = Lag.kr(fr,60);
		Out.ar(bus,{
			Mix.arFill(8, //number of harmonics
			    { arg x  ; var sig, frq;
				frq=fr;
				x=~fibs.(20).at(x);
				sig = FSinOsc.ar( frq*x ,0,0.01 * LFNoise1.kr(18*LFNoise1.kr)).distort;
				sig = Pan2.ar(sig, LFNoise1.kr(1));
				sig= sig * EnvGen.kr(Env.linen(6,2,99),doneAction: 2);
				sig*amp;
			})
		})}).add;
	
//original demo idea
	SynthDef(\cloud, { arg fr=100, amp=1; var out;  
		fr = Lag.kr(fr,60);
		Out.ar(0,{
			Mix.arFill(20, //number of harmonics
			    { arg x  ; var sig, frq;
				frq=fr;
				//sig = FSinOsc.ar( frq*x ,0,0.01/(x+1) * LFNoise1.kr(18*LFNoise1.kr));//.distort;
				sig = FSinOsc.ar( frq*x ,0,0.01 * LFNoise1.kr(18*LFNoise1.kr));//.distort;
				sig = sig+SinOsc.ar( frq ,0,0.01 * LFNoise1.kr(18*LFNoise1.kr));//.distort;
				sig = Pan2.ar(sig, LFNoise1.kr(1));
				sig= sig * EnvGen.kr(Env.linen(6,2,99),doneAction: 2);
				//sig=BHiShelf.ar(sig,1200,db: -10);
				sig*amp;
			})
		})}).add;


		
		s.waitForBoot({
			~waves=Buffer.alloc(s,10,2);
			~waves_3m=Buffer.alloc(s,10,2);
			~waves=Buffer.read(s,"/Users/michael/tank/THE FUTURE/SC-bounces/Hayburn.wav");
			~waves_3m=Buffer.read(s,"/Users/michael/tank/THE FUTURE/SC-bounces/3m-stereo\ bounce.wav");
			// initialize resonance
			(~klank==nil).if{
				~klankBus=NodeProxy.control(s,8);
				~klankBus.source=[400,300,360,600,500];
				//~klankBus.source=~tones;
				~klank=NodeProxy.audio(s,2);
				~klank.source= {|time=0.8 bottom=300 amp=1| DynKlank.ar(`[~klankBus,[0.1,0.1,0.3,0.2,0.3,0.3]*amp*0.5,time!6],PlayBuf.ar(2,~waves_3m,loop:1))*0.08};
			};
			// initialize membrane
			(~membrane==nil).if{
				~ocean=NodeProxy.audio(s,2);
				~ocean.fadeTime=5;
				~ocean.source={PlayBuf.ar(2,~waves,loop:1)*10};		
				~membrane=NodeProxy.audio(s,2);
				~membrane.fadeTime=5;
				~membrane.source={|tensionn=0.008 tensionnLag=140 los=0.99999 losLag=40| MembraneHexagon.ar(~ocean, tension: Lag.kr(tensionn,tensionnLag), loss: Lag.kr(los,losLag), mul: 0.2, add: 0)};
				//~membrane.source={|tensionn=0.008 los=0.99999| MembraneHexagon.ar(~ocean, tension: tensionn+LFNoise1.kr(0.1,0.0002), loss: los, mul: 0.2, add: 0)};//some wobbling, nice!
				//~membrane.source={|tensionn=0.008 los=0.99999| MembraneHexagon.ar(~ocean, tension: tensionn+LFNoise1.kr(0.1,0.0001), loss: los, mul: 0.2, add: 0)};//some wobbling, nice!
			}
		})
//~membrane.play;
//Server.scsynth;
//s.reboot;
//
//~klank.play;
//~membrane.postcs;
//~ocean;
//~ocean.postcs.postcs;
//~waves;
//~klank.play;

