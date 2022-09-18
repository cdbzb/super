

(
a=Signal.gaussianBank(2048,[400,900],1,s.sampleRate)[2] => 
Buffer.loadCollection(s,_) 
=>_.syncThen{|i| {Convolution2.ar(WhiteNoise.ar(0.1),i)}.play;
};
(lag: 4096/s.sampleRate) .play
)
(
SynthDef(\test,{Saw.ar(SinOsc.ar(1).range(100,400),0.1) => Out.ar(0,_)}).add.syncThen{|i| 
	Synth(i.name);
};
Synth(\default)
)


SynthDef(\test,{Out.ar(0,SinOsc.ar(456,0,0.1))}).doAdd.then({ Synth(\test) })
(
{Saw.ar(338,0.1) * Env.perc().kr(2,gate:1)}.asSynthDef.doAdd.then({|i|[instrument:i.name,dur:[4].q].pp});
(note:1).play
)



// @elgiano
fork { 
	var res1, res2, doSomethingAsync;
	
	////////////////////////////////////////////////////////////////
	res1 = Deferred.using({
		1.wait;
		\ok1
	}).wait;	
	res1.postln;
	
	////////////////////////////////////////////////////////////////
	doSomethingAsync = { 
		var d = Deferred();
		fork { 
			1.wait; d.value = \ok2
		};
		d
	};
	
	res2 = Deferred.using({
		doSomethingAsync.()
	}).wait;
	res2.postln;
}

///////////////////////////////////////////////////////////////
// Timeout example:
// with timeout callback
fork {
	var deferred = Deferred();
	fork { 2.0.wait; deferred.value = \ok };
	deferred.wait(1.0) // timeout...
}
// Note that, very importantly, this generates two errors: one for the timeout and one for the fact that you tried to set the value of a Deferred that already resolved!


////////////////////////////////////////////////////////////////
// @jamshark70
fork {
	var d = Deferred();
	var b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav",
		action: d.valueCallback
	);
	d.wait.numFrames.postln;
}
////////////////////////////////////////////////////////////////
// Simplified version provided by Deferred via :doRead
fork {
	var deferred = Buffer.doRead(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");
	deferred.wait;
	deferred.value.postln;
	deferred.value.numFrames.postln;
}

// or only using Deferred implicitly... this is basically using `action:` but with a method chaining syntex
Buffer.doRead(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav").then {
	|buffer|
	buffer.postln;
	buffer.numFrames.postln;
};
