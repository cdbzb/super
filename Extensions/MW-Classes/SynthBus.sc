SynthBus {
	var <synth,<nodes, server, <controls;

	*new {|def freq server| ^super.new.init(def,freq,server)}

	controlsPlus {^controls.collect{|i| 
		nodes.put((i++\_).asSymbol,nodes.at(i));
		[i,(i++\_).asSymbol]}.flatten
	}

	init { |def freq server|
		nodes=();
		server.isNil.if{server=Server.default};
		controls=def.controlNames;
		synth=Synth(def.asSymbol,freq:400,amp:0.1);
		controls.do{|i| var n=NodeProxy.control(server,1);synth.map(i.asSymbol,n);nodes.put(i,n)};
		//( NodeProxy.control(server,1).source_({freq});
		//synth.map(\freq,node);
		^this
	}
	//hmm but what if we want to message the synth!!

	doesNotUnderstand {|selector ...args|
		var key = selector.asSymbol;
		//send messages to the nodes
		this.controlsPlus.includes(key).if {
			^this.nodes.at(key)
			//(key ++ ' ' ++ args).postln;
			//Message(nodes.at(key),args).value;
			//Message(nodes.at(key),args).postln;
		};
		//TODO otherwise send messages to the synth!
		^nodes
	}
}

+ Symbol {
	controlNames { |defName|
		^SynthDescLib.at(\default).controls.select({|i|i.rate==\control}).collect(_.name)
	}
}
