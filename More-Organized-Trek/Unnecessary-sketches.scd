"~/tank/super/More-Organized-Trek/Songs/Unneccesary-song.scd".standardizePath.load
a={ ~unnecessary.at(0).do(_.p;)}.fork
a.play

~unnecessary.at(0).play
~unnecessary.cursor_(0).play
all {:x,x<-~unnecessary.resources.keys,var y=~unnecessary.resources.at(x.asSymbol),y.class==Part,::y.music.post;' '.post;x.postln}
~unnecessary.bass1.play;
( //	metabolism sketh	{{{2
	t=TempoClock.new.tempo_( 1.2 );
	u=TempoClock.new.tempo_( t.tempo*0.666 );
	Pfindur(4,//12,
		Ppar([
			//Pseq(~unnecessary.pbind[1..2]),
			//~unnecessary.pbind[2];
			//a.[0]=Pmono(\bl,\degree,2-1,\dur,0.5,\root,4,\octave,2,\trig,1);
			Pmono(\bl,\degree,2-1,\dur,Pseq([0.5,1.5]*1.5,1),\root,4,\octave,2,\trig,1),
			~unnecessary.pbind[2],
			~tk.at(\hat),
			~tk.at(\saw),
			Pbindf(~tk.at(\pulse), \degree,Pseq([\r,-2,4,-2],1),\dur,0.662 )//.play
			,
			~tk.at(\snare),
		])
	).play(t);
	//~tk.at(\hat).play(u)
);
//~unnecessary.save;
//~unnecessary.durs[2].list;

( //	tracklist	{{{1

	t=TempoClock.new.tempo_(1.2);
	a.[0]=Pmono(\bl,\degree,Pseq(~notes,4)-1,\dur,0.5,\root,4,\octave,2,\trig,1);
	Ppar([
		//Pseq([~unnecessary.pbind[1]],4).play; 
		~tk.at(\snare),
		~tk.at(\kick),
		~tk.at(\pulse),
		~tk.at(\saw),
		~tk.at(\hat)
	]).play(t);
)

