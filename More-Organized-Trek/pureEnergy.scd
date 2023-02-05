
(
var dur = 0.1;
SynthDef(\kick_nh, {
	var snd;
	snd = SinOsc.ar(Env([500 * \pitchBend.kr(1), 70, 50] / 50 * \freq.kr(60), [0.04, 0.05] * \bendTime.kr(1), \exp).ar);
	snd = snd + (HPF.ar(Hasher.ar(Sweep.ar), 1200) * Env.linen(0.001, 0.01, 0.001).ar * -5.dbamp);
	snd = snd + (snd * 2).tanh;
	snd = snd * Env.perc(0.001, \release.kr(0.3)).ar(Done.freeSelf);
	snd = snd * \amp.kr(1) ! 2;
	snd = snd * 5.dbamp;
	Out.ar(\out.kr(0), snd);
}).add;

[-1,-3,-5,-7,2,4,6,11, 13,15,17,22,17,15,13,11].df(\c).q(4)
=> [ freq:_,dur:dur, instrument:\sawSynthSustain,lagTime:0 ] =>_.pm
=> _.bubble 

++
[
	[]
].pp




=> Ppar(_) => Pfindur(8,_) => _.play

	)
	(
		{
				var dur = 0.1;
				var clock = Impulse.ar( dur.reciprocal );
				var sequence = [-1,-3,-5,-7,2,4,6,11, 13,15,17,22,17,15,13,11].df(\f).dq(inf);
				//arpeggia
				Saw.ar(
						Demand.ar(clock,0,sequence ) / 2
						* ( Demand.ar(Impulse.ar(3.2.reciprocal),0,[1,2.midiratio].dq(inf)) => Lag.ar(_,1) )
				)
				/2.5 /5
				* Env.perc().kr(0,gate:clock)
				=> {|i| [i, DelayN.ar(i,0.6,0.6)]}
				=>DWGReverbC1C3.ar(_,mix:0.14)
				=>Phaser2.ar(_,rate:0.12,fb:0.5)
				// hihat
				+ (
						WhiteNoise.ar(0.1) * Env.perc(0.01,0.1).kr(0,gate:clock)
						=> RLPF.ar(_, Demand.ar(clock,0,Dwhite(300,8000).linexp(300,8000,300,8000)),0.3)
						=> 
						{ |i|
								Select.ar(
										SinOsc.ar(0.3).range(0,2),
										array:[
												i * 2,
												CombC.ar(i, 0.2, Demand.ar(clock,0,Dwhite(0.01,0.02)))  
										].flat
								)
						}
						/7
						//// Kick
						+ (
								SinOsc.ar(Env([500 * \pitchBend.kr(1), 70, 50] / 50 * \freq.kr(30), [0.04, 0.05] * \bendTime.kr(0.5), \exp).ar)
								+ (HPF.ar(Hasher.ar(Sweep.ar), 1200) * Env.linen(0.001, 0.01, 0.001).ar * -5.dbamp)
								=> {|i| i + (i*2).tanh}
								* Env.perc(0.001, \release.kr(0.3)).ar(0, gate:
										[ "qqq".asBeats * dur * 8 => _.dq(1),
										"qq qq qq qq qq qq qx e x ".asBeats * dur * 8
										=> _.dq(inf) 
								].dq
								// (1).dq(inf) * dur
								=> TDuty.kr(_ ,0, gapFirst:1)
								// Impulse.ar(3.2.reciprocal)
						)
						* -5.dbamp
				))
				// Snare
				+ { var gate = Impulse.ar(1);
				LFTri.ar(Env([300, 230, 200] / 200 * \freqS.kr(220), [0.02, 0.03], \exp).ar) * Env.perc(0.001, 0.5).ar(gate:gate)
				* 3 => _.tanh
				+ (BPF.ar(Hasher.ar(Sweep.ar(gate-0.1)), \noiseFreq.kr(1200), 0.6) * Env.perc(0.1, 0.4).ar(gate:gate) * 5.dbamp)
				* 0.5 * \drive.kr(0.5) => _.tanh * 5.dbamp
				+ (SinOsc.ar( Env( [3000,100],0.02,\exp ).ar(0,gate)) * Env.perc(0.001, 0.02).ar( gate: gate ))
				* Env.perc(0.001, \decayS.kr(0.4)).ar(0, gate)
				/4
		}
		}.play;
	)

			
	
