VoiceLeading {
	var lines,durs,<>durationArray, <>valuesArray;
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
		lines=array;
		durs=durss;
		durationArray=this.makeDurationsArray;
		valuesArray=this.makeValuesArray
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
		^lines.collect{|i|i.reject{|x| x == \_ }}
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
		lines=lines.collect(_.df(root,octave,scale))
	}
	dm {|root='c' octave=5 scale='major'|
		key = \midinote;
		valuesArray=valuesArray.collect{|i|i.dm(root,octave,scale)};
		lines=lines.collect(_.dm(root,octave,scale))
	}
	p {
		^lines.collect{|i x|
			[key,valuesArray[x].q,dur:durationArray[x].q].p
		}
			=> Ppar(_)
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

/*
a=VoiceLeading([[1,2,3,4]+3,[1,\_,8,\_]],[0.1,0.2,0.11,2])
a.voice(1);a.voice(0)
[note:a.voice(1).line.q,dur:a.voice(1).durs.q].pp;
[note:a.voice(0).line.q,dur:a.voice(0).durs.q].pp
*/
