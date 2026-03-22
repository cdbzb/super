Phonemes {
	classvar <dicts, files, <inventories, <schemes;
	*initClass {
		files = #[
			"/Library/Application Support/Dreamtonics/Synthesizer V Studio/dicts/mandarin-xsampa/English.json",
			"/Library/Application Support/Dreamtonics/Synthesizer V Studio/dicts/japanese-romaji/English.json"
		];
		dicts = ();
		schemes = (
			english: "arpabet",
			mandarin: "xsampa",
			chinese: "xsampa",   // alias for mandarin
			japanese: "romaji",
			korean: "xsampa"
		);
		inventories = (
			english: (
				vowels: [
					"aa","ae","ah","ao","aw","ax","ay",
					"eh","er","ey","ih","iy","ow","oy","uh","uw"
				],
				consonants: [
					"b","ch","d","dx","dr","dh","f","g","hh","jh",
					"k","l","m","n","ng","p","r","s","sh","t",
					"tr","th","v","w","y","z","zh"
				]
			),
			mandarin: (
				vowels: [
					"a","A","o","@","e","7","U","u","i","y",
					"AU","@U","ia","iA","iAU","ie","iE",
					"iU","i@U","ua","uA","u@","ue","uo"
				],
				consonants: [
					"p","ph","t","th","k","kh",
					"ts","tsh","ts`","ts`h",      // alveolar & retroflex affricates
					"ts\\","ts\\h",                // alveolopalatal affricates (j, q)
					"s","s`","s\\",                // fricatives (s, sh, x)
					"z`",                          // retroflex approximant (r)
					"x","f","l","m","n","N"
				]
			),
			japanese: (
				vowels: ["a","i","u","e","o"],
				consonants: [
					"t","ty","d","dy","s","sh","j","z","ts","ch",
					"k","ky","g","gy","h","hy","b","by","p","py",
					"n","ny","m","my","r","ry","f","kw","gw","N","w","y"
				]
			),
			korean: (
				vowels: ["6","e_o","i","M","o","u","V"],
				consonants: [
					"4","l","b","p","pp","d","t","tt","g","k","k_t",
					"dz\\","ts\\_h","ts\\h",
					"h","m","n","N","s","s_t","w","j"
				]
			)
		);
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

	*resolveAliases { |languages|
		var aliases = (chinese: \mandarin);
		^languages.collect{|lang| aliases[lang] ? lang }
	}

	*pool { |languages, mode=\union, scheme, raw=false|
		var vowels, consonants, filtered;
		languages = this.resolveAliases(languages);
		filtered = raw.if{ languages }{
			languages.select{|lang| schemes[lang] == scheme }
		};
		(filtered.size == 0).if{
			"Phonemes.pool: no languages match scheme '%'. Use raw:true to bypass.".format(scheme).warn;
			^nil
		};
		vowels = filtered.collect{|lang| inventories[lang].vowels };
		consonants = filtered.collect{|lang| inventories[lang].consonants };
		(mode == \intersection).if{
			vowels = vowels.reduce(\sect);
			consonants = consonants.reduce(\sect);
		}{
			vowels = vowels.flat.as(Set).asArray;
			consonants = consonants.flat.as(Set).asArray;
		};
		^(vowels: vowels, consonants: consonants)
	}

	// per-language pools — one entry per language, for per-note selection
	*langPools { |languages|
		languages = this.resolveAliases(languages);
		^languages.collect{|lang|
			(
				language: lang,
				scheme: schemes[lang],
				vowels: inventories[lang].vowels,
				consonants: inventories[lang].consonants
			)
		}
	}

	// Returns array of \c and \v, collapsing consecutive runs
	*cvPattern { |syllable|
		var vowelChars = "aeiouAEIOU";
		var pattern = List.new;
		var last = nil;
		syllable.do{|char|
			char.isAlpha.if{
				var type = vowelChars.includes(char).if{ \v }{ \c };
				(type != last).if{
					pattern.add(type);
					last = type;
				}
			}
		};
		// ensure at least one vowel for singability
		(pattern.includes(\v).not).if{ pattern.add(\v) };
		^pattern.asArray
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

	vowelRun { |voice, languages, min=3, max=5|
		var pools = Phonemes.langPools(languages);
		var syllables = this.replace(",", "").replace(".", "")
			.replace("!", "").replace("?", "")
			.split(Char.space).reject{|i| i.size == 0 };
		var phonemes, langOverrides, phonesetOverrides;
		phonemes = List.new;
		langOverrides = List.new;
		phonesetOverrides = List.new;
		syllables.do{|syl|
			(["+", "-"].includes(syl)).if{
				phonemes.add("");
				langOverrides.add("");
				phonesetOverrides.add("");
			}{
				var pick = pools.choose;
				phonemes.add(
					rrand(min, max).collect{ pick.vowels.choose }.join(" ")
				);
				langOverrides.add(pick.language.asString);
				phonesetOverrides.add(pick.scheme);
			}
		};
		^(
			phonemes: phonemes.asArray,
			languageOverride: langOverrides.asArray,
			phonesetOverride: phonesetOverrides.asArray
		)
	}

	morphPhonemes { |voice, languages|
		var pools = Phonemes.langPools(languages);
		var syllables = this.replace(",", "").replace(".", "")
			.replace("!", "").replace("?", "")
			.split(Char.space).reject{|i| i.size == 0 };
		var phonemes, langOverrides, phonesetOverrides;
		phonemes = List.new;
		langOverrides = List.new;
		phonesetOverrides = List.new;
		syllables.do{|syl|
			(["+", "-"].includes(syl)).if{
				phonemes.add("");
				langOverrides.add("");
				phonesetOverrides.add("");
			}{
				var pick = pools.choose;
				var pattern = Phonemes.cvPattern(syl);
				phonemes.add(
					pattern.collect{|cv|
						(cv == \v).if{ pick.vowels.choose }{ pick.consonants.choose }
					}.join(" ")
				);
				langOverrides.add(pick.language.asString);
				phonesetOverrides.add(pick.scheme);
			}
		};
		^(
			phonemes: phonemes.asArray,
			languageOverride: langOverrides.asArray,
			phonesetOverride: phonesetOverrides.asArray
		)
	}
}
