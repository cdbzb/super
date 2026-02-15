(
Yoeminrak.env.use {

~quickDip =  { |dur=1 section| section = section ? currentEnvironment[\section]; { Env([0,0,-9.7!5], [dur - 1 + 0.92, 0.09] * Yoeminrak.secDur[section]/20 ).kr(2,gate:1)} };
~help = ~help ? () ++	(quickDip: "signature: dur section - 0.09 dip at end")

}
)
