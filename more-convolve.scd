~fftsize=4096;
Library.at(\functions,\prep).(Library.at(\IRs,\Forest,'Forest 1').fullPath,\forest);


(
	b={
		var sig=Saw.ar((LFNoise1.ar(0.6)*1000)+550,0.02);
		sig = PartConv.ar(sig,4096,Library.at(\forest));
		sig=Pan2.ar(sig,0);
	}.play
)

Library.at(\IRs);

(	~pickit= 
	{ | list |
		a=Routine({
			Library.atList(list).keys.do{|item index| 
				list=[\IRs];
				(index.asSymbol ++ '  ' ++ item).postln;
				~menu.add(index -> list.add(item) );

			};
			~menu;
		}).play
	}
)

~pickit.([~menu.at(12)]);

(
	a[0]= Array.newFrom(Library.at(\IRs).keys);
	a[0].do{ |item index |
		(index.asSymbol ++ '  ' ++ item).postln;
	};
	//nil;
)


a[0];
a[0][2];
a[1]=Array.newFrom(Library.at(\IRs,a[0][2]).keys);
a[1];
a[1][3];

Library.at(\IRs,a.at(3)).keys;
a=Array.newFrom(Library.at(\IRs,a.at(3)).keys);
a[7];
~emt1=Library.at(\IRs,)



~menu=();
~menu;
~menu.at(12)
Library.atList(~menu.at(12));

Dictionary
Array

Archive.archiveDir;






