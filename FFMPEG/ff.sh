#!/bin/bash

ffmpeg \
	-y \
-loop 1 -t 5 -i 2274.3.png \
-loop 1 -t 5 -i 2282.81.png  \
-loop 1 -t 5 -i 2288.6.png   \
-loop 1 -t 5 -i 2291.43.png  \
-loop 1 -t 5 -i 2354.542.png \
-i ../samples/keep\ this\ body/210212_105533.aif \
-filter_complex \
"[0:v]fade=t=out:st=4:d=2[v0]; \
[1:v]fade=t=in:st=0:d=2,fade=t=out:st=4:d=1[v1]; \
[2:v]fade=t=in:st=0:d=1,fade=t=out:st=4:d=1[v2]; \
[3:v]fade=t=in:st=0:d=1,fade=t=out:st=4:d=1[v3]; \
[4:v]fade=t=in:st=0:d=1,fade=t=out:st=4:d=1[v4]; \
[v0][v1][v2][v3][v4]concat=n=5:v=1:a=0,format=yuv420p[v]" -map "[v]" -map 5:a -shortest out.mp4


#ffmpeg -loop 1 -i input0.png -loop 1 -i input1.png -filter_complex \
#\
#"[1:v][0:v]blend=all_expr='A*(if(gte(T,3),1,T/3))+B*(1-(if(gte(T,3),1,T/3)))'" -t 4 frames_%04d.png

