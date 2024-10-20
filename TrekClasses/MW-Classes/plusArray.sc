+ Array {

	pick { | indices |
		^this.copySeries( *indices )
	}

	asDegrees { 
		|root=0 octave=5 scale=\major tuning| 
		^this.collect{|i| 
			i.asDegrees(root,octave,scale,tuning)
		}
	}

	degreescps { |root=0 octave=5 scale=\major tuning transpose|

		octave.isKindOf(Symbol).if{scale=octave;octave=5};
		^this.collect{|i|
			i.degreescps(root,octave,scale,tuning,transpose)
		}
	}

	degreesmidi {|root=0 octave=5 scale=\major tuning transpose|

		octave.isKindOf(Symbol).if{scale=octave;octave=5};
		^this.collect{|i|
			i.degreesmidi(root,octave,scale,tuning,transpose)
		}
	}

	flopEvents {
		^this.flop.collect(_.asEvent)
	}

	quantize {
		| percent=1| 
		var out = this.collect( _.value );
		^( out*(1-percent) + ( out.mean*(percent) ) )
	}

	quantizeWindow {
		|percent=0.25 windowSize=5|
		(this.size-windowSize).postln;
		this[0..(this.size-windowSize-1)].do{|i x|
			var chunk = this[x..(x +windowSize)];
			chunk=chunk.quantize(percent);
			chunk.do{|it in| this.put(in+x,it)}
		};
		^this;
	}

	asBeats { | map |
		var tempomap=TempoMap();

		map.isSymbol.if{

			tempomap = ( Song.tempoMap[map] ? TempoMap.fromDurs(Song.durs[map]) );
		};
		map.isNumber.if{

			tempomap = ( Song.tempoMap[map] ? TempoMap.fromDurs(Song.durs[map]) );
		};
		(map.class==Part).if{
			tempomap = map.tempoMap;
		};
		( map.class == TempoMap ).if{
			tempomap = map
		};
		^tempomap.dursToBeats(this)

	}

	pr_getQuarters { |quarters|
		( quarters.class==Pseq ).if{ quarters = quarters.list };
		( quarters.class==Symbol).if{ quarters = Song.quarters[quarters] };
		^quarters
	}

	warpToTempoMap { | tempoMap |
		^tempoMap.mapBeats(this)
	}
	warpToArray{ |quarters|
		quarters = quarters ++ quarters.last;

		^this.integrate.collect{|i|quarters.atInterpolated(i)}.differentiate
		.select(_.isStrictlyPositive)
	}

	warpTo {
		| quarters |
		quarters.isNil.if{^this};
		quarters = this.pr_getQuarters(quarters);
		( quarters.class==TempoMap ).if{
			^this.warpToTempoMap(quarters)
		}{
			^this.warpToArray(quarters)
		}
	}


	warpRecordedTo { | tempoMap | ///deprecate this method
		^tempoMap.mapRecordedDurs(this)
	}

	pushOne { | index amount |
		var offset = this[index-1] * (amount -1);
		this.put(index-1, this[index-1] + offset);
		this.put(index, this[index] - offset)
	}
	pushMany { |array|
		array = array.collect({|i| ( i==0 ).if{1}{i}});
		array.do{ |i x|
			( i!=1 ).if {this.pushOne( x, i )}
		}

	}
	push { | i a |
		i.isKindOf(SequenceableCollection).if{ ^this.pushMany(i) }{^this.pushOne(i,a)}
	}

	remap { |from to|
		^TempoMap(from, this).mapBeats(to)
	}

	dupFlat {|n|
		^this.dup(n).flatten
	}
	warpToPickup { //deprecated
		| quarters pickup |
		var array = this.put(0,this[0] * pickup.reciprocal);
		quarters = this.pr_getQuarters(quarters);
		^ array.warpTo(quarters)
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
					var b = beatNum.clipAt( counter );
					counter =counter+1;
					item*this.clipAt( b+start )
				},{
					var subArray = item.collect{
						|i x| 
						var b = beatNum.clipAt( counter+x );
						i*this.clipAt( b+start )
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

		scaleEnv { | env | 
			var startTimes = [0] ++ this => _.integrate;
			env.duration_(this.sum +10);
			^env[startTimes.tail] + env[startTimes.dropLast] / 2 * this
		}
		addLine {
			//		Song.songs.at(Song.current).addLine(this);
			^Song.currentSong.addLine(this);
		}

		duty { |...args|
			^Duty.kr( args[0],  args[1] ? 1 , this.dq)
		}

		octaveUp {
			^ this.collect{ |i| 
				case { i < -10 }{ i + 10 }
				{ i < 0 }{ -1 * i }
				{ i > 0 }{ i + 10 }
			}
		}
		octaveDown {
			^ this.collect{ |i| 
				case { i > 10 }{ i - 10 }
				{ i > 0 }{ -1 * i }
				{ i < 0 }{ i - 10 }
			}
		}
		shiftOctaves {|i|
			var result = this;
			i.abs.do{
				i.isPositive.if{
					result = result.octaveUp;
				}{
					result = result.octaveDown;
				}
			};
			^result
		}
		zip {|that|
			^this.bubble ++ that.bubble => _.flop
		}
		injectEach { |initialValue function|
			^this.collect({|i| i.inject(initialValue, function)})
		}
		scale {|string|
		/* 		[1,1,1].scale("3:4") */
			var ratio = SequenceOf(
				List[
					ParserFactory.makeIntegerParser,
					StrParser(":"),
					ParserFactory.makeIntegerParser,
				]
			).run(string).result ;
			^ this * ratio[2] / ratio[0]

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

}

+SequenceableCollection {

	atInterpolated {|index| 
		( index >= this.size).if{^0} {
			^([0] ++ this).integrate.at( index.floor ) + 
			(index.frac * this[index.floor]) 
		}
	}
}
