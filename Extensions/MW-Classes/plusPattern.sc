+Pattern {
	+= { |that|
			(that.class==Ppar).if{
					that.list_(that.list++this)
					^that
			}{
					^Ppar([this,that])
			}
	}
	set { |...args| ^Pbindf(this,*args) }
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

