(
    p ="/Users/michael/tank/super/Extensions/SonoroUgens/AdachiAyers/impulses/trombon/";
    //p = Platform.systemExtensionDir ++ "/Myplugins/AdachiAyers/impulses/trumpet/";

    b = Buffer.read(s,p++"Rgi.wav");
    c = Buffer.read(s,p++"Rgd.wav");
    d = Buffer.read(s,p++"Rrbri.wav");
    e = Buffer.read(s,p++"POUI.wav");

    //Define reverb synthdef
    ~nbuf = 2048*4;
    SynthDef(\reverb,{
        |out = 0, len = 2000, roomsize = #[6.2,8,2.7], receiver = #[3,3,1.2], b = 0.74, hw = 0.4, n = 3, revl = 0.3, bypass = 0, dist=1,angle=0.2|
        var in, bufL, bufR, trig, sigL, sigR, early, sig;
        var omangle = angle*pi*0.5;
        var source = [receiver[0] + (omangle.sin*dist), receiver[1] + (omangle.cos*dist), receiver[2]];
        in = Mix(In.ar(out,2))*0.5;
        bufL = LocalBuf(~nbuf);
        bufR = LocalBuf(~nbuf);
        trig = EarlyRefGen.kr(bufL, bufR, source, receiver, roomsize, hw, b.neg, n);
        sigL = PartConvT.ar(in, 2048, bufL, trig);
        sigR = PartConvT.ar(in, 2048, bufR, trig);
        early = [sigL, sigR];
        sig = DWGReverb3Band.ar(Mix(early) * 0.5, len) * revl + early;
        sig = Select.ar(bypass, [sig, in]);
        ReplaceOut.ar(out, sig);
    }).add;

    //Define trombone synthdef
    SynthDef("help_AdachiAyers",{arg out=0, radio=0.0085, reflec=0, reflec2=0,reflec3=0, kernel=0,trig=0,open=0.0014,gate=1,sweep=0.1,delay=800,gdamp=0.003,pan=0;

        var presion = MouseX.kr(6000,40000);
        var flip = 500;
        //var flip = MouseY.kr(30,1200);
        var env = EnvGen.kr(Env.asr(0,1,0.1),gate,doneAction:2);
        var gd2= SinOsc.kr(4,0,gdamp,1);
        var signal = AdachiAyers.ar(Lag.kr(flip*gd2,sweep),presion,radio,reflec,reflec2,reflec3,open,1,delay)*80;

        signal = Convolution2.ar(signal,kernel,trig,2048, 0.5)*env;
        signal = LeakDC.ar(signal);

        Out.ar(out,Pan2.ar(signal,pan));
    }).add;
    )
    s.meter

    (
	    x = Synth(\help_AdachiAyers,[\kernel, e,\reflec,b,\reflec2,c,\reflec3,d]);
	    x.set(\sweep,0.5);
	    [set:Pfunc({var b=rrand(100,800);x.set(\delay,b.reciprocal*44100/4);x.set(\flip,b*1.1)}),amp:0].pp
    )



(

{ MembraneCircleV.ar(Impulse.ar(2)=>Decay.ar(_,0.05)*ClipNoise.ar(1),ewidth:SinOsc.kr(10.reciprocal).unipolar,a1:SinOsc.kr(9.7.reciprocal).unipolar) }.play
{ MembraneCircleV.ar(Impulse.ar(2.11,)=>Decay.ar(_,0.1),tension:0.01,ewidth:SinOsc.kr(1.reciprocal).unipolar,a1:SinOsc.kr(9.7.reciprocal).unipolar) }.play(s)
{ MembraneCircleV.ar(Impulse.ar(2.11,)=>Decay.ar(_,0.1),tension:0.02,ewidth:SinOsc.kr(1.reciprocal).unipolar,a1:SinOsc.kr(9.7.reciprocal).unipolar) }.play(s)
)
(
{ PluckSynth.ar(freq: 440,  amp: 1,  gate: 1,  pos: 0.2,  c1: 0.25,  c3: 5,  release: 0.1,  f: 1,  m: 1,  k: 1,  r: 025,  l: 0.65,  ra: 0.001,  rho: 7850) }.play
)

/*
freq      Sound frequency.
  amp       Level amplitude. Betwen 0 and 1.
  gate      Releases synth when value changes from >0 to 0.
  pos       Relative pluck position from 0 to 1.
  c1        Inverse of DC decay time.
  c3        Hight frequency loss factor.
  release   Release time in seconds.
  f         Player force.
  m         System mass.
  k         String stiffness.
  r         Damping coefficient.
  l         String length.
  ra        String radio.
  rho       density of string.
  */
   SynthDef(\guitar, { arg out=0, freq=200, amp=0.5, t_gate=1,pos=1-1/7,c1=1,c3=35,
    release=0.1,facM=3,facK=1500,facR=5,facF0=50,fEatt=6, fEc1= -8 ,fEc2= -8,facatt=6,l=0.65,ra=0.001,rho=7850,pL=1,gate=1,pan=0;
        var facrel = LinExp.kr(amp,0,1,2,0.005).max(0.005);
        var rel = facrel*0.001; 
        var att = facatt *0.001;
        var attF = fEatt * 0.001;
        var envF = Env.new([0,0, 1, 0], [0,attF, rel],[fEc1,fEc2]);
        var env2 = Env.new([0,pL,pL,0],[0,att,rel],1);
        var envR = Env.new([0,1,1,0],[0,att,rel],1);
        var f = EnvGen.ar(envF,t_gate)*amp*facF0;
        var m = 0.001 * facM * EnvGen.ar(env2,t_gate);
        var k = facK * EnvGen.ar(env2,t_gate); 
        var r = facR * EnvGen.ar(envR,t_gate); 
        
        var son = 32000*PluckSynth.ar(freq, amp, gate,pos,c1,c3,release,f,m,k,r,l,ra,rho);
         Out.ar(out, Pan2.ar(son ,pan));
    }).add;
    [ instrument:\guitar,rho:1000,pos:0.2,ra:0.001,freq:[300,400,360,181],strum:0.06,dur:[Pwhite(0.05,0.08,Pwhite(4,8,1)),Pwhite(4,6.0) ].q(5)].p.play

