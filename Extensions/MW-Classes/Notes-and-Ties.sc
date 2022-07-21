Stem {
	var <value,<duration;
	*new{|value, duration| ^super.newCopyArgs (value,duration) }
	+ {
		|that|
		that.isMemberOf(Tied).if{^Stem(this.value,this.duration+that.duration)}
	}
}
Tied : Stem {
	*new{|value, duration| ^super.newCopyArgs (value,duration) }
}
Rst : Stem {
	*new{|duration| ^Stem(Rest(duration),duration)}
}

Melody[slot] : Array {
	*new{|...args| ^super.new(*args)}
	*foo {|a|^super.newFrom(a)}
	//call this method reduce?
	value { 
		^Melody.newFrom(
			this.split({|i| i.class==Stem}).collect{
				|i|
				(i.size==1).if{i.unbubble}
				{i.inject(i[0],{|x y| x+y })}
			}
		) 
	}
	dm { |root='a' octave=3 scale=\major|
		octave.isKindOf(Symbol).if{scale=octave;octave=5};
		^this.collect{|i|[i.value,i.duration]}.flop=>{|i| [midinote:i[0].dm(root,octave,scale).q,dur:i[1].q] }
	}
	df { |root='a' octave=3 scale=\major|
		^this.collect{|i|[i.value,i.duration]}.flop=>{|i| [freq:i[0].df(root,octave,scale).q,dur:i[1].q] }
	}

}

+Array{
	asMelody { |reps=1|
		var durs = this.subdivide;
		var result = this.flat.collect{
			|i, x|
			case
			{i.class==Ref}		{Tied(i.value,durs[x])}
			{i.isNumber}  		{Stem(i,durs[x])}
			{i.isKindOf(Tuple)}	{Stem(i.storeArgs,durs[x])}
			{i==\r}			{Stem(i,durs[x])}
		};
		^ Melody.newFrom(result!reps => _.flatten).value
	}
}

/*
[Stem(3,1),Tied(3,2),Stem(4,1)].split({|i| i.class==Stem})[0].sum
[T(1,3,5),[1,4,6]].asMelody.dm(\c,octave:5).pp
Melody.foo([1,2,3])
Melody.newFrom([ 1,23,3 ]).class
Array.newFrom([2,3,4])
[2,`2,[1,2, 3 ]].asMelody.collect{|i|[i.value,i.duration]}.flop=>{|i| [dur:i[0].q,midinote:i[1].dm(\a).q] }=>_.pp
[2,`2,[1,2, 3 ],[`3, 5], [3, 1]].asMelody.dm(octave:5).pp
a=Melody[Stem(1,2),Stem(2,2),Tied(2,1),Tied(4,1),Stem(9,9),Stem(3,3)].value.class
Melody.new([2,3,4])
a=Melody[Stem(1,2),Stem(2,2),Tied(2,1)].split({|i| i.class==Stem}).class
({|i| i.class==Stem })
a.splitt
a=Melody[Stem(1,2),Stem(2,2),Tied(2,1)].split

1
a.class
Phrase
.split({|i| i.class==Stem})[1].sum
b=Stem(3,1) +Tied(3,2)
b.duration
s.reboot
a=Tie(11,2)
a.value
*/
