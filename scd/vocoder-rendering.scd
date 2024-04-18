	a=Song.pts.select{|i| i.music.cs.contains( "arrier" ) and: i.start == Part.current.start}
	Monitors.stopFoldDown;Song.cursor_(Part.current.start);a.do (_.p)

	Song.pts.select{|i| n=i.name; n.contains("XTU") or: n.contains("ch") or: n.contains("xua") and: i.start == Song.cursor }.do(_.p)
