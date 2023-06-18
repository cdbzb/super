Vocaloid {
	classvar <>directory;
	classvar notePrototype;
	var <name, <project, <path, file;
	*initClass {
		directory = this.filenameSymbol.asString.dirname.dirname +/+ "Vocaloid";
	}
	*new {|name| ^super.new.init(name) }
	init{ |n|

		name = n;

		path = directory; //change storage scheme here

		file = directory +/+ name ++ ".json";

		project = String.readNew(File( this.class.filenameSymbol.asString.dirname.dirname +/+ "Vocaloid/Project-/sequence.json","r" ))
		=> JSON.parse(_);

		notePrototype = (
			'singingSkill': (
				'duration': 160,
				'weight': (
					'pre': 64,
					'post': 64 
				) 
			), 'langID': 1,
			'vibrato': (
				'rates': [ ( 'pos': 0, 'value': 50 ) ],
				'type': 0,
				'duration': 320,
				'depths': [ ( 'pos': 0, 'value': 0 ) ] ),
				'phoneme': "bh Q n",

				'aiExp': (
					'formantStart': 0.5,
					'pitchScalingOrigin': 0.5,
					'pitchDriftStart': 0.5,
					'pitchScalingCenter': 0.5, 
					'pitchTransitionStart': 0.5,
					'amplitudeWhole': 0.5,
					'formantWhole': 0.5,
					'pitchDriftEnd': 0.5,
					'formantEnd': 0.5, 
					'amplitudeEnd': 0.5,
					'pitchFine': 0.5,
					'amplitudeStart': 0.5,
					'pitchTransitionEnd': 0.5 
				), 'lyric': "bon",
				'pos': 0,
				'number': 53,
				'phonemePositions': [ ( 'pos': -107 ), ( 'pos': -1 ), ( 'pos': 328 ), ( 'pos': 428 ) ], 
				'velocity': 64,
				'isProtected': false, 
				'exp': (
					'bendDepth': 0,
					'bendLength': 0,
					'opening': 127,
					'decay': 50, 
					'accent': 50 )
					, 'duration': 480 
)
		

	}
	writeProject {
		JSON.stringify( project ).write(
			file, overwrite: true, ask: false
		);
	}
	open {
		"open -a 'VOCALOID6 Editor.app'" + file => _.unixCmd 
	}
	notes { | track=0 part=0 |
		^project.tracks[track].parts[part].notes
	}
	set { |event|
		event.legato = event.legato ? 1;
		event.pos = [0] ++ event.dur.integrate => _.dropLast();
		event.duration = event.dur * event.legato * 480 => _.floor => _.asInteger;
		event.pos = event.pos * 480 => _.floor => _.asInteger;
		event.keys.do{|key|
			this.setNotes(key,event.at(key))
		}
	}
	setNote {| index key value|
		
		this.notes[index].put(key,value);
	}
	setNotes { |key array|
		array.do{|i x|
			this.setNote(x, key, i)
		}
	}
	makeNotes {|num|
		project.tracks[0].parts[0].notes = notePrototype ! num
	}
}
