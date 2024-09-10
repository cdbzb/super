(
~polygon = {|vertices, rot = 0, scale = 1| 
	// rot = rot.raddeg;
	vertices.collect{|i|
		var angle = 2pi * i / vertices + rot;
		Point(angle.sin.round(0.01), angle.cos.round(0.01)) * scale
		// 1
	}
}
)

~polygon.(5, pi, 15).do(_.postln)
