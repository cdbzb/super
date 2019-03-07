~soundPath='/Users/michael/tank/SchaferHouse/SOUND/'

//Traffic walking
~traffic=SoundFile.collectIntoBuffers("/Users/michael/tank/SchaferHouse/SOUND/VENICE RECORDINGS/*");
~names.(~traffic);
~traffic[3].play;
~sr=s.sampleRate;
{PlayBuf.ar(2,~traffic[3],startPos:24.5*~sr)}.play;
{PlayBuf.ar(2,~traffic[4],startPos:24.5*~sr)}.play;




// IDEA circlewalk




//Enter Lobby (music??)
// lobby walk
//elevator
//enter room
//bag
//bathroom

