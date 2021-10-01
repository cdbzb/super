(
  { 
    Impulse.ar(0)
    =>Decay.ar(_,0.05)
    * ClipNoise.ar(0.1)
    =>MembraneHexagon.ar(_,\tension.kr( 0.008, 0.01 ),\loss.kr ( 0.99996 ) ) 
    =>Out.ar(\out.kr(0),_)
  }
  =>SynthDef(\membrane,_)=>_.add=>_.tag(\perc); 



	{Pulse.ar(\freq.kr(300),0.1,\amp.kr(0.1))* Env.perc(0.01,1).kr(2,gate:\gate.kr(1))=>Out.ar(\out.kr(0),_)}
        =>SynthDef(\twang,_)=>_.add =>_.tag(\key,\pluck);

	SynthDef(\swell20,{
		var freq = \freq.kr(300);
		//			var width = 4;
		var width = [4,5];
		Env.perc(\attack.kr(1),\release.kr(1),\amp.kr(0.1),\curve.ir()).kr(2,gate:\gate.kr(1))
		* Gendy1.ar(minfreq:freq-width,maxfreq:freq+width)
		/ 2
		=>Out.ar(\bus.kr(0),_)
	}).add;

SynthDef(\cleanPluck,{
		DWGPlucked2.ar(
				\freq.kr(300),
				\amp.kr(0.1),
				\gate.kr(1),
				\position.kr(0.14),
				1/\decay.kr(10),
				\damping.kr(30),
				Impulse.ar(0)*\volume.kr(0.1),
				\detune.kr(1.08),
				\coupling.kr(0.01))
=> Out.ar(\out.ir(0),_)
}).add.tag(\pluck);
)
