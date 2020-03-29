s.plotTreeL

StageLimiter.activate;
~av={ "~/tank/super/More-Organized-Trek/Songs/*".standardizePath.pathMatch.do({|i|i.load;/*i.postln.yield*/}) }.fork;
Song.songs.keys.do(_.postln)
Song.play(\complete,\displeased)
"~/tank/super/More-Organized-Trek/Songs/*".standardizePath.pathMatch.size
~av.play
~a
Song.songs.keys.do(_.postln)
~xtreme.play
~sickBay.play
~sickBay.resources.keys.do(_.postln)
~displeased.play
~sickBay.plucks5.play
~sickBay.condition
Song.complete.valueInfrastructure

(
	"~/tank/super/More-Organized-Trek/Songs/Complete-song.scd".standardizePath.load;
	"~/tank/super/More-Organized-Trek/Songs/Sickbay-song.scd".standardizePath.load
	"~/tank/super/More-Organized-Trek/Songs/Transform-song.scd".standardizePath.load;
	"~/tank/super/More-Organized-Trek/Songs/Unneccesary-song.scd".standardizePath.load
	"~/tank/super/More-Organized-Trek/Songs/Displeased-song.scd".standardizePath.load
	"~/tank/super/More-Organized-Trek/Songs/Xtreme-song.scd".standardizePath.load
	"~/tank/super/More-Organized-Trek/Songs/Three-song.scd".standardizePath.load
)


(

	"~/tank/super/More-Organized-Trek/Songs/Complete-song.scd".standardizePath.load;
	"~/tank/super/More-Organized-Trek/Songs/Transform-song.scd".standardizePath.load;
	Song.play(\transform,\complete)
)

Song.complete.at(0)
Song.complete.play(\pad0,\bassnotes)

a={|...args|args.postln}
a.(1)
(
	g=Window.new
	.bounds_(Rect(0,0,500,1000))
)

Song.songs
Song(\transform)
~transform.play
~unnecessary.


a=all{:x,x<-~sickBay.resources.keys,var y=~sickBay.resources.at(x.asSymbol),y.class==Part,y.music.class==Function,::x.postln}
~sickBay.play

~sickBay.condition !? {1.postln}
Song.songs.keys.do(_.postln)
~complete.play
~complete.helloImage.play
w.close
Window
s.plotTreeL
s.plotTreeL
~complete.cursor_(0).play

s.reboot
~syn1.bus.scope
~complete.trombone8.play
~complete.trombone8
~syn1.monitor.isPlaying
~syn1.bus
Synth(\tromboneVerb,addAction:\addToTail)
~sickBay.play
s.plotTreeL
~syn1=~synful.()
~complete.
all {:x,x<-~complete.resources.keys,var y=~complete.resources.at(x.asSymbol),y.class==Part,y.music.class==Function,::x.postln}
~complete.helloImage.play
~complete.bassnotes.play
~complete.pad8.play
~complete.keys6.play
~complete.cursor_(5).play
~complete.pad8.play; s.meter

music.class

~syn1.bus


