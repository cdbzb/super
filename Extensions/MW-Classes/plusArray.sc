+ Array {

        dq { | repeats=1 |
               ^ Dseq(this,repeats)
        }          
	pick { | indices |
		^this.copySeries( *indices )
	}

	asDegrees { 
		|root=0 octave=5 scale=\major tuning| 
		^this.collect{|i| 
			i.asDegrees(root,octave,scale,tuning)
		}
	}

        alter { |alteration|
          ^this + (alteration / 2)
        }

	degreescps { |root=0 octave=5 scale=\major tuning|
		^this.collect{|i|
			i.degreescps(root,octave,scale,tuning)
		}
	}

	degreesmidi {|root=0 octave=5 scale=\major tuning|
		^this.collect{|i|
			i.degreesmidi(root,octave,scale,tuning)
		}
	}

	flopEvents {
		^this.flop.collect(_.asEvent)
	}

	quantize {
		| percent=1| ^( this*(1-percent) + ( this.mean*(percent) ) )
	}

	quantizeWindow {
		|percent=0.25 windowSize=5|
		(this.size-windowSize).postln;
		this[0..(this.size-windowSize)].do{|i x|
			var chunk = this[x..(x +windowSize)];
			chunk=chunk.quantize(percent);
			chunk.do{|it in| this.put(in+x,it)}
		};
		^this;
	}

	//taken from Song-Part - should replace for modularity
	//TODO error check if array is too long
	parse {|array start=0| 
		var counter = 0;
		var beatNum; 
		array=array.deepCollect(2,{|i| 
			(i>1).if{ 1.dup(i) }{ i }
		});
		array=array.collect{|i| i.isArray.if({i.flatten},{i})};
		beatNum = array.flatten.collect{|m i| array.flatten.[0..i].sum};
		array.postln;
		beatNum = beatNum.collect{|i|(i-0.001).floor};
		^array.collect{ |item|
			item.isArray.not.if(
				{
					var b = beatNum[counter];
					counter =counter+1;
					item*this[b+start]
				},{
					var subArray = item.collect{
						|i x| 
						var b = beatNum[counter+x];
						i*this[b+start]
					}; 
					counter=counter+item.size; 
					subArray.sum;
				}
			);
		}
	} 
	parseBeats { |array start=0|
		var beatCounter = List.new, denominators = List.new;
		var result = List.new;
		array=array++1;
		array.do{
			|i|
			var denominator = i;
			\looptop.postln;
			case 
			{i < (1 - beatCounter.sum)}{
				\less.postln;
				denominators.add(denominator);
				beatCounter.add(i);
				i.postln;\less.post;beatCounter.postln;
			}{i == (1-beatCounter.sum)}{
				\equals.postln;
				denominators.add(denominator);
				beatCounter.add(i);
				( beatCounter.size==1 ).if({result.add(1)},{result.add(beatCounter/denominators)});
				beatCounter=List.new;denominators=List.new;
			}{i > (1 - beatCounter.sum)}{
				\grader.postln;
				i.postln;
				while ( {i > (1 - beatCounter.sum)},{
					i = i-(1-beatCounter.sum);
					((1-beatCounter.sum)>0).if {
						beatCounter.add(1-beatCounter.sum);
						denominators.add(denominator);
					};
					( beatCounter.size==1 ).if(
						{result.add(1/denominators[0])},
						{result.add(beatCounter/denominators)});
						beatCounter=List.new;denominators=List.new;
					} );
					denominators.add(denominator);
					beatCounter.add(i);

				}

			};
			^this.parse(result,start)
}
	addDurs {
//		Song.songs.at(Song.current).addLine(this);
		Song.currentSong.addDurs(this);
	}

	addLine {
//		Song.songs.at(Song.current).addLine(this);
		^Song.currentSong.addLine(this);
	}

        duty {
                ^Duty.kr(this[1],this[2],this[0])
        }
}

+Pseq {
	quantize { |amount|
		var pseq= this.copy;
		var list =pseq.list.asArray.quantize(amount);
		pseq.list_(list);
		^pseq
	}

	quantizeWindow { |amount|
		var pseq= this.copy;
		var list =pseq.list.asArray.quantize(amount);
		pseq.list_(list);
		^pseq
	}
        dropLast{
                this.copy[0..(this.size - 2)]
        }
}

+ List {

	parse {|array start=0| ^this.asArray.parse(array,start) }
        dq { | repeats=1 |
                ^Dseq(this,repeats)
        }          
}
