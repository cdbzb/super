
( //working one!

a=MicroKeys(\dd);
a.split( [
	[\sn_808, {|x| [62, 64].includes(x)}, (tone: 200)],
	[\bd_808, {|x| [60, 48].includes(x)}, (tone: 100)],
	[\hat_808, {|x| [67, 69].includes(x)},(tone: 100)],
	// [\default, nil, (pan:1)]
]);
m = MIDIItem("drumset_241119_155106")
.reject({|i| i.midicmd == \noteOff })
.reject{|e| [67, 69].includes(e.midinote)}
;
[
	player: 
	m.fromNoteTo(18, 23)
	, type:\mi2, 
	//params should be a 'Pbind' like Array
	params: p {
		var tone = [500, 450, 600, 450 ].collect{|i| [i, 110, 100, 100, 100, 200 ]} 
			=> _.q(inf) => _.collect({|e| e.q}) => _.asStream; 
		var verb = Effect.bus({|i| FreeVerb.ar(i, 0.9, 1) => Pan2.ar(_,-0.9) }, time: 8);
		var verbR = Effect.bus({|i| FreeVerb.ar(i, 0.9, 1) => Pan2.ar(_, 0.9) }, time: 8);
		var out = [verb, 0, verbR, 0].q(inf).collect({|e| e.q}).asStream; 
		var amp = Pwhite(0.1, 1.0, inf).clump(12).collect{|e| e.q;
		}.asStream;
		loop{ [
			tone: tone.next ,
			out: out.next,
			amp: amp.next,
		].yield }
	},
	mk: a 
].p.play;
)
/////
(
Event.addEventType(\params, {|e|
	Prout{
		loop{
			e.params.collect{ |param|
				[param.asSymbol, 
					e[param].value(e).next
				]
			}.flatten.yield
		}
	}
}

})
)
( ///Param
a=MicroKeys(\dd);
a.split( [
	[\sn_808, {|x| [62, 64].includes(x)}, (tone: 200)],
	[\bd_808, {|x| [60, 48].includes(x)}, (tone: 100)],
	[\hat_808, {|x| [67, 69].includes(x)},(tone: 100)],
	// [\default, nil, (pan:1)]
]);
m = MIDIItem("drumset_241119_155106")
.reject({|e| e.midicmd == \noteOff})
.reject{|e| [67, 69].includes(e.midinote)};
[
	type: \mi2, player: m.fromNoteTo(18, 23), mk: a,
	params: [
		// tone: [500, 450, 600, 450 ].collect{|i| [i, 200, 100, 200, 100, 100, 100].q}.q(inf),
		tone: [[500,100,100,100,100, 100].q,[400,100,100,100,100, 100]].q(inf).asStream,
		verb: Effect.bus({|i| FreeVerb.ar(i, 0.9, 1) => Pan2.ar(_,-0.9) }, time: 4),
		verbR: Effect.bus({|i| FreeVerb.ar(i, 0.9, 1) => Pan2.ar(_, 0.9) }, time: 4),
		out: {|e| [e.verb, 0, e.verbR, 0].q(inf) },
		params: [\tone,  ],
	] => Params(_)
].p.trace.play

)

(

a=MicroKeys(\dd);
a.split( [
	[\sn_808, {|x| [62, 64].includes(x)}, (tone: 200)],
	[\bd_808, {|x| [60, 48].includes(x)}, (tone: 100)],
	[\hat_808, {|x| [67, 69].includes(x)},(tone: 100)],
	// [\default, nil, (pan:1)]
]);
m = MIDIItem("drumset_241119_155106")
.reject{|e| [67, 69].includes(e.midinote)};
[
	player: m.fromNoteTo(18, 23).reject(_.midicmd == \noteOff), type:\mi2, 
	//params should be a 'Pbind' like Array
	tone: [500, 450, 600, 450 ].collect{|i| [i, 200, 100, 200, 100, 100, 100].q}.q(inf), 
	verb: Effect.bus({|i| FreeVerb.ar(i, 0.9, 1) => Pan2.ar(_,-0.9) }, time: 4),
	verbR: Effect.bus({|i| FreeVerb.ar(i, 0.9, 1) => Pan2.ar(_, 0.9) }, time: 4),
	// out: {|e| [e.verb, 0, e.verbR, 0].q(inf) },
	params: [\tone,  
		// \out
	],
	mk: a 
].p.play;
)
( //filters!

a=MicroKeys(\dd);
a.split( [
	[\sn_808, {|x| [62, 64].includes(x)}, (tone: 200)],
	[\bd_808, {|x| [60, 48].includes(x)}, (tone: 100)],
	[\hat_808, {|x| [67, 69].includes(x)},(tone: 100)],
	// [\default, nil, (pan:1)]
]);
m = MIDIItem("drumset_241119_155106")
.reject{|e| [67, 69].includes(e.midinote)};
t = MIDIItemTempoMap(m.fromNoteTo(18, 23), beats:"xe x q xe x q".beats);
[
	type: \mi2, mk: a, player: m,
	filter: [
		{ |i| 
			i.fromNoteTo(18, 23)
			.filter({|i| i.collect{|e| e.params = 
				[
					out: ( [62, 64].includes(e.midinote) ).if{Effect.bus({|i| FreeVerb.ar(i, 0.5, 1) }, inputChannels:2)}{1}
				]
			}})
		},

		{ |i| 
			i.fromNoteTo(18, 23)
			.filter({|i| i.collect{|e| e.params = 
				[
					out: ( [62, 64].includes(e.midinote) ).not.if{Effect.bus({|i| FreeVerb.ar(i, 0.5, 1) })}{1}
				]
			}})
		}

		// ,
		// { |i| 
		// 	i.fromNoteTo(18, 23)
		// 	.filter({|i| i.collect{|e| e.amp = ( [62, 64].includes(e.midinote) ).if{0.1}{1}}})
		// }
	].q(inf)
].p.play;
// [
// 	dur: 
// 	"ex x q ex x q".beats.warpTo(t.tempoMap)
// 	++
// 	"ex x q e e ee".beats.warpTo(t.tempoMap)
// 	=>
// 	_.q(inf),
// 	instrument: [[\bd_808, \bd_808, \sn_808].q(3),[\bd_808, \bd_808, \sn_808, ].q].q(inf),
// 	amp: m.fromNoteTo(18, 23)[\amp].q(inf),
// 	tone:[100, 100, 100].q(inf),
// 	snEffect: Pswitch( [
// 		Effect.bus({|i| FreeVerb.ar(i,0.5,1) }, inputChannels:2),
// 		0
// 	],
// 		Ptime(inf) / 2 % t.tempoMap[7] =>  _.floor,
// 		inf
// ),
// 	out: Pfunc ({|e| (e.instrument == \sn_808).if { e.snEffect }{0}},nil)
// ].pp;
[
	freq: [\r, 5, 6,6.5, 7, 11, \r ].df(\c, 2).q(inf),
	dur: "e ex ex  ex ex e qqqq".beats.warpTo(t.tempoMap ++ t.tempoMap).q(inf),
	amp:0.2,
	instrument: \yowbass
].pp;
[
	instrument: \cp_808,
	dur: "e*16".beats.warpTo(t).q(inf),

].pp;
[
	degree: Ptuple(Pwhite(1, 20, inf).dup(4)),
	dur: "x*16".beats.warpTo(t.tempoMap).q(inf),
	scale: Scale.mixolydian,
	root:0,
	instrument: \harp,
	out:[0,1],
	amp:0.02
].pp
)
