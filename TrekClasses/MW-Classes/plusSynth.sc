+ Synth {
	dur {|time releaseTime=0 clock|
		clock ? clock = TempoClock.default;
		clock.sched(time,{this.release(releaseTime)});
	}
}

+ Synths {
	dur {|time releaseTime=0 clock|
		clock ? clock = TempoClock.default;
		clock.sched(time,{this.release(releaseTime)});
	}
}
