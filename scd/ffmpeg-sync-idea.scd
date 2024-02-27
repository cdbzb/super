(
"ffmpeg -i input.mp4 "
"-filter_complex "
"\""
"[0:v]trim=00:20[v0]; "
"[0:v]trim=20:40,setpts=(PTS-STARTPTS)*.5[v1]; "
"[0:v]trim=40:60,setpts=PTS-STARTPTS[v2]; "
"[v0][v1][v2]concat=n=3:v=1[new]\" "
" -map \"[new]\" output.mp4 "
=> _.unixCmd
)

(
var segment = [20, 40];
var rate = 0.5;

"[0:v]trim="
++segment[0]++":"++segment[1]
// "20:40"
++",setpts=(PTS-STARTPTS)*"
++rate.asString.drop(1)
// ".5"
++"[v1]; "
)

(
~seg = { |segment=#[20,40] rate=0.5 |
	"[0:v]trim="
	++segment[0]++":"++segment[1]
	// "20:40"
	++",setpts=(PTS-STARTPTS)*"
	++rate.asString.drop(1)
	// ".5"
	++"[v1]; ";
};
~seg.([ 20,30 ],0.2)
)
