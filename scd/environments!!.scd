(
a =( name: \foo, sections: ());

a.addSection = {|self name func| self.sections[name] = ().make(func)};
a.playSection = {|e section| e.sections[section].make({ currentEnvironment.do(_.()) })};

a.addSection(\verse, {
	~durs = 1!16 / 3;
	~kick = { [ instrument: \bd_808, dur: ~durs.q ].pp };
	~snare = { [instrument: \sn_808, rest: [\r, 1].q(inf), dur: ~durs.q].pp }
});

a.addSection(\chorus, {
	~durs = 1!16 / 2;
	~kick = { [ instrument: \bd_808, dur: ~durs.q ].pp };
	~snare = { [instrument: \sn_808, rest: [\r, 1].q(inf), dur: ~durs.q].pp }
});
// a.playSection(\verse)

)
a.playSection(\chorus)
a=MultiLevelIdentityDictionary()
a.put( \verse, \bass, I.d )
a.put( \verse, \snare, I.d )
a[\verse].do(_.postln)
a[\verse].values.do(_.play)
a.put( \b, \foo,\9 )
a[{|x| x+1}]


