 Event.addEventType(\cyc, {
 	 var song = Yoeminrak.song[~sec];
 	 
 	 // Apply solo filtering if solo is specified
 	 if (~solo.notNil) {
 	 	 song = song.select { |event|
 	 	 	 var eventTypeStr = event.type.asString;
 	 	 	 ~solo.asArray.any { |soloItem|
 	 	 	 	 eventTypeStr.contains(soloItem.asString)
 	 	 	 }
 	 	 };
 	 };
 	 
 	 // Apply mute filtering if mute is specified
 	 if (~mute.notNil) {
 	 	 song = song.reject { |event|
 	 	 	 var eventTypeStr = event.type.asString;
 	 	 	 ~mute.asArray.any { |muteItem|
 	 	 	 	 eventTypeStr.contains(muteItem.asString)
 	 	 	 }
 	 	 };
 	 };
 	 
 	 song.play(~start ? 0);
     Yoeminrak.env.put(\lastCyc, currentEnvironment)
 });
