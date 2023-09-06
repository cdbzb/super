+Quark {
	classes {  
		^Class.allClasses.select({ |x| 
			x.filenameSymbol.asString.contains(this.name)
		}).reject{|x| x.asString.contains("Meta_")}
	}

	scFiles {
		"find" + Quark("panola").localPath.escapeChar(Char.space) + "-iname '*.sc'" => _.unixCmd
	}

	classesSystemCmd{
		// ^"find" + localPath.escapeChar(Char.space) + "-iname \"*.sc\" -exec grep -E [:space:]?[[:upper:]][[:lower:]]*\\ { {} \\; | sed 's/[[:space:]]*\\(.*\\){/\\1/' "//.systemCmd
		^"find" + localPath.escapeChar(Char.space) + "-iname \"*.sc\" -exec grep -E ^[[:space:]]?\\b[[:upper:]][[:lower:]]*\\ { {} \\; | sed 's/[[:space:]]*\\(.*\\){/\\1/' "//.systemCmd
	}
/* find /Users/michael/Library/Application\ Support/SuperCollider/downloaded-quarks/panola -iname "*.sc" -exec grep -E ^[[:space:]]?\\b[[:upper:]][A-Za-z]*\ \(:[[:space:]]*[A-Za-z]*[[:space:]]\)\?{ {} \; | sed 's/[[:space:]]*\(.*\){/\1/' | cut -d" " -f1 */

	schelpFiles { 
		^localPath.asPathName.deepFiles.flat.select{|i| 
			i.extension == "schelp"
		}	
	}
	getSchelpFile {|class|
		^this.schelpFiles.select{ |i| i.fileNameWithoutExtension == class.asString}.flat.unbubble
	}

	objectList {
		var summary = { |pathname|
			var node;
			pathname.notNil.if {
				node = SCDoc.parseFileFull(pathname.fullPath)  ;
				SCDocEntry(node,pathname.fullPath).summary
			}{ "missing documentation" }
		};
		^this.classes.collect{|x|
			x->summary.(this.getSchelpFile(x))
		}.asDict
	}
}

