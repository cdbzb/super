
i=Image.new("~/titles/109 anxious to help.png");
w=i.plot;
w.close;


(
p = "~/Downloads/Cards_PNG/*.png".pathMatch;

w=Window;
		c=Image.new(p.choose);
w=c.plot;
w.close;
r = Routine({
	52.do ({ arg i;
		AppClock.sched((i/6),{
			c=Image.new(p.choose);
			w= c.plot;});
	});
}).play

)

AppClock.play(r)

(
var w, r;
w = Window.new("trem", Rect(512, 256, 360, 130));
w.front;
r = Routine({
    60.do({ arg i;
        0.05.yield;
        w.bounds = w.bounds.moveBy(10.rand2, 10.rand2);
        w.alpha = cos(i*0.1pi)*0.5+0.5;
    });
    1.yield;
    w.close;
});
AppClock.play(r);
)