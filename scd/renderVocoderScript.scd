(//setup
Monitors.pentagon;
Monitors.stopFoldDown;
~vocoders=Song.pts.select{|i| i.music.cs.contains("vocodeT")}.sort{|i j| i.start < j.start};
~counter=( -1 );
)
( //get next and check if other parts are sending to carrier
~counter=~counter + 1;
Part.current_( ~vocoders[~counter] );
Song.cursor_(~vocoders[~counter].start);
Song.at( Part.current.start).select{|i| i.music.cs.contains("p.carrierBus")}.postln;
)

( //freeze
~vocoders[~counter].record_(true);
~vocoders[~counter].frozen_(false);
//if there are other parts you need to uncomment the following
// Song.partsWithAtCursor([\lines, \xu]).do(_.p); s.meter
s.meter;~vocoders[~counter].play;
)
~vocoders[~counter].play
Song.cursor_(0);Song.play;s.meter;Stills.muted_(true)
