+Array {
  triggers{ 
    var size = this.size;
    ^Array.fill2D(size,size,{|i j| (i==j).if{1}{-1}});
  }
  tduty{ |values=1 gapFirst=0|
	  //^TDuty.kr(this.dq,0,values)
		^TDuty.multiNew('control',this.dq,0,0,values, gapFirst)
  }
  demand{ | dur |
	  //(values.isKindOf(Array)).if{values = values.dq};
	  //^Demand.kr(this.tduty,0,values)
	^Demand.multiNewList(['control',dur.tduty,0] ++this)
  }
}
+ TDuty {
  *fromDurs { | durs repeats=1 | 
    ^TDuty.kr(durs.dq(repeats),0,durs.triggers.dq(repeats))
  }
}

+Object{
  tduty{ |values=1 gapFirst=0|
	  //^TDuty.kr(this.dq,0,values)
		^TDuty.multiNew('control',this.dq,0,0,values, gapFirst)
  }
  demand{ | dur |
    //(values.isKindOf(Array)).if{values = values.dq};
    //^Demand.kr(this.tduty,0,values)
    ^Demand.multiNewList(['control',dur.tduty,0] ++ this)
  }
  duty { | ...args |
    ^Duty.multiNew('control', args[0],  args[1] ? 1 ,0, this)
  }
  stripSymbols{ ^this.replace(\r,0)}
  dq { | repeats=1 |
    //^Dseq(this,repeats)
    ^Dseq.multiNewList([ 'demand',repeats ] ++ this)
  }          
  //dq { | repeats=1 |
  //       ^ Dseq(this,repeats)
  //}          

}
