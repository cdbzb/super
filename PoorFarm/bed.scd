s.boot;
s.reboot;

{HPF.ar(Crackle.ar(1.9),100,SinOsc.ar(0.02,0,0.2,0.05))}.play;
(
{SinOsc.ar((200+(Crackle.ar(1.9)*800)),0,0.05)}.play;
{SinOsc.ar((250+(Crackle.ar(1.9)*600)),0,0.03)}.play;
{SinOsc.ar((175+(Crackle.ar(1.9)*400)),0,0.08)}.play;
)

a={Out.ar(1,SinOsc.ar(25,0,SinOsc.kr(0.1,0,1)))}




Task ({ //record 
  var path="/tmp/";
  var length=60;
	a={Out.ar(0,SinOsc.ar(25,0,SinOsc.kr(0.1,0,1)))};
	s.recChannels_(1);
	s.recHeaderFormat_("wav");
	s.recSampleFormat_("int16");
	s.prepareForRecord(path++"25-cycle-bed.wav");
	1.wait;
	s.record(path++"25-cycle-bed.wav");
	a.play;
	60.wait;
	a.stop;
	3.wait;
	s.stopRecording;
},).play;

s.meter

