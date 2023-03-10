CmdPeriod.remove(~masterFader)
CmdPeriod.objects
s.reboot
s.plotTreeL

(
	CmdPeriod.removeAll;
	StageLimiter.activate;
	s.options.numOutputBusChannels_(16);
	s.options.outputStreamsEnabled="01000";
	s.reboot
	s.meter
	o=s.options;
//	o.outDevice_("USBStreamer ");
s.meter;
	o.outDevice_("Digiface USB (23953833)");
	s.options.sampleRate_(48000);
		s.reboot;
		s.waitForBoot{
			~masterFader=Volume(s,0,4,persist:true,max:0).gui(bounds:Rect(-400,800,80,350));
			//s.meter(bounds:Rect(-900,100,200,200));
			s.plotTreeL;
		};
		g=();
)


(//electronic music is easy
	h=Group.new;
	r={
		40.do{
			{
				[Gendy4,Gendy1,Gendy2].choose.ar(minfreq:150*(3.rand+1),maxfreq:250*(3.rand+1),mul:0.005)
				* Env.triangle(15).kr(2,gate:\gate.kr(1)) 
			}.play(h,4.rand+8);
			10.rand.wait;
			5.rand.even.if({
				PlateReverb.ar([Gendy4,Gendy1,Gendy2].choose.ar(minfreq:150*(3.rand+1),maxfreq:250*(3.rand+1),mul:0.005)
				* Env.triangle(12).kr(2,gate:1)) }.play(h,4.rand+8));
			5.rand.wait
		}
	}.fork
)
h.release(5).r.stop
h.free;
s.meter

(///like a bowed gong
	//todo spread the delays around the speakers
	f=Group(s);
	r={
		19.do{{
			var primes = all {:x,x<-(100..8000),x.isPrime};
			//var sig=Impulse.ar(3)*0.01;
			var sig=Gendy1.ar(minfreq:rrand(100,500))*0.01;
			15.do{
				var i= primes.choose;
				sig=sig+DelayN.ar(sig,0.1,i/48000)
			};
			sig*0.05* Env.triangle(30.rand).kr(2,gate:1) ;
		}.play(f,3.rand+1+8);
		10.rand.wait;
		}
	}.fork
)
f.release(5);r.stop
r.stop

( ////yaaay this notation works
	g=Group(s);
	[0,2].do{|i|{ |gate=1| 
		var sig = 
			Saw.ar(800+LFBrownNoise1.kr(2,mul:30),0.1) 
			=> LPF.ar(_,1299) ;
		var sig2 = 
			Pulse.ar(125+SinOsc.kr(0.1*LFBrownNoise1.kr(0.3,add:0.3),pi.rand,100),0.1,0.08);
		[ sig,sig2 ]	
			=> PlateReverb.ar(_) * 0.3 * Env.linen(0,80,6).kr(2,gate:gate)
			=> Out.ar(i+7,_);
	}.play(g)}
)
g.release(10)
s.meter

