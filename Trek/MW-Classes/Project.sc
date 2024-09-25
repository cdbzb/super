Project {
	classvar <dir, <>current, <projectList;
	var <name, <path;
	*initClass {
		dir = this.filenameSymbol.asString.dirname.dirname +/+ "Projects";
		File.exists(dir).not.if{ "mkdir" + dir => _.unixCmd };
		projectList = dir +/+ "*" => _.pathMatch
	}
	*dir_ { |path|
		dir = path;
		File.exists(dir).not.if{ "mkdir" + dir => _.unixCmd };
	}
	*new{ |name|
		^super.newCopyArgs(name).init
	}
	*ls {
		dir.asPathName.entries.collect(_.folderName).do(_.postln)
	}
	*insertNew {|name| 
		Nvim.replaceLineWith( "Project(\\\"%\\\")".format(name ++ "_" ++  Date.getDate.stamp) )
	}
	init{ |name|
		path = dir +/+ name  ;
		File.exists(path).not.if{ "mkdir" + path => _.unixCmd };
		current = this;
	}

}
