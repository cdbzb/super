(
~quarters = [0.5,1,1,1,1] + Array.fill(5,{0.05.rand.round(0.01)});
~eighths = "e e e e".asBeats;
~pickup = 0.5;
~quartersMod = ~quarters.put(0,~quarters[0] * ~pickup.reciprocal)
)
~quartersMod = ~quarters.collect{|i x| ( x==0 ).if{i.reciprocal}{i}}

~eighths.warpTo(~quartersMod);

