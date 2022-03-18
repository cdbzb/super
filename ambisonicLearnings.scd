(
~size = 4096;  // SC's Pan2 size

~pos = Array.interpolation(~size, -1.0, 1.0);  // pan position

// sine-cosine panning law
(
~sinCosLaw = (pi / 4 * Array.with(
	(~pos.neg + 1),  // left
	(~pos + 1)  // right
)
	).sin;
);

// plot!
~sinCosLaw.at(0).plot("sin-cos: left");
~sinCosLaw.at(1).plot("sin-cos: right");
)
'Ambisonic Enlightenment'.help
// ------------------------------------------------------------
// 5.0 decoder
//
// mono pink noise source
// omni encoder


// define encoder / decoder matrices
~encoder = FoaEncoderMatrix.newOmni
//~decoder = FoaDecoderMatrix.newDiametric([[45,24], [0,-45],[ -45,24 ]].degrad)
~decoder = FoaDecoderMatrix.newPanto(5,'flat',1);

// inspect
~encoder.kind
~encoder.numChannels
~encoder.dirChannels

~decoder.kind
~decoder.numChannels
~decoder.dirChannels.raddeg


(
{
    var sig;// audio signal
    var angle, azim;            // angle and azimuth control
    var f1, f2, b1, b2, rr,fl;        // 5.0 output channels
    var lo;                 // low freq channel place holder


    // display encoder and decoder
    "Ambisonic encoding via % encoder".format(~encoder.kind).postln;
    "Ambisonic decoding via % decoder".format(~decoder.kind).postln;

    // angle ---> top         = push to plane wave
    //            bottom        = omni-directional
    angle = MouseY.kr(pi/25, 0);
    angle =LFBrownNoise1.kr(0.2).range(05,pi/2);
    angle = SinOsc.kr(0.101.rand).range(0,pi/2);
    //angle = 0;


    //(instrument:\stringyy,out:4,amp:0.8,dur:10).play
    // azimuth -> hard left     = back
    //          centre     = centre
    //          hard right     = back
    azim = MouseX.kr(pi, -pi);
    azim = LFBrownNoise1.kr(1)*pi;
    azim = SinOsc.kr(0.11.rand).range(pi,-pi);
    //azim = -pi;
    //azim = 0;


    // ------------------------------------------------------------
    // test sig
    sig = 6.collect{ [
	    WhiteNoise.ar(0.05)* Gendy1.kr(minfreq:1,maxfreq:13)=>MoogFF.ar(_,400.rrand(13000)) * 10,	    // mono pink noise
	    Gendy1.arWidth(freq:[300,350,400,500,900]*([2,0.5,0.3].choose*[1,1.33,1.5].choose)+ SinOsc.kr(2.rrand(5.2))) => Mix.ar(_) => LeakDC.ar(_) *0.05 ,
	    Blip.ar(2.rrand(6)*100+10,40)*0.5
    ].choose
     


    // ------------------------------------------------------------
    // encode
    => FoaEncode.ar(_, ~encoder)
    //sig = FoaPanB.ar(sig,SinOsc.ar(0.1).range(-pi,pi),SinOsc.ar(0.087).range(-pi , pi));

    // ------------------------------------------------------------
    // transform
    => FoaTransform.ar(_, 'press', angle, azim)
    //sig = FoaProximitysig.ar(sig,SinOsc.ar(0.3.rand).range(3,15))/10;
    } => Mix.ar(_) * 0.1
    =>FoaTransform.ar(_,'pressZ',SinOsc.ar(0.1))
    //ROTATE
    //=>FoaRTT.ar(_,SinOsc.kr(2))
    ;


    // ------------------------------------------------------------
    // decode (to 5.0)

    FoaDecode.ar(sig, ~decoder)[[0,1,2,4,3]];
    //lo = Silent.ar;

    //[f1, f2,b1, b2, rr, fl]    // reorder output to match speaker arrangement

}.play;
)
Atk.downloadKernels;
Atk.downloadMatrices;
Atk.downloadSounds;	
Atk
QuarksGui.new
Quarks.install("https://github.com/ambisonictoolkit/atk-sc3.git");

