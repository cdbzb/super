(
~quarters = [0.5,1,1,1,1] + Array.fill(5,{0.05.rand.round(0.01)});
~eighths = "e q q q".asBeats;
~pickup = 0.5;
~quartersMod = ~quarters.collect{|i x| ( x==0 ).if{i.reciprocal}{i}};
~quartersMod = ~quarters.put(0,~quarters[0] * ~pickup.reciprocal)
)

~eighths.warpTo(~quartersMod);
"e q q q ".parseBeats(start:1)
a = Song.section(\impossible)

a=Song.parseBeats(\impossible, "e e e E E E e x x e e q".asBeats, 0)
b=Song.asBeatsPickup(\impossible, "e | e e E E E e x x e e q")
b=Song.setQuartersPickup(\impossible, "e | e e E E E e x x e e q")
Song.quarters[\impossible]
Song.durs[\impossible].list
(
[
dur:b.q,
lag:Song.durs[\impossible].list[0]
].pp
;
[
dur:a.q,
freq:700

].pp;
Song.pbind[\impossible].play
)
1

