(
~test= {
	~b=Bus.audio();
	//Item(\latencyTest);
	//Item.latencyCompensation_(0);
	Item(\latencyTest).arm(length:5,bus:~b.index);
	Item(\latencyTest).node.wakeUp;
	fork{
		0.5.wait;
		Item(\latencyTest).play;
		[note:Pseries(1,2,5)+4.rand,out:~b.index].pp;
		6.wait;
		Item(\latencyTest).play;
		[note:Pseries(1,1,5)-4,out:0].pp;

	}

}
)
~test.()

