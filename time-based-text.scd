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

Document.new("type some text")
    .bounds_(Rect(100,SCWindow.screenBounds.height - 250, 400, 200))
    .keyDownAction = { |doc, key| r.value(key) ; time = Main.elapsedTime};
)

// play back text in time
(
d = Document.new("type some text")
    .bounds_(Rect(550,SCWindow.screenBounds.height-250,400,200));
fork({
    a.do { |pair|
        d.string = d.string ++ pair[0];
        pair[1].wait;
    }
}, AppClock)
)
