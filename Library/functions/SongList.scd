(
~listSongs = {
	var b,songs = List();
	var a=Pipe(" ls /Users/michael/tank/super/Dur","r");
	b = a.getLine;
	while({b.notNil}, {songs.add(b); b = a.getLine; });  
	songs.reject(_=="Old")
}
)
~listSongs.()
