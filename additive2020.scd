(
g=Group.new();
[out:Pwhite((0.3),inf),amp:0.06000,dur:Pwhite(0.5,2),freq:Prand([300,360,400,480],inf),type:\tuneUp].pp;
[group:g,amp:0.1000,dur:Pwhite(1,1.5),freq:Prand([300,360,400,480],inf),type:\tuningGong].pp;
[dur:Pwhite(0.1,1),freq:Prand([300,360,400,480],inf),type:\reedy].pp;
{g.set(\transpose,1.2);10.0.rand}.sched(10)
)
 SynthDef(\add,{|freq=440 cutoff=12000|
	 var partials = (1..60)
	 .select(_.isPrime);
	 var mutes = ( partials * freq) < cutoff;
	 var sig = 60.collect{|i|SinOsc.ar(( i+1 )*freq + SinOsc.kr(Rand(1.5)).range(-5,5),0,(0.1/( i+1 ))+LFBrownNoise1.kr(1/10).range(-0.1,0.1))};
	 sig * mutes
	 => Mix.ar(_)
	 => Out.ar(1,_)
	 }).add;
SynthDef(\addPlusNoise,{|freq=400 cutoff=12000 blend=1 |
	//var step = \step.ir(9);
	var step = 19;
	var floor = 400;
	var numberOfPartials = (12000-floor)/step/10 => _.asInteger;
	var linear = Array.series(numberOfPartials,10,freq);
	var randomExponential = Array.exprand(numberOfPartials, freq, 20000);
	numberOfPartials.collect{|x|SinOsc.ar(linear[x]*blend+(randomExponential[x]*(1-blend)))*1/1000}
	=> Mix.ar(_)
	=> Out.ar(\out.kr(0),_)

}).add;
)
DynKlang
(
a = Synths(\addPlusNoise,\out,(0..3));
a.set(\blend,0.99);
b = Bus.control(s,4);
a.map(\blend,b);
{LFBrownNoise1.kr({1.0.rand} dup: 4).unipolar}.play(s,b.index)
)
 (
  a=Synth(\add,[\freq,450,\cutoff,8300]);
  b= Bus.control(s,1);
  a.map(\cutoff,b);
  c={SinOsc.kr(1/6).unipolar*10000+2000}.play(s,b);
  c.free
  b.set(15000);
  b.scope;
  b.index
 )
