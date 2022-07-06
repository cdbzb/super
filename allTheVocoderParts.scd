
fork{ Song.pts.select{|i| i.rpp!=nil}.do{|i|  i.rpp.open(hidden:1); 2.wait } }
