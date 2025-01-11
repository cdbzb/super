(
~fourths = Array.fill(11, {|x| x*5 % 12});
~fifths = Array.fill(11, {|x| x* (-5) => _.abs % 12 });
~sharps = {|x| (1 .. ~fifths.indexOf(x)).collect{|x| ~fourths.wrapAt( 2 - x )} }.(2);
~flats = {|x| (1 .. ~fourths.indexOf(x)).collect{|x| ~fifths.wrapAt( x + 1 )} }
)
