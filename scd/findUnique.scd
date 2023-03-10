a=Song.lyrics.collect( { |i| i.split($ ).collect(_.asSymbol)} )
~q={|array index| array.keep(index)++array.copyToEnd(index + 1)}
~q.((0..8),4)
~findUnique={|array index| array[index].difference(~q.(array,index).flat)}
~findUnique.(a,7)
a.collect({|i x| ~findUnique.(a,x)}).do(_.postln)
