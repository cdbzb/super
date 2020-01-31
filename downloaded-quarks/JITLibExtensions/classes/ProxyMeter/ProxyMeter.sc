
ProxyMeter {
	classvar <>ppvClass;
	classvar <all;
	classvar <skipjack, <sourceFunc;
	classvar <>prefix = "pm_";
	classvar <showingKrs = false;

	classvar <proxyGuis, <prePostViews;

	var <ampName, <ampProxy, <arProxy, <space;
	var <ampVals = #[0,0], <views, <resp;

	*initClass {

		// could also be PrePostViewOld in 3.5.x and earlier
		ppvClass = PrePostView;

		all = ();

		sourceFunc = { |arProxy|
			{ |decay = 0.99994|
				var inArray = InFeedback.ar(arProxy.bus.index, arProxy.bus.numChannels).asArray;
				var amps = A2K.kr(PeakFollower.ar(inArray, decay: decay));

				var max = 0;
				amps.do { |amp| max = max(max, amp)	};
				max;
			}
		};

		proxyGuis = List[];
		prePostViews = ();

		CmdPeriod.add(this);
	}

	*cmdPeriod { fork { 0.5.wait; all.do { |meter| meter.ampProxy.wakeUp } } }

	*addNdefGui { |gui| this.addMonitorGui(gui.monitorGui); }
	*removeNdefGui { |gui| this.removeMonitorGui(gui.monitorGui); }

	*addMixer { |mixer|
		mixer.arGuis.do (this.addNdefGui(_));
		this.addNdefGui(mixer.editGui);
	}
	*removeMixer { |mixer|
		mixer.arGuis.do (this.removeNdefGui(_));
		this.removeNdefGui(mixer.editGui);
		mixer.parent.refresh;
	}

	*addMonitorGui { |gui|
		if (proxyGuis.includes(gui).not) {
			proxyGuis.add(gui);
			prePostViews.put(gui, ppvClass.forMonitor(gui));
		};
		this.checkSkip;
	}

	*removeMonitorGui { |gui|
		var ppv = prePostViews.removeAt(gui).remove;
		all.do { |meter|
			meter.views.remove(ppv);
			if (meter.views.isEmpty) {
				meter.remove
			};
		};
		proxyGuis.remove(gui);
	}

	*checkSkip { if (skipjack.isNil) { this.makeSkipJack } }

	*makeSkipJack {
		skipjack.stop;
		skipjack = SkipJack({
			this.checkGuiObjects;
			this.checkChangedGuis;
			this.checkAll;
			all.do(_.sendPoll);
		}, 0.03, false, 'ProxyMeter');
	}

	*checkGuiObjects {
		var closedGuis = proxyGuis.select { |gui| gui.parent.isClosed };

		closedGuis.do { |gui| this.removeMonitorGui(gui) };

		// add new Meters for new proxies;
		proxyGuis.do { |gui|
			var proxy = gui.object;
			var ppv = prePostViews[gui];
			if (proxy.notNil and: { proxy.bus.notNil }) {
				if (proxy.rate != \audio) {
					// check and sync orphaned ppvs
					ppv.setAmps(0,0);
				} {
					this.checkAdd(proxy);
					this.checkAddPrePost(proxy, prePostViews[gui]);
				}
			}
		};
	}

	*checkChangedGuis {
		all.do { |meter|
			meter.views.do { |ppv|
				var gui = ProxyMeter.prePostViews.findKeyForValue(ppv);
				if (gui.notNil and: { gui.object != meter.arProxy }) {
					meter.views.remove(ppv);
				}
			}
		}
	}

	*checkAll {
		var currProxies = proxyGuis.collect(_.object)
		.select { |px| px.isNil or: {px.rate != \audio } };
		var toRemove = all.select { |meter|
			meter.views.isEmpty or:
			{ currProxies.includes(meter.arProxy).not }
		};
		toRemove.do { |meter, name| meter.clear; };
	}

	*checkAddPrePost { |proxy, ppv|
		var mymeter = all.detect { |meter| meter.arProxy === proxy };
		if (mymeter.notNil) { mymeter.views.add(ppv); };
		all.do { |meter| if (meter != mymeter) { meter.views.remove(ppv) } };
	}

	*checkAdd { |proxy|
		if (proxy.bus.isNil) { ^this };
		if (all.isEmpty or: { (all.detect { |meter| (meter.arProxy == proxy) }).isNil }) {
			this.new(proxy);
		};
	}

	*clear {
		skipjack.stop;
		all.do(_.remove);
		all.clear;
	}

	*new { |proxy, view|
		if (proxy.isKindOf(NodeProxy).not) {
			^nil;
		} {
			this.checkSkip;
			^super.new.init(proxy);
		};
	}

	init { |proxy, view|
		arProxy = proxy;
		views = IdentitySet[];
		this.makeAmpProxy;
		this.makeResp;
	}

	remove {
		ampProxy.end;
		Ndef.all[ampProxy.server.name].removeAt(ampName);
		// views.do(_.remove);
		all.removeAt(ampName);
	}

	makeAmpProxy {

		ampName = (prefix ++ (arProxy.key ?? { UniqueID.next })).asSymbol;

		ampProxy = Ndef(ampName -> arProxy.server.name, sourceFunc.value(arProxy));

	//	"ProxyMeter: added proxy % at key %.\n".postf(ampProxy, ampName);

		space = ProxySpace.findSpace(arProxy);
			// if desired, add to the arproxy's proxyspace
		if (showingKrs) { this.showKr };

		all.put(ampName, this);
	}

	showKr { space.envir.put(ampName, ampProxy) }
	hideKr { space.envir.removeAt(ampName) }

	sendPoll { ampProxy.server.listSendMsg(ampProxy.bus.getnMsg(1)); }

	makeResp {

		resp.remove;
		resp =  OSCFunc({ |msg|
			var vols = msg.copyToEnd(3);
			var preVol = vols[0];
			var postVol = if (arProxy.monitor.isPlaying, arProxy.vol, 0) * preVol;
			defer {
				views.do { |ppv| ppv.setAmps(preVol, postVol) };
			}
		}, '/c_setn', ampProxy.server.addr, nil, [ampProxy.bus.index])
		.permanent_(true);

	}

	*showKrs { showingKrs = true; 	all.do(_.showKr); }
	*hideKrs { showingKrs = false;	all.do(_.hideKr); }

}
