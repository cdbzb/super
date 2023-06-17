+Pattern {
	+= { |that|
			(that.class==Ppar).if{
				(that.class == Array).if {
					var ppar1 = this.list.collect{|i| [0,this]}.flatten;
					ppar1.list_(ppar1.list++this);
					^ppar1
				}{
					that.list_(that.list++this)
					^that
				}
			}{
				
				( that.class == Array ).if { ^Ptpar([0,this]++that=>_.flatten) }
					^Ppar([this,that])
			}
	}
	set { |...args| ^Pbindf(this,*args) }
}
+Array{
	par{|num=1| ^Ppar(this,num)}
}
+Pattern{
	findur{|i |
		^Pfindur(i,this)
	}
}
+Ppar {
	set { |...args| var first = [this.list,args.flop].flop;
	list=first.collect{|i| i[0].set(*i[1])};
	^Ppar(list)
	}
}
	//[[\out, \instrument ],[\a,[\c, \b ]]].flop
	//[\out,(0..2),\instrument,\d].flop
	//[\out,2].flop
	//[1,[0, 2 ],3,4].clump(2).collect(_.flop)
	//[[1,2,3,4],[\a,\b,\c,[\z,\x,\c]]].flop

	//this is right
	///////////////
	//[[\first,\secong,\third],[1,\apple,3,[\pear,\quince,\berry],2,[88,99]].flop].flop
	//[[\first,\secong,\third],[1,2,3,2].flop].flop

