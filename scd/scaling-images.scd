(
~scale = 1.5;
w= Window(\foo, Rect(100,100,1400,1600) );
i = Image.open("/tmp/60.png");
i.setSize(1400 * ~scale => _.asInteger,1600 * ~scale => _.asInteger, resizeMode:\keepAspectRatio);
w.setInnerExtent(1400*~scale,1600*~scale);
w.drawFunc_({Pen.drawImage(Point(0,0),i)});
w.front;
w.setExtent(200,300).front
)
