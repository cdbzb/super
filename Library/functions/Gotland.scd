
~rpr=NetAddr("192.168.1.130",8000);
~locate={|seconds| ~rpr.sendMsg('time',seconds*1.001)};
~locateSecs={|seconds| ~rpr.sendMsg('time',seconds)};
~schedule={|time function| (time>TempoClock.default.beats).if({TempoClock.default.schedAbs(time,function)})}; 
~startFrom={|time| ~start=time;~locateSecs.(time);TempoClock.default.beats=time;~rpr.sendMsg('/stop');~rpr.sendMsg('/play')};
CmdPeriod.add({~rpr.sendMsg('/stop')});
