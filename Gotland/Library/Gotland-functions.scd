(
	~t=TempoClock.new.permanent=true;
	~rpr=NetAddr("192.168.1.130",8000);
	~locate={|seconds| ~rpr.sendMsg('time',seconds*1.001)};
	~locateSecs={|seconds| ~rpr.sendMsg('time',seconds)};
	~schedule={|time function| (time>~t.beats).if({~t.schedAbs(time,function)})}; 
	~startFrom={|time| ~start=time;~locateSecs.(time);~t.beats=time;~rpr.sendMsg('/stop');~rpr.sendMsg('/play')};
	CmdPeriod.add({~rpr.sendMsg('/stop')});
)
