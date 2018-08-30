/*
 * EXAMPLE 1:
 * Create a system of two inter-connected strings. The strings are fixed at their left end points and
 * coupled together at their right end points.
 */

/*
***********************
*PRE-CALCULATION STAGE*
***********************
*/
(
var objs,massMatrix,connPointMatrix,excPointMatrix,readoutPointMatrix;

// the virtual object descriptions making up our system
objs = [
    Resonator1D(100,0.3,0.698698,0.001515,\leftClampedRightFree),
    Resonator1D(200,0.1,0.698698,0.001515,\leftClampedRightFree)
];

// note that the mass ratio is 1, meaning that an equal amount of energy will flow from string 1 to string 2
// as from string 2 to string 1 in the ideal lossless case
massMatrix = Array2D.fromArray(2,1,[
    1,
    1
]);

// string are connected at relative position 1: i.e. their right end points
connPointMatrix = Array2D.fromArray(2,1,[
    1,
    1
]);

// excite string 1 and 2 separately and both together at a random relative position along their lengths
excPointMatrix = Array2D.fromArray(2,3,[
    1.0.rand, 0,        1.0.rand,
    0,        1.0.rand, 1.0.rand
]);

// listen to string 1 and 2 separately and both together at a random relative position along their lengths
readoutPointMatrix = Array2D.fromArray(2,6,[
    1.0.rand, 1.0.rand, 0,        0,        1.0.rand, 1.0.rand,
    0,        0,        1.0.rand, 1.0.rand, 1.0.rand, 1.0.rand
]);

// construct our 2-string system and calculate its modal data (this can take a second or two
// depending on the available computing power)
~network = ResonatorNetwork(objs,connPointMatrix,massMatrix,excPointMatrix,readoutPointMatrix).calcModalData(gain:40.dbamp,maxFreq:16000,incl:"yynn")
)

// post all normal mode frequencies and t60 decay times of our resonator network
(
var sr = 44100 ? s.sampleRate;
[~network.modalData["eigenvaluesPolar"]["angle"]*sr/2pi,6.91/((1.0 - ~network.modalData["eigenvaluesPolar"]["radius"])*sr)].flop do: _.postln;
)

/*
******************
*SIMULATION STAGE*
******************
*/
(
s.waitForBoot({
    // a synth def template for simulating the string
    ~makeResonatorSynthDef = { arg inA1,inA2,inB1,inB2,synthDefName;
        inA1.postln;
        SynthDef(synthDefName,{ arg inBus,outBus = 0,inputGain = 1,outputGain = 1,dryWet = 1;
            var input,output,a1,a2,b1,b2;

            a1 = \a1.ir(inA1);
            a2 = \a2.ir(inA2);
            b1 = \b1.ir(inB1);
            b2 = \b2.ir(inB2);
            input = In.ar(inBus)*inputGain;
            output = SOS.ar(input,0,a1,a2,b1,b2).sum*outputGain;

            Out.ar(outBus,(1 - dryWet)*input + (dryWet*output))
        }).add
    };

    // very simple strike-type excitation synth def
    SynthDef(\strike,{ arg outBus = 0,lpFreq = 12000,strikeFreq = 1;
        var signal = LPF.ar(Impulse.ar(strikeFreq),lpFreq);
        Out.ar(outBus,signal)
    }).add
})
)

/*
 * Every excitation / readout point combination is represented by its own transfer function,
 * and hence needs to be simulated explicitly.  The following example will demonstrate two
 * different ways of simulating the output of our system as a stereo signal. Method 1 may be
 * seen as more physically correct, but uses roughly twice the number of modes of method 2
 */

// method 1: simulate system output by using two different transfer functions for the left and
// right channels

(
// simulate first string in response to exciting it and listening to it at a random relative
// location (use for left channel)
~makeResonatorSynthDef.(
    ~network.modalData["biquadCoefs"]["a1"][0][0],
    ~network.modalData["biquadCoefs"]["a2"][0][0],
    ~network.modalData["biquadCoefs"]["b1"].neg,
    ~network.modalData["biquadCoefs"]["b2"].neg,
    \string1_left
);

// simulate first string in response to exciting it at the same location, but listening to it
// at another random relative location (use for right channel)
~makeResonatorSynthDef.(
    ~network.modalData["biquadCoefs"]["a1"][1][0],
    ~network.modalData["biquadCoefs"]["a2"][1][0],
    ~network.modalData["biquadCoefs"]["b1"].neg,
    ~network.modalData["biquadCoefs"]["b2"].neg,
    \string1_right
)
)

(
s.makeBundle(nil,{
    x = Synth(\string1_left,[\inBus,10,\outBus,0,\outputGain,5],1,\addToTail);
    y = Synth(\string1_right,[\inBus,10,\outBus,1,\outputGain,5],1,\addToTail);
    z = Synth(\strike,[\outBus,10,\lpFreq,8000],1,\addToHead)
})
)

