VoiceLeading {
        var lines,durs,<>durationArray, <>valuesArray, <>triggers;
        var <>demandDurations, <>demandValues;
	var key=\degree;
	*new { |lines durs|
		^super.new.init(lines,durs)
	}
	*initClass {
	}

	++ { | that | 
		^VoiceLeading(
			lines.collect{|i x| i++that.lines[x]},
			//durs.collect{|i x| i++that.durs[x]},
			durs++that.durs
		)

	}
	init { |array durss|
                var longest = ( array.size>1 ).if{
                  array.collect({|i| i.size}).sort.tail.unbubble  //size of longest subarray
                }{
                  array[0].size
                };
                (array.rank == 1).if { array = array.bubble };
                (durss.isNumber).if{durss = durss.bubble; \bubble.postln};
                //pad durs using wrapAt (should this be clipAt??)
                //durss = longest.collect{|i| durss.wrapAt(i)};
		  durss = array[0].size.collect{|i| durss.wrapAt(i)};

                //pad array using clipAt
                //\xya.post;array.reshapeLike( ( 1 ! array.collect({|i| i.size}).sort.tail.unbubble) ! array.size, \clipAt ).postln;
		lines=array;
		durs=durss;
                ////////// these are for Pbinds
		durationArray=this.makeDurationsArray;        //hmmm but I need 2 versions!
		valuesArray=this.makeValuesArray;
                ////////// 
                triggers =lines.deepCollect(2 , { |i|  //set triggers
                  (i == \r ).if{0}{1} 
                });
                triggers = triggers.collect(_ ++ 0); // for release
                lines = lines.collect{|line|                  //set first rest to 20k
                  (line[0]==\r ).if{
                    [ 20 ] ++ line.tail => _.postln
                    }{
                      line
                    }
                };
                lines = lines.collect{|line|                  //replace rests with ties
                  line.replace(\r,\_).postln
                };
                demandDurations = this.makeDurationsArray; 
                demandValues = this.makeValuesArray;
	}

	durs { | index |
		(index.isNil).if{
			^durs
		}{
			^durationArray[index].q
		}
	}

	lines { | index |
		(index.isNil).if{
			^lines
		}{	
			^valuesArray[index].q
		}			
	}

	durs_ { | array |
		durs=array
	}

	makeDurationsArray {
		var indices=lines.collect{
			|line| line.collect{
				|i x| (i==\_).if{-1}{x}
			}.reject{|i| i == (-1)};
		};
		^indices.collect { |a| 
			var padded=(a++(lines[0].size));
			a.size.collect{
				|i| var delta=padded[i+1]-a[i]; 
				(delta>1).if{
					delta.collect{ |j| j+a[i] }
				}{
					[a[i]]
				} 
			}.collect{|i x|i.sum({|i| durs[i] })}
		} 
	}
	makeValuesArray {
		^lines.collect{|i|i.reject{|x| x == \_ }}.postln
	}

	voice {|number|
		^(
			line:lines[number].reject{|i|i==\_},
			durs:durationArray[number]
		)
	}
	at {|i| var line=this.voice(i);^[dur:line.durs.q,freq:line.line.q]}
	env {|i| ^Env(this.voice(i).line,this.voice(i).durs)}
	df {|root='c' octave=5 scale='major'|
		key = \freq;
		valuesArray=valuesArray.collect{|i|i.df(root,octave,scale)};
		demandValues=demandValues.collect{|i|i.df(root,octave,scale)};
		lines=lines.collect(_.df(root,octave,scale))
	}
	dm {|root='c' octave=5 scale='major'|
		key = \midinote;
		valuesArray=valuesArray.collect{|i|i.dm(root,octave,scale)};
		demandValues=demandValues.collect{|i|i.dm(root,octave,scale)};
		lines=lines.collect(_.dm(root,octave,scale))
	}
	p {
		^lines.collect{|i x|
			[key,valuesArray[x].q,dur:durationArray[x].q].p
		}
			=> Ppar(_)
	}
        //dur {^durationArray}
        dur {^demandDurations}
        gate { ^demandDurations.collect{ |i x|
          Demand.kr(( durs  ).tduty, 0, this.triggers[x].dq)} 
          ++ 0 //for release
        }
        everyNoteTrigger {
          ^this.dur.collect {|i|
            TDuty.kr(i.dropLast.dq, 0, 1)
          } 
        }
        
        duty { | voice=0 repeats=1 |
          ^valuesArray[voice].dq(repeats).duty(durationArray[voice].dq(repeats))
        }
        demand { 
          ^demandDurations.collect{ |i x|
            Demand.kr(i.tduty,0,demandValues[x].dq)
          }
        }
	pp { this.p.play }
	pm { |instrument|
		^lines.collect{|i x|
			[key,valuesArray[x].q,dur:durationArray[x].q].pm(instrument.asSymbol)
		}
			=> Ppar(_)
	}
	pma { |instrument|
		^lines.collect{|i x|
			[key,valuesArray[x].q,dur:durationArray[x].q].pma(instrument.asSymbol)
		}
			=> Ppar(_)
	}
	setPattern { |array|
		var lists = lines.collect{|i x|
			 [key,valuesArray[x].q,dur:durationArray[x].q];
		 };
			^[lists,array]
			.flop
			.collect(_.reshapeLike([[1,2,3,4],[1,2]]))
			.collect({|i|Message(i[0],i[1][0]).value(i[1][1])})
			=> Ppar(_)
	}
	// do this again for multiple keys
//	set {|key values| ^( this.p.bubble ++ values.bubble =>_.flopWith{|p i| Pset(key,i,p) })}

}
