s;
s=Server.local;
Server.default=s;

a=NodeProxy.new.play;
a[0]={Saw.ar(400,0.2)};
a[1]=\filter->{|in| LPF.ar(in,400)}; 
a[1]=\filter->{|in| LPF.ar(in,2200)}; 
a.set(\wet1,1);
a.play(1,1,fadeTime:3);
a.fadeTime = 5;
a[1].fadeTime=5;
a[1]=
