(
c=Semaphore(1);
	fork{
		c.wait;
		d=~synful.();
		while ({d.controller.isNil},{0.01.wait});
		while ({d.controller.loaded != true},{0.01.wait});
		c.signal;
	};
	fork{
		"waiting";
		c.wait;
		"synful loaded".postln
	}
)

(
	fork{
		x=~synful.();
		x.condition.wait;
		(type:\midi,midiout:x.controller.midi,midinote:60).play
	}
)

s.reboot

(
	(b.value!=true).if{a=Maybe.new};
	//put this V inside ~synful ?? 
	b=Maybe(a.controller);b=Maybe(b.loaded);
	fork{
		{b.value!=true}.while{0.1.wait};
		[type:\midi,midiout:a.value.controller.midi,midinote:Pwhite(60,70,10),legato:1.3].pp
	};
	(b.value!=true).if{a.value=~synful.()} ;
)

