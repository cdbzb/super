
	// via https://web.archive.org/web/20191104212834/https://www.nada.kth.se/utbildning/grukth/exjobb/rapportlistor/2010/rapporter10/szabo_adam_10131.pdf
SynthDef(\Rolandd, { | freq = 523.3572, mix=0.75, detune = 0.5 |
	var detuneCurve = { |x|
(10028.7312891634*x.pow(11)) -
(50818.8652045924*x.pow(10)) +
(111363.4808729368*x.pow(9)) -
(138150.6761080548*x.pow(8)) +
(106649.6679158292*x.pow(7)) -
(53046.9642751875*x.pow(6)) +
(17019.9518580080*x.pow(5)) -
(3425.0836591318*x.pow(4)) +
(404.2703938388*x.pow(3)) -
(24.1878824391*x.pow(2)) +
(0.6717417634*x) +
0.0030115596
	};
	var centerGain = { |x| (-0.55366 * x) + 0.99785 };
	var sideGain = { |x| (-0.73764 * x.pow(2)) + (1.2841 * x) + 0.044372 };

	var center = LFSaw.ar(freq.lag(0.2), Rand());
	var detuneFactor = freq * detuneCurve.(detune);
	var freqs = [
(freq - (detuneFactor * 0.11002313)),
(freq - (detuneFactor * 0.06288439)),
(freq - (detuneFactor * 0.01952356)),
// (freq + (detuneFactor * 0)),
(freq + (detuneFactor * 0.01991221)),
(freq + (detuneFactor * 0.06216538)),
(freq + (detuneFactor * 0.10745242))
	];
	var side = Mix.fill(6, { |n|
LFSaw.ar(freqs[n], Rand(0, 2))
	});

	var sig = (center * centerGain.(mix)) + (side * sideGain.(mix));



	sig = HPF.ar(sig * \amp.kr(0.1) / 3 ! 2, freq);
	sig * Env.asr().kr(2,\gate.kr(1))
	   => Out.ar(\out.kr(0), _)
}).add;

(
	   { arg out=0, freq=440, amp=0.1, pan=0, gate=1;
		   var z;
		   z = LPF.ar(
			   Mix.new(VarSaw.ar(freq * (\poly.kr(0) / 127 * \polyRange.kr(1) => _.midiratio) + [0, Rand(-0.4,0.0), Rand(0.0,0.4)], 0, 0.3, 0.3)),
			   XLine.kr(Rand(4000,5000), Rand(2500,3200), 1)
		   ) * Linen.kr(gate, 0.01, 0.7, 0.3, 2);
		   OffsetOut.ar(out, Pan2.ar(z, pan, amp));
	   } => SynthDef(\defaultMk, _) => _.add
   )