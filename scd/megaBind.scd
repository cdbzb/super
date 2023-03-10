
(
b= [1,2,3,4]/3;
(
//idea 0 instead of rest for .df
	freq: [[1,2,3],[6,5,4],[6,5,14]].flop.df(\e) ,
	dur: b,
	amp: Env.asr(0.1,0.2,4),
	bump: Env.perc(),
	wobble: {Env([2,6,4,1.5],b + [0,0,[2, 3,4 ]],[\step,\step,\lin]).kr(0,1)},
	filterMod: { SinOsc.kr(~wobble).range(800,1900) },
	play:{
		{
			var freq = ~freq.dq.demand(~dur);
			Gendy1.arWidth( freq:freq.lag([0,1,1,1].dq.demand(~dur)/3)) +
			 VarSaw.ar(
				 freq: freq.lag([0,1,1,1].dq.demand(~dur)/2)
			            * [1,2,3/4,2/3]
				    + (LFBrownNoise2.ar({rrand(1000,2000)}!3)*10),
				 width:LFBrownNoise1.kr(10).range(0.8,0.9)
			 )
			* (
				0.5 *
				~bump.kr(0,gate:TDuty.kr(~dur.dropLast.dropLast.dq))
				+ ~amp.kr(2,gate:~freq ++ 0 =>_.dq=>_.demand(~dur.dq))
			)
			=> TwoTube.ar(_,0.5,0.8,800,1876).tanh
			=> MoogFF.ar(_,~filterMod,2)
			=> Splay.ar(_)
		}.play
	}
).play
)
///// IDEA MegaBind
///// Main Idea:  Multiple Dur streams
///// Idea 2 :Some keys are Patterns - other keys are Demand rate or Envelopes

[
	durs: [1,2,1,4,3,2],
	phrase: p{|e| e.durs.parse([2,1,2,1])},

]
(
(
freq: [1,\r,3,2,\r, -6,\r,\r].df(\a),
gate: { ~freq.collect({|i| i.isNumber.binaryValue }) },
play:{
	{
		var freq = ~freq.replace(\r,0);
		SinOsc.ar(freq.dq.demand([1,1,1,1,1,1]/3),0,~gate/10)
	}.play
}

).play
)

///////////new methods!!
(
{
	var f = [\r,1,2,\r,4].df(\e);
	var d = [1,1,1,1,1];
	//how to get this to be per actual note!!
	
	var mod = [3,5,7,0].dq.demand( d );
	Pulse.ar(f.asDemandFreqs.dq.demand(d) + SinOsc.kr([0]++mod,0,3).lag(0.3),LFBrownNoise1.kr(1),0.1) * Env.asr(0.5,1,3).kr(0,gate:f.asDemandGate.dq.demand(d))

}.play
)
// phrase onsets!
[0,1,1,0,0,1] => {|i| i.size.collect{|j| i[j] * i.clipAt(j+1) + i.clipAt(j+1) % 2}} => _.shift(1)

(
var array = [\r,1,2,3,\r,\r,5];
var durs = 1 ! array.size;
var indices = (0..array.size).select{|i| array.asDemandGate[i].asBoolean};
array.asDemandGate.postln;
indices => { |a| 
			var padded=(a++(array.size));
			a.size.collect{
				|i| var delta=padded[i+1]-a[i]; 
				(delta>1).if{
					delta.collect{ |j| j+a[i] }
				}{
					[a[i]]
				} 
			}.collect{|i x|i.sum({|i| durs[i] })}
		}
)

/*
whats wanted:
[2,3,4].demandPhrase([\r,1,1,\r,1],[1,1,1,1,1]) /// [2,2,3,3,4].demand([1,1,1,1,1]) 
[\r,1,2,\r,\r,4].asDemandFreqs                  /// [1,1,2,2,2,4]
[\r,1,2,\r,\r,4].asDemandGate                   /// [0,1,1,0,0,1,0]
function to transform [2,3,4] to [\r,2,3,\r,\r,4].asDemandFreqs] ??
// if we call this method dDstretch...
[2,3,4].q.asStream => {|stream| var a = \r; [0,1,1,0,0,1,0].collect{|i| i.asBoolean.if{a=stream.next}{a}}} =>_.asDemandFreqs
~spanRests= {|values tune| values.q.asStream =>{|stream| var a = \r; tune.collect{|i| (i != \r).if{ a= stream.next}{a}}}}
//then 
~spanRests.( [2,3,4],([1,1,\r,1]) )
[2,3,4] spanRests: [1,1,\r,1] demand: [1,1,1,1] 
.demand(durs)
[2,3,\r,5] demand: [1,1,1,1].dq
*/
(
var freqs = [1, 3, 5, \r, 6, 1].df(\e);
var durs =  [1, 2, 1, 3,  2,  4, 2]/4;
var mod = [4,6,4,8,5];
{
	8.collect{|i|
		var modd = SinOsc.kr(
			mod.scramble.spanRests(freqs).dq.demand(durs)
			,0,8);
			Pulse.ar(rrand(2,12) * freqs.asDemandFreqs.dq.demand( durs ).lag(  1*[0,0.5,0.5,0.5,0.5,0.5].dq.demand(durs) ) + modd, width:WhiteNoise.ar(0.1).range(0,0.1))

			=>EchoNone.ar(_,0.300,0.300,5)
			//+ Pulse.ar(freqs.asDemandFreqs.dq.demand( durs ) + modd, width:WhiteNoise.ar(0.1).range(0,0.1))
			* Env.asr().kr(0,gate:freqs.asDemandGate.dq demand: durs)
		} => Splay.ar(_) => MoogFF.ar(_,[1,3,5,6].df(\e,octave:7) + Line.kr(2000,0,durs.sum),3)

	}.play;
	Synth(\stringyy,[\freq,[11,1,3].df(\e,octave:[3,4]),\amp,0.5,\width,19]).dur(durs.sum);
)


