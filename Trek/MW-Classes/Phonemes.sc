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
					"4","l","b","p","d","t","g","k","k_t",
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
	// Strips silent trailing 'e' after consonant (rice→CVC not CVCV)
	*cvPattern { |syllable|
		var vowelChars = "aeiouAEIOU";
		var letters = syllable.select{|c| c.isAlpha };
		var pattern = List.new;
		var last = nil;
		// drop silent trailing e: if word ends in consonant+e and has another vowel
		(letters.size > 2 and: {
			"eE".includes(letters.last) and: {
				vowelChars.includes(letters[letters.size - 2]).not and: {
					letters.drop(-1).any{|c| vowelChars.includes(c) }
				}
			}
		}).if{ letters = letters.drop(-1) };
		letters.do{|char|
			var type = vowelChars.includes(char).if{ \v }{ \c };
			(type != last).if{
				pattern.add(type);
				last = type;
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

	vowelRun { |voice, languages, min=3, max=5, randomSeed=12345|
		var pools = Phonemes.langPools(languages);
		var rng = Pseq((0..999), inf).asStream;
		var syllables = this.replace(",", "").replace(".", "")
			.replace("!", "").replace("?", "")
			.split(Char.space).reject{|i| i.size == 0 };
		var phonemes, langOverrides, phonesetOverrides;
		thisThread.randSeed = randomSeed;
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

	morphPhonemes { |voice, languages, randomSeed=12345|
		var pools = Phonemes.langPools(languages);
		var syllables = this.replace(",", "").replace(".", "")
			.replace("!", "").replace("?", "")
			.split(Char.space).reject{|i| i.size == 0 };
		var phonemes, langOverrides, phonesetOverrides;
		var vowelMap, consonantMap;
		thisThread.randSeed = randomSeed;
		phonemes = List.new;
		langOverrides = List.new;
		phonesetOverrides = List.new;
		// per-language substitution ciphers: same input char → same output phoneme
		vowelMap = IdentityDictionary.new;
		consonantMap = IdentityDictionary.new;
		syllables.do{|syl|
			(["+", "-"].includes(syl)).if{
				phonemes.add("");
				langOverrides.add("");
				phonesetOverrides.add("");
			}{
				var pick = pools.choose;
				var langKey = pick.language;
				var pattern = Phonemes.cvPattern(syl);
				var vowelChars = "aeiouAEIOU";
				var letters = syl.select{|c| c.isAlpha };
				var vIdx = 0, cIdx = 0;
				// ensure per-language maps exist
				vowelMap[langKey].isNil.if{ vowelMap[langKey] = () };
				consonantMap[langKey].isNil.if{ consonantMap[langKey] = () };
				phonemes.add(
					Phonemes.cvPattern(syl).collect{|cv|
						var charGroup, mapKey, map;
						(cv == \v).if{
							// collect consecutive vowel chars as the group
							charGroup = "";
							while({ vIdx < letters.size and: { vowelChars.includes(letters[vIdx]) } }, {
								charGroup = charGroup ++ letters[vIdx];
								vIdx = vIdx + 1;
							});
							mapKey = charGroup.toLower.asSymbol;
							map = vowelMap[langKey];
							map[mapKey].isNil.if{
								map[mapKey] = pick.vowels.choose;
							};
							map[mapKey]
						}{
							// collect consecutive consonant chars as the group
							charGroup = "";
							while({ cIdx < letters.size and: { vowelChars.includes(letters[cIdx]).not } }, {
								charGroup = charGroup ++ letters[cIdx];
								cIdx = cIdx + 1;
							});
							mapKey = charGroup.toLower.asSymbol;
							map = consonantMap[langKey];
							map[mapKey].isNil.if{
								map[mapKey] = pick.consonants.choose;
							};
							map[mapKey]
						}
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
