
(
fork{
	Trek.allTheSongs[5].load;
	~titles = Order.new(Trek.allTheSongs.size);
	~titles.put(5,
		(
			text: " In the inner chamber \n ",
			dur:5
		)
	);
	Song.cursor_(28);
	Song.play;
	Song.durTillEnd.wait;
	1.wait;
	defer{ {|dur text| Stills.plotTitleCard(dur:dur,text:text) }.valueWithEnvir( ~titles.at(5)  )};
	{ Dust.ar(50) => Decay.ar(_,0.1) * Gendy3.ar(freq: [240, 300, 335]) /15  }.play.dur(5, 3);
	fork{
		Trek.allTheSongs[6].load;
		Song.cursor_(0);
	};
	5.wait;
	Song.play;
}
)

(

	~titles = ~titles ? Order.new(Trek.allTheSongs.size);
	~transition = { |section=0 title preroll=3 |
	fork{
		Trek.allTheSongs[section].load;
		~titles.put(section, title);
		Song.cursor_(Song.sections - preroll);
		Song.play;
		Song.durTillEnd.wait;
		1.wait;
		defer{ {|dur text| Stills.plotTitleCard(dur:dur,text:text) }.valueWithEnvir( ~titles.at(section)  )};
		{ Dust.ar(50) => Decay.ar(_,0.1) * Gendy3.ar(freq: [240, 300, 335]) /15  }.play.dur(5, 3);
		fork{
			Trek.allTheSongs[section + 1].load;
			Song.cursor_(0);
		};
		5.wait;
		Song.play;
	}
};
// ~transition.( 6, (dur:4, text: "Another Transformation"), preroll:1 )
~transition.( 7, (dur:4, text: "A little later:\nthe Enterprise's Briefing Room"), preroll:3)

)
Stills.plotTitleCard(dur:3,text:"hmmm")//.fade(3, 1)
