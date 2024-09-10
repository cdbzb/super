(
var keys="zsxdcvgbhnjm.;";
w = Window.new;
w.front;
v = w.view;
v.keyDownAction = {|view char|
	(
		note: keys.indexOf(char)
	).play

}
)
