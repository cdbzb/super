// record: type some text
(
var time = Main.elapsedTime;
a = List.new;
r = Routine { |char|
loop {
    a = a.add([char, Main.elapsedTime - time]);
    char = 0.yield;
}
};

w=Window.new("type some text");
    w.bounds_(Rect(100, 250, 400, 200));
	v=View.new(w);
    v.keyDownAction = { |window key| var time; r.value(key) ; time = Main.elapsedTime};
	w.front;

)

// ndow("EZText", Rect(300, 300, 260, 60)).front;
(
g = EZText( w,          // parent
            250@50,     // bounds
            "testing",  // label
            { |ez| (ez.value.asString ++" is the value of " ++ ez).postln }, // action
            [1, 2, 3],  // initValue
            true        // initAction
);
g.setColors(Color.grey,Color.white);
);

// Simplest version, no parent view, so a window is created
(
    g = EZText(label:" test ");
    g.action_({ |ez| (ez.value.asString ++" is the value of " ++ ez).postln });
);

(
    g = EZText(bounds: Rect( 100, 200, 150, 50), label:" test ", layout: \vert);
    g.action_({ |ez| (ez.value.asString ++" is the value of " ++ ez).postln });
);play back text in time
(
d = Document.new("type some text")
    .bounds_(Rect(550,SCWindow.screenBounds.height-250,400,200));
fork({
    a.do { |pair|
        d.string = d.string ++ pair[0];
        pair[1].wait;
    }
}, AppClock)
Archive.archiveDir;
q=();
Archive.archiveDir="/tmp";
q.midi=[[12,13,16],[\a]];
Archive.put(\midi)
Archive.put(\midi,q	);
Archive.at(\midi).midi;
d=Archive.global.at(\midi);
d.midi;
p=Pipe.new("'/Applications/REAPER ƒ/REAPER64.app/Contents/MacOS/REAPER' -new ", "r");
a=File.prgetCwd;
~rpr.new.();
~rpr.saveas(filename:"trashme2.RPP");
~rpr.openFile="trashme.RPP";
Platform
a=File.getcwd.asString;
p.close;
a;
s.reboot;
SCN	

p.getLine;
p.close;
Archive.;
p=PathName.new("/Applications/REAPER\ ƒ/REAPER64.app/Contents/MacOS/REAPER");
p=Pipe.call('ls',"r");
:
/Users/michael/tank/super
s.boot;
a=~rpr.new.();
a.close;
a;