(
    fork {
        loop {
            play {
                var mod = SinOsc.kr(Rand(0.1, 0.9), 0, Rand(5, 20));
		var freqs = Array.exprand(500.rand,400,22000);
		var levels = freqs.collect({|i|1/(i)});
		var wobbl=freqs.collect([0,1].choose);
                Pan2.ar(DynKlang.ar(`[ freqs,levels*400,mod*wobbl]), 1.0.rand)
                    * EnvGen.kr(Env.sine(4), 1, 0.02, doneAction: Done.freeSelf)
            };
            2.wait;
        }
    }
    )
    a.add(2)
    ~reps
    s.forceReboot
    a
    ( // rising gong-like sounds
	    fork{
		    3.do{
			    a=[];
			    ~reps = [3].q(12).asStream;
			    ~reps = Prand([1,3,4,0.6], 12).asStream;
			    {
				    ~nearHarmonic = {|freq x| 20.collect({|i| (i*freq / x)-1 }).abs.inject(100,_ min: _)};
				    ~even = Array.series(100,400,20);
				    ~even = Array.rand(100,400,20000);
				    ~near = { |fund| ~even.collect({|i| (~nearHarmonic.(fund,i)<0.03).if{0}{1}  })};
				    ~near.(450);
				    SynthDef(\tuneUp,{
					    var blend = 1-(Line.kr(0,1,9)*~near.(~root ? 500));
					    SinOsc.ar(~even+\transpose.kr(0,5),0,0.01*blend)
					    * blend
					    => Mix.ar(_)
					    * Env.linen([ 0,0,0,5 ].choose,8,20).kr(2,gate:1)
					    * 1
					    => Out.ar(\out.kr(1),_)
				    }).add;
				    //idea add count to sched ?
				    a=a.add(Synth(\tuneUp,[\out,4.rand]));~reps.next}.sched(0.5);
				    {a.do(_.set(\transpose,50))}.sched(15);
			    15.wait
			    };
		    };
)
~reps
[1,2,3,4,5].scan(0,{|a b| a+1/b })
Array.rand(100,0.001,1.0).round(0.01).sort
\bilin.help

.lincurve()
(1..60).reciprocal
( //tune up sound - sounds good with the one above
	~reps = [10].q(10).asStream;
~numberOfPartials = s.sampleRate/150/2;
//~noise = Array.exprand(~numberOfPartials,150,s.sampleRate/2).sort;
~noise = Array.rand(~numberOfPartials,100,s.sampleRate/2).sort;
~tone = (~numberOfPartials-1).asInteger.collect({|i| ( i + 1 ) * 150 });
{

	{
		var line = Line.kr(0,1,10);
		var freq = line * ~tone + ( (1-line) * ~noise );
		var amp =
		(1..(~numberOfPartials+1)).reciprocal;
		//Array.geom(~numberOfPartials,0.01,0.98);
		SinOsc.ar(freq,0,amp)
		=> Mix.ar(_)
		* Env.linen(1,1,11).kr(2,gate:1)
		* 0.2


	}.play;
	~reps.next
} => SystemClock.sched(1,_);
)
~cents=2**((1200/_).reciprocal);
( //fat sound that gets in tune
var detune = 25;//cents
var noise = Array.rand(100,~cents.(detune),~cents.(detune).reciprocal);
var chord =[1,3/2,4/3,5/6];
chord = [1,3,5,6].collect(Scale.major.ratios[_])++chord * [0.5,1,2]
//*[1,3/2] => _.flat
;
{{
	var line = Line.kr(1,0,10)+LFBrownNoise1.kr().range(0,0.5);
	var blur = noise*line+(1-line);
	var fundamental = chord.choose*150;
	var numberOfPartials = s.sampleRate/fundamental/2 => _.floor => _.asInteger;
	SinOsc.ar(
		fundamental
		+SinOsc.kr(5).range(0,1)
		*(1..numberOfPartials) *blur,
		//SinOsc.kr(2.0.rand).range(-3,3)
		0
		,
		0.1 *
		((1..numberOfPartials)*2).reciprocal
		//higr number is darker
		**rrand(1.0,2.0)
		//makes is organ-y
		*Array.fill(100,{[0,1,1,1].choose})

	)

	=>Mix.ar(_) =>_.tanh
	* Env.linen(0.5,3,9).kr(2,gate:1)
	=> Out.ar((0..3).choose,_)
}.play(target:ParGroup.new());[0.1,0.1,0.2,0.1,0.21,6].choose} => SystemClock.sched(0.5,_)
)
(
~reedy = { |freq = 400|
	{
	var numberOfPartials = s.sampleRate/freq/2 => _.floor => _.asInteger;
	var detune = 25;//cents
	var noise = Array.rand(numberOfPartials,~cents.(detune),~cents.(detune).reciprocal);
		var line = Line.kr(1,0,10)+LFBrownNoise1.kr().range(0,0.5);
		var blur = noise*line+(1-line);
		SinOsc.ar(
			freq
			+SinOsc.kr(5).range(0,1)
			*(1..numberOfPartials) *blur,
			0
			,
			0.1 *
			((1..numberOfPartials)*2).reciprocal
			//higr number is darker
			**rrand(1.0,2.0)
			//makes is organ-y
			*Array.fill(100,{[0,1,1,1].choose})

			)

	=>Mix.ar(_) =>_.tanh
	* Env.linen(0.5,3,9).kr(2,gate:1)
	=> Out.ar((0..3).choose,_)
}.play
};
Event.addEventType(\reedy,{var freq= ~freq; topEnvironment.use{~reedy.(freq)}},(type:\note));
)
(type:\reedy,freq:500).play;
[type:\reedy,dur:Pwhite(0.1,1),degree:Pwhite(3,20)-8,freq:Pfunc({|e|e.degree.df('c')})].pp

(
[type:\reedy,key:[\b,\d].q(inf).stutter(12),
deg:[1,3,5,7].q(inf),
freq:Pfunc({|e| (e.deg).df(e.key)})
].p.trace.play
)
~bandLimit = {|array freq| array.reject( (s.sampleRate/2) < ( _*freq ))};
~bandLimit.( (1..100),500)
(
a=Harmonics(100).rand(1,100) => ~bandLimit.(_,400);
{ SinOsc.ar(a.sort*400,0, 0.01)}.play

)
~reedy.([1,3,5].df())
[1,3,5,7].df('c').do(~reedy.(_));
[type:\set,freq:Pwhite(0,28),device:Pfunc({|e|~reedy.([e.freq].df().unbubble)}),freq:Pwhite(300,888)].p.trace.play;
[amp:0.3,instrument:\stringyy,type:\note,degree:Pwhite(0,20)].p.trace.play;
[degree:Pbrown(-10,20,1),legato:Pwrand([1,3,10],[9,1,1]/11,inf),dur:Pwhite(0.1,1)].pp
(note:1).play
.sine2
Buffer
s.makeGui
{SinOsc.ar( (1..10000)*00 ) => Mix.ar(_)}.play;s.makeGui
~numHarmonics=(s.sampleRate/2)/_=>_.floor
~numHarmonics.(60)
440*50
60*367


