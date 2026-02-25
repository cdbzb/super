// Canonical \addMe event type.
// Configure per song block via:
//   ~addMeSong    = \songKey;   (required)
//   ~addMeSection = N;          (required)
//   ~addMeStrings = false;      (optional — suppresses stringyy layer for whole section)
//
// Per-event: strings: false suppresses stringyy for that event only.
// Strum convention: Float 0.0 (inherited from proto) → replaced with 0.1;
//                   Integer 0 (intentional) → kept as 0.
Event.addEventType(\addMe, {
    var songKey, section, song, env, env2, env3, getChordFreq;

    songKey = Yoeminrak.env[\addMeSong]
        ?? { Error("\\addMe: Yoeminrak.env[\\addMeSong] not set").throw };
    section = Yoeminrak.env[\addMeSection]
        ?? { Error("\\addMe: Yoeminrak.env[\\addMeSection] not set").throw };
    song = Yoeminrak.song[songKey];

    getChordFreq = { |e, filter|
        e.chord.notNil.if {
            var c = e.chord.isKindOf(Tuple3).if { e.chord.at1 }{ e.chord };
            c[e.which ? [0,1,2,3,4]] => ( filter ? I.d )
        }
    };

    env = currentEnvironment.copy;
    env.type = ~newType ? \yoeString3;
    env.section = section;
    song.add(env);

    Yoeminrak.env[\preview].notNil.if { env.play };

    (env.harp.isNil and: env.chord.notNil).if {
        env2 = env.copy;
        env2.freq = { getChordFreq.value(env2) };
        env2.use {
            ~type       = \default;
            ~instrument = \harp;
            ~coef       = 0.1;
            ~latency    = 0.025;
            // nil or Float 0.0 → use default 0.1; Integer 0 → intentional zero strum
            ~strum      = (~strum.isNil or: { ~strum.isFloat and: { ~strum == 0.0 } }).if { 0.1 } { ~strum };
            ~amp        = 0.1;
        };
        song.add(env2);
        Yoeminrak.env[\preview].notNil.if { env2.play };

        // ~strings: false (per-event) or Yoeminrak.env[\addMeStrings] = false (per-section)
        // suppresses the stringyy doubling layer
        (~strings.isNil and: { Yoeminrak.env[\addMeStrings] ? true }).if {
            env3 = env.copy;
            // note: follows the same ~which as the harp
            env3.freq = { getChordFreq.value(env3, {|i| i / 2}) };
            env3.use {
                ~type       = \default;
                ~instrument = \stringyy;
                ~amp        = 1;
                ~latency    = 0.025;
            };
            song.add(env3);
            Yoeminrak.env[\preview].notNil.if { env3.play };
        };
    };
});
