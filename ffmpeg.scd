{SinOsc.ar(400*SinOsc.kr(150).range(0.9,1.1))}.play
(
	~getFrame= {|seconds|
		Pipe("ffmpeg -ss "++seconds.asString++" -i '/Users/michael/tank/Trek/video for stills etc/media/return to tomorrow.mov'  -vframes 1  -f image2 "++seconds.asString++".jpg ","w")
	};
)
a=Image.open("/Users/michael/tank/super/2282.81.jpg")
Pipe("ffmpeg -ss "++seconds.asString++" -i '/Users/michael/tank/Trek/video for stills etc/media/return to tomorrow.mov'  -vframes 1  -f image2 "++seconds.asString++".jpg ","w")

	~markers=(
		kirk: ~kirk,
		spock: 30.2
	);

	~markers.do{|seconds|~getFrame.(seconds)};
	~markers.do(_.postln);

 ~a={|mark|Image.open( "/Users/michael/tank/super/"++ ~markers[ mark ].asString++".jpg")};
 ~a.(\spock).plot(freeOnClose:true).alwaysOnTop_(true);
)
~markers[\kirk]

~a=NodeProxy.audio(s,1)
~a.source=\default
~a.play
~a.set(\freq,800)
~kirk=(38*60+2.81)
~getFrame.(~kirk)
~a.(\kirk).plot
~a.(\kirk)



