Phonemes {
	classvar <dicts,files;
	*initClass {
		files = #[ 
			"/Library/Application Support/Dreamtonics/Synthesizer V Studio/dicts/mandarin-xsampa/English.json",
			"/Library/Application Support/Dreamtonics/Synthesizer V Studio/dicts/japanese-romaji/English.json"
		];
		dicts = ();
	}
	*parseDicts {
		"loading dicts...".postln;
		[\xsampaDict, \romajiDict].do{|i x|
			dicts.put(
				i,
					files[x].standardizePath 
					=> File.readAllString(_)
					=> JSON.parse(_) 
			)
		};
		dicts = dicts.collect{|dict|
			dict.data.collect({|i|  i.w.asSymbol -> i.p }).asEvent
		}
	}
	*romajiDict {
		( dicts.size==0 ).if{ this.parseDicts }; 
		^dicts.romajiDict
	}
	*xsampaDict {
		( dicts.size==0 ).if{ this.parseDicts }; 
		^dicts.xsampaDict
	}
}
+ String {
	romaji {
		^this.replace(".").replace(",").replace("!").replace("?")
		.split(Char.space)
		.collect{|i|
			Phonemes.romajiDict.at(i.asSymbol)
		}
	}
	xsampa {
		^this.toLower.replace(".").replace(",").replace("!").replace("?")
		.split(Char.space)
		.collect{|i|
			Phonemes.xsampaDict.at(i.asSymbol)
		}
	}

}
