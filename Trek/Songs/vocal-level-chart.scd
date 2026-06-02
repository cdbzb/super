/*  vocal-level-chart.scd  — Trek per-section vocal gain reporter
 *
 *  Usage:   Trek.prepare;                       // load all songs (populates synthVTracks per song)
 *           thisProcess.interpreter.executeFile("/Users/michael/tank/super/Trek/Songs/vocal-level-chart.scd");
 *           ~vocalLevelChart.();                 // whole show
 *           ~vocalLevelChart.(role: \mccoy);     // one character across sections
 *
 *  Columns per section:  role  voice  fader(dB)  track(dB)  sum(dB)
 *    fader  = section ASR-fader sustain dB        (parsed from Trek.faders[i].cs)
 *    track  = synthVTracks[voice] baked gain dB   (parsed from the voice fn .cs)
 *    sum    = fader + track  (relative vocal level; ignores reverb-wet, compressor, limiter)
 *
 *  GAINS are read LIVE (re-run after you re-tune and numbers update).
 *  role->voice mapping + roles-present are a SNAPSHOT of the source cast
 *  (the binary `trek_cast` archive is mutated per-song at load, so it can't be
 *  read back per-section; baked below from the song files).
 */
(
// ---------- parsers (validated against the real voice/fader strings) ----------
~depthAt = { |str, idx|
	var d = 0;
	idx.do { |i| var c = str[i]; (c == $() .if { d = d + 1 }; (c == $)) .if { d = d - 1 } };
	d
};
~stripComments = { |src|
	src.split($\n).collect { |ln| var c = ln.find("//"); c.notNil.if { ln.keep(c) } { ln } }.join("\n")
};
~parseGainDb = { |src|
	var clean = ~stripComments.(src);
	var db = 0, lin = 1.0, flags = [];
	clean.findRegexp("-?[0-9]+\\.?[0-9]*\\.dbamp").do { |m|
		(~depthAt.(clean, m[0]) == 0).if { db = db + m[1].drop(-6).asFloat };
	};
	clean.findRegexp("[*/] *[0-9]+\\.?[0-9]*").do { |m|
		var idx = m[0], str = m[1], op = str[0];
		var numStr = str.drop(1).stripWhiteSpace;
		var tail = clean.copyRange(idx + str.size, idx + str.size + 5);
		numStr.endsWith(".").if { numStr = numStr.drop(-1) };
		((~depthAt.(clean, idx) == 0) and: { tail.beginsWith("dbamp").not }).if {
			(op == $*).if { lin = lin * numStr.asFloat } { lin = lin / numStr.asFloat };
		};
	};
	(clean.findRegexp("\\* *amp").size > 0).if {
		var hi = clean.findRegexp("amp *=");
		(hi.size > 0).if {
			var win = clean.copyRange(hi[0][0], hi[0][0] + 16);
			var nums = win.findRegexp("[0-9]+\\.?[0-9]*").collect { |x| x[1].asFloat };
			((win.find("/").notNil) and: { nums.size >= 2 }).if
				{ lin = lin * (nums[0] / nums[1]) } { (nums.size >= 1).if { lin = lin * nums[0] } };
		};
	};
	(clean.containsi("synthVGlobalVol")).if { flags = flags.add(\globalVol) };
	[ db + lin.ampdb, flags ]
};
~parseFaderDb = { |src|
	var clean = ~stripComments.(src);
	var i = clean.find("asrFader") ? clean.find("Env.asr");
	i.isNil.if { nil } {
		var nums = clean.copyRange(i, i + 40).findRegexp("-?[0-9]+\\.?[0-9]*").collect { |x| x[1].asFloat };
		nums[1]
	}
};

// ---------- baked role->voice snapshot (global cast + per-section overrides) ----------
~globalCast = (
	kirk: \xuan, henoch: \ninezero, spock: \asterian, kirkLungs: \mo, thalassa: \aiko,
	mulhall: \feng, chapel: \feng, vocoder: \xuan, mccoy: \xuan, sargon: \genbu
);
// per-section (0-based) active overrides from the song files
~sectionOverrides = [
	(sulu:\an, uhuru:\cheng), (uhura:\cheng, sulu:\an), (mccoy:\mo, scott:\an),
	(scott:\an, mccoy:\mo), (mccoy:\mo), (kirkLungs:\genbu, mccoy:\mo),
	(mccoy:\xuan), (mccoy:\mo), (scott:\an, mccoy:\mo), (),
	(mccoy:\xuan), (mccoy:\xuan, mccoyJun:\jun), (formulaLead:\ninezero), (mccoy:\an),
	(), (mccoy:\jun), (scott:\kevin), (mccoy:\xuan), (), (), (mccoy:\xuan), (), (mccoy:\mo)
];
// roles/voices that actually sing in each section (from P.synthV(role:/key) scan)
~sectionRoles = [
	[\kirk,\spock,\sulu,\uhuru,\vocoder,\kevin],
	[\kirk,\spock,\sulu,\uhura,\vocoder,\feng,\kevin,\jun],
	[\kirk,\mccoy,\mulhall,\scott,\spock,\vocoder,\kevin,\ninezero],
	[\kirk,\mccoy,\mulhall,\scott,\spock,\vocoder],
	[\kirk,\mccoy,\spock,\vocoder,\chapel,\kevin,\ninezero,\xuan],
	[\kirkLungs,\mccoy,\mulhall,\spock,\sargon,\genbu,\default],
	[\mccoy,\mulhall,\sargon,\spock],
	[\kirk,\mccoy,\vocoder,\aiko,\feng],
	[\kirk,\mccoy,\mulhall,\scott,\spock,\feng,\kevin],
	[\kirk,\mo,\an,\ninezero],
	[\kirk,\mccoy,\henoch,\thalassa,\sargon,\chapel,\genbu,\kevin],
	[\kirk,\mccoy,\mccoyJun,\henoch,\sargon,\chapel,\feng,\genbu],
	[\formulaLead,\chapel,\an,\mo,\kevin],
	[\mccoy,\ninezero,\jun],
	[\thalassa,\henoch,\sargon,\aiko,\an,\feng,\genbu,\mo,\kevin],
	[\mccoy,\chapel],
	[\thalassa,\henoch,\scott,\aiko,\an,\feng,\clear],
	[\mccoy,\aiko,\genbu],
	[\feng,\mo],
	[\thalassa,\henoch],
	[\mccoy,\thalassa,\chapel,\cheng,\feng,\kevin,\vocoder],
	[\kirk,\mccoy,\mulhall,\mo,\feng,\kevin],
	[\kirk,\mccoy,\mulhall,\spock,\thalassa,\henoch,\sargon,\chapel,\cheng,\ninezero,\kevin,\vocoder]
];

~resolveVoice = { |role, sectIdx|
	(~sectionOverrides[sectIdx] ? ()).atFail(role, { ~globalCast.atFail(role, { role }) })
};

// ---------- the chart ----------
~vocalLevelChart = { |role|
	var keys = Trek.keys;
	Trek.loadTransitions;
	keys.do { |key i|
		var song = Song.songs[key];
		var faderDb = (Trek.faders[i].notNil).if { ~parseFaderDb.(Trek.faders[i].cs) } { nil };
		var gv = song.notNil.if { song.synthVGlobalVol };   // -3.dbamp in song 9, else nil
		var roles = (~sectionRoles[i] ? []);
		role.notNil.if { roles = roles.select { |r| r == role } };
		(song.notNil and: { roles.notEmpty }).if {
			("\nSECTION % (%)   fader %"
				.format((i+1).asString.padLeft(2), key,
					faderDb.notNil.if { faderDb.round(0.1).asString } { "?" })).postln;
			"  role         voice       track     sum".postln;
			roles.do { |r|
				var voice = ~resolveVoice.(r, i);
				var fn = (song.synthVTracks.notNil).if { song.synthVTracks.at(voice) } { nil };
				var res, trackDb, sum, note = "";
				fn.notNil.if {
					res = ~parseGainDb.(fn.cs);
					trackDb = res[0];
					(res[1].includes(\globalVol) and: { gv.notNil }).if {
						trackDb = trackDb + gv.ampdb; note = " (xGlobalVol)";
					};
					sum = faderDb.notNil.if { (trackDb + faderDb) } { trackDb };
					("  %  %  %  %%".format(
						r.asString.padRight(11), voice.asString.padRight(10),
						trackDb.round(0.1).asString.padLeft(7),
						sum.round(0.1).asString.padLeft(7), note)).postln;
				} {
					("  %  %  (no synthVTracks loaded)".format(
						r.asString.padRight(11), voice.asString.padRight(10))).postln;
				};
			};
		};
	};
	"";
};
"vocal-level-chart loaded.  ~vocalLevelChart.()  or  ~vocalLevelChart.(role: \\mccoy)".postln;
)
