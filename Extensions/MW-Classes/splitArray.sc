+Array{
	split{ |test|
		^
		this//.collect({|i| if(i.class==String, {i=Ref(i)},{i})})
		.collect{|i j| [j,i]}
		.select{|i| i[1]=>test}
		.collect(_[0])++this.size
		=> {|i| (i.size-1).collect{|x| i[x+1]-i[x]}}
		=> _.collect(1!_)
		=> this.reshapeLike(_)
	}
	dmx {
		^this.split({|i| i.class==String})
		.collect({|a| 
			//a.postln
			{|durs ins...pairs| 
				ins.postln; 
				[instrument:ins,dur:durs.asDrumPat.list.q(inf) ]++pairs
				=>_.p
			}.valueArray(a)
		})
	}
	melody { |root='c' octave=5 scale='major' beat=1|
		^[ 
			midinote:
			 

				this.dm(root,octave,scale).flat.collect{ |i| 
					if( i.class==Tuple2,{[ i.at1,i.at2 ]},{i} )
				}.q,
				dur:
				this.subdivide(beat).q
			
		]

	}

	subdivide { |beat=1|
		^this.collect({|i| 
			if( i.size==0, {
				if (i == \r,{Rest(beat)},{beat})
			},{
				i.subdivide(i.size.reciprocal*beat)} 
			)}).flat 
	}

}
+ String{
	prFlat {|list|^list add: this}
}
/*
["lll",1].reshapeLike([[1,[2]]])
[0,1,0,2,4].split({|i|i==0})
a=Ref("aaa")
a.class
Ref("aaa")
[\mm,0,9,8,\n,9,8,8,\z,9,9].split({|i|i.class==Symbol})
(
[
	"....x...",\hihat,\amp,0.1,\rel,Pwhite(0.1,2),
	"x.......x.x.x.x.x.......x.......",\kick3,
	"x..x..x.",\MT_808,\amp,0.05,\pan,Pwhite(-1,1),
	"x......x.........",\cymbalsDS,\amp,0.01,\out,Effect(Phaser1.ar(_,rate:0.05)).bus.index,
].dmx
=>Ppar(_)=> Pfin(64*4*4,_) => _.play
)
(


.split({|i| i.class==String})
.collect({|a| 
	//a.postln
	{|durs ins...pairs| 
		ins.postln; 
		[instrument:ins,dur:durs.asDrumPat ]++pairs
		=>_.p
	}.valueArray(a)
})
=>Ppar(_,8)
=>_.play
)
b={|i j| i.postln;j.postln}
b.valueArray([1,2,3])
["asd",1,2].reshapeLike([[1,[2,3]]])
List
*/
