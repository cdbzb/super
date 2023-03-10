
{[300,400,500].dq => Demand.kr(KeyState.kr(38,-1,1).poll,0,_) => SinOsc.ar(_)}.play
(
~keyplay = {|array|
	{
		array.dq => Demand.kr(KeyState.kr(38,-1,1),0,_) => SinOsc.ar(_,0,0.1)
		* Env.perc().kr(0,gate:KeyState.kr(38,-1,1))
	}.play
}
)
(
~keyplay.([6,6,5,4,3,3,3].df(\f));
KeyRecorder()
)
