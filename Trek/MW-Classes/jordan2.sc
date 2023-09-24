PFF {
	*new {|a| ^PFF.getFunc(a) }
	*getFunc {|a|
		^a.isKindOf(Symbol).if(
			{ {|...b| a.applyTo(*b)} },
			{ a }
		)
	}
	*expand { |f|
		^{|x| PFF(f).(*x) }
	}
	*id { ^{|n| n} }
	*concat {
		^{ |...x| x.reject(_.isNil) }
	}
	*concatKeepNil {
		^{ |...x| x.reject(_.isNil) }
	}
	*tap {|f|
		^{|x| PFF(f).(x); x }
	}
	*par {|redux ...fs|
		if(fs.size < 1, {Error("PFF.fork must have 1 or more functions").throw});

		^{|x|
			PFF.concatKeepNil.(x, *fs.collect({|f| PFF(f).(x) }))
			.reduce(PFF(redux))
		}
	}
	*fork {|redux ...fs|
		if(fs.size < 3, {Error("PFF.fork must have 3 or more functions").throw});

		^{|x|
			fs.collect({|f| PFF(f).(x) })
			.reduce(PFF(redux))
		}
	}
	*split {|...fs|
		^{|xs|
			if(fs.size != xs.size, {Error("Size mismatch in split").throw});
			xs.collect{|x, i| PFF(fs[i]).(x) }
		}
	}
}

+Object {
	|> { |f, adverb|
		^case
		{adverb.isNil} {PFF(f).(this)}
		{adverb == \fork}{
			PFF.fork(*f).(this)
		}
		{adverb == \par}{
			PFF.par(*f).(this)
		}
		{adverb == \tap} {
			PFF.tap(f).(this)
		}

		{adverb == \split}{
			PFF.split(*f).(this)
		}
		{ Error("does not understand adverb " + adverb).throw }
	}
}

+Symbol {
	|> {|f, adverb| ^PFF(this).perform('|>', f, adverb) } // deffers to Function's impl
}

+Function {
	|> { |f, adverb|
		^case
		{adverb.isNil} {
			{ |...a| PFF(f).(this.(*a)) }
		}
		{adverb == \fork}{
			if(f.size < 3, {Error("|>.fork must have an array of 3 or more functions").throw});
			{ |...a|
				PFF.fork(*f).( this.(*a) )
			}
		}
		{adverb == \par}{
			if(f.size < 2, {Error("|>.split must have an array of 2 or more functions").throw});
			{ |...a|
				PFF.par(*f).( this.(*a) )
			}
		}
		{adverb == \tap} {
			{ |...a|
				PFF.tap(f).( this.(*a) )
			}
		}
		{adverb == \split}{
			{|...a|
				PFF.split(*f).( this.(*a) )
			}
		}

		{ Error("does not understand adverb " + adverb).throw }

	}
}
