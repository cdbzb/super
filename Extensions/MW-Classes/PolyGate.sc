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
  asDemandFreqs{

	  var result = this.copy;
	  var firstNonRest = (0..result.size).select{|i|result[i].isNumber}.minItem; //first non rest
	  //c=result[firstNonRest];
	  firstNonRest.do{|i| result[i]=result[firstNonRest]}; //change initial rests to first non rest
	  result => {|a| 
		  a.do{|i x| (i==\r).if{a[x]=a[x-1]}{a[x]=i}}; 
	  ^a 
	  }; //change subsequent rests to be previous non rest
  }
  asDemandGate{
	  ^this.collect{|i| i.isNumber.binaryValue} ++ 0
  }
  spanRests { 
      // [1,2,3].spanRests([4,\r,5,6]) == [1,1,2,3]
      |tune| 
      var a = \r; 
      var stream = this.q.asStream; 
      ^tune.collect{ |i|
          (i != \r).if{ a = stream.next } { a }
      }
  }
}
