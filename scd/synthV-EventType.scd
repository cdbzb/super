(
Event.addEventType(\synthV, {
	P.synthV(start: ~start,role:~role,music:~music.(),take:~take,params:~params.()).postln;
	P.double(start: ~start,role:~role,take:~take,music:~music.(),params:~params.()).postln
	// ~params.().postcs
});
a= (type:\synthV,role:  \kirk  , start:5,take:\trash, params: `{|p b| [ \lyrics, "goodbye" ] },music:`{|p b e| { e.playbuf}.play });
a.play;
)

