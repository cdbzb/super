(
 // also 4096 works on my machine; 1024 too often and amortisation too pushed, 8192 more high load FFT
~fftsize =4096;

~prep = {|in label| // in is fullPath, label is symbol
		    // to use call: PartConv.ar(Library.at(\label)) 
	var irbuffer, bufsize, spectrum;
	spectrum = Buffer.new;
	irbuffer = Buffer.read(s, in, action: { |buffer|
	bufsize = PartConv.calcBufSize(~fftsize, buffer);
	spectrum = Buffer.alloc(s, bufsize, 1);
	Library.put(label, spectrum.bufnum);
	spectrum.preparePartConv(buffer, ~fftsize);
	});
};
)

~upstairs= Library.at(\IRs,\Domestic,'Upstairs 1 floor');
~prep.(~upstairs.fullPath, 'upstairs');
~prep.(Library.at(\IRs,'Vintage Spring Reverb','Spring Stereo').fullPath, 'spring');
~cup=Library.at(\IRs,\Claustrophobia,'Glass Cup stereo');
~prep.(~cup.fullPath,\cup);
~prep.("/Users/michael/tank/IR/Saane/Roland RE-201 Space Echo/Mode•02.wav", \space2);
Buffer.freeAll;

( // awesome space motor
{
    //var input = PlayBuf.ar(1, ~target, loop:1);
    var input = SinOsc.ar(2200+100*SinOsc.ar(0.1),0,0.01);
    var input2 = SinOsc.ar(1500+100*SinOsc.ar(0.211),0,0.01);
    PartConv.ar([input,input2], ~fftsize, Library.at(\upstairs), 0.5)
}.play
)

// convolve with live input
(
{
    var input = SoundIn.ar(0);
    PartConv.ar(input, ~fftsize, ~irspectrum.bufnum)
}.play
)

(//initialize IRs library entry
var irPath;
irPath = PathName.new("/Users/michael/tank/IR/");
irPath.filesDo{|file| 
	if (file.extension == "wav", {
			(file.folderName ++ "  " ++ file.fileNameWithoutExtension).postln;

			Library.put(\IRs,file.folderName.asSymbol , file.fileNameWithoutExtension.asSymbol , file);
	})};
	Buffer.freeAll;
)

Library.clear;
Library.at(\IRs).keys;
~spring=Library.at(\IRs,'Vintage Spring Reverb','Spring Stereo');

Library.at(\IRs,\Domestic).keys;
Library.at(\IRs,'Domestic','Bathroom');
Library.at(\IRs,'Domestic',\Bathroom);
Library.postTree;
Library.put("IRs");
a=Library.at(\IRs,\Forest).keys;

