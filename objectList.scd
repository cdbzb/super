(
~classes = { |quark| 
	Class.allClasses.select({ |i| 
		i.filenameSymbol.asString.contains(quark)
	})
};

~schelpFiles = SCDoc.helpSourceDirs.collect{ |i|
	i.asPathName.deepFiles
}.flat.select{|i| 
	i.extension == "schelp"
};

~getSchelpFile = {|class|
	~schelpFiles.select{ |i| i.fileNameWithoutExtension == class.asString}.flat.unbubble
};

~summary = { |pathname|
		var node;
		pathname.notNil.if {
			node = SCDoc.parseFileFull(pathname.fullPath)  ;
			 SCDocEntry(node,pathname.fullPath).summary
	}{ "missing documentation" }
};
~objectList = {|quarkName| 
	~classes.(quarkName).collect{|x|
		x->~summary.(~getSchelpFile.(x))
	}.asDict
}
)

~objectList.("panola")
