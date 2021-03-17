(
//refactoring idea!!

//addLine makes a new section and makes it current ....
//adds it to the current song .....
//each part is added to the current section
//needed: semantics for adding anoher song inline!!


//opportunity to use git branch


//idea!! section doesn't "have" a string = section is associated with a string
// what if there is a big dict of lines
~sectionz = Dictionary.new;
~section={ |string="x", array=#[2], array2, array3 |
	(
		lyric: string,
		tune: array2,
		// should durs be GLOBAL per line??
		// NO - per song to permit alternatives - SOLVE THIS
		durs: array,
		parts: array3 ? List.from(array3),
		play:{ 
			play music in current context
		}
	)
}
)

a=~section.("hello!",[1,2],[3,4].dm(\c))
a.part=[note:a.tune.q,dur:a.durs.q].p
~part={
	(
		parent: current Section,
		music: ...
		play: ~parent.playme
	)
}

~parts = {
	//list of parts each associated with thier own secions that can be played or armed together
}

(//song is a list of sections ---- OR SONGS!
	//idea SONG has durs = section durations

~song = { |list|
	(
		sections:list,
		addE: {|e section| e.sections.add(section)},
		durs: {|e| e.sections.collect({|i|i.durs.sum})},
		play:{
			var secLoc = [0] ++ ~sections.collect({|i|i.durs.sum});
			~sections.do({|i x| {i.play }.sched(secLoc[ x ]) }) 
		}
	)
}
)

(
b=~song.(List[a,c]);
d=~song.(List[c,b])
d.addE(c)
d.sections.size
d.play
c=~section.("good bye!",[1.5,2]);
c.part=[note:[-5,8].q,instrument:\stringyy,dur:c.durs.q].p;
b.addE(c);
b.play
)

~csec=Object();

a.play
