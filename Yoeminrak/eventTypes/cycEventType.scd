 Event.addEventType(\cyc, {
 	 var song = Yoeminrak.song[~sec];
 	 
 	 // Apply solo filtering if solo is specified
 	 if (~solo.notNil) {
 	 	 song = song.select { |event|
 	 	 	 event.type.asString.contains(~solo.asString)
 	 	 };
 	 };
 	 
 	 // Apply mute filtering if mute is specified
 	 if (~mute.notNil) {
 	 	 song = song.reject { |event|
 	 	 	 event.type.asString.contains(~mute.asString)
 	 	 };
 	 };
 	 
 	 song.play(~start ? 0);
     Yoeminrak.env.put(\lastCyc, currentEnvironment)
 });
