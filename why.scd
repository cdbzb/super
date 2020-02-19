(//weirerierire{{{
	fork{
		8.do{
			var a={ |out=0|
			var freqs=NamedControl.kr(\freqs,rrand(1500!5,500),9!5);
			var amps=Control.names([\amps]).kr(0.1!5);
			var ring=Control.names([\ring]).kr(1.0.rand!5);
			var ref=`[freqs,amps,ring];
			Saw.ar( \freq.kr([400,500,550,580]*[1,2,0.6,0.4].choose+rrand(-5!4,5),0.05),\amp.kr(0.1) )
			=> DynKlank.ar(ref,_) //+ PinkNoise.ar(0.5.rand)
			//=>Splay.ar(_,4)
			=>FreeVerb.ar(_,0.8,0.8)
			* Env.linen(5,20,9).kr(2,gate:1)
		}=>_.play;

		fork{
			10.do{
				0.1.wait;
				a.setn(\freqs,Array.rand(5,500,2000)
				//.sort
				//.reverse
			);
				4.9.rand.wait;
			}
		};
	8.0.rand.wait}
}	//}}}
)
( //why!!!!!!{{{
	var b={ |out=0|
		var ring = NamedControl.kr(\ring,0.07!5,3!5);
		var freqs = NamedControl.kr(\freqs,Vowel(\u).freqs,rrand(3,4!5));
		var amps = NamedControl.kr(\amps,Vowel(\u).dBs.dbamp/10,3!5);
		Saw.ar( \freq.kr([400,500,550,580]*[1,2,0.6,0.4,0.16].choose+rand(-5!4,5),0.05)/[2,1].choose,\amp.kr(0.1) )
		=> DynKlank.ar(`[freqs,amps,ring],_) + PinkNoise.ar(0.1.rand)
		//verb optional
		=>FreeVerb.ar(_,0.8,0.8)
		* Env.linen(2,6,9).kr(2,gate:1)
	};

	fork{
		10.do{
			fork{var pace=2;
				a=b.play;
				//~set={|symbol| var v= Vowel(symbol); a.setn(\freqs,v.freqs);a.setn(\amps,v.amps.dbamp/10)};
				~set={|symbol| 
					var v= Vowel(symbol); 
					[\freqs,v.freqs,\amps,v.amps.dbamp/10].pairsDo(a.setn(_,_))
				};
				(pace+1).rand.wait;
				~set.(\a);
				pace.wait;
				2.0.rand.wait;
				~set.(\i)
			};
			7.rand.wait;
		}
	}
//}}}
)
( //why!!!!!! Pretty Version hmmm{{{
	var b={ 
		var freqs = NamedControl.kr(\freqs,Vowel(\u).freqs,rrand(3,4!5));
		var ring = NamedControl.kr(\ring,0.07!5,3!5);
		var amps = NamedControl.kr(\amps,Vowel(\u).dBs.dbamp/10,3!5);
		Saw.ar( \freq.kr([400,500,550,580]
		*[1,2,0.6,0.4,0.16].choose+rand(-5!4,5),0.05)/[2,1].choose,\amp.kr(0.1) )
		=> DynKlank.ar(`[freqs,amps,ring],_) + PinkNoise.ar(0.1.rand)
		//verb optional
		=>FreeVerb.ar(_,0.8,0.8)
		* Env.linen(1,6,9).kr(2,gate:1)
		=> Pan4.ar(_,LFNoise1.kr(0.5))
		=> Out.ar(0,_)
	} => SynthDef(\why,_) => _.add;



			~why= { |notes=#[300,400,500,600]|
				var pace=2;
				var init=Vowel(\u);
				fork{
					~set={|symbol| var v= Vowel(symbol); a.setn(\freqs,v.freqs);a.setn(\amps,v.amps.dbamp/10);
					//a.setn(\ring,v.rqs.reciprocal
					//	/ v.freqs *4
					// )
				};
					a=Synth(\why,[\freq,notes,\freqs,[init.freqs],\amps,[init.amps.dbamp/10]]);
					//a=b.play;
					~set.(\u);
					(pace+1).rand.wait;
					~set.(\a,\tenor);
					pace.wait;
					2.0.rand.wait;
					~set.(\i)
				}.play
			};
		
		b ? b=Bus.audio(s,1);
		r.free;r={PlateReverb.ar(In.ar(b))*3}.play(s,2);
	fork{
	 var h=Arpeggio([1,3,5,7],16);
	//(degree:h,strum:0.06,legato:1.3).play;
	//{4.wait;(degree:h-3,strum:0.07,legato:1.5).play}.fork;
	[degree:[h,h-3].q(6),dur:Pwhite(6,6.5),legato:1.1,strum:Pwhite(0.05,0.06),out:[b]].pp;
		4.do{
			var a=[1,3,5,7].collect (Scale.major.performDegreeToKey(_)+60).midicps;
			//a=[1,3,5,7].collect (Scale.major.degreeToFreq(_,60.midicps+rrand(-1,1.0),rrand(-2,-1)));
			~why.(a);
			6.wait;
			a=[1,3,5,7]-3.collect (Scale.major.performDegreeToKey(_)+60).midicps;
			//a=([1,3,5,7]-3).collect (Scale.major.degreeToFreq(_,60.midicps,rrand(-1,0)));
			~why.(a);
			7.rand.wait;
		}
	}
	
)
)
(
)
//}}}

