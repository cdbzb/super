NoteName {
	var degreeNumber;
	*new { ^super.new }
}
A : NoteName {
	*new { ^super.new }
}
B : NoteName {
	*new { ^super.new }
}
C : NoteName {
	*new { ^super.new }
}
D : NoteName {
	*new { ^super.new }
}
E : NoteName {
	*new { ^super.new }
}
F : NoteName {
	*new { ^super.new }
}
G : NoteName {
	*new { ^super.new }
}
NoteWithAccidental {
	var <accidental;
	*new { |notename accidental|
		^super.newCopyArgs( accidental )
	}
}
