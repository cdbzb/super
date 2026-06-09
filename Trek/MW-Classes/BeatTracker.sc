MIDIBeatTracker {
	// Beat tracking over noteOn events via dynamic programming (Ellis-style):
	// choose the sequence of onsets that maximizes summed salience minus
	// penalties for tempo change and skipped beats. Globally optimal, unlike
	// the greedy last-pair extrapolation in AbstractMidiEvents.gui.
	//
	// notes:       Array of note Events (timestamp, amp, sustain, midinote)
	// periodPrior: seconds per beat to start from (e.g. from two hand-picked notes)
	// anchorIndex: index into notes of the last hand-picked beat; tracking runs forward from it
	// pins:        note indices forced to be beats; the DP runs segment-wise between them
	//
	// track returns Array of (time:, noteIndex:) — noteIndex is nil for ghost
	// beats interpolated across spans where no onset was chosen.
	var <>notes, <>periodPrior, <>anchorIndex, <>pins;
	var <>salienceFunc;       // { |note, i, clusterSize| salience } — override to taste
	var <>maxSpan = 4;        // one transition may cover up to this many beats
	var <>tempoWeight = 4;    // penalty: tempoWeight * (log2 period ratio).squared
	var <>skipPenalty = 0.7;  // per ghost beat
	var <>maxLog2Dev = 0.6;   // gate: implied period within 2**(±this) of the running period
	var saliences;

	*new { |notes, periodPrior, anchorIndex = 0, pins|
		^super.newCopyArgs(notes.asArray, periodPrior, anchorIndex, pins ? [])
	}

	saliences {
		saliences.isNil.if { this.prCalcSaliences };
		^saliences
	}

	prCalcSaliences {
		var func = salienceFunc ?? {{ |note, i, clusterSize|
			(note[\amp] ? 0.5)                                // louder
			+ (0.15 * (clusterSize - 1).min(3))               // chords
			+ ((note[\sustain] ? 0).clip(0, 1) * 0.3)         // longer
			+ (((note[\midinote] ? 60) < 52).if { 0.2 }{ 0 }) // bass register
		}};
		saliences = notes.collect{ |n, i|
			var cluster = notes.count{ |m| (m[\timestamp] - n[\timestamp]).abs < 0.03 };
			func.(n, i, cluster)
		}
	}

	track {
		var beats = [], period = periodPrior, prev = anchorIndex;
		var anchorT, waypoints, seg;
		this.saliences;
		anchorT = notes[anchorIndex][\timestamp];
		waypoints = pins.asArray
		.select{ |i| notes[i][\timestamp] > anchorT }
		.sort{ |a, b| notes[a][\timestamp] < notes[b][\timestamp] };
		(waypoints ++ [nil]).do{ |w| // nil = final open-ended segment
			seg = this.prTrackSegment(prev, period, w);
			beats = beats ++ seg[\beats];
			period = seg[\period];
			w.notNil.if { prev = w };
		};
		^beats
	}

	prTrackSegment { |fromIdx, period0, toIdx|
		// best beat path from notes[fromIdx] (exclusive) to notes[toIdx] (forced),
		// or to the best free endpoint when toIdx is nil
		var t0 = notes[fromIdx][\timestamp];
		var tEnd = toIdx.notNil.if { notes[toIdx][\timestamp] }{ inf };
		var cands = (0..notes.size - 1).select{ |i|
			(notes[i][\timestamp] > t0) and: { notes[i][\timestamp] <= tEnd }
		};
		var nc = cands.size;
		var times, score, per, back, span;
		var endPos, chain, pos, walkT, beats = [];
		(nc == 0).if { ^(beats: [], period: period0) };
		times = cands.collect{ |i| notes[i][\timestamp] };
		score = Array.newClear(nc);
		per   = Array.newClear(nc);
		back  = Array.newClear(nc); // -1 = the segment start node
		span  = Array.newClear(nc);

		nc.do{ |j|
			var tj = times[j];
			var best, bestPer, bestBack, bestSpan;
			var consider = { |prevScore, prevPer, prevT, backIdx|
				maxSpan.do{ |kk|
					var k = kk + 1;
					var implied = (tj - prevT) / k;
					(implied > 1e-6).if {
						var dev = (implied / prevPer).log2;
						(dev.abs <= maxLog2Dev).if {
							var sc = prevScore + saliences[cands[j]]
							- (tempoWeight * dev.squared)
							- (skipPenalty * (k - 1));
							(best.isNil or: { sc > best }).if {
								best = sc; bestPer = implied;
								bestBack = backIdx; bestSpan = k;
							}
						}
					}
				}
			};
			consider.(0, period0, t0, -1);
			block { |brk|
				(j - 1).forBy(0, -1) { |i|
					// predecessors further back than any allowed span can't connect
					((tj - times[i]) > (maxSpan * period0 * 8)).if { brk.() };
					score[i].notNil.if { consider.(score[i], per[i], times[i], i) }
				}
			};
			best.notNil.if {
				score[j] = best; per[j] = bestPer;
				back[j] = bestBack; span[j] = bestSpan;
			}
		};

		toIdx.notNil.if {
			endPos = cands.indexOf(toIdx);
			endPos.isNil.if { ^(beats: [], period: period0) };
			score[endPos].isNil.if {
				// pin unreachable under the tempo gate: connect it directly
				var k = ((times[endPos] - t0) / period0).round.max(1).asInteger;
				score[endPos] = 0;
				per[endPos] = (times[endPos] - t0) / k;
				back[endPos] = -1;
				span[endPos] = k;
			}
		}{
			score.do{ |sc, j|
				sc.notNil.if {
					(endPos.isNil or: { sc > score[endPos] }).if { endPos = j }
				}
			};
			endPos.isNil.if { ^(beats: [], period: period0) };
		};

		chain = [];
		pos = endPos;
		while { pos != -1 } {
			chain = chain.add(pos);
			pos = back[pos];
		};
		chain = chain.reverse;
		walkT = t0;
		chain.do{ |p|
			var k = span[p], t = times[p];
			(k - 1).do{ |m|
				beats = beats.add((time: walkT + ((t - walkT) * (m + 1) / k), noteIndex: nil))
			};
			beats = beats.add((time: t, noteIndex: cands[p]));
			walkT = t;
		};
		^(beats: beats, period: per[endPos])
	}
}
