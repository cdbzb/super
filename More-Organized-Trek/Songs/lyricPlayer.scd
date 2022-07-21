
(
~lyricWindow = Window.new(bounds:Rect(0,00,1040,200))
	.background_(Color.clear)
	;
~text = StaticText.new(~lyricWindow,  bounds: Rect(0,0,1040,300))
	.align_(\center)
	.font_(Font(\helvetica,40,bold:true))
	;
Song.currentSong.sections.do{ |i| 
	P(\lyric,start:i,music:{ |p b e|
		~lyricWindow.front;
		{
			~text.string_(Song.lyrics[i])
			.stringColor_(Color.rand)
		}.defer
	})
}
)
