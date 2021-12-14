SynthDefLibrary {

    classvar <>listings,<>taglist,<>currentPack,<>files;

    *initClass {
        Class.initClassTree(Phaser2);
        listings=List.new;
        taglist = ();
        //Server.default.waitForBoot
        StartUp.add( {
            var files=files++"/Users/michael/tank/super/SynthDefLibrary/*".pathMatch;
            files.do{|file| file.load}
        } )
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
            //taglist.e.do{|i| '  '.post; i.asArray[0].postln}
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
