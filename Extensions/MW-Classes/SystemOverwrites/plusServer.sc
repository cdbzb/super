+ Server { 
	plotTreeL {|interval=0.5 x=(-800) y=400 dx=400 dy=800|
		var onClose, window = Window.new(name.asString + "Node Tree",
			Rect(x,y,dx,dy),
			scroll:true
		).front;
		window.view.hasHorizontalScroller_(false).background_(Color.grey(0.9));
		onClose = this.plotTreeView(interval, window.view, { defer {window.close}; });
		window.onClose = {
			onClose.value;
		};
		{Pipe.new("osascript -e \'activate application \"Kitty.app\"\'", "w").close}.defer(0.1)
	}

	meter { |numIns, numOuts|
		^if( GUI.id == \swing and: { \JSCPeakMeter.asClass.notNil }, {
			\JSCPeakMeter.asClass.meterServer( this );
		}, {
			ServerMeter(this, numIns, numOuts);
			{Pipe.new("osascript -e \'activate application \"VimR\"\'", "w").close}.defer(0.1)
		});
	}

}
