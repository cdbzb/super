fork {  // shortcut to run a routine
> p=ProxySpace.push;
> ~sound={0.1*SinOsc.ar};
> s.prepareForRecord("/home/me/recording.wav");

s.sync;  // make sure the server is really ready to record

> s.record;
> ~sound.play;

90.wait;

> // ~sound.release(30);

30.wait;

> //when released
> s.stopRecording;

};

