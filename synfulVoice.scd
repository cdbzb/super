a=~synful3.();
a.shuffle
a.init
(
b={|channel=0, inst=\violas, bank=\trem | Plazy({
	a.patch(inst, bank, channel);
	[chan:channel,legato:1,type:\vst_midi,vst:a.controller,freq:Pwhite(200,500)*2.0.rand,dur:Prand([0.1,2,Rest(1)],inf)].p
}); }
)
(
b.(1,\violins,\mute).play;
b.(2,\horn).play;
b.(3,\bass,\arco).play;
a.setOut(Effect(FreeVerb.ar(_,1,1),inputChannels:2).bus.index)
)


(
~orch=(
	violin:0,
	viola:1,
	cello:2,
	bass:3
);
//~orch.pairsDo(a.patch(_,\arco,channel:_))
~orch.pairsDo({|i j| a.patch(i,\arco,j)});
[chan:~orch.viola,type:\vst_midi,vst:a.controller,note:[[1,3,5],[1,4,6],[1,2,5]].q(inf)-8].pp;
[chan:~orch.violin,type:\vst_midi,vst:a.controller,note:[[1,3,5],[1,4,6],[1,2,5]].q(inf)-8].pp;
[chan:~orch.bass,type:\vst_midi,vst:a.controller,note:[[1,3,5],[1,4,6],[1,2,5]].q(inf)-8].pp;
[amp:0,expr:Pfunc({|e| a.expression(( thisThread.seconds.sin*60+60),0)}),dur:0.1].pp;
)
[expression:[60,80,20].q,expr:Pfunc({|e| a.expression(e.expression,lag:dur)})]//gotta implement the lag here!
(
Event.addEventType(\synful,{
	var node=~instance.expr[~channel];
	node.source_(~expression);
	//node.fadeTime_(~dur);
	node.fadeTime=~expressionLag;
	~type=\vst_midi;
	~vst=~instance.controller;
	~chan=~channel;
	currentEnvironment.play

}, );
)
a.init;
a.activateAll;
a.expr[0].scope
a.shuffle
[amp:0.5,dur:Pwhite(0.01,0.3,inf),type:\synful,expression:Prand( [0.5,0.2,0.9], inf )=>Pstutter(10,_),expressionLag:1,freq:[1,3,5,7,11,13].df(\c).q(inf),channel:0.rand,instance:a,legato:Pwrand([1,0.1,0.5],[9,1,1]/11,inf)].pp

a.setOut(Effect(FreeVerb.ar(_,0.8,0.8),inputChannels:2).bus.index)
a.expr[0].scope
a.activate(0);
a.shuffle
a.activate(1)
(type:\synful,expression:0.9,channel:0,instance:a,dur:5,dur:3,note:1).play
{ [type:\synful,\patch:[\cello,\viola,\violin].choose,\bank:\tremolo,expression:[[0.5, 0.1 ].choose,0.8,0.2,0].q,channel:16.rand,note:Pwhite(0,20,inf),legato:1,instance:a,dur:[1,3,2].q].pp;a.shuffle }.sched(Array.fill(9,{25.rand}))
a.shuffle
a.activateAll
Ppar(
	[
		[channel:Pwhite(0,16),dur:Pwhite(0.1,1,inf),note:[ Pwhite(0,12,Pwhite(1,6,1)),Rest(1) ].q(inf),legato:1,type:\vst_midi,vst:a.controller].p,
		[channel:1,dur:Pwhite(0.1,1,inf),note:[ Pwhite(0,12,Pwhite(1,6,1)),Rest(1) ].q(inf),legato:1,type:\vst_midi,vst:a.controller].p,
		
		[type:\synful,expression:Prand( [0.5,0.2,0.9], inf ),channel:0,instance:a,dur:4].p,
		[type:\synful,expression:Prand( [0.5,0.2,0.9], inf ),channel:1,instance:a,dur:4].p
	]
).play
a.init
a.expr[0].source=0.10
a.expr[0].fadeTime_(5)
a.expr[0].scope
(\type: \vst_midi,vst:a.controller,chan:0,dur:100).play

a
TempoClock.seconds.sin
{thisThread.seconds.post}.value


[
	[ [1,2,3],\a ],
	[ [2,3,4],\b ]
].flop[0].bubble++[[ 5,5,5 ]]


a=Penvir((patch:\violin,\bank:\arco))
a.nextN(10)
Plambda([dev:\patch].p,(patch:\violin)).trace.play

