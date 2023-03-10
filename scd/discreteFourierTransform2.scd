(
~size =22;
~brown = Pbrown(0.8;,1.3,0.02).asStream;

~real = Signal.fill(~size,{~brown.next + 0.2.bilinrand} ) + 1 /6;// + Signal.fill(64,{|x| x/64} ) /;
~imag= Signal.newClear(~size);
~complex = ~real.dft(~imag, 'dir');

/////////// Processing goes here
~mask = 50/64*~size => _.floor;
~filtered = ~complex.real * Signal.rectWindow(~size,~mask);
~filtered2 = ~complex.imag* Signal.hammingWindow(~size,~mask); // why???
~complex = Complex(~filtered,~filtered2);

///////////
[ ~complex.real.idft(~complex.imag).real, ~real].plot;


[ dur:~complex.real.idft(~complex.imag).real.q , instrument:\snare ].pp;
[ dur: ~real.q, instrument:\hihat ].pp


)
~complex.imag.plot
[~complex.real,~complex.imag].plot
SignalRectWindow()

///
c = Signal.newFrom(b)
d = c.asWavetable
b=Buffer.loadCollection(s,d)
b.plot

