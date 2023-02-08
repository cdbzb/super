/*

 _____ _   _    _    _   _ _  __ __   _____  _   _
|_   _| | | |  / \  | \ | | |/ / \ \ / / _ \| | | |
  | | | |_| | / _ \ |  \| | ' /   \ V / | | | | | |
  | | |  _  |/ ___ \| |\  | . \    | || |_| | |_| |
  |_| |_| |_/_/   \_\_| \_|_|\_\   |_| \___/ \___/

  500,000 DAMN SUBSCRIBERS ON THE SYNTHDEF CHANNEL

I was going through some old patches and found this extremely silly trap beat generator from 3 years ago.

It's a little one-note, but it makes me laugh, and sometimes sounds pretty good. I thought I'd share the patch.

INSTRUCTIONS: There are only two blocks, just execute the first one and then the second one. To regenerate, hit Ctrl-. and run the second block again. There are no dependencies, and this runs on a default SC installation.

*/

(
var compressor;

compressor = { |snd, attack, release, threshold, ratio|
	var amplitudeDb, gainDb;
	amplitudeDb = Amplitude.ar(snd, attack, release).ampdb.mean;
	gainDb = ((amplitudeDb - threshold) * (1 / ratio - 1)).min(0);
	snd * gainDb.dbamp;
};

~paramGenerators = ();

~paramGenerators[\kick] = {
	[
		bendTime: exprand(0.5, 1),
		pitchBend: exprand(1, 2), // 1 preferred
		release: rrand(0.5, 1),
	];
};
SynthDef(\kick, {
	var snd;
	snd = SinOsc.ar(Env([500 * \pitchBend.kr(1), 70, 50] / 50 * \freq.kr(60), [0.04, 0.05] * \bendTime.kr(1), \exp).ar);
	snd = snd + (HPF.ar(Hasher.ar(Sweep.ar), 1200) * Env.linen(0.001, 0.01, 0.001).ar * -5.dbamp);
	snd = snd + (snd * 2).tanh;
	snd = snd * Env.perc(0.001, \release.kr(0.3)).ar(Done.freeSelf);
	snd = snd * \amp.kr(1) ! 2;
	snd = snd * 5.dbamp;
	Out.ar(\out.kr(0), snd);
}).add;

~paramGenerators[\sub] = {
	[
		drive: exprand(1, 20),
		pitchBendDur: exprand(0.5, 2),
		release: exprand(5, 8),
	];
};
SynthDef(\sub, {
	var snd, freq;
	freq = Env([100, 60, 50] / 50 * \freq.kr(60), [0.03, 0.15] * \pitchBendDur.kr(1), \exp).ar;
	snd = SinOsc.ar(freq * [1, 2]).sum;
	snd = BPF.ar(snd, 60, 0.3);
	snd = snd + (DelayC.ar(HPF.ar((snd * (1 + Env.perc(0, \release.kr(5)).ar) * \drive.kr(1)).tanh, 800), 0.1, SinOsc.ar(1, [0, pi]).range(0, 1) * 1e-3) * 0.dbamp);
	snd = snd * Env.adsr(0.1, \release.kr(5), 0, 0.03).ar(Done.freeSelf, \gate.kr(1));
	snd = snd * \amp.kr(1);
	snd = snd * 0.dbamp;
	Out.ar(\out.kr(0), snd);
}).add;

~paramGenerators[\clap] = {
	[
		decay: exprand(0.05, 0.15),
	];
};
SynthDef(\clap, {
	var snd;
	snd = Hasher.ar(Sweep.ar);
	snd = RHPF.ar(snd, 1225 * [0.9, 1.2, 1.15, 1.8, 1.4] * 1.1, 0.1);
	snd = snd * Env.perc(1e-4, \decay.kr(0.15)).delay([0, 2, 5, 3, 2.5, 4] * 0.7e-2).ar;
	snd = snd * ([0, -3, -5, -8, -2] * 2).dbamp;
	snd = [snd[3], snd[4], snd[0], snd[1], snd[2]];
	snd = Splay.ar(snd);
	snd = MoogFF.ar(snd, 8000, 0) * 10.dbamp;
	snd = snd * Env.perc(0.0, 0.3).ar(Done.freeSelf);
	snd = snd * 5.dbamp;
	snd = Pan2.ar(snd, \pan.kr(0));
	Out.ar(\out.kr(0), snd);
}).add;

~paramGenerators[\snare] = {
	[
		freq: exprand(200, 500),
		noiseFreq: exprand(1500, 2300),
		decay: exprand(0.1, 0.2),
		drive: rrand(0, 5).dbamp,
	];
};
SynthDef(\snare, {
	var snd;
	snd = LFTri.ar(Env([300, 230, 200] / 200 * \freq.kr(220), [0.02, 0.03], \exp).ar) * Env.perc(0.001, 0.5).ar;
	snd = (snd * 3).tanh;
	snd = snd + (BPF.ar(Hasher.ar(Sweep.ar), \noiseFreq.kr(1200), 0.6) * Env.perc(0.1, 0.4).ar * 5.dbamp);
	snd = (snd * 0.5 * \drive.kr(0.5)).tanh * 5.dbamp;
	snd = snd + (SinOsc.ar(XLine.ar(3000, 100, 0.02)) * Env.perc(0.001, 0.02).ar);
	snd = snd * Env.perc(0.001, \decay.kr(0.4)).ar(Done.freeSelf);
	snd = snd * 8.dbamp;
	snd = snd ! 2;
	Out.ar(\out.kr(0), snd);
}).add;

~paramGenerators[\hat] = {
	[
		freq: exprand(1.5, 2.3),
		decay: exprand(0.03, 0.09),
	];
};
SynthDef(\hat, {
	var snd, freq;
	freq = \freq.kr(1);
	snd = SinOsc.ar(3370 * freq) * 3120;
	snd = SinOsc.ar(3250 * freq + snd) * 3120;
	snd = SinOsc.ar(100 * freq + snd);
	snd = snd + Hasher.ar(Sweep.ar);
	snd = RHPF.ar(snd, [4e3, 7e3] * freq, 0.1).sum * 10.dbamp;
	snd = snd * Env.perc(0.001, \decay.kr(0.08)).ar(Done.freeSelf);
	snd = Pan2.ar(snd, \pan.kr(0));
	snd = snd * \amp.kr(1);
	snd = snd * -5.dbamp;
	Out.ar(\out.kr(0), snd);
}).add;

SynthDef(\drumfx, {
	var snd, low, mid, high, lowFreq, highFreq;
	snd = In.ar(\out.kr(0), 2);

	lowFreq = 300;
	highFreq = 3200;
	low = LPF.ar(LPF.ar(snd, lowFreq), lowFreq);
	snd = snd - low;
	mid = LPF.ar(LPF.ar(snd, highFreq), highFreq);
	high = snd - mid;

	low = compressor.(low, 0.01, 0.05, -6, 4);
	mid = compressor.(mid, 0.01, 0.05, -6, 4);
	high = compressor.(high, 0.01, 0.05, -6, 4);

	snd = snd * -5.dbamp;
	// clip on master, baby!
	snd = snd.clip2;
	ReplaceOut.ar(\out.kr(0), snd);
}).add;

~paramGenerators[\fmPad] = {
	[
		ratio: [1, 2, 3, 4].choose,
		ratio2: [0.5, 1, 2, 3, 4].choose,
		index: rand(8000.0),
		attack: exprand(0.01, 0.1),
		release: exprand(0.5, 2),
		lpf: exprand(8000, 16e3),
		fmDecay1: exprand(0.1, 0.5),
		fmDecay2: exprand(0.1, 0.5),
		vibratoDepth: rrand(0.0, 0.5).squared,
		vibratoFreq: exprand(4, 6),
		bend: rrand(0, 12),
	]
};
SynthDef(\fmPad, {
	var snd, freq;
	freq = \freq.kr(440) * (SinOsc.kr(\vibratoFreq.kr(4)) * \vibratoDepth.kr).midiratio;
	freq = freq * Line.ar(\bend.kr(0), 0, 0.01).midiratio;
	snd = SinOsc.ar(freq + (SinOsc.ar(freq * \ratio.kr(1)) * \index.kr * Env.adsr(0, \fmDecay1.kr(0.3), 0.5).ar));
	snd = snd + SinOsc.ar(freq + (SinOsc.ar(freq * \ratio2.kr(1)) * \index.kr * Env.adsr(0, \fmDecay2.kr(0.3), 0.5).ar));
	snd = snd * Env.perc(\attack.kr(0), \release.kr(1)).ar(Done.freeSelf);
	snd = snd * freq.explin(600, 4000, 0, -10).dbamp;
	snd = LPF.ar(snd, \lpf.kr(1000));
	snd = snd * -13.dbamp;
	snd = snd * \amp.kr(1) ! 2;
	Out.ar(\out.kr(0), snd);
}).add;

SynthDef(\send, {
	var snd;
	snd = In.ar(\in.kr(0), 2);
	snd = snd * \amp.kr(1);
	Out.ar(\out.kr(0), snd);
}).add;

~paramGenerators[\melodyFx] = {
	[
		delayTimeInBeats: [0.5, 1, 1.5, 2].choose,
		feedback: rrand(-10, -5).dbamp,
	];
};
SynthDef(\melodyFx, {
	var snd, wet, beat, delayTimeInBeats, adjustedDelayTime;
	var introLengthInSeconds;
	var filterFreq;
	delayTimeInBeats = \delayTimeInBeats.kr(1);
	beat = \beat.kr(1);
	introLengthInSeconds = beat * \introLength.kr(0);
	snd = In.ar(\out.kr(0), 2);
	snd = snd + LocalIn.ar(2);
	adjustedDelayTime = delayTimeInBeats * beat - ControlDur.ir;
	wet = DelayC.ar(snd, adjustedDelayTime + 1e-2, adjustedDelayTime + (SinOsc.ar(4, [0, pi]) * 1e-4));
	wet = wet * \feedback.kr(0.5);
	wet = LPF.ar(wet, 3000);
	wet = HPF.ar(wet, 100);
	LocalOut.ar(wet);
	snd = snd + (DelayC.ar(GVerb.ar(snd.sum, 10), 0, LFNoise2.kr(3 ! 2).linlin(-1, 1, 0, 0.001)) * -10.dbamp);
	snd = snd * Line.kr(-5, 0, introLengthInSeconds).dbamp;
	filterFreq = XLine.kr(700, 16e3, introLengthInSeconds);
	snd = LPF.ar(LPF.ar(snd, filterFreq), filterFreq);
	ReplaceOut.ar(\out.kr(0), snd);
}).add;

SynthDef(\reverseCymbal, {
	var snd;
	snd = { PinkNoise.ar } ! 2;
	snd = BPF.ar([snd], [3210, 6253, 8255, 6326, 10425] * ExpRand(0.1, 1), 0.1).sum * 10.dbamp;
	snd = snd * Env.perc(\dur.kr(1), 0.05, curve: 4).ar(Done.freeSelf);
	snd = snd * -2.dbamp;
	Out.ar(\out.kr(0), snd);
}).add;
)

