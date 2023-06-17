+ Pattern  {
	effect{ |symbol out=0 dur=10 server=(Server.default)|
		var pBus=Bus.audio(server,2).index;
		^Ppar([
			(instrument:symbol.asSymbol,dur:10,in:pBus, out:out)=>Pfin(1,_),
			this=>Pset(\out,pBus,_)
		])
	}
}

//Chain : Pattern {
//	var bus;
//	var pattern
//}
