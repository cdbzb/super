/*
 An audio interface as an object: the CoreAudio device names, its channel count and
 speaker layout, and — the reason this class exists — its measured latency.

 Latency is a property of the RIG, not of the machine: Monitors can reboot onto a
 different interface at any moment, so a measurement only means anything attached to
 the device it was taken on.

 Registered rigs live in *initClass. Measurements are pinned per key into startup.scd
 (per-machine, deliberately outside version control):

     AudioInterface('rme').roundTrip = 0.098083333333333;    // loopback-measured ...
     AudioInterface('rme').outputShare = 0.396;              // CoreAudio-reported

 AudioItem.roundTripLatency / .outputLatency read through AudioInterface.current,
 falling back to their own globals when the booted device is not registered.

 NB MIDI input latency does NOT belong here — it is a property of the controller
 (key scan, USB polling), not of the audio interface. Different registry.
*/
AudioInterface {
	classvar <all;
	/* CoreAudio latency-split helper; see bin/audio-latency.swift */
	classvar <>helper;
	classvar currentKey, currentValue;

	var <key;
	/* CoreAudio device names. inName defaults to outName (one interface both ways);
	   they differ on the built-in rig and on capture routings like OBS. */
	var <>outName, <>inName;
	var <>channels;
	/* \stereo or \pentagon — what Monitors consults to pick a decoder */
	var <>layout;
	/* Loopback-measured TOTAL round trip in seconds (L_out + L_in). nil = never
	   measured on this rig. The loopback can only ever yield the sum. */
	var <>roundTrip;
	/* L_out / (L_out + L_in), from CoreAudio via the helper. The split is not
	   observable from inside the box; trust the driver for the RATIO and the
	   loopback for the TOTAL. nil falls back to 0.5 (symmetric legs). */
	var <>outputShare;
	/* Date.getDate.stamp of the last measurement, for the startup.scd comment */
	var <>measured;

	*initClass {
		all = IdentityDictionary.new;
		helper = "~/tank/super/bin/audio-latency.swift";
		this.prRegisterDefaults
	}

	/* The rigs Monitors used to hardcode, in three places at once: its deviceChannels
	   dictionary, its per-device switching methods, and the channel-count default. */
	*prRegisterDefaults {
		this.new(\macbook,     "MacBook Pro Speakers",       "MacBook Pro Microphone", 2);
		this.new(\headphones,  "External Headphones",        "MacBook Pro Microphone", 2);
		this.new(\teams,       "TeamsMulti",                 "MacBook Pro Microphone", 2);
		this.new(\obs,         "OBS",                        "BlackHole 2ch",          2);
		this.new(\blackHole,   "BlackHole 2ch",              nil,                      2);
		this.new(\blackHole16, "BlackHole 16ch",             nil,                      5);
		/* TWO different Digiface units are named in this tree: Monitors.rme used
		   23953833, while startup.scd's boot-time case chain looks for 24192375
		   (and gives it 9 out / 1 in). They are separate serial numbers, so they are
		   separate rigs and must hold separate measurements — rename these keys to
		   whatever actually distinguishes them (upstairs/downstairs?). */
		this.new(\rme,         "Digiface USB (23953833)",    nil,                      5);
		this.new(\rme2,        "Digiface USB (24192375)",    nil,                      9);
		this.new(\streamer,    "USBStreamer ",               nil,                      8);
		this.new(\mobius,      "Mobious Ag",                 nil,                      2);
		this.new(\epos,        "EPOS PC 8 USB",              nil,                      2);
		this.new(\bose,        "BoseAg",                     nil,                      2);
		this.new(\airpods,     "Pro Ag",                     nil,                      2);
		this.new(\zoom,        "ZoomAudioD",                 nil,                      2);
	}

	/* Look up or declare. Re-declaring an existing key updates only the fields
	   passed, so a startup.scd pin never has to restate the device names. */
	*new { |key, outName, inName, channels, layout|
		var i;
		key = key.asSymbol;
		i = all[key];
		i.isNil.if {
			i = super.new.prInit(key, outName, inName, channels, layout);
			all[key] = i;
			currentKey = nil    /* a new registration may be the booted device */
		} {
			outName !? { i.outName_(outName) };
			inName !? { i.inName_(inName) };
			channels !? { i.channels_(channels) };
			layout !? { i.layout_(layout) }
		};
		^i
	}

	prInit { |inKey, out, in, chans, lay|
		key = inKey;
		outName = out ? inKey.asString;
		inName = in ? outName;
		channels = chans ? 2;
		layout = lay ? (channels <= 2).if { \stereo } { \pentagon };
	}

	/* The booted interface, or nil when the out device is unset (system default) or
	   unregistered. Cached on the device-name string: this sits in the record path
	   (AudioItem) and the prepare path (EventList), both of which are hot. */
	*current {
		var name = Server.default.options.outDevice;
		name.isNil.if { ^nil };
		(name == currentKey).if { ^currentValue };
		currentKey = name;
		currentValue = all.detect { |i| i.outName == name };
		^currentValue
	}

	*currentOr { |fallbackKey| ^this.current ?? { this.new(fallbackKey) } }

	/* Derived legs. nil while roundTrip is unmeasured — callers decide what an
	   unmeasured rig means rather than silently getting 0. */
	outputLatency { ^roundTrip !? { roundTrip * (outputShare ? 0.5) } }
	inputLatency { ^roundTrip !? { roundTrip * (1 - (outputShare ? 0.5)) } }

	isCurrent { ^AudioInterface.current === this }

	/* Point the server at this rig and reboot onto it. Monitors' per-device methods
	   are now one-line delegates to this. */
	select { |reboot = true|
		var o = Server.default.options;
		o.outDevice_(outName);
		o.inDevice_(inName);
		currentKey = nil;
		reboot.if { Server.default.reboot };
		^this
	}

	/* Loopback ping: play an impulse out `out`, record it back in `in`, and read the
	   leading edge. Route the cable through the REAL path — the monitoring output you
	   listen to, into the input you record through. An internal TotalMix-style
	   loopback never reaches a converter and measures the driver, not the rig.

	   Sets roundTrip and outputShare on THIS instance and (write: true) pins both
	   into startup.scd. Re-measure after a buffer-size change. */
	measure { |in = 0, out = 0, amp = 0.5, dur = 0.5, write = true, action, share|
		var server = Server.default;
		server.serverRunning.not.if {
			^"AudioInterface(%).measure: server not running".format(key).warn
		};
		/* Measuring while a DIFFERENT device is booted would time the current rig and
		   pin the answer under this key — exactly the silent mis-association this
		   class exists to prevent. */
		this.isCurrent.not.if {
			^"AudioInterface(%).measure: % is not the booted device (%). Run .select "
			"first, or measure the booted rig instead."
				.format(key, outName, server.options.outDevice ? "system default").warn
		};
		fork {
			var frames = (dur * server.sampleRate).asInteger;
			var buf = Buffer.alloc(server, frames, 1);
			server.sync;
			SynthDef(\audioInterfaceLoopbackPing, { |out = 0, in = 0, amp = 0.5, buf|
				var ping = Decay.ar(Impulse.ar(0), 0.005) * SinOsc.ar(2000) * amp;
				Out.ar(out, ping);
				RecordBuf.ar(SoundIn.ar(in), buf, loop: 0, doneAction: 2);
			}).add;
			server.sync;
			server.bind {
				Synth(\audioInterfaceLoopbackPing, [\out, out, \in, in, \amp, amp, \buf, buf])
			};
			(dur + 0.2).wait;
			buf.loadToFloatArray(action: { |data|
				var peak = data.abs.maxItem;
				var idx, rt;
				(peak < 0.01).if {
					"AudioInterface(%).measure: no signal (peak %) — is the loopback "
					"connected?".format(key, peak.round(1e-4)).warn
				} {
					/* leading edge (first half-peak crossing), not the peak itself */
					idx = data.detectIndex { |x| x.abs > (peak * 0.5) };
					rt = idx / server.sampleRate;
					roundTrip = rt;
					outputShare = share ?? { AudioInterface.queryOutputShare ? 0.5 };
					measured = Date.getDate.stamp;
					"AudioInterface(%): % ms round trip (peak %)"
						.format(key, (rt * 1000).round(0.01), peak.round(0.01)).postln;
					"  output leg % ms (share %)"
						.format((this.outputLatency * 1000).round(0.01),
							outputShare.round(0.001)).postln;
					write.if { this.writeStartup };
					action.(rt);
				};
				buf.free;
			});
		}
	}

	/* ---- CoreAudio helper ---------------------------------------------------- */

	/* One shell round trip (~1 s), returned whole so callers parse what they need
	   instead of invoking it repeatedly. nil when the helper is missing. */
	*report { |deviceSubstring|
		var path = helper.standardizePath;
		var flag = (deviceSubstring !? {
			" --device " ++ deviceSubstring.asString.shellQuote
		}) ? "";
		File.exists(path).not.if { ^nil };
		^("%% 2>/dev/null".format(path.shellQuote, flag)).unixCmdGetStdOut
	}

	/* L_out's share of the round trip, per the driver: device latency + safety offset
	   + buffer frames + stream latency, each direction. The driver reports only what
	   it can see — on an ADAT front end the outboard converters are invisible — so
	   this is the RATIO only; the loopback supplies the TOTAL. */
	*queryOutputShare { |deviceSubstring|
		var report = this.report(deviceSubstring);
		var line = report !? {
			report.split(Char.nl).detect { |l| l.beginsWith("L_out share") }
		};
		^line !? { line.split($ ).reject(_.isEmpty)[2].asFloat }
	}

	/* Ask the driver for this rig's split without running a loopback. Useful to seed
	   outputShare on a rig you cannot cable up; roundTrip still needs a real ping. */
	queryShare {
		var s = AudioInterface.queryOutputShare(outName);
		s !? { outputShare = s;
			"AudioInterface(%): outputShare = %".format(key, s.round(0.001)).postln };
		^s
	}

	/* SC can enumerate devices before boot but has no way to report which device
	   scsynth actually opened — if the named device is absent it falls back silently
	   and the pinned latency then describes hardware that is not in the path. The
	   honest check available in the language is presence: warn when a requested name
	   is not in the device list at all. ^true when both names are present. */
	*verify {
		var o = Server.default.options;
		var outs = ServerOptions.outDevices;
		var ins = ServerOptions.inDevices;
		var ok = true;
		o.outDevice.notNil.if {
			outs.includesEqual(o.outDevice).not.if {
				ok = false;
				"AudioInterface.verify: out device % is NOT present — scsynth will fall "
				"back and any pinned latency is wrong.".format(o.outDevice.asCompileString).warn
			}
		};
		o.inDevice.notNil.if {
			ins.includesEqual(o.inDevice).not.if {
				ok = false;
				"AudioInterface.verify: in device % is NOT present — scsynth will fall "
				"back and any pinned latency is wrong.".format(o.inDevice.asCompileString).warn
			}
		};
		^ok
	}

	/* ---- startup.scd persistence -------------------------------------------- */

	/* Pin roundTrip and outputShare under this key. Per-machine state, deliberately
	   outside version control — startup.scd is the right home. */
	writeStartup { |path|
		var lines, stamp;
		path = path ?? { Platform.userConfigDir +/+ "startup.scd" };
		File.exists(path).not.if {
			^"AudioInterface(%).writeStartup: no startup file at %".format(key, path).warn
		};
		stamp = measured ? Date.getDate.stamp;
		lines = File.readAllString(path).split(Char.nl);
		lines = AudioInterface.prPinLine(lines, this.prLhs("roundTrip"), roundTrip,
			"loopback-measured " ++ stamp);
		outputShare.notNil.if {
			lines = AudioInterface.prPinLine(lines, this.prLhs("outputShare"), outputShare,
				"CoreAudio-reported " ++ stamp)
		};
		File.use(path, "w", { |f| f.write(lines.join(Char.nl) ++ Char.nl) });
		"AudioInterface(%): pinned roundTrip = % in %".format(key, roundTrip, path).postln;
		^path
	}

	prLhs { |field| ^"AudioInterface(%).%".format(key.asCompileString, field) }

	/* Idempotently pin `<lhs> = <value>;` into a startup.scd line array: drop any
	   previous pin wherever it sits, then let the insertion point decide where the
	   new one belongs. */
	*prPinLine { |lines, lhs, value, note|
		var line = "% = %; // %".format(lhs, value, note);
		var closeIdx;
		lines = lines.reject { |l| l.contains(lhs) };
		closeIdx = this.prTrailingBlockClose(lines);
		closeIdx.notNil.if { ^lines.keep(closeIdx) ++ [line] ++ lines.drop(closeIdx) };
		(lines.last.size == 0).if { lines = lines.drop(-1) }; /* keep single trailing \n */
		^lines ++ [line]
	}

	/* A startup.scd that is one `( var ...; ... )` block is sclang's WHOLE-PROGRAM
	   form (the cmdlinecode grammar): nothing may follow the closing paren. */
	*prTrailingBlockClose { |lines|
		var lastCode, code, cut;
		lines.do { |l, i|
			var t = l.stripWhiteSpace;
			(t.notEmpty and: { t.beginsWith("//").not }).if { lastCode = i }
		};
		lastCode.isNil.if { ^nil };
		/* a trailing line comment is whitespace to the parser, so `) // note`
		   closes the block just as `)` does */
		code = lines[lastCode];
		cut = code.find("//");
		cut.notNil.if { code = code.keep(cut) };
		^(code.stripWhiteSpace == ")").if { lastCode } { nil }
	}

	/* ---- reporting ----------------------------------------------------------- */

	*unmeasured { ^all.values.select { |i| i.roundTrip.isNil } }

	*printAll {
		"AudioInterface — * = booted".postln;
		all.values.sort { |a, b| a.key.asString <= b.key.asString }.do { |i| i.postLine };
		^all
	}

	postLine {
		"%  %  %ch  %  rt %  L_out %".format(
			this.isCurrent.if { "*" } { " " },
			key.asString.padRight(12),
			channels,
			layout.asString.padRight(9),
			roundTrip.isNil.if { "unmeasured" } { (roundTrip * 1000).round(0.01).asString ++ " ms" },
			this.outputLatency.isNil.if { "—" } { (this.outputLatency * 1000).round(0.01).asString ++ " ms" }
		).postln
	}

	printOn { |stream| stream << "AudioInterface(" << key << ")" }
}

AD : String {
    var <>chans;
    *new {|string chans| ^ super.new(string).init(chans) }
    init{|inChans| chans = inChans}
}
