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
"[1:v][0:v]blend=all_expr='A*(if(gte(T,3),1,T/3))+B*(1-(if(gte(T,3),1,T/3)))'[v0]; \
 [2:v][1:v]blend=all_expr='A*(if(gte(T,3),1,T/3))+B*(1-(if(gte(T,3),1,T/3)))'[v1]; \
 [3:v][2:v]blend=all_expr='A*(if(gte(T,3),1,T/3))+B*(1-(if(gte(T,3),1,T/3)))'[v2]; \
 [4:v][3:v]blend=all_expr='A*(if(gte(T,3),1,T/3))+B*(1-(if(gte(T,3),1,T/3)))'[v3]; \
 [v0][v1][v2][v3]concat=n=4:v=1:a=0,format=yuv420p[v]" \
-map "[v]" -map 5:a -shortest out.mov


