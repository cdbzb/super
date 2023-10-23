+Quark {
	classes {  
		^Class.allClasses.select({ |x| 
			x.filenameSymbol.asString.contains(this.name)
		}).reject{|x| x.asString.contains("Meta_")}
	}

	schelpFiles { 
		^localPath.asPathName.deepFiles.flat.select{|i| 
			i.extension == "schelp"
		}	
	}
	getSchelpFile {|class|
		^schelpFiles.(this.name).select{ |i| i.fileNameWithoutExtension == class.asString}.flat.unbubble
	}

	~objectList = {|quarkName| 
		var summary = { |pathname|
			var node;
			pathname.notNil.if {
				node = SCDoc.parseFileFull(pathname.fullPath)  ;
				SCDocEntry(node,pathname.fullPath).summary
			}{ "missing documentation" }
		};
		this.classes.collect{|x|
			x->summary.(this.getSschelpFile.(x, this.name))
		}.asDict
	}
}

~objectList.("MathLib").at(Quaternion)