x.free; y.free; z.free

// method 2: simulate system output by using the same transfer function for the left and right
// channels by spreading the individual second order sections (i.e. modes) equally over them

(
var evenInd,oddInd;

// simulate first string in response to exciting it and listening to it at a random relative
// location (use for both channels)
evenInd = (0,2..~network.modalData["biquadCoefs"]["b1"].lastIndex);
oddInd = (1,3..~network.modalData["biquadCoefs"]["b1"].lastIndex);
~makeResonatorSynthDef.(
    ~network.modalData["biquadCoefs"]["a1"][0][0]|@|evenInd,
    ~network.modalData["biquadCoefs"]["a2"][0][0]|@|evenInd,
    (~network.modalData["biquadCoefs"]["b1"]|@|evenInd).neg,
    (~network.modalData["biquadCoefs"]["b2"]|@|evenInd).neg,
    \string1_left2
);

~makeResonatorSynthDef.(
    ~network.modalData["biquadCoefs"]["a1"][0][0]|@|oddInd,
    ~network.modalData["biquadCoefs"]["a2"][0][0]|@|oddInd,
    (~network.modalData["biquadCoefs"]["b1"]|@|oddInd).neg,
    (~network.modalData["biquadCoefs"]["b2"]|@|oddInd).neg,
    \string1_right2
)
)

(
s.makeBundle(nil,{
    x = Synth(\string1_left2,[\inBus,10,\outBus,0,\outputGain,10],1,\addToTail);
    y = Synth(\string1_right2,[\inBus,10,\outBus,1,\outputGain,10],1,\addToTail);
    z = Synth(\strike,[\outBus,10,\lpFreq,8000],1,\addToHead)
})
)

x.free; y.free; z.free

// simulate system output by using the two transfer functions which correspond to exciting
// the first string at the same random realtive location as before, but now listen to the
// response of the second string instead

(
// simulate second string in response to exciting the first string by listening to it at a random relative
// location (use for left channel)
~makeResonatorSynthDef.(
    ~network.modalData["biquadCoefs"]["a1"][2][0],
    ~network.modalData["biquadCoefs"]["a2"][2][0],
    ~network.modalData["biquadCoefs"]["b1"].neg,
    ~network.modalData["biquadCoefs"]["b2"].neg,
    \string2_left
);

// simulate second string in response to exciting the first string at the same location,
// but listening to it at another random relative location (use for right channel)
~makeResonatorSynthDef.(
    ~network.modalData["biquadCoefs"]["a1"][3][0],
    ~network.modalData["biquadCoefs"]["a2"][3][0],
    ~network.modalData["biquadCoefs"]["b1"].neg,
    ~network.modalData["biquadCoefs"]["b2"].neg,
    \string2_right
)
)

(
s.makeBundle(nil,{
    x = Synth(\string2_left,[\inBus,10,\outBus,0,\outputGain,10],1,\addToTail);
    y = Synth(\string2_right,[\inBus,10,\outBus,1,\outputGain,10],1,\addToTail);
    z = Synth(\strike,[\outBus,10,\lpFreq,8000],1,\addToHead)
})
)

x.free; y.free; z.free

// simulate system output by using the two transfer functions which correspond to exciting the
// second string at a random realtive location, but now listen to the response of the first string instead

(
// simulate first string in response to exciting the second string by listening to it at a random relative
// location (use for left channel)
~makeResonatorSynthDef.(
    ~network.modalData["biquadCoefs"]["a1"][0][1],
    ~network.modalData["biquadCoefs"]["a2"][0][1],
    ~network.modalData["biquadCoefs"]["b1"].neg,
    ~network.modalData["biquadCoefs"]["b2"].neg,
    \string1_left3
);

// simulate first string in response to exciting the second string at the same location,
// but listening to it at another random relative location (use for right channel)
~makeResonatorSynthDef.(
    ~network.modalData["biquadCoefs"]["a1"][1][1],
    ~network.modalData["biquadCoefs"]["a2"][1][1],
    ~network.modalData["biquadCoefs"]["b1"].neg,
    ~network.modalData["biquadCoefs"]["b2"].neg,
    \string1_right3
)
)

(
s.makeBundle(nil,{
    x = Synth(\string1_left3,[\inBus,10,\outBus,0,\outputGain,10],1,\addToTail);
    y = Synth(\string1_right3,[\inBus,10,\outBus,1,\outputGain,10],1,\addToTail);
    z = Synth(\strike,[\outBus,10,\lpFreq,8000],1,\addToHead)
})
)

x.free; y.free; z.free

// simulate system output by using the two transfer functions which correspond to exciting both
// strings at a random realtive location, and listen to the response of both strings

