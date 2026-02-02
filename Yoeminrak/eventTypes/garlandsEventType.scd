
( //tangled from yoeminrak-tangleDoc-12-25.org
Event.addEventType(\garlands, {
    var section = ~section ? 1;
    var useGendy = ~useGendy ? false;  // false = SinOsc/Saw/Pulse/VarSaw, true = Gendy1/Gendy3
    var useConvolution = ~useConvolution ? false;

    {
        var trig = Impulse.ar(XLine.kr(8, 2, 5) * [2,1,0.66].choose);
        var freq = Demand.ar(
            trig: trig,
            reset: 0,
            demandUGens: List[
                Drand(In.kr(Yoeminrak.env[\currentInstance][\chord], 5), inf)
            ]
        );
        var sig;

        useGendy.if({
            [Gendy1, Gendy3].choose.arWidth(width: ~width ? 1.03.rrand(1.2), freq: freq * [2,4,5,6,8].choose) / 2
        }, {
            [SinOsc, Saw, Pulse, VarSaw].choose.ar(freq * [2,4,5,6,16].choose) / 2
        })

        * Env.perc(0.05, 0.1).ar(0, trig)
        * [Line, XLine].choose.kr(1, 0.0001, 7, doneAction: 2)
        => Pan2.ar(_, 1.rrand(-1))

        => useConvolution.if({
            Convolution.ar(_, Dust.ar(50) => FreeVerb.ar(_, 0.5, 0.8))
        }, {
            FreeVerb.ar(_, 0.4, ~wet ? 1) / 2
        })

        / 2
    }.play
});
);



( //tangled from yoeminrak-tangleDoc-12-25.org
Event.addEventType(\garlands2, {
    var totalDur = ~totalDur ? 8 * Yoeminrak.secDur[~section ? 0]/20;
    var initDur = ~initDur ? 0.1 * Yoeminrak.secDur[~section ? 0]/20;
    var numDivisions = ~numDivisions ? 12;
    var curve = ~curve ? \exp;
    var section = ~section ? 1;
    var useGendy = ~useGendy ? false;
    var useConvolution = ~useConvolution ? false;

    var durations = Yoeminrak.garland(totalDur, initDur, numDivisions, curve) ++ ~extraDur;

    var env = currentEnvironment;
    env.type = nil;
    currentEnvironment.asKeyValuePairs.postln ++
    [
	// type:\note,
	dur: durations.q,
    ]
    => {|i| ~mono.if { i.ppm }{ i.pp }}
});
)
