
// Sickbay
(
s.waitForBoot{
	Song(\chapelForgets,[]).current;
	["(Chapel is holding the hypos and trying to remember something very important.)","c",[6]].addLine;
	P(\pad, music: { |p b e|
		{
			Gendy2.arWidth(freq:[1,-1].df(\c)* Pulse.kr(4).range(1,1.midiratio),width:1.midiratio)
			* 0.02
			=> {|i|i + AllpassC.ar(i,0.1,[1].dm(\b,[3,5]).midicps.reciprocal,decaytime:SinOsc.ar(0.1).range(0.5,2),mul:0.45)}
			=> {|i|i + AllpassC.ar(i,0.1,[1].dm(\c,[3,5]).midicps.reciprocal,decaytime:SinOsc.ar([0.09,0.11,0.12,0.13]).range(0.5,2),mul:0.75)}
			* 
			Env([0.1,1,0],[2,9],curve:[0,-2])//.plot
			.kr(2,gate:1)
			=> HPF.ar(_,250)
		}.play
	});
	["MCCOY: Nurse, how are the last metabolic readings on our patients?","4 5 4 3 4 5.5 5 4 3 3 2 3 4.5 4.5 5.5".dm(\c)].addLine;
	P.tune(\Nurse);
	["CHAPEL: You'll find them excellent, Doctor. Well within normal.","3 4 5 7 5 4 4 3".dm(\a,\mixolydian)].addLine;
	P.tune(\excellent);
	["MCCOY: Is something wrong, Miss Chapel?","r"].addLine;
	["CHAPEL: Er, yes. I, er, I had something to say. I can't seem to remember.","3 4 3 2.5 3 4 5 4 3 7 11 6 7 5 6 4 3".dm('a-',\mixolydian)].addLine;
	P.tune(\Er);
	["MCCOY: Regarding our patients?","r"].addLine;
	["CHAPEL: Yes. That must be it. ","r"].addLine;
	["I am so pleased the way they are responding, Doctor.","r" ].addLine;
	["The formula's working perfectly.","r"].addLine;
	["MCCOY: You look tired, Miss Chapel. Perhaps you'd care for me to administer the last few injections.","r"].addLine;
	["CHAPEL: Tired? Well, not at all, Doctor. Thank you for asking.","r"].addLine;
	["(Leaves a puzzled McCoy.)","r"].addLine;
}
)
