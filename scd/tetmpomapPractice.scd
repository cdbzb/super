(
~durs = [ 0.802, 0.226, 0.32, 0.825, 0.241, 0.269, [ 0.379, 0.335, 0.406, 0.303 ] *0.9 ].flat;
~beats = "qE E E qE E E ex x ex x ".asBeats;
t = TempoMap(~beats,~durs);
//q = t.quantizeRangeInPlace(0.9,1,6);
q = t.quantizeWindow(0.5);
u=t.quantize(1);
[
	dur: "q e e q e e e e q".asBeats .warpTo(q) .q,
	freq: [1,3,4,5,2,4,6,7,5].df(\d,[3,4]).q,
	out:Effect( { |i| i * 5 => SineShaper.ar(_,0.2) /2   => FreeVerb.ar(_,0.1,0.9)},inputChannels:2 ).bus.index

].pp;
[
	dur:t.beats.warpTo(q).q,
	freq:[11,7,6,5,4,3,2,3,1,2].df(\d).q
].pp;
[
	freq: ".x.x.x.x".asDrumPat(4,4),
	instrument:\kick_gentle,
	dur:0.5!16=>_.warpTo(q)=>_.q
].pp;
[
	
	freq: "..x...x.".asDrumPat(4,4),
	instrument:\sn_808,
	dur:0.5!16=>_.warpTo(q)=>_.q,
	out:Effect(DWGReverbC1C3.ar(_,mix:0.2)).bus.index,
	out:Effect(DWGReverbC1C3.ar(_,mix:0.2)).bus.index
].pp;
[
	
	freq: "xxxxxxxx".asDrumPat(4,4),
	instrument:\hat_808,
	dur:[0.28,0.22]!12=>_.flat=>_.warpTo(t.quantizeWindow(0.8,5))=>_.q
].pp;


)