(
a=  (
	durs: [1,3,2,4,3,2,3]/4,
	demanD: {|e i| i.asDemandFreqs.dq.demand(e.durs) }  ,
	freq:[1,2,3].df(\e),
	play:{
		{
			SinOsc.ar([1,2,3].df(\e) => ~demanD,0,0.1)
			//SinOsc.ar([1,2,3].df(\e).asDemandFreqs.dq.demand(~durs),0,0.1)
		}.play
	}
) ;
a.play
)


(
var mod;
~durs = [1,3,2,5,4,4]/4;
~make = {|i|  i.asDemandFreqs.dq.demand(~durs) };
~gate = {|i|  i.asDemandGate.dq.demand(~durs) };
~freq=[2,3,4,\r,[ 2,4 ],[ 1.7,3.2 ]].df(\e).flop;
~freq.do{ |freq|
	{var mod = Pulse.ar([6,1].dq(inf).demand(~durs.spanRests(~freq)) * [1,1.1],0.5,10);
	Saw.ar(freq => ~make + ( mod * Line.kr(5,1,~durs.sum) )) * Env.asr().kr(0,gate:freq => ~gate)
	=> MoogFF.ar(_,  SinOsc.ar(0.1).exprange(800,8000),2)
	=> EchoNone.ar(_,0.4,0.3,4)
}.play.dur(8)
}

)

a.parent
(
b=(

	array: { VoiceLeading(~pitches,~durs) => {|i| [i.valuesArray,i.durationArray]}}.flop  ,
	freqAndDur: {[freq: ~array[0],dur:~array[1]]},
	voices: {
		( ~freqAndDur ++ ~bind
			 ).flop.collect {|i| Event.newFrom(i)} 
	},
	outer:I.d,
	inner:I.d,
	release: {Env.linen(~durs.sum+5).kr(2,gate:1)},
	play:{3.postln}
);

a=LambdaEnvir( (
	play: {
		{
			~release; 
			~voices.collect(~inner)
		//everything outside the loop applies to the array of channels
		=> ~outer
		}.play
	},

	pitches:[[ 1, 3,  4,  \r, 3, 5,  4,  2 ].df(\e),
	         [ 2,\r,11,  \_, \r,\r,\r,\r, ].df(\e),
		 [ 1,  \_, \_, 4.5,  5 , \_, 6, \_ ].df(\e, octave:4)],
	durs: [1,2,3,2,2,3,2,3]/5,
	bind:{ // these are expanded to voices
		[
			amp: [0.1,0.08,0.1 * [2,1,2.5].dq.demand(~array[1][2]) + SinOsc.ar(7,0,0.05)*18],
			echo:[{ Phaser2.ar(_,rate:0.1,fb:1)*5 },{EchoNone.ar(_,0.4,0.4,19)},{ AnalogPhaser.ar(_,SinOsc.kr(1).unipolar,modulation:0.5,feedback:0.9) }],
			lag: [0,1,0],
			//echo:{{|i| [i[0],EchoNone.ar(i[1],0.4,0.4,19),i[2]]}}

		]
	},
	inner:{
		{ |i x| //voices are passed in freq, dur + keys in bind
			{
				Saw.ar(i.freq.asDemandFreqs.dq.demand(i.dur).max(100).lag(i.lag) 

				+ SinOsc.ar([3,5,7],0,2)
			)
			* Env.asr(0).kr(0,gate:i.freq.asDemandGate.dq.demand(i.dur))
			* i.amp
			* (x!=2).if{Env.perc().kr(0,gate:i.dur.dropLast => _.tduty)}{1}
			=> i.echo
			=> MoogFF.ar(_,XLine.kr(10000,100,12),2.99)

		}
		}
	},
	outer:{
		{|i|
			EarlyRef.ar(i,[[1,2,3],1,1],[2,0,0],[5,5,5]) => DWGReverbC1C3.ar(_,mix:0.2)
			=> Splay.ar(_)
			=>Limiter.ar(_,0.01) *5
		}
	},
) ).proto_(b); a.play
)
/////////megaBind!!!!!
(
a= MegaBind(
	release:16,
	pitches: [
		[6,3,3].df(\b),
		[1,3,5].df(\e)
	],
	durs: [1,2,1]/2,
	bind: [
		amp: [{SinOsc.ar([4,7]).unipolar}],
		lag: [[0,5],0]
	],
	inner:{|i| 
		VarSaw.ar(i.freq.dq.demand(i.dur)+100 => {|j| j.lag(i.lag.dq.demand(i.dur))},0,0.1)
		* i.amp
		* Env.asr().kr(0,gate: i.freq.asDemandGate.dq.demand(i.dur))
		* (i==1).if{ Env.perc().kr(0,gate:i.dur.tduty)}{1}
	},
	fx: { 
		|i| FreeVerb.ar(i,0.5,1) 
		* SinOsc.ar([4,6,3,4])
		*0.1
	} 

);
a.play
)
