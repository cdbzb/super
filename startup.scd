//var files="/Users/michael/tank/super/Library/functions/*".pathMatch;
files=files++"/Users/michael/tank/super/Library/synthdefs/*".pathMatch;
files.do({|file| file.load; file.postln});
Library.postTree;
StageLimiter.activate;