(
Routine {
	var s;
	var tempo, root, melody;
	var beat;

	var kickPattern;
	var melodyBus, melodyGroup, melodyFx;
	var introLength;
	var params;
	var hatPan;

	s = Server.default;

	kickPattern = [
		[2.5, 0.5, 5],
		[3, 2, 3],
	].choose;

	tempo = [120, 125, 128, 130, 135, 140].choose;
	root = (6..10).choose;
	melody = {
		var notes, result, length;
		notes = [-5, 0, 2, 3, 7, 8, 12];
		result = List();
		result.add(0);
		length = [4, 8, 16].choose;
		(length - 1).do { |i|
			var candidates;
			candidates = notes.copy;
			if (result.last == 8) {
				candidates = [7];
			};
			if (result.last == 2) {
				candidates = [0, 3, 7];
			};
			candidates.remove(result.last);
			if (i == (length - 2)) {
				candidates.remove(notes[0]);
				candidates.remove(8);
			};
			result.add(candidates.choose);
		};
		60 + ([0, 1, 2].choose * 12) + root + result;
	}.value;

	params = (
		melody: (
			noteDuration: if(melody.size == 16, 1 / 2, if(melody.size == 4, 1, [1, 1 / 2].choose)),
		),
		melodyFx: ~paramGenerators[\melodyFx].value,
		kick: ~paramGenerators[\kick].value,
		sub: ~paramGenerators[\sub].value,
		fmPad: ~paramGenerators[\fmPad].value,
		snare: ~paramGenerators[\snare].value,
		hat: ~paramGenerators[\hat].value,
		clap: ~paramGenerators[\clap].value,
	);
	hatPan = rrand(0.3, 0.6);

	introLength = 4 * if(melody.size == 4, 4, [4, 8].choose);
	beat = 60 / tempo;

	melodyBus = Bus.audio(Server.default, 2);
	melodyGroup = Group(Server.default);
	melodyFx = Synth.after(melodyGroup, \melodyFx, [out: melodyBus, beat: beat, introLength: introLength] ++ params[\melodyFx]);
	Synth.after(melodyFx, \send, [in: melodyBus, out: 0]);

	Synth.tail(Server.default, \drumfx);
	Server.default.sync;

	fork {
		loop {
			melody.do { |note|
				s.makeBundle(s.latency, {
					Synth(\fmPad, [amp: 1, freq: note.midicps, out: melodyBus] ++ params[\fmPad], melodyGroup);
				});
				(beat * params[\melody][\noteDuration]).yield;
			};
		};
	};
	fork {
		var reverseCymbalDur;
		reverseCymbalDur = rrand(2, 6);
		(introLength * beat - (reverseCymbalDur + 0.1)).yield;
		s.makeBundle(s.latency, {
			Synth(\reverseCymbal, [amp: 1, out: 0, dur: reverseCymbalDur]);
		});
	};
	(introLength * beat).yield;
	fork {
		loop {
			kickPattern.do { |beats|
				s.makeBundle(s.latency, {
					Synth(\kick, [amp: 1.0, freq: (24 + root).midicps] ++ params[\kick]);
				});
				(beat * beats).yield;
			};
		};
	};
	fork {
		loop {
			kickPattern.do { |beats|
				var synth;
				s.makeBundle(s.latency, {
					synth = Synth(\sub, [amp: 1.0, freq: (24 + root).midicps] ++ params[\sub]);
				});
				(beat * beats).yield;
				s.makeBundle(s.latency, {
					synth.set(\gate, 0);
				});
			};
		};
	};
	fork {
		(beat * 2).yield;
		loop {
			[4, 4].do { |beats|
				s.makeBundle(s.latency, {
					Synth(\snare, [amp: 1] ++ params[\snare]);
				});
				fork {
					0.01.yield;
					s.makeBundle(s.latency, {
						Synth(\clap, [amp: 1] ++ params[\clap]);
					});
				};
				(beat * beats).yield;
			};
		};
	};
	fork {
		var pan;
		pan = hatPan;
		loop {
			4.do { |i|
				var subdivision;
				subdivision = [2, 3, 8].wchoose([2, 2, [0, 1, 0, 3][i % 4]].normalizeSum);
				subdivision.do { |j|
					s.makeBundle(s.latency, {
						Synth(\hat, [amp: 1.0 * if(j == 0, 3, 0).dbamp, pan: pan] ++ params[\hat]);
					});
					(beat / subdivision).yield;
					pan = pan * -1;
				};
			};
		};
	};
} .play;
)
