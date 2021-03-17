
(
[
"xx.xxx.x".asDrumPat(8,8),\sn_808,
"..x...x.".asDrumPat(8,8),\LT_808,
"x..x..x.".asDrumPat(8,8),\MT_808,
"......x.".asDrumPat,\cymbal_808,
//"..xx..xx".asDrumPat/3*4,\rimshot_808,
"xxxxxxxx".asDrumPat(8,8),\hat_808,
"x...x...x...x...x...x...x.x.x.x.".asDrumPat(8,2),\bd_808

]
.pairsDo({|i j| [out:8,dur:i,instrument:j].p=>Pn(_,inf)=>_.play});
{In.ar(8,2)=>FreeVerb.ar(_,0.5,0.5).distort}.play(s,0);
//[instrument:\noizykey2,degree:Pclump(2, Prand([1,4,5],inf)),octave:Pxrand([2,3,Rest(2),Rest(),2,3],inf),out:[8,9],dur:Prand([1,1,0.5,0.5,[0.25].q(4)],inf),amp:0.05].pp;



 //autoharp
	fork{
		150.do{
			[
				[1,3,5,11]   ,
				[1,13,5,21]  ,
				[1,13,15,21] ,
				[1,3,15,21]  ,
				[1,15,23,11] ,
			].choose
			=>_.dm([\d, \a, \g ].choose,octave:4)
			=>(out:[0,1,1,0],instrument:\noizykey,midinote:_,strum:rrand(0.01,0.03))
			=>_.play;
		[ 0.5,0.5,1 ].choose.wait

	}}
)

