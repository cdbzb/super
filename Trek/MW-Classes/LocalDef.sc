LocalDef {
	var name;
	classvar <>dictionary;
	*initClass{
		dictionary = ()
	}
	*new {|function| 
		^super.new.init(function)
	}
	init { |function|

		var compileString=function.cs.asSymbol;
		dictionary.postln;
		dictionary.at(compileString).isNil.if {
			name = rrand(10**8,10**9).floor.asSymbol;
			SynthDef(name,function).add;
			dictionary.put(compileString,name);
			^name
		} {
			^dictionary.at(compileString)
		};
	}
}
+Function{
	playL {
		var def,synth;
		//LocalDef.dictionary.at(this.cs.asSymbol).isNil.if
		def = LocalDef(this);
		//(\type:\on,instrument:def).play
		fork{
			({SynthDescLib.at(def).isNil}).while({0.001.wait});
			synth = Synth.newPaused(def);
			Server.default.bind{synth.run}
		};
	}
	playE { 
		^(instrument:this).play.id[0]
		=>{|i|Node.basicNew(nodeID:i)}
	}
}

