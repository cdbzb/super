
~head = Bus.control(s, 4);
~yaw = Bus.control;
~pitch= Bus.control;
~roll= Bus.control;
OSCdef(\test,{|msg time addr port|~head.set(*msg[1..])},"/quaternion", recvPort:8000  );
OSCdef(\test,{|msg time addr port|~yaw.set(*msg[1])},"/yaw", recvPort:8000  );
OSCdef(\test,{|msg time addr port|~pitch.set(*msg[1].postln)},"/pitch", recvPort:8000  );
OSCdef(\test,{|msg time addr port|~roll.set(*msg[1])},"/roll", recvPort:8000  );
~head.scope;
~pitch.scope
~front = FoaEncoderMatrix.newDirection(0, 0);
~decoder = FoaDecoderKernel.newSpherical(4, s, s.sampleRate, nil);
(
{
	var tracker = In.kr(~head);
	var yaw = In.kr(~yaw,1) * pi;
	var pitch = In.kr(~pitch,1) * pi/2;
	s.meter
	var roll = In.kr(~roll,1) * pi/2;
	Impulse.ar(3) => FreeVerb.ar(_,0.1,0.5)
	=> FoaEncode.ar(_, ~front)
	=> _.poll
	=> FoaTransform.ar(_, \rtt, yaw, pitch, roll)=>_.poll
	// * In.kr(~head, 4)
	=> FoaDecode.ar(_, ~decoder)
().play
}.play
)
	Monitors.headphones
	().play
	s.meter