(
// simulate both strings in response to exciting both strings at a random relative location,
// and listen to both of them at another random relative location (use for left channel)
~makeResonatorSynthDef.(
    ~network.modalData["biquadCoefs"]["a1"][4][2],
    ~network.modalData["biquadCoefs"]["a2"][4][2],
    ~network.modalData["biquadCoefs"]["b1"].neg,
    ~network.modalData["biquadCoefs"]["b2"].neg,
    \string12_left
);

// simulate both strings in response to exciting both strings at a random relative location,
// and listen to both of them at another random relative location (use for right channel)
~makeResonatorSynthDef.(
    ~network.modalData["biquadCoefs"]["a1"][5][2],
    ~network.modalData["biquadCoefs"]["a2"][5][2],
    ~network.modalData["biquadCoefs"]["b1"].neg,
    ~network.modalData["biquadCoefs"]["b2"].neg,
    \string12_right
)
)

(
s.makeBundle(nil,{
    x = Synth(\string12_left,[\inBus,10,\outBus,0,\outputGain,5],1,\addToTail);
    y = Synth(\string12_right,[\inBus,10,\outBus,1,\outputGain,5],1,\addToTail);
    z = Synth(\strike,[\outBus,10,\lpFreq,8000],1,\addToHead)
})
)

x.free; y.free; z.free



/*
 * EXAMPLE 2:
 * Create a more complicated system of inter-connected objects. Create two plates which are
 * inter-connected at a random location along their surface through the two end points of a string.
 */

/*
***********************
*PRE-CALCULATION STAGE*
***********************
*/
(
var objs,massMatrix,connPointMatrix,excPointMatrix,readoutPointMatrix;

// the virtual object descriptions making up our system
objs = [
    Resonator2D(0,20,0.61,0.0015,\allSidesClamped,1),
    Resonator1D(100,0.3,0.698698,0.001515,\bothClamped),
    Resonator2D(0,50,0.61,0.0015,\allSidesClamped,1),
];

// note that the mass ratio of the string to both plates is set as 2, meaning that this should increase the
// transfer of energy from the string to the plates in response to exciting the string as opposed to using
// an equal mass ratio
massMatrix = Array2D.fromArray(3,2,[
    1, 0,
    5, 5,
    0, 1
]);

// connect plates and strings
connPointMatrix = Array2D.fromArray(3,2,[
    {1.0.rand}!2, 0,
    1.0.rand,     1.0.rand,
    0,            {1.0.rand}!2
]);

// excite plate 1, the string and plate 2 at a random relative position
excPointMatrix = Array2D.fromArray(3,3,[
    {1.0.rand}!2, 0,        0,
    0,            1.0.rand, 0,
    0,            0,        {1.0.rand}!2
]);

// listen to plate 1, the string and plate 2 at a random relative position
readoutPointMatrix = Array2D.fromArray(3,6,[
    {1.0.rand}!2, {1.0.rand}!2, 0,        0,        0,            0,
    0,            0,            1.0.rand, 1.0.rand, 0,            0,
    0,            0,            0,        0,        {1.0.rand}!2, {1.0.rand}!2
]);

// construct our 3-object system and calculate its modal data (this can take a second or two
// depending on the available computing power)
~network = ResonatorNetwork(objs,connPointMatrix,massMatrix,excPointMatrix,readoutPointMatrix).calcModalData(minFreq:25,maxFreq:16000,gain:36.dbamp)
)

/*
******************
*SIMULATION STAGE*
******************
*/
(
// alternative excitation synth def for continuous excitation (adapted from an sctweet by nathaniel virgo)
SynthDef(\bandNoise,{ arg outBus = 0,amp = 1,freqLo = 50,freqHi = 12000,freqModT = 3e-02,gate = 1,cutoff = 80;
    var source = PinkNoise.ar;
    25 do: { source = BBandStop.ar(source,LFDNoise1.kr(freqModT).exprange(freqLo,freqHi),ExpRand(0.5,1.5)) };
    Out.ar(outBus,HPF.ar(LPF.ar(source,1e4,amp),cutoff))
}).add
)

// simulate output of string in response to exciting the string
(
~makeResonatorSynthDef.(
    ~network.modalData["biquadCoefs"]["a1"][2][1],
    ~network.modalData["biquadCoefs"]["a2"][2][1],
    ~network.modalData["biquadCoefs"]["b1"].neg,
    ~network.modalData["biquadCoefs"]["b2"].neg,
    \plate1_left
);

~makeResonatorSynthDef.(
    ~network.modalData["biquadCoefs"]["a1"][3][1],
    ~network.modalData["biquadCoefs"]["a2"][3][1],
    ~network.modalData["biquadCoefs"]["b1"].neg,
    ~network.modalData["biquadCoefs"]["b2"].neg,
    \plate1_right
)
)

(
s.makeBundle(nil,{
    x = Synth(\plate1_left,[\inBus,10,\outBus,0,\outputGain,1],1,\addToTail);
    y = Synth(\plate1_right,[\inBus,10,\outBus,1,\outputGain,1],1,\addToTail);
    z = Synth(\bandNoise,[\outBus,10],1,\addToHead)
})
)

x.free; y.free; z.free
