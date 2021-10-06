"ffmpeg -f concat -safe 0 -i /Users/michael/tank/super/FFMPEG/pngs.txt  -vsync vfr -pix_fmt yuv420p -framerate 24 output.mov".unixCmd


//-shortest 
ffmpeg -loop 1 -i img.jpg -i audio.wav -c:v libx264 -c:a aac -b:a 192k -shortest out.mp4


