(
Song(\medical,[]).current;
["Medical Log. Stardate 4770.3. ",[4,3,2,1,-5, 1,-7,-4, -7,1,2,3, 1, -7,3].dm(\c)].addLine;
~justTheTune.('Stardate');
[ "Do I list one death or two? When " ,"d"].addLine;
P(\chord,start:'one death',music:
	{ |p b e|
		(strum:0.05,midinote:[1,3,5,11].dm(\d,scale:\minor)).play
	}
);
)

~recorder.(Song.currentSong,1)
Song.pbind[0].play
Song.writeLyricDurationFile
Song.save


/*
Kirk's body died, 
Sargon was too far /*distant*/ 
from his receptacle to transfer back. 
Sargon is dead. 
But is Captain Kirk dead? 
His body is, but his 
consciousness is still in the receptacle 
// into which it was transferred earlier.

[Sickbay]

(The medical team hook Kirk's body up to a life support machine.) 
NURSE: All his vital organs are now working, Doctor. 
MCCOY: Yes, we can keep them going for a few 
weeks, or a month. For all the good it'll do.
*/
