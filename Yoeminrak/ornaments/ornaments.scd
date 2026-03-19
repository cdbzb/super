(
Yoeminrak.env.use {

~quickDip = { |dur=1 tempo=true|
    {
        var sec = currentEnvironment[\section] ? 0;
        var beat = currentEnvironment[\beat] ? 0;
        var beatDurMean = Yoeminrak.secDur.wrapAt(sec) / 20;
        var totalSecs;

        tempo.if {
            var fps = 29.97;
            var beatNum = beat.floor.asInteger;
            var beatFrac = beat % 1;
            var marks = Yoeminrak.marks;
            var durRemaining = dur;
            var i = 0;
            var chunk, beatDur;

            // helper: seconds for beat (beatNum + i) in this section, with fallback
            beatDur = { |idx|
                var m1 = (sec * 20) + idx + 1;
                var m2 = m1 + 1;
                (marks[m1.asSymbol].isNil or: { marks[m2.asSymbol].isNil }).if {
                    beatDurMean
                } {
                    (marks[m2.asSymbol][\frame] - marks[m1.asSymbol][\frame]) / fps
                }
            };

            // first beat: only the remaining fraction
            chunk = min(1 - beatFrac, durRemaining);
            totalSecs = chunk * beatDur.(beatNum);
            durRemaining = durRemaining - chunk;
            i = 1;

            while { durRemaining > 0 } {
                chunk = min(1, durRemaining);
                totalSecs = totalSecs + (chunk * beatDur.(beatNum + i));
                durRemaining = durRemaining - chunk;
                i = i + 1;
            };
        } {
            totalSecs = dur * beatDurMean;
        };

        Env([0,0,-9.7!5, 0, 0], [dur - 1 + 0.92, 0.09, 0.001, 0] * (totalSecs / dur)).kr(2,gate:1)
    }
};
~help = ~help ? () ++	(quickDip: "signature: dur tempo:true - 0.09 dip at end. tempo:false uses mean beat duration")

}
)
