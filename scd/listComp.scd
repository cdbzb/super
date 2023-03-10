all{:x,x<-{}}
app: /.*/
'list comprehensions'.help
(
~chordAt={|start end array| array[start..end].inject((1..128),sect(_,_))};
l=LambdaEnvir((
	chordAt: { {|start end array| array[start..end].inject((1..128),sect(_,_))} },
	length: 40,
	durs: {~length.collect{ [2,0.5,1,5].choose }},
	swells: {
		all{:[x,y,note],x<-(1..~length),y<-(1..~length),note<-(60..77),
		y>x,
		~chordAt.(x,y,~chords).includes(note)	}
	},
	//find common tones
	chords: {~length.collect({3.collect{rrand(1,7)+[0,4,5,7].choose+60}})},
	pbind: {[dur:~durs.q,midinote:~chords.q,legato:Pwhite(0.5,2)].p},
	onsets: { [0]++~durs.collect{|i x| ~durs[0..( x )].sum} },
	list: {
		~swells.collect{|i| 
		var start = ~onsets[i[0]]; 
		var length =  ~onsets[i[1]] - start ; 
		(
			start:start,
			instrument:\stringyy,
			dur:length,
			midinote:~chordAt.(i[0],i[1],~chords)+[12,0, 24 ].choose
		) };
	},
	play:{~list.do{|e|TempoClock.sched(e.start,{e.play})};~pbind.play}

)).play;
//~swells=all{:[x,y],x<-(0..l.chords.size),y<-(0..l.chords.size),y>x,~chordAt.(x,y,l.chords).size>0};
//s.reboot
//~list= l.swells.collect{|i| var start = l.onsets[i[0]]; var length =  l.onsets[i[1]] - start ; (start:start,instrument:\stringyy,dur:length,midinote:~chordAt.(i[0],i[1],l.chords)+[12,0, 24 ].choose)};
//~list.size
//l.swells.size
//l.onsets
//l.durs
//l.swells
//l.chords
//~list.do{|e|TempoClock.sched(e.start,{e.play})};
//~list.do(_.postln)
//l.pbind.play
)
~swells.size
~chordAt.(1,4).size
l.chords[3..4].inject((1..128),sect(_,_))
l.chordAt.(0,1)
[1,2,3].includes(3)


