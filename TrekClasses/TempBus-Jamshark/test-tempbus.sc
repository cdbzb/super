TempBus : Bus {
	var conditions;
	var cond;

	*new { arg rate = \audio, index = 0, numChannels = 2, server;
		^super.new(rate, index, numChannels, server).tempBusInit;
	}

	tempBusInit {
		conditions = Array.new;
		cond = Condition {
			conditions.every { |condfunc| condfunc.value }
		}
	}

	setStop { |test, action, clock(thisThread.clock)|
		conditions = conditions.add(test);
		^Routine {
			cond.wait;
			action.value;
			this.free;
		}.play(clock)
	}

	stopOnNodeEnd { |node, action|
		var responder = SimpleController(node)
		.put(\n_end, { cond.signal });
		NodeWatcher.register(node);
		^this.setStop({ node.isPlaying.not }, action.addFunc({ responder.remove }));
	}

	signal { cond.signal }

	*makeMapNodeForEvent { |event|
		var synthLib, desc, outdesc;
		var bus;
		synthLib = event[\synthLib] ?? { SynthDescLib.global };
		desc = synthLib.at(event[\instrument]);
		outdesc = desc.outputs.detect { |desc|
			desc.startingChannel == \out
		};
		if(outdesc.isNil) {
			Error("SynthDef '%' for mapping event has no 'out' control".format(event[\instrument])).throw;
		};
		bus = this.perform(outdesc.rate, event[\server], outdesc.numberOfChannels);
		event.put(\out, bus);
		// stop condition depends on parent synth, not this event's synth
		// so just give this object back
		^bus
	}

	*initClass {
		// sadly the default event type is not even close to well-factored
		// so the only way to extend it is to copy it wholesale :-\
		Event.addEventType(\notemap, { |server|
			var freqs, lag, strum, sustain;
			var bndl, addAction, sendGate, ids;
			var msgFunc, instrumentName, offset, strumOffset;
			var playingNodeCount;
			var allMaps;

			freqs = ~detunedFreq.value;

			// msgFunc gets the synth's control values from the Event
			msgFunc = ~getMsgFunc.valueEnvir;
			instrumentName = ~synthDefName.valueEnvir;

			// determine how to send those commands
			// sendGate == false turns off releases

			sendGate = ~sendGate ? ~hasGate;

			// update values in the Event that may be determined by functions

			~freq = freqs;
			~amp = ~amp.value;
			~sustain = sustain = ~sustain.value;
			lag = ~lag;
			offset = ~timingOffset;
			strum = ~strum;
			~server = server;
			~isPlaying = true;
			addAction = Node.actionNumberFor(~addAction);

			// compute the control values and generate OSC commands
			bndl = msgFunc.valueEnvir;
			bndl = [9 /* \s_new */, instrumentName, ids, addAction, ~group] ++ bndl;

			if(strum == 0 and: { (sendGate and: { sustain.isArray })
				or: { offset.isArray } or: { lag.isArray } }) {
				bndl = flopTogether(
					bndl,
					[sustain, lag, offset]
				);
				#sustain, lag, offset = bndl[1].flop;
				bndl = bndl[0];
			} {
				bndl = bndl.flop
			};

			// produce a node id for each synth

			playingNodeCount = bndl.size;
			~id = ids = Array.fill(bndl.size, { server.nextNodeID });
			bndl = bndl.collect { | msg, i |
				msg[2] = ids[i];
				(6, 8 .. msg.size-1).do { |j|
					var map, event;
					if(msg[j].isKindOf(Event)) {
						event = msg[j].copy;
						map = TempBus.makeMapNodeForEvent(event);  // sets 'out'
						allMaps = allMaps.add(event);
						map.setStop(
							test: { playingNodeCount <= 0 },
							action: { event.put(\type, \off).play }
						);
						event.put(\group, ids[i]);
						msg[j] = map.asMap;
					};
				};
				OSCFunc({
					playingNodeCount = playingNodeCount - 1;
					allMaps.do { |mapEvent| mapEvent[\out].signal };
				}, '/n_end', server.addr, argTemplate: [ids[i]]).oneShot;
				msg.asOSCArgArray
			};

			// schedule when the bundles are sent

			if (strum == 0) {
				~schedBundleArray.(lag, offset, server, bndl, ~latency);
				if (sendGate) {
					~schedBundleArray.(
						lag,
						sustain + offset,
						server,
						[15 /* \n_set */, ids, \gate, 0].flop,
						~latency
					);
				}
			} {
				if (strum < 0) {
					bndl = bndl.reverse;
					ids = ids.reverse
				};
				strumOffset = offset + Array.series(bndl.size, 0, strum.abs);
				~schedBundleArray.(
					lag, strumOffset, server, bndl, ~latency
				);
				if (sendGate) {
					if (~strumEndsTogether) {
						strumOffset = sustain + offset
					} {
						strumOffset = sustain + strumOffset
					};
					~schedBundleArray.(
						lag, strumOffset, server,
						[15 /* \n_set */, ids, \gate, 0].flop,
						~latency
					);
				}
			};

			allMaps.do(_.play);
		});
	}
}
