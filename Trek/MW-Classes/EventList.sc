EventList {
	classvar <all, <>current, <>playFn, <>cursor;
	// §9b: the most recent list-play epoch, snapshotted by MIDIItem.record into the
	// take so source-preferred addItem aligns to the playthrough the overdub actually
	// heard — not this list's lastPlayEpoch, which any later replay would clobber.
	classvar <currentPlayEpoch;
	var <events, <preview, <>defaultType, <routes, <>addFunc, <>previewPrep;
	var <>env, <>context;
	var <>autoExpand = false;
	var <>batchWindow = 0.05, batchEndTime = -1e9, batchFirstWhen = 0;
	var <name, <>voiceSpace;
	var <solo, <mute;
	// tempoMap is getter-only here: the setter (tempoMap_) coerces V2 MonoMaps and
	// drops the beat->wall cache, so it must not be auto-generated.
	var <>beatDur, <tempoMap;
	// §10 prepare/fire: leadTime = prepare budget; first sound lands at exactly
	// leadTime + latency after play (deterministic — see prPlayPrepared; nil =
	// adaptive ASAP start). prPlayGen = generation counter letting stop/replay
	// cancel already-scheduled sends.
	var <>leadTime, <lastPlayEpoch;
	var prPlayGen = 0;
	// Memoized beat->wall integral (see beatToWall): cumulative wall-seconds at each
	// tempoEnv segment boundary, built once per tempoEnv so completed segments aren't
	// re-integrated for every event. Keyed on tempoEnv identity.
	var prWallEnv, prWallStarts, prWallCum, prWallLevels, prWallTimes, prWallCurves;
	// Base-wall integral (prBaseWallAt) at each prWallStarts boundary, cached so a warm
	// beatToWall pays ONE tempoMap.timeAt (the partial's endpoint), not two.
	var prWallBase;
	// Per-segment cumulative sub-grids for ramp segments over a tempoMap base
	// (nil for step/flat-base segments) — see prBuildRampSub.
	var prWallSubs;

	*initClass {
		all = ();
		Class.initClassTree(Event);
        Event.addEventType(\eventList, {
            ~eventList.isKindOf(EventList).if{
                ~eventList
            }{
                EventList(~eventList)
            }.play(~start ? 0, to: ~end)});
	}

	*new { |name, defaultType|
		var instance;
		name.notNil.if {
			all[name].notNil.if {
				current = all[name];
				defaultType !? { current.defaultType_(defaultType) };
				^current
			}
		};
		instance = super.new.init(defaultType, name);
		name !? {
			all[name] = instance;
			current = instance;
		};
		^instance
	}

	*at { |name| ^all[name] }

	*kf { |name, voiceSpace|
		^this.new(name, \keyFrame).voiceSpace_(voiceSpace ? VoiceSpace.default)
	}

	*newFrom { |other, name, newVoiceSpace=false|
		var src = other.isKindOf(Symbol).if { all[other] } { other };
		var instance;
		src.isNil.if { Error("EventList.newFrom: no list named %".format(other)).throw };
		instance = this.new(name, src.defaultType);
		^instance.copyFrom(src, newVoiceSpace)
	}

	copy { |newVoiceSpace=false|
		var instance = this.class.new(nil, defaultType);
		^instance.copyFrom(this, newVoiceSpace)
	}

	copyFrom { |other, newVoiceSpace=false|
		events      = other.events.copy;
		context     = other.context.copy;
		routes      = other.routes.copy;
		env         = other.env.copy;
		addFunc     = other.addFunc;
		previewPrep = other.previewPrep;
		autoExpand  = other.autoExpand;
		batchWindow = other.batchWindow;
		// tempo + mix state travel with the copy — without these a copied (or nested)
		// list plays flat at 1 s/beat and forgets its solo/mute scoping (§5).
		beatDur     = other.beatDur;
		tempoMap    = other.tempoMap;
		solo        = other.solo.copy;
		mute        = other.mute.copy;
		voiceSpace  = newVoiceSpace.if { VoiceSpace.new } { other.voiceSpace };
		^this
	}

	// class-level forwarding for common methods
	*add { |...args, kwargs|
		var when = args[0];
		args[1].isKindOf(Pattern).if { ^current.addPattern(when ? 0, args[1]) };
		when.isKindOf(Array).if {
			var whens = when;
			var n = whens.size;
			var base = (when: whens) ++ kwargs.asEvent;
			var previewOffsets = current.nextPreviewOffset(whens);
			^n.collect { |i|
				var ev = current.getSlice(base, i, n);
				current.dispatch(ev, { |e| current.storeAndPreview(e, previewOffsets[i]) });
				ev
			}
		};
		when.isKindOf(Event).if { ^current.add(when) };
		^current.add((when: when ? 0) ++ kwargs.asEvent)
	}
	*addContext { |...args, kwargs|
		var event;
		args[0].isKindOf(Event).if {
			event = args[0]
		} {
			event = (when: args[0] ? 0) ++ kwargs.asEvent
		};
		^current.addContext(event)
	}
	*play { |from, fromEvent, fromSection|
		^current.play(cursor.debug("CURSOR") ? from ? 0 => _.postln, fromEvent, fromSection)
	}
	*clear { ^current.clear }
	*clearContext { ^current.clearContext }
	*setupContext { ^current.setupContext }
	*size { ^current.size }
	*do { |func| ^current.do(func) }
	*addRoute { |key, type| ^current.addRoute(key, type) }
	*preview_ { |val| ^current.preview_(val) }
	*preview { ^current.preview }
	*addFunc_ { |val| ^current.addFunc_(val) }
	*env { ^current.env }
	*context { ^current.context }
	*context_ { |list| ^current.context_(list) }
	*previewPrep { ^current.previewPrep }
	*previewPrep_ { |val| ^current.previewPrep_(val) }
	*voices { ^current.voices }
	*resolvedEvents { ^current.resolvedEvents }

	/*
	 aName is the registry key under `all`, and the prefix voiceKey namespaces
	 this list's voices with. Set here rather than by the caller so it stays
	 getter-only: writing it later would desync the instance from its `all` key.
	*/
	init { |defType, aName|
		events = List[];
		context = List[];
		defaultType = defType;
		name = aName;
		routes = ();
		env = ();
	}

	addRoute { |key, type|
		routes[key] = type;
	}

	voiceKey { |v|
		(name.notNil and: { v.notNil }).if {
			^(name.asString ++ "_" ++ v.asString).asSymbol
		};
		^v
	}

	/*
	 Read-time view of a stored event: the voice namespaced, the voiceSpace
	 attached. Copy only if something is actually rewritten — the stored event
	 in `events` is never mutated.
	*/
	resolveEvent { |ev|
		var res = (name.notNil or: { voiceSpace.notNil }).if { ev.copy } { ev };
		name.notNil.if { res.put(\voice, this.voiceKey(ev[\voice] ? \default)) };
		voiceSpace.notNil.if { res.proto = (voiceSpace: voiceSpace) };
		^res
	}

	resolvedEvents { ^events.collect { |e| this.resolveEvent(e) } }

	voices {
		var seen = Set[];
		events.do { |e|
			e[\voice] !? { |v| seen.add(this.voiceKey(v)) }
		};
		^seen.asArray
	}

	// Copy events of `voice` whose `when` is in [from, to) (nil bound = open),
	// shift each by `offset` beats, and re-insert. `newVoice` retargets the copies;
	// `dropTempoTrack` strips \tempoTrack so the copy doesn't duplicate tempo anchors.
	// `offset` is a pure delta — to land a slice at beat X, use offset = X - from.
	copyVoice { |voice, offset = 0, from, to, newVoice, dropTempoTrack = true|
		var copies = events
			.select { |e|
				var w = e[\when] ? 0;
				((e[\voice] ? \default) == voice)
					and: { from.isNil or: { w >= from } }
					and: { to.isNil   or: { w <  to  } }
			}
			.collect { |e|
				var c = e.copy;
				c[\when] = (c[\when] ? 0) + offset;
				newVoice       !? { c[\voice] = newVoice };
				dropTempoTrack.if { c.removeAt(\tempoTrack) };
				c
			};
		events.addAll(copies);
		^copies
	}

	// §9a step 3 / §9b: shared insertion primitive. Copies a player's events into
	// THIS list, `whenFn.(e)` supplying each event's `when:` in list beats. Tags
	// mirror asEventList (ParamSpace.sc): source name for solo/mute isolation,
	// server latency, optional voice/mk. Returns the added copies.
	prInsertItemEvents { |player, whenFn, voice, mk|
		var srcName = player.source.tryPerform(\name) !? { |n| n.asString.asSymbol };
		var added = player.midiEvents.collect { |e|
			var c = e.copy.put(\when, whenFn.(e));
			srcName !? { c[\name] = c[\name] ? srcName };
			c.put(\latency, Server.default.latency);
			voice !? { c[\voice] = voice };
			mk !? { c.put(\mk, mk) };
			c
		};
		events.addAll(added);
		^added
	}

	// default \mk for inserted events: the take's recordedMk, reduced to a light
	// reference (name Symbol) — never a live object. MIDIItem.player doesn't stamp
	// recordedMk onto the player, so fall back to the source item (mirrors
	// MIDIItemPlayer.play's `recordedMk ? source.recordedMk`).
	prItemMk { |player|
		var r = player.tryPerform(\recordedMk)
			?? { player.tryPerform(\source).tryPerform(\recordedMk) };
		^r !? {
			case
			{ r.isKindOf(Event) } { r[\name] }
			{ r.isKindOf(MicroKeys) } { r.name ? r }
			{ r.isKindOf(Symbol) } { r }
		}
	}

	/*
	 §9a step 3 + §9b: insert a MIDI item/player/selection into this list.

	 at: <beat> — item START lands there. Positions within it come from the
	 selection tempomap when one exists; WITHOUT one, timestamps are read as flat
	 seconds-as-beats from player.start, which misplaces the interior on any list
	 whose tempoMap is not 1 s/beat.

	 at: nil — SOURCE PREFERRED POSITION (REAPER's term): each event lands at the
	 beat it was PERFORMED at. MIDIItem.record snapshots the play epoch
	 (EventList.currentPlayEpoch) into the take, so a LATER replay of this list
	 cannot misalign it; older takes without the snapshot fall back to
	 lastPlayEpoch. Both epochs archive and the arithmetic differences them, so a
	 later session still places correctly. Needs a take recorded while this list
	 played.

	 at: \original — sugar for at: this.itemStartBeat(player). THE sealed insert
	 after a tempoMap change, and the order matters: change the map FIRST, then
	 addItem(take, \original).

	 offset: <beats> — additive nudge after position resolution, in beats, so it
	 lands downstream of every wall<->beat conversion and never touches the map.
	 Same meaning as copyVoice's offset. Consumed at insert: to change it,
	 re-insert.

	 align: 0..1 switches from FLATTENING to NESTING — see prAddItemNested. What
	 differs is what lands in `events`: flattened gives one editable event per
	 note, tagged with the source name, so solo/mute and event surgery see the
	 notes; nested gives one opaque event whose placement is recomputed every
	 prepare.
	*/
	addItem { |player, at, voice, mk, offset, align|
		var tm, whenFn, ep, sl, env, fromWall, epoch;
		(player.isNumber or: { player == \original }).if { var swap = player; player = at; at = swap };
		player = player.player;
		align.notNil.if { ^this.prAddItemNested(player, at, voice, mk, offset, align) };
		(at == \original).if {
			at = this.itemStartBeat(player) ?? {
				^"EventList.addItem: at: \\original needs a take with a recordPlayEpoch (recorded against a playing list) — pass a beat instead".warn
			}
		};
		at.notNil.if {
			tm = { player.tempomap }.try;
			whenFn = tm.notNil.if(
				{ { |e| at + tm.prAtExtrapolated(e.timestamp - tm.t0, tm.env) } },
				{ { |e| at + (e.timestamp - (player.start ? 0)) } });
		} {
			// Prefer the epoch snapshotted INTO the take at record time (the playthrough
			// it overdubbed against) so a later replay of this list can't misalign it;
			// fall back to this list's lastPlayEpoch for takes from before this was wired.
			ep = player.tryPerform(\recordPlayEpoch) ? lastPlayEpoch;
			ep.isNil.if {
				^"EventList.addItem: no play epoch — record the take while this list plays, or pass at:".warn
			};
			player.isKindOf(MIDIItemPlayer).not.if {
				^"EventList.addItem: % is not a MIDI take/player (still recording?)"
					.format(player).warn
			};
			epoch = player.recordEpoch;
			epoch.isNil.if {
				^"EventList.addItem: take has no recordEpoch (recorded in an older session/class?) — pass at:".warn
			};
			sl = ep[\list] ? this;   // the epoch's detached clock, never the live list
			env = ep[\tempoEnv];
			fromWall = sl.beatToWall(ep[\fromBeat], env);
			whenFn = { |e| sl.wallToBeat(epoch + e.timestamp - ep[\seconds] + fromWall, env) };
		};
		offset.notNil.if { var f = whenFn; whenFn = { |e| f.(e) + offset } };
		^this.prInsertItemEvents(player, whenFn, voice, mk ?? { this.prItemMk(player) })
	}

	// addItem's align: mode. Nests the take as a child \eventList rather than
	// flattening it, so placement is recomputed every prepare. The entry beat is
	// blended by the SAME amount as the interior: both endpoint placements pin child
	// beat 0 to `when` (§12j), so a fixed entry would pull the interior toward a grid
	// the take does not start on — at align 1 you would be locked to a grid offset by
	// the whole rounding residual. Blending keeps both ends exact: 0 enters where it
	// was played, 1 on the beat. An explicit at: wins over the computed entry.
	// `when` is baked at INSERT time — editing \align on the stored event re-blends
	// the interior but not the entry, so to change align, re-insert.
	// Returned as a one-element Array so removal reads the same in both modes:
	// e.events.removeAll(a).
	prAddItemNested { |player, at, voice, mk, offset, align|
		var mkName = mk ?? { this.prItemMk(player) };
		// anonymous child on purpose: EventList(name) ANSWERS an existing list of that
		// name, and asEventList appends to it — so a named child silently doubles its
		// events on a second call.
		var child = player.asEventList(nil, mkName ? \default);
		var when = at ?? {
			var a = this.itemAnchorBeat(player) ?? {
				^"EventList.addItem: align: needs a take with a recordPlayEpoch (recorded against a playing list) — pass at: as well".warn
			};
			a.blend(a.round(1), align)
		};
		voice !? { child.events.do { |e| e[\voice] = voice } };
		^[this.add((
			when: when + (offset ? 0),
			newType: \eventList,
			eventList: child,
			align: align,
			name: player.source.tryPerform(\name) !? { |n| n.asString.asSymbol }))]
	}

	// beat in THIS list's CURRENT frame that sounds at the take's recorded wall
	// moment (player.recordWall) — the wall-preserving b0 for a sealed
	// followTrack: \eventList insert. Change the tempoMap FIRST, then call: the
	// wall moment is fixed by the take's baked epoch, the beat is resolved
	// against whatever this list's clock is NOW. Composed through this.tempoEnv
	// (bare wallToBeat with nil env would ignore \tempoTrack events). nil for
	// takes without a recordPlayEpoch.
	// Frame-origin conversion: recordWall counts from the RECORDED playthrough's
	// beat 0, but a tempoMap wall frame is rebased by its t0 (first selected
	// note) — a selection-map guide plays t0 EARLIER than the flat playthrough
	// the take heard. Convert recorded wall -> source timestamps (+ srcT0) ->
	// this list's rebased frame (- dstT0), else the take lands t0 late relative
	// to the guide. Limitation: a rebase done outside the tempoMap (e.g. a flat
	// list whose player.start was set) is invisible to the epoch snapshot.
	itemStartBeat { |player| ^this.prItemBeat(player, 0) }

	// The list beat at which the take's FIRST MARKED NOTE was played — i.e. the
	// right value for addItem's at:, which positions that note rather than the
	// take's start. (itemStartBeat is the take's start, so passing it instead puts
	// the whole take early by the recorded distance from the start to the first
	// mark.) With no saved selection there is no map, addItem positions timestamp 0
	// instead, and this returns itemStartBeat to match. Round to land on the grid:
	//   e.addItem(p, at: e.itemAnchorBeat(p).round(1))
	// NB deliberately split into statements: with the `{...}.try` inlined in the
	// prItemBeat argument list, the closure's caught throw (no-selection tempomap)
	// corrupted the pending call frame in the 3.14.0-dev build — prItemBeat then
	// fired against a garbage receiver ("Message 'prItemBeat' not understood",
	// receiver a derived MIDIItemPlayer). Split form is immune. 2026-08-07.
	itemAnchorBeat { |player|
		var tOff = { player.player.tempomap.t0 }.try;
		^this.prItemBeat(player, tOff ? 0)
	}

	// beat in this list's current frame at which `tOff` seconds into the take sounded
	prItemBeat { |player, tOff = 0|
		^player.player.tryPerform(\recordWall) !? { |w|
			var ep = player.player.recordPlayEpoch;
			var srcT0 = (ep !? { ep[\list].tempoMap.tryPerform(\t0) }) ? 0;
			var dstT0 = tempoMap.tryPerform(\t0) ? 0;
			this.wallToBeat(w + tOff + srcT0 - dstT0, this.tempoEnv)
		}
	}

	add { |...args, kwargs|
		var event, previewOffset, when = args[0];
		args[1].isKindOf(Pattern).if { ^this.addPattern(when ? 0, args[1]) };
		when.isKindOf(Array).if {
			var whens = when;
			var n = whens.size;
			var base = (when: whens) ++ kwargs.asEvent;
			var previewOffsets = this.nextPreviewOffset(whens);
			^n.collect { |i|
				var ev = this.getSlice(base, i, n);
				this.dispatch(ev, { |e| this.storeAndPreview(e, previewOffsets[i]) });
				ev
			}
		};
		when.isKindOf(Event).if {
			event = when
		} {
			event = kwargs.asEvent;
			when.notNil.if { event[\when] = when }
		};
		event[\voice].isKindOf(Array).if {
			^this.expandEvent(event[\voice].size, event)
		};
		// eventList: is only ever meaningful on an \eventList event, so infer the type
		// rather than making every nesting call spell out newType:
		(event[\eventList].notNil and: { event[\newType].isNil }).if {
			event[\newType] = \eventList
		};
		previewOffset = this.nextPreviewOffset(event[\when] ? 0);
		this.dispatch(event, { |e| this.storeAndPreview(e, previewOffset) });
		^event
	}

	/*
	 Beats from the current batch's first event to `when` — the delay the preview
	 is scheduled at, so evaluating several add lines together auditions them with
	 their real rhythm instead of stacking them on one instant. A batch is inferred
	 from evaluation speed, not from the selection: adds landing within batchWindow
	 of each other share an origin, and each add extends the window.

	 NOT a pure query, hence `next`: it opens or extends the batch. Calling it
	 speculatively (or twice, or from a postln) shifts the batch's timing.
	*/
	nextPreviewOffset { |when|
		var now = SystemClock.seconds;
		var first = when.isKindOf(Array).if { when[0] } { when };
		(now >= batchEndTime).if { batchFirstWhen = first };
		batchEndTime = now + batchWindow;
		^when.isKindOf(Array).if {
			when.collect { |w| w - batchFirstWhen }
		} {
			when - batchFirstWhen
		}
	}

	// Every slice of a multi-valued event, added. getSlice is the single-slice form.
	expandEvent { |numSlices, event|
		^numSlices.collect { |index| this.add(this.getSlice(event, index, numSlices)) }
	}

    /*
	 Slice `index` of `numSlices` out of a multi-valued template event:
	
	 uses .clipAt, so a short array clamps to its last element: [60, 64] over 4 slices
	 gives 60, 64, 64, 64. 
	
	 Zero-arg Function values are left unevaluated here and resolved through
	 LambdaEnvir below, where they see their position as ~x / ~n (NB ~x, not ~i),
	 the whole axis as ~whens, and each other. Those three helpers are stripped
	 again so they never reach the played event.
     */
	getSlice { |event, index, numSlices|
		var scratch = ();
		var hasFunc = false;
		var out = ();
		event.keysValuesDo { |key, val|
			case
				{ val.isKindOf(Env) or: { val.isKindOf(Tuple3) } or: { val.isKindOf(Tuple4) } }
					{ scratch[key] = val }
				{ val.isKindOf(Function) and: { val.numArgs == 0 } }
					{ scratch[key] = val; hasFunc = true }
				{ val.isArray }
					{ scratch[key] = val.clipAt(index) }
				{ scratch[key] = val }
		};
		// nothing to resolve: skip LambdaEnvir entirely (hence scratch, not out)
		hasFunc.not.if { ^scratch };
		scratch[\x] = index;
		scratch[\n] = numSlices;
		scratch[\whens] = event[\when].asArray;
		{
			var le = LambdaEnvir(scratch);
			le.use { scratch.keysDo { |key| out[key] = le.at(key) } };
		}.value;
		[\x, \n, \whens].do { |key| out.removeAt(key) };
		^out
	}

	addContext { |...args, kwargs|
		var event;
		args[0].isKindOf(Event).if {
			event = args[0]
		} {
			event = (when: args[0] ? 0) ++ kwargs.asEvent
		};
		this.dispatch(event, { |e| context.add(e) });
		^event
	}

	dispatch { |event, sink|
		routes.keysValuesDo { |key, type|
			event[key].notNil.if {
				event.put(\type, type);
				addFunc !? { addFunc.(event, this) };
				sink.(event);
				^this
			}
		};
		autoExpand.if {
			event.select { |v, k| routes[k].isNil }.values
				.any { |i| i.rank > 0 }.if {
				event.asPairs.flop.collect { |i| i.asEvent }
					.do { |e| this.dispatch(e, sink) };
				^this
			};
		};
		event.put(\type, event[\newType] ? defaultType);
		addFunc !? { addFunc.(event, this) };
		sink.(event);
		^this
	}

	/*
	 Drain a pattern into stored events, walking `beat` forward by each event's
	 \dur. Three independent stops: maxEvents (nil = uncapped), maxWhen as a beat
	 ceiling, and the stream itself running out — so an endless pattern with no
	 maxEvents still terminates at maxWhen. The count is checked before pulling,
	 so maxEvents: 8 stores exactly 8.
	*/
	addPattern { |when=0, pattern, maxEvents, maxWhen=300, eventName|
		var stream = pattern.asStream;
		var beat = when;
		var i = 0;
		block { |break|
			loop {
				var event, previewOffset;
				(maxEvents.notNil and: { i >= maxEvents }).if { break.value };
				(beat > maxWhen).if { break.value };
				event = stream.next(());
				event.isNil.if { break.value };
				event.put(\when, beat);
				eventName !? { event.put(\name, eventName) };
				previewOffset = this.nextPreviewOffset(beat);
				// via dispatch, so pattern events get routes/addFunc/type stamping too.
				// A \type the pattern set is promoted to \newType, else dispatch's
				// fallback stamp overwrites it with defaultType.
				(event[\type].notNil and: { event[\newType].isNil }).if {
					event.put(\newType, event[\type])
				};
				this.dispatch(event, { |e| this.storeAndPreview(e, previewOffset) });
				beat = beat + (event[\dur] ? 1);
				i = i + 1;
			}
		};
		^this
	}

	solo_ { |val| solo = val.notNil.if { val.asArray.as(Set) } }
	mute_ { |val| mute = val.notNil.if { val.asArray.as(Set) } }

	shouldPlay { |event|
		// match solo/mute tokens against BOTH the event's name and its voice, so
		// voices (\chords, \chords2, ...) can be muted/soloed even when name is nil.
		var keys = [event[\name], event[\voice]].reject(_.isNil).collect(_.asString);
		solo.notNil.if {
			keys.isEmpty.if { ^false };
			^solo.any { |s| keys.any { |k| k.contains(s.asString) } }
		};
		(mute.notNil and: { keys.isEmpty.not }).if {
			^mute.any { |s| keys.any { |k| k.contains(s.asString) } }.not
		};
		^true
	}

	/*
	 Terminal step of the add pipeline (add -> dispatch -> here): the event ALWAYS
	 lands in `events`; it is additionally auditioned when preview is on and
	 solo/mute lets it through. previewOffset is in beats from the batch origin —
	 see nextPreviewOffset — and 0 means "at the batch origin", not "no preview".
	*/
	storeAndPreview { |event, previewOffset|
		events.add(event);
		(preview.notNil and: { this.shouldPlay(event) }).if {
			var resolved = this.resolveEvent(event);
			var bd = beatDur ? TempoClock.default.beatDur;
			previewPrep !? { previewPrep.(resolved, this) };
			this.prIsAudioFollow(resolved).if {
				var tempoEnv = this.tempoEnv(this.resolvedEvents);
				var actions;
				resolved = this.prForwardAudioFollow(resolved);
				actions = (resolved[\tempoFollowMode] == \env).if {
					AudioItem.tempoFollowEnvActions(resolved, this, tempoEnv, batchFirstWhen)
				} {
					AudioItem.tempoFollowActions(resolved, this, tempoEnv, batchFirstWhen)
				};
				actions.do { |pair|
					SystemClock.sched(pair[0], { pair[1].value; nil })
				}
			} {
				SystemClock.sched(
					previewOffset * bd,
					{ resolved.play; nil }
				)
			}
		}
	}

	preview_ { |val|
		var wasOff = preview.isNil;
		preview = val;
		(wasOff and: { val.notNil }).if { this.setupContext }
	}

	setupContext {
		context.do { |e| this.resolveEvent(e).copy.put(\when, 0).play }
	}

	// evts defaults to this list's own events; VoiceSpace passes its filtered
	// (scoped + shouldPlay) set so the tempo derivation matches what it plays.
	extractTempo { |evts|
		var tl = List[];
		(evts ? events).do { |ev|
			ev[\tempoTrack] !? { |v| tl.add([ev[\when] ? 0, v]) }
		};
		tl.sort({ |a, b| a[0] < b[0] });
		^tl
	}

	timelineToEnv { |timeline, initial|
		var levels = [initial];
		var times = [];
		var curves = [];
		var curBeat = 0, curLevel = initial;
		timeline.do { |pair|
			var beat = pair[0];
			var val = pair[1];
			var dt = beat - curBeat;
			(dt > 0).if {
				levels = levels.add(curLevel);
				times = times.add(dt);
				curves = curves.add(\step);
			};
			case
				{ val.isNumber } {
					levels = levels.add(val);
					times = times.add(0);
					curves = curves.add(\step);
					curLevel = val;
					curBeat = beat;
				}
				{ val.isKindOf(Tuple3) } {
					var resolved = val.at1.value;
					levels = levels.add(resolved);
					times = times.add(val.at2);
					curves = curves.add(val.at3);
					curLevel = resolved;
					curBeat = beat + val.at2;
				}
				{ val.isKindOf(Env) } {
					levels = levels.add(val.levels[0]);
					times = times.add(0);
					curves = curves.add(\step);
					val.times.do { |t, i|
						levels = levels.add(val.levels[i+1]);
						times = times.add(t);
						curves = curves.add(val.curves.isArray.if { val.curves.wrapAt(i) } { val.curves });
					};
					curLevel = val.levels.last;
					curBeat = beat + val.times.sum;
				};
		};
		while { (times.size > 0) and: { times[0] == 0 } } {
			levels = levels.drop(1);
			times = times.drop(1);
			curves = curves.drop(1);
		};
		(times.size == 0).if {
			levels = [levels[0], levels[0]];
			times = [0];
			curves = [\step];
		};
		^Env(levels, times, curves)
	}

	// \tempoTrack values are dimensionless tempo MULTIPLIERS (identity = 1) on the
	// base tempo, NOT absolute beatDurs — so a recorded tempoMap and a \tempoTrack
	// automation compose. Identity is 1 (regions with no \tempoTrack keep the base
	// tempo). For a list with no tempoMap and beatDur 1 (the ParamSpace path), a
	// multiplier equals the old absolute sec/beat numerically.
	tempoEnv { |evts|
		var tl = this.extractTempo(evts);
		^(tl.size > 0).if {
			var env = this.timelineToEnv(tl, 1);
			// Validate here — the one place both directions share — rather than
			// throwing only from wallToBeat: a non-positive multiplier makes the
			// composed clock non-monotone, so playback is already wrong before any
			// capture-time inversion crashes.
			env.levels.any { |l| l <= 0 }.if {
				"EventList.tempoEnv: non-positive \\tempoTrack multiplier in % — beat<->wall mapping is not invertible"
					.format(env.levels).warn
			};
			env
		}
	}

	// §12 seam: this list's base clock. A V2 MonoMap is COERCED here, once, into a
	// concrete AnchorTempoMap — the list must never HOLD a raw MonoMap: every
	// beatToWall/prBaseWallAt lookup would then pay a symbolic chain's per-event
	// cost, and a FunctionMap wrapping another EventList (the 5d bridge) would
	// recurse straight back into this list. rebase: true, because a list clock is
	// a SHAPE read from beat 0 — prBaseWallAt calls timeAt and never adds t0, so a
	// map whose seconds start mid-take must not drag the whole list late.
	// Anything else (a MIDIItemTempoMap, a TempoMap facade, nil) is stored exactly
	// as it always was.
	tempoMap_ { |map|
		tempoMap = map.isKindOf(MonoMap).if { map.asAnchorTempoMap(rebase: true) } { map };
		// The beat->wall integral is keyed on tempoEnv IDENTITY only, but its
		// cumulative sums (prWallCum / prWallBase / prWallSubs) are integrals of
		// the BASE clock — swapping that clock under a retained tempoEnv (which
		// every caller holds across a batch: prepare, asMonoMap, fire) would keep
		// serving the old map's seconds. Drop it; the next lookup rebuilds.
		prWallEnv = nil;
		^this
	}

	// Straighten this list's clock: amount 1 = one constant tempo, 0 = bit-exact
	// unchanged. On a list from asEventList — whose map holds the performance's
	// rubato, which is what makes the regularized whens play back as performed —
	// this is a continuous knob from as-played to metronomic. The notes never move,
	// their clock does, so this is NOT AbstractMidiEvents.quantize, which rewrites
	// timestamps. Chainable. Cumulative: two 0.5 calls land near 0.75, so for a knob
	// blend from a kept original rather than calling again.
	quantize { |amount = 1| ^this.prMapEdit { |m| m.quantize(amount) } }

	// Straighten locally: each span blends toward the mean slope over a `window` of
	// BEATS (default a quarter of the map's extent), so jitter goes and long-range
	// shape stays.
	quantizeWindow { |amount = 1, window| ^this.prMapEdit { |m| m.quantizeWindow(amount, window) } }

	// Straighten the beat span [from, to] only, leaving the rest of the clock alone.
	quantizeSpan { |from, to, amount = 1| ^this.prMapEdit { |m| m.quantizeSpan(from, to, amount) } }

	// The knob from "as performed" (amount 0) to "every child beat on a parent beat"
	// (amount 1) — same sense as the `align:` key on a nested \eventList event. NOT
	// what quantize does: quantize straightens toward the CHILD's own mean tempo,
	// which floats free of the parent and so drifts against it; this blends the
	// child's clock toward the PARENT's clock over the span it will occupy, so 1 is
	// exactly what followTrack: true gives and 0 is untouched playback. Use with
	// followTrack OFF — the child has to keep its own clock for this to mean
	// anything. `at` is the parent beat child beat 0 lands on (the same value the
	// nesting event's when: gets); `scale` is parent beats per child beat, for a take
	// whose marks sit at a different metric level. This is the authoring-time bake;
	// `align:` does the same blend at play time, without touching the child's map.
	// Cumulative like quantize: a second call re-blends the already-blended map, so
	// for a knob keep the pristine map and blend from it each time. The result is
	// SINGLE-PURPOSE: its anchor times embed THIS parent's tempoEnv at THIS at/scale,
	// and the coerced AnchorTempoMap carries no record of that — nest it elsewhere,
	// at a different when:, or stack the align: key on top (a double blend) and it is
	// silently wrong. Prefer the align: key unless standalone playback needs the bake.
	alignTo { |parent, at = 0, amount = 1, scale = 1|
		var m, xs, x0, y0, env, base;
		tempoMap.isNil.if { ^this };
		m = tempoMap.asMonoMap;
		m.respondsTo(\xs).not.if {
			Error("EventList.alignTo: need an anchor map, got %".format(m.class)).throw
		};
		xs = m.xs;
		x0 = xs.first;
		y0 = m.ys.first;
		env = parent.tempoEnv;
		base = parent.beatToWall(at, env);
		^this.tempoMap_(AnchorMap(
			xs,
			xs.collect { |x, i|
				(m.ys[i] - y0).blend(
					parent.beatToWall(at + ((x - x0) * scale), env) - base,
					amount)
			},
			m.fromFrame, m.toFrame, m.extendBelow, m.extendAbove))
	}

	// Bridge out to a MonoMap, edit, and assign THROUGH tempoMap_ — the setter owns
	// both the coercion back to an AnchorTempoMap and dropping the beat->wall cache,
	// so this must never touch the ivar. A flat list (nil map) is already straight,
	// so it is a no-op. The guard is the point: without it a func that answers
	// nil (a span op given a bad range) stores nil and the list silently goes flat.
	prMapEdit { |func|
		var edited;
		tempoMap.isNil.if { ^this };
		edited = func.(tempoMap.asMonoMap);
		edited.isKindOf(MonoMap).not.if {
			Error("EventList.prMapEdit: map edit answered %, expected a MonoMap"
				.format(edited.class)).throw
		};
		^this.tempoMap_(edited)
	}

	// Base wall-seconds elapsed across the beat interval [a, b], BEFORE any
	// \tempoTrack multiplier: the recorded tempoMap's delta if present, else flat
	// beatDur. t0 cancels in the delta, so this is offset-free (and the play-time
	// secondsAt(t) - secondsAt(from) subtraction stays identical to the old map).
	baseWallDelta { |a, b|
		tempoMap.notNil.if { ^tempoMap.timeAt(b) - tempoMap.timeAt(a) };
		^(b - a) * (beatDur ? TempoClock.default.beatDur)
	}

	// Absolute form of baseWallDelta: base wall-seconds from beat 0 to `beat`.
	// baseWallDelta(a, b) == prBaseWallAt(b) - prBaseWallAt(a); caching this at fixed
	// anchor points (prWallBase, ramp sub-grids) halves the timeAt calls per lookup.
	prBaseWallAt { |beat|
		tempoMap.notNil.if { ^tempoMap.timeAt(beat) };
		^beat * (beatDur ? TempoClock.default.beatDur)
	}

	// Pointwise compose of the \tempoTrack multiplier with the base tempo:
	//   wall(beat) = INTEGRAL over [0, beat] of baseSecPerBeat(x) * m(x) dx.
	// A flat multiplier of 1 reproduces the base map exactly; 2 plays it twice as
	// slow while preserving the base map's accel/rit SHAPE.
	// One-time integral of the tempoEnv: cumulative wall-seconds at every segment
	// boundary. Each segment's contribution (the exact trapezoid for a flat base, or
	// the sub-sampled ramp for a tempoMap base) is computed ONCE here instead of being
	// re-derived from beat 0 on every beatToWall call. O(segments) build; beatToWall is
	// then O(1) + one partial segment per event.
	prBuildWallCache { |tempoEnv|
		var levels = tempoEnv.levels, times = tempoEnv.times, curves = tempoEnv.curves;
		var cur = 0, sum = 0;
		var starts = [0], cum = [0], subs = [];
		times.size.do { |i|
			var cv = curves.isArray.if { curves.wrapAt(i) } { curves };
			var segEnd = cur + times[i];
			var contrib, sub;
			((cv != \step) and: { tempoMap.notNil } and: { times[i] > 0 }).if {
				// Ramp over a tempoMap base: cache the cumulative sub-grid so
				// beatToWall partials inside this segment are O(1), not a fresh
				// re-integration from the segment start per call (383 us/call on a
				// real guide list — dominated prepare).
				sub = this.prBuildRampSub(levels[i], levels[i + 1], cur, times[i]);
				contrib = sub[\cum].last;
			} {
				contrib = (cv == \step).if {
					levels[i] * this.baseWallDelta(cur, segEnd)
				} {
					this.prIntegrateRamp(levels[i], levels[i+1], cur, times[i], cur, segEnd)
				};
			};
			sum = sum + contrib;
			subs = subs.add(sub);
			cur = segEnd;
			starts = starts.add(cur);
			cum = cum.add(sum);
		};
		prWallEnv = tempoEnv;
		prWallStarts = starts; prWallCum = cum;
		prWallLevels = levels; prWallTimes = times; prWallCurves = curves;
		prWallSubs = subs;
		prWallBase = starts.collect { |st| this.prBaseWallAt(st) };
	}

	// Cumulative sub-sampled integral across ONE ramp segment (same ~16 steps/beat
	// scheme as prIntegrateRamp, but on a fixed grid anchored at the segment start).
	prBuildRampSub { |mA, mB, segStart, segLen|
		var k = (16 * segLen).ceil.max(1).asInteger;
		var step = segLen / k;
		var mAt = { |x| mA + ((mB - mA) * (x - segStart) / segLen) };
		var cum = [0];
		var base = [this.prBaseWallAt(segStart)];
		var sum = 0, x0 = segStart;
		k.do { |j|
			var x1 = segStart + ((j + 1) * step);
			sum = sum + (mAt.((x0 + x1) / 2) * this.baseWallDelta(x0, x1));
			cum = cum.add(sum);
			base = base.add(this.prBaseWallAt(x1));
			x0 = x1;
		};
		^(step: step, mA: mA, mB: mB, segStart: segStart, segLen: segLen, cum: cum, base: base)
	}

	// O(1) partial-ramp lookup: cached cumulative up to the last grid point at or
	// before `beat`, plus one midpoint step for the remainder. Continuous and
	// monotone; agrees with prBuildRampSub at every grid point.
	prRampSubAt { |sub, beat|
		var j = ((beat - sub[\segStart]) / sub[\step]).floor.asInteger.clip(0, sub[\cum].size - 1);
		var x0 = sub[\segStart] + (j * sub[\step]);
		var mAt = { |x| sub[\mA] + ((sub[\mB] - sub[\mA]) * (x - sub[\segStart]) / sub[\segLen]) };
		^sub[\cum][j] + ((beat > x0).if {
			mAt.((x0 + beat) / 2) * (this.prBaseWallAt(beat) - sub[\base][j])
		} { 0 })
	}

	beatToWall { |beat, tempoEnv|
		var seg, segStart, cv;
		tempoEnv.isNil.if { ^this.baseWallDelta(0, beat) };
		(prWallEnv !== tempoEnv).if { this.prBuildWallCache(tempoEnv) };
		(beat <= 0).if { ^0 };
		// Segment whose half-open span contains beat (or the flat tail past the last one).
		seg = prWallTimes.size;
		block { |break|
			prWallTimes.size.do { |k|
				(beat <= prWallStarts[k + 1]).if { seg = k; break.value };
			};
		};
		(seg < prWallTimes.size).if {
			segStart = prWallStarts[seg];
			cv = prWallCurves.isArray.if { prWallCurves.wrapAt(seg) } { prWallCurves };
			^prWallCum[seg] + (cv == \step).if {
				prWallLevels[seg] * (this.prBaseWallAt(beat) - prWallBase[seg])
			} {
				prWallSubs[seg].notNil.if {
					this.prRampSubAt(prWallSubs[seg], beat)
				} {
					this.prIntegrateRamp(
						prWallLevels[seg], prWallLevels[seg + 1],
						segStart, prWallTimes[seg], segStart, beat)
				}
			};
		};
		// Past the final boundary: flat extrapolation at the last multiplier.
		^prWallCum.last + (prWallLevels.last * (this.prBaseWallAt(beat) - prWallBase.last))
	}

	// Inverse of beatToWall: elapsed wall-seconds from beat 0 -> list beat.
	// With a tempoEnv, beatToWall clamps beats <= 0, so its inverse likewise
	// returns 0 for non-positive wall time. Tempo multipliers must stay positive
	// for the composed clock to be invertible.
	wallToBeat { |sec, tempoEnv|
		var seg, lo, hi, mid, local, cv, level, baseTarget, steps;
		tempoEnv.isNil.if {
			tempoMap.notNil.if {
				^tempoMap.beatAt(tempoMap.timeAt(0) + sec)
			};
			^sec / (beatDur ? TempoClock.default.beatDur)
		};
		(prWallEnv !== tempoEnv).if { this.prBuildWallCache(tempoEnv) };
		(sec <= 0).if { ^0 };

		// Last cumulative boundary not greater than sec (binary search).
		lo = 0; hi = prWallCum.size - 1;
		while { lo < hi } {
			mid = ((lo + hi + 1) / 2).floor.asInteger;
			(prWallCum[mid] <= sec).if { lo = mid } { hi = mid - 1 };
		};
		seg = lo;
		local = sec - prWallCum[seg];

		// Past the final boundary: the final multiplier is held constant.
		(seg >= prWallTimes.size).if {
			level = prWallLevels.last;
			(level <= 0).if { Error("EventList.wallToBeat: tempo multiplier must be positive").throw };
			baseTarget = prWallBase.last + (local / level);
			tempoMap.notNil.if { ^tempoMap.beatAt(baseTarget) };
			^prWallStarts.last + (local / (level * (beatDur ? TempoClock.default.beatDur)))
		};

		cv = prWallCurves.isArray.if { prWallCurves.wrapAt(seg) } { prWallCurves };
		(cv == \step).if {
			level = prWallLevels[seg];
			(level <= 0).if { Error("EventList.wallToBeat: tempo multiplier must be positive").throw };
			baseTarget = prWallBase[seg] + (local / level);
			tempoMap.notNil.if { ^tempoMap.beatAt(baseTarget) };
			^prWallStarts[seg] + (local / (level * (beatDur ? TempoClock.default.beatDur)))
		};

		// A linear multiplier over a flat base has an exact quadratic inverse.
		tempoMap.isNil.if {
			var mA = prWallLevels[seg], mB = prWallLevels[seg + 1];
			var len = prWallTimes[seg], slope = (mB - mA) / len;
			var baseDur = beatDur ? TempoClock.default.beatDur, x;
			(mA.min(mB) <= 0).if { Error("EventList.wallToBeat: tempo multiplier must be positive").throw };
			x = (slope.abs < 1e-12).if {
				local / (baseDur * mA)
			} {
				// max(0): the discriminant is mB^2 at the segment end in exact
				// arithmetic, so float rounding can only dip it epsilon-negative.
				((mA.neg) + ((mA.squared + (2 * slope * local / baseDur)).max(0).sqrt)) / slope
			};
			^prWallStarts[seg] + x
		};

		// tempoMap x ramp uses the same cached approximation as beatToWall;
		// bisection therefore round-trips that approximation, not a second integral.
		(prWallLevels[seg].min(prWallLevels[seg + 1]) <= 0).if {
			Error("EventList.wallToBeat: tempo multiplier must be positive").throw
		};
		lo = prWallStarts[seg]; hi = prWallStarts[seg + 1];
		steps = 0;
		// Early exit at 1e-10 beats; the step cap bounds the loop when lo/hi are
		// large enough that adjacent floats sit further apart than the tolerance.
		while { ((hi - lo) > 1e-10) and: { steps < 60 } } {
			mid = (lo + hi) / 2;
			(this.beatToWall(mid, tempoEnv) < sec).if { lo = mid } { hi = mid };
			steps = steps + 1;
		};
		^(lo + hi) / 2
	}

	// INTEGRAL over [a, b] of m(x) * baseSecPerBeat(x) dx, where m ramps linearly
	// from mA (at segStart) to mB (at segStart + segLen). With a flat base this is
	// the exact trapezoid in m; a nonlinear tempoMap base is sub-sampled (~16
	// steps/beat, m read at segment midpoints) since m * nonlinear-base has no
	// closed form.
	prIntegrateRamp { |mA, mB, segStart, segLen, a, b|
		var k, x0, sum = 0;
		var mAt = { |x| mA + ((mB - mA) * (x - segStart) / segLen) };
		tempoMap.isNil.if {
			^(mAt.(a) + mAt.(b)) / 2 * this.baseWallDelta(a, b)
		};
		k = (16 * (b - a)).ceil max: 1;
		x0 = a;
		k.do { |j|
			var x1 = a + ((b - a) * (j + 1) / k);
			sum = sum + (mAt.((x0 + x1) / 2) * this.baseWallDelta(x0, x1));
			x0 = x1;
		};
		^sum
	}

	// `to` (nil = play to the end) upper-bounds playback to the half-open beat
	// window [from, to) in THIS list's frame — the counterpart to `from`. It is
	// absolute (not shifted by fromEvent/fromSection). Reached from \eventList via
	// end:. Ignored on the playFn override path.
	play { |from=0, fromEvent, fromSection, to|
		from = from ? 0;
		fromEvent !? {
			var ev = events[fromEvent];
			ev.notNil.if { from = (ev[\when] ? 0) + from }
		};
		fromSection !? {
			(defaultType == \seg).if {
				var hit = events.detect { |e| e[\section] == fromSection };
				hit.notNil.if { from = (hit[\when] ? 0) + from }
			} {
				"EventList.play: fromSection ignored — defaultType is %".format(defaultType).warn
			}
		};
		voiceSpace.notNil.if {
			// No tempoMap on a VoiceSpace list => base of 1 s/beat, so \tempoTrack values
			// read as absolute s/beat (identity = 1), matching pre-delegation behavior.
			beatDur ?? { this.beatDur_(1) };
			^this.prPlayPrepared(from, to)
		};
		playFn.notNil.if { ^playFn.(this, from) };
		^this.prPlayPrepared(from, to)
	}

	// §10c: prepare (all language/allocation work, synchronous, before the epoch) then
	// fire (schedule lightweight sends).
	//
	// leadTime is the prepare BUDGET, and the point of setting it is DETERMINISM (same
	// idea as server latency: fix the wait, don't minimize it): with leadTime set, the
	// first sound lands exactly leadTime + latency after the play call — choose it
	// slightly above this list's prepare cost. Only if prepare OVERRUNS the budget does
	// the epoch slide (with a warning), because sliding beats a late storm. leadTime
	// nil = adaptive: start as soon as safely possible (prepare-end + latency + pad),
	// minimal but not deterministic.
	//
	// Timing MUST be measured with Main.elapsedTime (physical), NOT SystemClock.seconds:
	// that is the calling THREAD's logical time, frozen for the whole of a synchronous
	// evaluation — prepare cost reads as zero against it, and an epoch anchored to it
	// sits Δ (eval lag + prepare cost) in the physical past. Bundles are stamped from
	// logical time + latency, so every send then leaves with only latency - Δ of real
	// headroom → server "late" storms whenever Δ > latency. (Found live 2026-07-06:
	// lates until leadTime ≈ latency + Δ, misread as "2x latency".)
	prPlayPrepared { |from = 0, to|
		var lat = Server.default.latency ? 0.2;
		// The epoch anchors to LOGICAL time (thisThread.seconds), like everything else
		// scheduled in sclang — so events co-evaluated with .play line up with the list
		// by construction: (lag: leadTime).play sounds exactly on the list's first
		// beat, no matter how much eval work preceded .play in the same block (that
		// work is exactly what broke the alignment when the epoch anchored to physical
		// time). The overrun check below still guards against PHYSICAL time, so the
		// budget must cover logical-drift + prepare; it warns + slides when it doesn't.
		var t0 = thisThread.seconds;
		var epoch = t0 + (leadTime ? 0) + lat;
		// Select once; prepare reuses both the events and the env built from them
		// instead of re-running the scoped/shouldPlay selection.
		var evts = this.prPlayEvents;
		var tempoEnv = this.tempoEnv(evts);
		var sched = this.prepare(epoch, from, to: to, tempoEnv: tempoEnv, evts: evts);
		// Sends fire `lat` early (they self-bundle at +lat), so the real deadline for
		// the FIRST entry is epoch - lat = t0 + leadTime.
		var d = (Main.elapsedTime + 0.02) - (epoch - lat);
		(d > 0).if {
			(leadTime.notNil and: { leadTime > 0 }).if {
				"EventList.play: eval drift + prepare (%s) overran leadTime (%s) — starting %s late"
					.format((Main.elapsedTime - t0).round(0.001), leadTime, d.round(0.001)).warn
			};
			epoch = epoch + d;
			sched.do { |i| i[\time] = i[\time] + d };
		};
		// Absolute transport time at which `from` sounds, plus the exact composed
		// tempo environment used to prepare this playback. Recording/capture code can
		// subtract seconds, add beatToWall(from), then call wallToBeat without
		// reconstructing mutable playback state. Deliberately NOT cleared by stop or
		// invalidated by later list mutation: the snapshot describes what the recorded
		// take actually heard, so capture-after-stop (or after a re-quantize) must
		// keep using it, not the list's current state.
		// list: a detached clock snapshot — beatToWall/wallToBeat on the LIVE list
		// read tempoMap/beatDur, so a later destructive quantize would otherwise
		// silently re-time captures against a clock the take never heard.
		lastPlayEpoch = (seconds: epoch, fromBeat: from, tempoEnv: tempoEnv,
			list: this.prClockSnapshot);
		// Publish for MIDIItem.record to snapshot: a take recorded now is overdubbing
		// against THIS playthrough. Survives stop (the take keeps its own copy).
		currentPlayEpoch = lastPlayEpoch;
		// A nested own-tempo child inserted before `from` can produce pre-epoch entries.
		// Exact wallToBeat trimming is not wired into nested preparation yet; drop them
		// rather than firing a burst at start.
		sched = sched.reject { |i| i[\time] < (epoch - 0.001) };
		this.fire(sched);
		^this
	}

	// §10a: resolve this list — and any nested \eventList events — into a flat schedule
	// of (time: absWallSeconds, send: {}, label:) entries against a shared epoch.
	// `place` answers "what absolute wall-second does a beat in THIS list's frame land
	// on?"; top-level lists get the default, nested lists get one from prExpandList.
	// `seen` guards cyclic nesting.
	prepare { |epoch, from = 0, place, seen, to, tempoEnv, evts|
		var sched = List[];
		var fromWall, playable;
		seen = seen ?? { IdentitySet[] };
		seen.includes(this).if {
			"EventList.prepare: cyclic \\eventList nesting at % — skipped".format(name).warn;
			^sched
		};
		evts     = evts ?? { this.prPlayEvents };
		tempoEnv = tempoEnv ?? { this.tempoEnv(evts) };
		fromWall = this.beatToWall(from, tempoEnv);
		place    = place ?? { { |beat| epoch + (this.beatToWall(beat, tempoEnv) - fromWall) } };
		playable = voiceSpace.notNil.if {
			evts.reject { |e| (e[\type] ? \keyFrame) == \keyFrame }
		} { evts };
		playable.do { |ev|
			ev[\tempoTrack].isNil.if {
				(ev[\type] == \eventList).if {
					sched.addAll(this.prExpandList(ev, epoch, place, from, seen))
				} {
					sched.addAll(this.prEmit(ev, place, tempoEnv, from))
				}
			}
		};
		voiceSpace !? {
			sched.addAll(voiceSpace.prepareVoices(this, epoch, from, place, evts, tempoEnv))
		};
		// Half-open upper bound: drop everything at/after beat `to`. Done in the WALL
		// domain (place is monotonic in beat, so time >= place.(to) iff beat >= to) so
		// one filter covers every branch — discrete, mi2/audioItem follow, voices — and
		// applies per-list, so a nested child trims to its own end: in its own frame.
		to !? {
			var toWall = place.(to);
			sched = sched.reject { |i| i[\time] >= (toWall - 0.001) };
		};
		^sched
	}

	// The filtered (scoped + shouldPlay) events exactly as play/prepare uses them.
	prPlayEvents {
		^this.resolvedEvents.select { |e| this.shouldPlay(e) }
	}
	// tempoEnv as play/prepare will actually use it: derived from the filtered
	// events, so it matches what sounds.
	prPlayTempoEnv {
		^this.tempoEnv(this.prPlayEvents)
	}

	// §10b: expand a nested \eventList event into schedule entries. followTrack: true
	// reinterprets child beats in the PARENT frame (the child rides the parent's
	// tempoTrack — same convention as \mi2 followTrack); otherwise the child keeps its
	// own beat->wall map, shifted so child beat `start` lands at the parent's wall time
	// for `when`. rate = tempo/stretch scales child beats per parent beat.
	prExpandList { |ev, epoch, place, from = 0, seen|
		var child = ev[\eventList].isKindOf(EventList).if { ev[\eventList] } { EventList.at(ev[\eventList]) };
		var b0    = ev[\when] ? 0;
		var cFrom = ev[\start] ? 0;
		var cTo   = ev[\end];  // child-frame half-open end (nil = to child's end)
		var rate  = (ev[\tempo] ? 1) / (ev[\stretch] ? 1);
		// groove: a Groove (beat->beat) applied in the CHILD's beat frame, before the
		// conversion to parent beats — so the child swings on its own subdivisions
		// while the parent's tempo map still governs the wall placement.
		var groove = ev[\groove];
		var gAt = groove.notNil.if({ { |b| groove.mapBeat(b) } }, { { |b| b } });
		// align: 0..1 — 1 is followTrack: true (child beats ARE parent beats), 0 is
		// followTrack absent (child plays its own performed seconds), in between a
		// blend of the two. Present => it decides, and followTrack is redundant.
		var align = ev[\align];
		var childPlace, childSeen, refG;
		child.isNil.if {
			"EventList.prepare: no list named %".format(ev[\eventList]).warn;
			^List[]
		};
		childSeen = (seen ?? { IdentitySet[] }).copy;
		childSeen.add(this);
		align.notNil.if { ^this.prExpandBlended(ev, epoch, place, from, childSeen,
			child, b0, cFrom, cTo, rate, gAt, align) };
		((ev[\followTrack] ? false) != false).if {
			(ev[\followTrack] == true).not.if {
				"EventList.prepare: followTrack:% on nested \\eventList — source-map values only apply to \\mi2; following track".format(ev[\followTrack]).warn
			};
			// Trim like \mi2: playing the parent from past the insert point starts
			// partway INTO the child. The cut is a GROOVED child beat, so `from`
			// resolves through the inverse — else a mid-list start lands on the wrong
			// child beat and every note after it skews.
			refG = gAt.(cFrom);
			(from > b0).if {
				var cut = refG + ((from - b0) * rate);
				cFrom = groove.notNil.if({ groove.unmapBeat(cut) }, { cut });
				refG = cut;
				b0 = from;
			};
			childPlace = { |cBeat| place.(b0 + ((gAt.(cBeat) - refG) / rate)) };
		} {
			var cEnv = child.prPlayTempoEnv;
			var anchor = place.(b0);
			var cFromWall = child.beatToWall(gAt.(cFrom), cEnv);
			childPlace = { |cBeat| anchor + (child.beatToWall(gAt.(cBeat), cEnv) - cFromWall) };
		};
		^child.prepare(epoch, cFrom, childPlace, childSeen, cTo)
	}

	// The `align:` blend. Both endpoint placements answer WALL times and both are
	// monotone in child beat, so their blend is too — which is what makes it safe to
	// invert below. At align 1 and 0 the expression reduces exactly to prExpandList's
	// two branches, so those stay the reference. Nothing is mutated: unlike alignTo,
	// the child's tempoMap is untouched, so replays and nesting stay repeatable.
	// The mid-list cut has no closed form here (the blend mixes two beat axes), so it
	// is bisected — same move as Groove's inverse and wallToBeat's subsampled case.
	prExpandBlended { |ev, epoch, place, from, childSeen, child, b0, cFrom, cTo, rate, gAt, align|
		var cEnv      = child.prPlayTempoEnv;
		var anchor    = place.(b0);
		var refG      = gAt.(cFrom);
		var cFromWall = child.beatToWall(refG, cEnv);
		var childPlace = { |cBeat|
			(anchor + (child.beatToWall(gAt.(cBeat), cEnv) - cFromWall))
				.blend(place.(b0 + ((gAt.(cBeat) - refG) / rate)), align)
		};
		(((ev[\followTrack] ? false) != false) and: { align != 1 }).if {
			"EventList.prepare: align:% on a nested \\eventList overrides followTrack"
				.format(align).warn
		};
		(from > b0).if { cFrom = this.prBisectBeat(childPlace, place.(from), cFrom) };
		^child.prepare(epoch, cFrom, childPlace, childSeen, cTo)
	}

	// child beat whose placement reaches targetWall, never below `lo`. Bracket by
	// doubling, then halve; the placement is monotone, so this converges.
	prBisectBeat { |placeFn, targetWall, lo|
		var hi = lo + 1, span = 1;
		(placeFn.(lo) >= targetWall).if { ^lo };
		while { placeFn.(hi) < targetWall and: { span < 1e6 } } {
			span = span * 2;
			hi = lo + span
		};
		(placeFn.(hi) < targetWall).if {
			"EventList.prBisectBeat: target wall never reached — child ends before the cut; nothing will play".warn;
			^hi
		};
		64.do {
			var mid = (lo + hi) * 0.5;
			(placeFn.(mid) < targetWall).if { lo = mid } { hi = mid }
		};
		^(lo + hi) * 0.5
	}

	// \mi2 convention on \audioItem: followTrack routes to the tempo-follow path.
	// true/\flat = flat source (sourceBeatDur: 1, recorded seconds as beats),
	// \eventList = the list's base map (tempo-follow's native default), a map
	// object = that map as the source (forwards to sourceTempoMap:, for takes
	// whose map the list no longer owns — e.g. after a destructive quantize).
	// Explicit sourceTempoMap/sourceBeatDur wins. \audioItemTempoFollow passes
	// through unchanged. Only affects list playback — a direct .play stays sealed.
	prForwardAudioFollow { |ev|
		(ev[\type] == \audioItem).if {
			var ft = ev[\followTrack];
			(ev[\sourceTempoMap].isNil and: { ev[\sourceBeatDur].isNil }).if {
				ft.respondsTo(\timeAt).if {
					ev = ev.copy;
					ev[\sourceTempoMap] = ft;
				} {
					(ft != \eventList).if {
						ev = ev.copy;
						ev[\sourceBeatDur] = 1;
					}
				}
			}
		};
		^ev
	}

	// Item-frame accessors for a per-event source map (sourceTempoMap: <map>):
	// itemBeat/itemSec are relative to the map's domain starts, so a selection map
	// built from the take lines up with the player's own timestamps.
	prSrcTimeAt { |map, itemBeat|
		^map.timeAt(map.beatDomain.first + itemBeat) - map.timeDomain.first
	}
	prSrcBeatAt { |map, itemSec|
		^map.beatAt(map.timeDomain.first + itemSec) - map.beatDomain.first
	}

	// Route a \audioItemTempoFollow event, or a \audioItem carrying followTrack,
	// to the tempo-follow builders. record: true only means record when ARMED —
	// recording stays on the sealed \audioItem path, but unarmed the event is
	// playback intent and follows (the rapid record/play toggle: leave record:
	// true in the event, flip AudioItem.armed). The warning is a deliberate
	// reminder that the item will record on the next armed play. Armed is
	// sampled at prepare time, not mid-playback.
	prIsAudioFollow { |ev|
		^(ev[\type] == \audioItemTempoFollow) or: {
			(ev[\type] == \audioItem)
			and: { (ev[\followTrack] ? false) != false }
			and: {
				((ev[\record] ? false) != true) or: {
					AudioItem.armed.not.if {
						"AudioItem %: not armed — following track; will record if armed"
							.format(ev[\name]).warn;
						true
					} { false }
				}
			}
		}
	}

	// Detached copy of this list's base clock — an EventList carrying only
	// tempoMap/beatDur, so later mutations of the live list (in-place durs_/beats_
	// included: hence deepCopy, a shallow copy would share the beats/durs arrays)
	// can't rewrite history. Used by prRecordStamp and lastPlayEpoch.
	prClockSnapshot {
		var snap = EventList.new;
		snap.tempoMap = tempoMap.deepCopy;
		snap.beatDur = beatDur;
		^snap
	}

	// §9a step 2 (in-memory): snapshot of the clock a record: true \audioItem is
	// about to record against — a detached EventList carrying copies of this
	// list's tempoMap/beatDur plus the composed tempoEnv, so later mutations
	// (e.g. a destructive quantize swapping tempoMap) can't rewrite history.
	// latency/lag are captured for future record-onset compensation (roadmap);
	// persisted sidecar storage is future work (retune-project.md §2e schema).
	prRecordStamp { |ev, tempoEnv|
		^(
			list: this.prClockSnapshot,
			tempoEnv: tempoEnv.copy,
			when: ev[\when] ? 0,
			start: ev[\start] ? ev[\startPos] ? 0,
			latency: ev[\latency] ? Server.default.latency,
			lag: ev[\lag] ? 0,
			// measured device round trip at record time (\raw convention):
			// stamp-based playback reads the file this much later
			roundTrip: AudioItem.roundTripLatency,
			latencyConvention: \raw
		)
	}

	// Per-type schedule builders (§10a). Sends must stay lightweight: everything
	// expensive (warping, file reads, env math) happens here, at prepare time.
	prEmit { |ev, place, tempoEnv, from = 0|
		var out = List[];
		this.prIsAudioFollow(ev).if {
			var fromAbs = place.(from);
			var actions;
			ev = this.prForwardAudioFollow(ev);
			actions = (ev[\tempoFollowMode] == \env).if {
				AudioItem.tempoFollowEnvActions(ev, this, tempoEnv, from, place)
			} {
				AudioItem.tempoFollowActions(ev, this, tempoEnv, from, place)
			};
			actions.do { |pair|
				out.add((time: fromAbs + pair[0], send: pair[1], label: \audioItemTempoFollow))
			};
			^out
		};
		// mirrors prIsAudioFollow: record: true + armed must stay on the sealed
		// \mi2 path (the event type does the recording — the follow path flattens
		// events at prepare time and never runs it); unarmed it's playback intent
		// and follows. Armed is sampled at prepare time, not mid-playback.
		(((ev[\followTrack] ? false) != false) and: { ev[\type] == \mi2 } and: {
			((ev[\record] ? false) != true) or: {
				MIDIItem.armed.not.if {
					"MIDIItem %: not armed — following track; will record if armed"
						.format(ev[\name]).warn;
					true
				} { false }
			}
		}).if {
			^this.prEmitMi2Follow(ev, tempoEnv, from, place)
		};
		((ev[\when] ? 0) >= from).if {
			var send = (((ev[\type] == \audioItem) and: { (ev[\record] ? false) == true })).if {
				// record-time clock stamp: the \audioItem record branch stores it
				// under (name, take) so playback can resolve the true source clock
				var stamped = ev.copy;
				stamped[\recordedAgainst] = this.prRecordStamp(stamped, tempoEnv);
				{ stamped.copy.play }
			} {
				{ ev.copy.play }
			};
			out.add((time: place.(ev[\when] ? 0), send: send, label: (ev[\type] ? \event)))
		};
		^out
	}

	// Route (c) (§9b/§10): warp a followTrack \mi2 item's internal events onto this
	// list's tempo frame and flatten each note into the schedule — one (time, send) per
	// event, no inner TempoClock (which retires the queueSize:65536 hack). The warp is
	// done in the BEAT domain and placement goes through `place`, so it composes under
	// nesting. sourceTempoMap: \eventList inverts recorded seconds through this list's
	// own tempoMap (for takes recorded against it); a map OBJECT inverts through that
	// map in item-frame coordinates (e.g. take.selection.tempomap, for takes whose map
	// this list doesn't own); the default treats recorded seconds as beats (flat
	// clock), scaled by rate. Shorthand: any non-boolean followTrack value forwards to
	// sourceTempoMap, so followTrack: \eventList (or a map) is the one-key
	// form. When `from` is past the item's onset the item is trimmed (player.from
	// also chases CC state); emits nothing if `from` is past the whole item. A flat track reproduces the sealed \mi2 timing exactly.
	// (\mi is excluded: its fromNote(~from,~to) sub-range isn't replicated here.)
	prEmitMi2Follow { |ev, tempoEnv, from = 0, place|
		var out    = List[];
		var player = ev[\player];
		var b0     = ev[\when] ? 0;
		var rate   = (ev[\tempo] ? 1) / (ev[\stretch] ? 1);
		var originBeat = b0.max(from);
		var pstart, beatOff, tm, wallBase, warped, wPlayer, useMap, useSrc, mapAnchor, srcMap, srcOrigin;
		player.isNil.if { ^out };
		ev[\filter] !? { |f| player = f.(player) };
		ev[\params] !? { |p| player = player.setParams(p) }; // \mi2 finish does this
		tm = tempoMap;
		// followTrack forwards non-boolean values to sourceTempoMap (followTrack: \eventList
		// == followTrack: true, sourceTempoMap: \eventList); explicit sourceTempoMap wins.
		srcMap = ev[\sourceTempoMap] ?? {
			(ev[\followTrack] == true).if { nil } { ev[\followTrack] }
		};
		useMap = (srcMap == \eventList) and: {
			(tm.notNil and: { tm.respondsTo(\timeAt) } and: { tm.respondsTo(\beatAt) }).if { true } {
				"prEmitMi2Follow: sourceTempoMap:\\eventList needs an invertible tempo-map base; using flat".warn;
				false
			}
		};
		// general case: a map OBJECT stamped on the event — the take's own map, in
		// item-frame coordinates (independent of this list's tempoMap)
		useSrc = useMap.not and: {
			srcMap.respondsTo(\timeAt) and: { srcMap.respondsTo(\beatAt) }
		};
		// item-frame beat that sounds at list beat originBeat (== originBeat until rate != 1)
		mapAnchor = b0 + ((originBeat - b0) * rate);
		// Where item-seconds 0 sits in the player's own timeline — prSrcTimeAt/BeatAt
		// measure from the map's domain start, so this is that start as a take
		// timestamp. In order: a MIDIItemTempoMap's t0 (its times were rebased by t0 at
		// construction, so it reports timeDomain [0, ...] and the start is invisible
		// there); an absolute-origin map's own domain start (asMonoMap(origin:
		// \absolute)); else player.start, the general convention that a map's domain
		// starts where the item does. Wrong here and the take shifts by the gap from
		// its start to the first marked note. A relative-origin asMonoMap of a t0 map
		// is the one unfixable case — it discarded t0, and its domain start of 0 is
		// indistinguishable from an honestly item-start-based map. Use \absolute.
		// The trim below moves the timestamps, so the origin moves with them.
		srcOrigin = srcMap.tryPerform(\t0) ?? {
			var d = (srcMap.tryPerform(\timeDomain) !? (_.first)) ? 0;
			(d != 0).if { d } { player.start ? 0 }
		};
		(from > b0).if {
			// trim in the player's own time domain: recorded seconds through the map
			// when one is in play, else flat beats-as-seconds — a beat-domain cut on
			// a map source trims at the wrong recorded second AND shifts the
			// inversion's rel-origin, skewing every note after a mid-list `from`.
			var base = useSrc.if { srcOrigin } { player.start ? 0 };
			var tFrom = base + (useMap.if {
				tm.timeAt(mapAnchor) - tm.timeAt(b0)
			} {
				useSrc.if {
					this.prSrcTimeAt(srcMap, mapAnchor - b0)
				} {
					(from - b0) * rate
				}
			});
			(tFrom >= (player.end ? player.bounds.end)).if { ^out }; // fully before `from`
			player = player.from(tFrom); // rebases to 0 and chases CC state to tFrom
			srcOrigin = srcOrigin - tFrom; // timestamps moved, so the origin does too
		};
		pstart = player.start ? 0;
		beatOff = case
			{ useMap } {
				var startSec = tm.timeAt(mapAnchor);
				// TempoMap (\clamp) freezes the beat past the map's ends, where
				// MIDIItemTempoMap (\carry) keeps the endpoint tempo going — item
				// events past the map's end behave differently per base map class.
				(tm.respondsTo(\extrapolation) and: { tm.extrapolation == \clamp }).if {
					"prEmitMi2Follow: base tempo map clamps at its ends — item events past the map's end freeze at the boundary beat".warn
				};
				{ |rel| (tm.beatAt(startSec + rel) - mapAnchor) / rate }
			}
			{ useSrc } {
				var itemAnchor = mapAnchor - b0;
				var itemOff = pstart - srcOrigin; // rel (from player.start) -> item seconds
				(srcMap.respondsTo(\extrapolation) and: { srcMap.extrapolation == \clamp }).if {
					"prEmitMi2Follow: source map clamps at its ends — item events past the map's end freeze at the boundary beat".warn
				};
				{ |rel| (this.prSrcBeatAt(srcMap, rel + itemOff) - itemAnchor) / rate }
			}
			{ { |rel| rel / rate } };
		wallBase = place.(originBeat);
		warped = player.midiEvents.collect { |e|
			var c   = e.copy;
			var rel = (e[\timestamp] ? 0) - pstart;
			var nb  = originBeat + beatOff.(rel);
			var placedNb = place.(nb);
			c[\timestamp] = placedNb - wallBase;
			e[\sustain] !? { |sus|
				c[\sustain] = place.(originBeat + beatOff.(rel + sus)) - placedNb
			};
			c
		};
		wPlayer = MIDIItemPlayer(warped, player.source);
		wPlayer.start = 0; // timestamps are already wall-relative to wallBase
		wPlayer.play(ev[\mk] ? MicroKeys(\default), sched: { |t, func|
			out.add((time: wallBase + t, send: func, label: \mi2))
		});
		^out
	}

	// §10c: dispatch the prepared sends from ONE Routine walking the sorted schedule.
	// (One schedAbs per entry overflows SystemClock's fixed-size global queue on dense
	// \mi2 takes — "scheduler queue is full" — and dropped everything after it.) Each
	// send runs `latency` early and self-bundles at +latency (event latency /
	// makeBundle), landing at item.time; sends are lightweight by construction (all
	// heavy work happened in prepare), so same-time sends running back-to-back can't
	// stall the logical clock the way the old playFrom actions did. The generation
	// bump cancels any previous playback of this list; stop cancels this one (the
	// routine breaks at its next wake).
	fire { |sched|
		var lat = Server.default.latency ? 0.2;
		var gen, sorted;
		sorted = sched.asArray.sort { |a, b| (a[\time] ? 0) < (b[\time] ? 0) };
		prPlayGen = prPlayGen + 1;
		gen = prPlayGen;
		Routine {
			var t = thisThread.seconds;
			block { |break|
				sorted.do { |item|
					var due = (item[\time] ? 0) - lat;
					(due - t).max(0).wait;
					t = t.max(due);
					(gen != prPlayGen).if { break.value };
					item[\send].value;
				}
			}
		}.play(SystemClock);
	}

	// Cancel anything scheduled by fire (pending sends check the generation first).
	stop { prPlayGen = prPlayGen + 1 }

	clear {
		events = List[];
		preview = nil;
		this.tempoMap = nil;   // through the setter: also drops the beat->wall cache
		beatDur = nil;
	}

	clearContext { context = List[] }

	size { ^events.size }

	do { |func| events.do(func) }

	at { |index| ^events[index] }
}

// Sugar: \bass.add(0, freq: 999, ...) → EventList.current.add tagged with name: \bass.
// Mirrors EventList *add's three branches (scalar/Array/Event when) since SC has no
// way to splat kwargs through to another method.
+ Symbol {
	add { |...args, kwargs|
		var when = args[0];
		var list = EventList.current;
		args[1].isKindOf(Pattern).if { ^list.addPattern(when ? 0, args[1], eventName: this) };
		kwargs = kwargs ++ [\name, this];
		when.isKindOf(Event).if {
			when[\name] = this;
			^list.add(when)
		};
		when.isKindOf(Array).if {
			var whens = when;
			var n = whens.size;
			var base = (when: whens) ++ kwargs.asEvent;
			var previewOffsets = list.nextPreviewOffset(whens);
			^n.collect { |i|
				var ev = list.getSlice(base, i, n);
				list.dispatch(ev, { |e| list.storeAndPreview(e, previewOffsets[i]) });
				ev
			}
		};
		^list.add((when: when ? 0) ++ kwargs.asEvent)
	}

	addPattern { |when=0, pattern, maxEvents, maxWhen=300|
		^EventList.current.addPattern(when, pattern, maxEvents, maxWhen, this)
	}
}
