// a function to get the n loudest partials for a formant filter using Klank and Vowel

// needs the Vowel quark:

"Vowel".include;


// tenor, for instance
a = "aeiou".as(Array).collect { |x| Vowel(x.asSymbol, \bass) };

// function for threshold
(
f = { |vowel, thresh = 0.9|
 var freqs = (40..10000).collect { |x| x + 0.5.rand2 };
 var result = [];
 freqs.do { |freq|
 var amp = vowel.ampAt(freq);
 if(amp > thresh) {
 result = result.add([freq, amp])
 }
 };
 result.size.postln;
 result.flop
};
)
g.(a[0], 0.7).value;
// or alternatively, for number of partials
(
g = { |vowel, numPartials = 30|
 var freqs = (40..10000).collect { |x| x + 0.5.rand2 };
 var result = [];
 freqs.do { |freq|
 var amp = vowel.ampAt(freq);
 result = result.add([freq, amp])
 };

 result = result.sort { |a, b| a[1] > b[1] }.keep(numPartials);

 result.flop
};
)

Vowel

// some examples

Ndef(\vow, { Klank.ar(`(f.(a[0], 0.7) ++ 0.2), Impulse.ar(MouseX.kr(1, 1000, 1))) * 0.001 }).play;
Ndef(\vow, { Klank.ar(`(f.(a[0], 0.3) ++ 0.2), Impulse.ar(MouseX.kr(1, 1000, 1))) * 0.001 }).play;
Ndef(\vow, { Klank.ar(`(f.(a[2], 0.7) ++ 0.2), Impulse.ar(MouseX.kr(1, 1000, 1))) * 0.001 }).play;
Ndef(\vow, { Klank.ar(`(f.(a[2], 0.3) ++ 0.2), Impulse.ar(MouseX.kr(1, 1000, 1))) * 0.001 }).play;

// use for instance to get the 42 loudest partials, for each vowel
z = a.collect { |x| g.(x, 42) }.flopDeep(1);
VocalFry.scd
Sent from Astro for Android
f;
Vowel.compose([\a,\e,\i], [\bass,\soprano,\alto], [0.2, 0.3, 0.5]);
Vowel.compose([\a,\e], [\soprano], [9, 4].normalizeSum);
Vowel.compose([\a], [\tenor, \counterTenor, \soprano], [1, 4, 2].normalizeSum);

(
{ var v = Vowel.compose(
    [\a, \e, \i], 
    [\soprano, \bass, \tenor, \counterTenor, \alto], 
    ({10.rand}!5).normalizeSum
);
Formants.ar(50 + 300.rand, v) * 0.1; 
}.play;
)

Klank.ar (Vowel(\a,\tenor));
Formlet

a=Vowel(\a,\tenor);
a.freqs;

(
{
    var in;
    in = Blip.ar(SinOsc.kr(5,0,20,300), 1000, 0.1);
    Formlet.ar(in, XLine.kr(1500,700,8), 0.005, 0.04);
}.play;
)

(
// mouse control of frequency and decay time.
{
    var in, freq;
    in =Impulse.ar(MouseX.kr(2,1000,0),0,20,300);
    Formlet.ar(in,
        MouseY.kr(700,2000,1),
        0.005, MouseX.kr(0.01,0.2,1));
}.play;
)

(
// mouse control of frequency and decay time.
{
    var freq;
    freq = Formlet.kr(
        Dust.kr(10 ! 2),
        MouseY.kr(7,200,1),
        0.005, MouseX.kr(0.1,2,1)
    );
    SinOsc.ar(freq * 200 + [500, 600] - 100) * 0.2
}.play;
)


