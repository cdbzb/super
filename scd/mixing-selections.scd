
(
~randomSection = {
	~song = Trek.keys.choose;
	~fader.free;
	~fader = Trek.faders[Trek.keys.indexOf(~song)].();
	// var song = Song.songs.choose;
	Song.songs.at(~song).current;
	Song.playSection(~section = Song.sections.rand) 
};
~edit = {
	Trek.editFile(Trek.keys.indexOf(~song));
	fork{0.2.wait; Song.scroll(~section)}
}
)
~randomSection.()
~biggerSection.()
~edit.()
