+Array{
	split  { | test | 
		var b=this.collect{|i x| i.isSymbol.if{x}}.reject(_.isNil).flat;
		b =b ++( this.size  );
		(b[0] == 0).not.if{b = [0]++b};
		b=b.dropLast.collect{|i x| b.at(x+1)-i};
		^this.clumps(b)
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

	subdivide { |beat=1|
			var a = this.collect({
					|i| 
					(i.isKindOf(Tuple)).if{i=i.at1};
					if( i.size==0, {
							if (i == \r,{Rest(beat)},{(i/i.abs)*beat})
					},{
							i.subdivide(i.size.reciprocal*beat)
					} 
			)}).flat.collect({|i|i.isNumber.if{i.abs}{i.value}});
			^a;
	}

}

+ String{
	prFlat {|list|^list add: this}
}
/*
[
		[1,3,2,[-2,2],T(2,3)!3,[T(3,4,21),T(3,5,17)]].melody++
		[\legato,2.2,out:Effect( TwoTube.ar(_,0.1,0.8,2000,111,mul:3),out:1).bus.index]=>_ .p=>Pn(_,2) , 
		[\r,\r,\r,\r,\r,\r,[17,[-17, 16]],15].melody++

		[\legato,2.2,out:Effect( TwoTube.ar(_,0.1,0.8,2000,111,mul:3),out:1).bus.index]=>_ .p , 
] => Ppar(_,4)
=>_.play
Tuple2
[1,[2,2],[-2,4]].melody.pp
T(1,2).isKindOf(Tuple)
a=Ref("aaa")
a.class
Ref("aaa")
[1,2,-1,3].tie
[1,1,[-1,1]].subdivide.tie
'-'/class
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
