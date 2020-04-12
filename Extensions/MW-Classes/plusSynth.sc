+ Synth {
	dur {|time clock|
		clock ? clock = TempoClock.default;
		clock.sched(time,{this.release()});
	}
}

+ Synths {
	dur {|time clock|
		clock ? clock = TempoClock.default;
		clock.sched(time,{this.release()});
	}
}
