(
	~fade={|w|
		fork{var alpha=1;
			while({alpha>0},{alpha=alpha-0.01;0.01.wait;{w.alpha_(alpha)}.defer})
		}
	};
)
w=Window.new.alwaysOnTop_(true).front;
~fade.(w)
Event.addEventType(\still,{AppClock.sched(0.01,{~stills.preview(~key,monitor:~monitor,fade:~fade,wait:~wait)})})

~stills.set('whatsWrong?',2288.6);
a=(type:\still,key:'kirk-face',stills:~stills, fade:9, monitor:0,dur:3)
a.play
TempoClock.sched(1,{a.play})

(type:\still,key:'whatsWrong?',stills:~stills, fade:9, monitor:0,dur:3).play
[type:\still,key:'whatsWrong?',stills:~stills, fade:9, monitor:0,dur:3].p.play
(
	~stills.isNil.if{~stills=Stills("/Users/michael/tank/Trek/video for stills etc/media/return to tomorrow.mov")}; //{{{
	~stills.set('kirk-face',(38*60+2.81));
)
(
	//s.latency
		{
		[lag:0.00,note:1,dur:[1,1,1].q(3)].p.play;
			0.03.wait;
				SystemClock.sched(1,{{~stills.preview('kirk-face',wait:0.51,fade:2,monitor:0,text:['Sargon here','' ])}.defer});
				SystemClock.sched(2,{{~stills.preview('kirk-face',wait:0.51,fade:2,monitor:0,text:['','' ])}.defer});
				SystemClock.sched(3,{{~stills.preview('kirk-face',wait:0.51,fade:2,monitor:0,text:['Sargon here','' ])}.defer});
				SystemClock.sched(4,{{~stills.preview('kirk-face',wait:0.51,fade:2,monitor:0,text:['Sargon here','' ])}.defer});
				SystemClock.sched(5,{{~stills.preview('kirk-face',wait:0.51,fade:2,monitor:0,text:['Sargon here','' ])}.defer});
				SystemClock.sched(6,{{~stills.preview('kirk-face',wait:0.51,fade:2,monitor:0,text:['','' ])}.defer});
				SystemClock.sched(7,{{~stills.preview('kirk-face',fade:2,monitor:0,text:['','' ])}.defer});
				SystemClock.sched(8,{{~stills.preview('kirk-face',fade:2,monitor:0,text:['','' ])}.defer});
			
		}.fork
	
)

w={Window.new().alwaysOnTop_(true).front}.defer;

s.latency_(1)
	//b=['aaa','sss']
	//b[1]
)
~stills.preview('kirk-face',fade:2,monitor:0)
~stills.set('enter-Thalassa',(37*60+54.30));//}}}
Window.closeAll
(
	[note:3].p.play(SystemClock);
)

(
	t=StaticText.new(w,Rect(0,0,500,200))
	.string_('LLLL')
	.stringColor_(Color.rand)
	.align_(\left)
	.font_(Font(\helvetica,90,bold:true))
)
