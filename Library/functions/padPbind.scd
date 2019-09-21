//append rest to Pbind

Library.put(\functions,\padPbind,
	{|pbind release=5| pbind++Pbind(\note,Pseq([\r]),\dur,release) };
);
