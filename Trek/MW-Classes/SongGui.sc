SongGui {
	*sections {
		Song.currentSong.sections.do{|i x|
			x.asString + Song.lyrics[x] => _.postln
		}
	}
	// for parts use Song.currentSong[5]
	*scrollToSection {|section|
		Nvim.scroll(Song.lyrics[Song.section(section)])
	}
	*lyricWindow {
		var win = Window.new(bounds:Rect(540,0,540,540))
			// .background_(Color.clear)
			.front;
		var text = StaticText.new(win,  bounds: Rect(0,0,1040,300))
			.align_(\left)
			.font_(Font(\helvetica,20,bold:true)) 
			.string_(
				Song.lyrics.collect{|i x| x.asString + i + "\n"}.inject("", _++_)
			);
			var v = win.view;
			v.keyDownAction={ |view char|
				var parts, part, luacode;
				Song.scroll(Song.lyrics[char.asString.asInteger]);
				parts = Song.at(char.asString.asInteger);
				text.string_(
					parts.collect{ |i x| x.asString + i + "\n"}.inject("", _++_)
				);
				view.keyDownAction={ |view char|
					part = 
					// $\\ ++
					parts[char.asString.asInteger].key;

					luacode = "vim.fn.search(\"%\")".format(part);
					try{ SCNvim.luaeval(luacode) };
					SCNvim.luaeval("vim.api.nvim_feedkeys(\"%\", \"%\", %)".format("z.", "m", "false")) ;

					win.close
				};
				// win.close
			}
		^win
	}
	*scrollToPart { |part|
		part = Song.currentSong[part];
		
	}
}
