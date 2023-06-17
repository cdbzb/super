(
{
	var levels = [5,1,2,1] /5 => _.dq(inf);
	var durs = 0.1 ! 4 + ( [0,0.1,0,0.1] /2 ) /2 => _.dq(inf);
	var triggers = TDuty.kr( durs.dq(inf), 0,1 );
	var energy = EnvGen.ar( Env.linen(0, 0.00, 0.015), triggers, doneAction:0   ) 
		* Demand.kr(triggers,0,levels 
			// * 40
			// *8
		);
	Shakers.ar(3, energy:energy   , decay: 1)
	// /5
	// * 2
	=> Pan2.ar(_, 0.8)
	// + SinOsc.ar(300,0,0.05)
	=> DelayN.ar(_,0.2 -0.03 )

}.play;
[
	dur: 0.5,
	instrument: \kick3
].pp;
[
	instrument: \hihat,
	dur: 0.5/2
].pp

(instrument: \cymbalsDS, amp: 0.02).play
)

