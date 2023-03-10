Song.pts.select(_.rpp.class==VocalRPP)//.collect(_.rpp)
a=Song.pts.select({|i| i.rpp!=nil}).collect{|i| i.rpp}.select{|i|File.exists(i.wav).not}
a[1].open
a[1].recordVocoderGuide
Reaper.save
(
fork{
	a[2..].do(
		{|i|
			i.open;
			2.wait;
			i.recordVocoderGuide(channels:2);
			20.wait;
			Reaper.save;
			1.wait

		};
	)
}
)
File("/tmp/ll").exists
