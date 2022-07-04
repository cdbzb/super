(
Song(\chamber1,[]).current;
//[ Chamber ] 
["SPOCK: Captain, the security guards. ","r"].addLine;
["KIRK: Kirk here. ","r"].addLine;
["SCOTT [OC]: Can you read me, Captain? ","r"].addLine;
["KIRK: Yes, Scotty, and I shouldn't be able to this deep inside the planet, but perhaps this has been arranged for us, too. Is the security guard up there?","r"].addLine;
//[ Transporter Room ]
["SCOTT: They're fine. They Just didn't dematerialise.","r"].addLine;
//[ Chamber ]
["SCOTT [OC]: I don't like it, sir. ","r"].addLine;
["KIRK: No problem yet. Maintain alert. Kirk out. ","r"].addLine;
["MULHALL: Atmosphere report, Captain. A fraction richer in oxygen than usual for us, but otherwise normal. ","r",[3]].addLine;
Song.trillFunc = {|lowerNoteDegree b p e|
	3.do{
		[
			freq:[lowerNoteDegree,11].df(\c).q(inf),
			dur: Pwhite(0.05,0.16,inf),
			legato:Prand([0.8,1.1],inf),
			pan:(-1).rrand(1.0),
			out: Effect({|i| i * Env.linen(0,b.sum,4).kr(2,gate:1) },inputChannels:2).bus.index
		].pm(\default).play
	}
};
P(\trill,start:\Atmos,music:{|p b e| 
	p.trillFunc.(7,b,p,e)
});
["SPOCK: This vault was constructed about a half a million years ago. About the same time the planet surface was destroyed, if our sensor readings are accurate. ","r",[5]].addLine;
P(\trill,start:\accurate,music:{|p b e| 
	p.trillFunc.(6.5,b,p,e)
});
["KIRK: Composition of walls? ","r"].addLine;
["SPOCK: They're an alloy or substance completely unknown to me. Much stronger and harder than anything I've measured before. ","r"].addLine;
["MULHALL: All readings are off the scale, Captain. ","r"].addLine;
["MCCOY: The air seems fresh. It must be re-circulated somehow. ","r"].addLine;
["KIRK: Is that for us, or does it need fresh air? ","r"].addLine;
)
