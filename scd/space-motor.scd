t=Steno.new;

t.quelle(\a,{Pan2.ar(ModSin(LFNoise1.kr(0.05,200,200),LFNoise1.kr(.011,2,5)))});

t.filter(\b,{|in|TwoTube.ar(in*0.2,d1length:LFNoise1.kr(0.3,200,3000),d2length:2321)});
t.filter(\c,{|in| Pan2.ar(in ,0)});

t.("ab");


g.free;
s.plotTree;