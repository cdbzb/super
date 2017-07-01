// Recording snippet

(
SynthDef(\playTone, { |freq, duration|
    var w = SinOsc.ar(freq) * XLine.ar(1001,1,duration,add: -1,doneAction:2) / 1000;
    Out.ar(0,w!2);
}).add;
)

(
SynthDef(\recordTone, { |buffer|
    RecordBuf.ar(In.ar(0,2), buffer, loop: 0, doneAction: 2);
}).add;
)

(Routine({
	var recordfn = { |freq, duration|
        var server = Server.local;
        var buffer = Buffer.alloc(server, server.sampleRate * duration, 2);

        server.sync;

        server.makeBundle(func: {
            var player = Synth(\playTone, [\freq, freq, \duration, duration]);
            var recorder = Synth.after(player, \recordTone, [\buffer, buffer]);
        });

        duration.wait;

        buffer.write(
            "/tmp/test.wav",
            "WAVE",
            "int16",
            completionMessage: ["/b_free", buffer]
        );
    };

    recordfn.value(440,1.1);

}).next)
