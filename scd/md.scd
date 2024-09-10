(
~pmd= {|midinote, key=\c|
	var st = #[1, 1.5, 2, 2.5, 3, 4, 4.5, 5, 5.5, 6, 6.5, 7];
	var octave = #[-4,-3,-2,-1,0,0,1,2,3];
	midinote = midinote - NoteNames.names[key];
	octave = midinote / 12 => _.floor => octave[_];
	midinote % 12 => st[_] + ( octave.abs * 10 ) * (midinote <60.0).if{-1}{1};
};

~md={|array|
	array.collect{|i| ~pmd.(i)}
}
)
~md.([ 60, 58 ] 	, \d)

