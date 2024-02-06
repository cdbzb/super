(
~folderDependencies = ();
~invertedDependencies = ();
~addDependency = {
	|folder, dependsOnFolder, description|
	~folderDependencies[folder] = ~folderDependencies[folder] ?? { () };
	~folderDependencies[folder][dependsOnFolder] = ~folderDependencies[folder][dependsOnFolder] ?? { () };
	~folderDependencies[folder][dependsOnFolder] = ~folderDependencies[folder][dependsOnFolder].add(description);

	~invertedDependencies[dependsOnFolder] = ~invertedDependencies[dependsOnFolder] ?? { () };
	~invertedDependencies[dependsOnFolder][folder] = ~invertedDependencies[dependsOnFolder][folder] ?? { () };
	~invertedDependencies[dependsOnFolder][folder] = ~invertedDependencies[dependsOnFolder][folder].add(description);
};

~process = {
	|cls|
	(cls.methods ++ cls.class.methods).do {
		|method|
		var dependencyFolder, folder;
		var selectors = Array.newFrom(method.selectors.asArray);
		var selector;

		folder = method.filenameSymbol.asString;
		folder = folder.findRegexp(".*SCClassLibrary/(.*)/(.*).sc");
		if (folder.size >= 2) {
			folder = folder[1][1].asSymbol;		

			while { selectors.isEmpty.not } {
				selector = selectors.pop();
				if (selector.isKindOf(FunctionDef)) {
					selectors = selectors.addAll(selector.selectors.asArray)
				};
				if (selector.isKindOf(Symbol) and: { selector.isClassName }) {
					dependencyFolder = selector.asClass !? _.filenameSymbol !? _.asString;
					dependencyFolder = dependencyFolder !? _.findRegexp(".*SCClassLibrary/(.*)/(.*).sc");
					if (dependencyFolder.size > 1) {
						dependencyFolder = dependencyFolder[1][1].asSymbol;
						~addDependency.(folder, dependencyFolder, 
							"%:%".format(cls.name, method.name).asSymbol -> selector
						)
					} {
						"Nil path: %".format(selector).postln;
					}
				}
			};
		} {
			"Weird folder: %".format(method.filenameSymbol).postln;
		};

	};
};

Class.allClasses.do {
	|cls|
	var folder = cls.filenameSymbol;
	if (folder.notNil) {
		folder = folder.asString.findRegexp(".*SCClassLibrary/(.*)/(.*).sc");
		if (folder.size < 2) {
			// skip
		} {
			~process.(cls);
		}
	} {
		"Nil path: %".format(cls).postln
	}
};

~invertedDependencies.inspect;
)
