SynthDefLibrary {

    classvar <>listings,<>taglist,<>currentPack,<>files;

    *initClass {
        listings=List.new;
        taglist = ();
        ServerBoot.add({
            var dir = this.filenameSymbol.asString.dirname.dirname +/+ "SynthDefLibrary";
            var scdFiles = (dir +/+ "*.scd").pathMatch;
            var cacheDir = dir +/+ "cached";
            File.mkdir(cacheDir);
            this.loadWithCache(scdFiles, cacheDir)
        }, Server.default);
        StartUp.add({
            var dir = this.filenameSymbol.asString.dirname.dirname +/+ "SynthDefLibrary";
            var scdFiles = (dir +/+ "*.scd").pathMatch;
            var cacheDir = dir +/+ "cached";
            File.mkdir(cacheDir);
            Server.default.serverRunning.if {
                this.loadWithCache(scdFiles, cacheDir)
            }
        })
    }

    *loadWithCache { |scdFiles, cacheDir|
        var taglistPath = cacheDir +/+ "taglist.archive";
        var listingsPath = cacheDir +/+ "listings.archive";
        var defsDir = cacheDir +/+ "defs";
        var dirty = false;

        File.mkdir(defsDir);

        // check if any .scd is newer than its cached marker
        scdFiles.do{|file|
            var marker = cacheDir +/+ PathName(file).fileNameWithoutExtension ++ ".cached";
            File.exists(marker).not.if { dirty = true };
            File.exists(marker).if {
                (File.mtime(file) > File.mtime(marker)).if { dirty = true }
            };
        };
        File.exists(taglistPath).not.if { dirty = true };

        dirty.if {
            var before = SynthDescLib.global.synthDescs.keys.copy;
            "SynthDefLibrary: compiling SynthDefs...".postln;
            scdFiles.do{|file|
                var marker;
                try{ file.load };
                marker = cacheDir +/+ PathName(file).fileNameWithoutExtension ++ ".cached";
                File.use(marker, "w", {|f| f.write(Date.getDate.asString)});
            };
            // write only newly added SynthDefs to defs subdir
            SynthDescLib.global.synthDescs.keysValuesDo{|name, desc|
                before.includes(name).not.if {
                    desc.def !? {|def| def.writeDefFile(defsDir) }
                }
            };
            taglist.writeArchive(taglistPath);
            listings.writeArchive(listingsPath);
            "SynthDefLibrary: cached % files, % defs".format(
                scdFiles.size,
                (defsDir +/+ "*.scsyndef").pathMatch.size
            ).postln;
        } {
            "SynthDefLibrary: loading from cache...".postln;
            SynthDescLib.global.read(defsDir +/+ "*.scsyndef");
            Server.default.loadDirectory(defsDir);
            taglist = Object.readArchive(taglistPath) ? ();
            listings = Object.readArchive(listingsPath) ? List.new;
            "SynthDefLibrary: loaded % cached defs".format(
                (defsDir +/+ "*.scsyndef").pathMatch.size
            ).postln;
        }
    }

    *clearCache {
        var dir = this.filenameSymbol.asString.dirname.dirname +/+ "SynthDefLibrary" +/+ "cached";
        ("rm -rf" + dir.shellQuote).unixCmd;
        "SynthDefLibrary: cache cleared. Will recompile on next boot.".postln;
    }

    *add { |def tags|
        listings.add( ( name:def.name,tags:tags ) );
        currentPack.notNil.if{tags = tags.addAll(currentPack)};
        tags.do{
            |i|
            i.postln;
            taglist.at(i).isNil.if {
                taglist.add(i -> Set.new(128))
            };
			taglist.at(i).add(def.name);
            (currentPack == \end ).if{ currentPack=(nil) }
        }
    }

    *tree {
        taglist.keysDo{|e|
            e.postln;
            taglist.at(e).asArray.do({
					|i|
					'  '.post; i.postln
			});
        }
    }
}

+ SynthDef {
    tag { |...args|
        SynthDefLibrary.add(this,args)
    }
    startPack {
        |...pack|
        SynthDefLibrary.currentPack_(pack);
        this.tag(pack)
    }
    endPack {
        SynthDefLibrary.currentPack_(\end)
    }
}

+ Symbol {
    showSynthDefSource {
        //("pbcopy " ++ this.asString).unixCmd
        ("pbcopy " ++ this.asString).postln
    }
}


/*
SynthDef(\test,{ SinOsc.ar(400,0.1)=>Out.ar(0,_) }).add..tag(\bad,\kkk)startPack(\sines);
SynthDef(\tost,{ SinOsc.ar(100,0.1)=>Out.ar(0,_) }).add.tag(\bad,\kkk).endPack;
SynthDef(\tust,{ SinOsc.ar(200,0.1)=>Out.ar(0,_) }).add.tag(\bad,\kkk)
SynthDefLibrary.listings
SynthDefLibrary.taglist.sines
SynthDefLibrary.taglist.bad
a=List[]
a.addAll(3)
*/
