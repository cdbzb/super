SynthBus {
	var <synth,<nodes, server, <controls, <>defName;

	*new {|def server| ^super.new.init(def,server)}

	//*new { |defName, args, target, addAction=\addToHead| ^super.new.init(defName,args,target,addAction)}

	controlsPlus {^controls.collect{|i| 
		nodes.put((i++\_).asSymbol,nodes.at(i));
		[i,(i++\_).asSymbol]}.flatten
	}

	init { |def args|
		nodes=();
		server.isNil.if{server=Server.default};
		controls=def.controlNames;
		synth=Synth(def.asSymbol,args:[args]);
		controls.do{|i| var n=NodeProxy.control(server,1);synth.map(i.asSymbol,n);nodes.put(i,n)};
		args.pairsDo{|key value| nodes.at(key).source = {value}};
		//( NodeProxy.control(server,1).source_({freq});
		//synth.map(\freq,node);
		^this
	}
	//hmm but what if we want to message the synth!!

	release {|time| synth.release(time); time.isNil.if{time=0}; fork{time.wait;nodes.do(_.free)}}

	doesNotUnderstand {|selector ...args|
		var key = selector.asSymbol;
		//send messages to the nodes
		this.controlsPlus.includes(key).if( {
			^this.nodes.at(key)
			//(key ++ ' ' ++ args).postln;
			//Message(nodes.at(key),args).value;
			//Message(nodes.at(key),args).postln;
		},{
			[synth,key,args].postln;
			//Message(synth,key,args).value
			^[synth,key,args];
			
		});
		//TODO otherwise send messages to the synth!
		^nodes
	}
}

+ Symbol {
	controlNames { |defName|
		^SynthDescLib.at(this).controls.select({|i|i.rate==\control}).collect(_.name)
	}
}
