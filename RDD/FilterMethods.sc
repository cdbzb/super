+ UGen {
  allpassC {
    arg maxdelaytime = 0.2, delaytime = 0.2, decaytime = 1.0;
    ^AllpassC.multiNew(this.rate, this, maxdelaytime, delaytime, decaytime)
  }
  allpassL {
    arg maxdelaytime = 0.2, delaytime = 0.2, decaytime = 1.0;
    ^AllpassL.multiNew(this.rate, this, maxdelaytime, delaytime, decaytime)
  }
  allpassN {
    arg maxdelaytime = 0.2, delaytime = 0.2, decaytime = 1.0;
    ^AllpassN.multiNew(this.rate, this, maxdelaytime, delaytime, decaytime)
  }
  bBandPass {
    arg freq = 1200.0, bw = 1.0;
    ^BBandPass.multiNew(this.rate, this, freq, bw)
  }
  bBandStop {
    arg freq = 1200.0, bw = 1.0;
    ^BBandStop.multiNew(this.rate, this, freq, bw)
  }
  bLowPass {
    arg freq = 1200.0, rq = 1.0;
    ^BLowPass.multiNew(this.rate, this, freq, rq)
  }
  bpf {
    arg freq = 440.0, rq = 1.0;
    ^BPF.multiNew(this.rate, this, freq, rq)
  }
  bpz2 {
    ^BPZ2.multiNew(this.rate, this)
  }
  brf {
    arg freq = 440.0, rq = 1.0;
    ^BRF.multiNew(this.rate, this, freq, rq)
  }
  bufWr {
    arg bufnum = 0.0, phase = 0.0, loop = 1.0;
    "sc_filter_method: reordering not implemented: [3,0,1,2] ".error;
    ^BufWr.multiNew(this.rate, bufnum, phase, loop, this)
  }
  combC {
    arg maxdelaytime = 0.2, delaytime = 0.2, decaytime = 1.0;
    ^CombC.multiNew(this.rate, this, maxdelaytime, delaytime, decaytime)
  }
  combL {
    arg maxdelaytime = 0.2, delaytime = 0.2, decaytime = 1.0;
    ^CombL.multiNew(this.rate, this, maxdelaytime, delaytime, decaytime)
  }
  combN {
    arg maxdelaytime = 0.2, delaytime = 0.2, decaytime = 1.0;
    ^CombN.multiNew(this.rate, this, maxdelaytime, delaytime, decaytime)
  }
  decay {
    arg decayTime = 1.0;
    ^Decay.multiNew(this.rate, this, decayTime)
  }
  decay2 {
    arg attackTime = 1.0e-2, decayTime = 1.0;
    ^Decay2.multiNew(this.rate, this, attackTime, decayTime)
  }
  delayN {
    arg maxdelaytime = 0.2, delaytime = 0.2;
    ^DelayN.multiNew(this.rate, this, maxdelaytime, delaytime)
  }
  //demand {
   // arg reset = 0.0, demandUGens = 0.0;
    //^Demand.multiNew(this.rate, this, reset, demandUGens)
  //}
  detectSilence {
    arg amp = 1.0e-4, time = 0.1, doneAction = 0.0;
    ^DetectSilence.multiNew(this.rate, this, amp, time, doneAction)
  }
  freeVerb {
    arg mix = 0.33, room = 0.5, damp = 0.5;
    ^FreeVerb.multiNew(this.rate, this, mix, room, damp)
  }
  freeVerb2 {
    arg in2 = 0.0, mix = 0.33, room = 0.5, damp = 0.5;
    ^FreeVerb2.multiNew(this.rate, this, in2, mix, room, damp)
  }
  gVerb {
    arg roomsize = 10.0, revtime = 3.0, damping = 0.5, inputbw = 0.5, spread = 15.0, drylevel = 1.0, earlyreflevel = 0.7, taillevel = 0.5, maxroomsize = 300.0;
    ^GVerb.multiNew(this.rate, this, roomsize, revtime, damping, inputbw, spread, drylevel, earlyreflevel, taillevel, maxroomsize)
  }
  hasher {
    ^Hasher.multiNew(this.rate, this)
  }
  hpf {
    arg freq = 440.0;
    ^HPF.multiNew(this.rate, this, freq)
  }
  hpz1 {
    ^HPZ1.multiNew(this.rate, this)
  }
  inRange {
    arg lo = 0.0, hi = 1.0;
    ^InRange.multiNew(this.rate, this, lo, hi)
  }
  klank {
    arg freqscale = 1.0, freqoffset = 0.0, decayscale = 1.0, specificationsArrayRef = 0.0;
    "sc_filter_method: reordering not implemented: [4,0,1,2,3] ".error;
    ^Klank.multiNew(this.rate, this, freqscale, freqoffset, decayscale, specificationsArrayRef)
  }
  lpf {
    arg freq = 440.0;
    ^LPF.multiNew(this.rate, this, freq)
  }
  lagUD {
    arg lagTimeU = 0.1, lagTimeD = 0.1;
    ^LagUD.multiNew(this.rate, this, lagTimeU, lagTimeD)
  }
  lag3UD {
    arg lagTimeU = 0.1, lagTimeD = 0.1;
    ^Lag3UD.multiNew(this.rate, this, lagTimeU, lagTimeD)
  }
  leakDC {
    arg coef = 0.995;
    ^LeakDC.multiNew(this.rate, this, coef)
  }
  limiter {
    arg level = 1.0, dur = 1.0e-2;
    ^Limiter.multiNew(this.rate, this, level, dur)
  }
  linExp {
    arg srclo = 0.0, srchi = 1.0, dstlo = 1.0, dsthi = 2.0;
    ^LinExp.multiNew(this.rate, this, srclo, srchi, dstlo, dsthi)
  }
  linPan2 {
    arg pos = 0.0, level = 1.0;
    ^LinPan2.multiNew(this.rate, this, pos, level)
  }
  localOut {
    ^LocalOut.multiNew(this.rate, this)
  }
  mantissaMask {
    arg bits = 3.0;
    ^MantissaMask.multiNew(this.rate, this, bits)
  }
  modDif {
    arg y = 0.0, mod = 1.0;
    ^ModDif.multiNew(this.rate, this, y, mod)
  }
  moogFF {
    arg freq = 100.0, gain = 2.0, reset = 0.0;
    ^MoogFF.multiNew(this.rate, this, freq, gain, reset)
  }
  moogLadder {
    arg ffreq = 440.0, res = 0.0;
    ^MoogLadder.multiNew(this.rate, this, ffreq, res)
  }
  normalizer {
    arg level = 1.0, dur = 1.0e-2;
    ^Normalizer.multiNew(this.rate, this, level, dur)
  }
  onePole {
    arg coef = 0.5;
    ^OnePole.multiNew(this.rate, this, coef)
  }
  out {
    arg bus = 0.0;
    ^Out.multiNew(this.rate, bus, this)
  }
  pan2 {
    arg pos = 0.0, level = 1.0;
    ^Pan2.multiNew(this.rate, this, pos, level)
  }
  pitchShift {
    arg windowSize = 0.2, pitchRatio = 1.0, pitchDispersion = 0.0, timeDispersion = 0.0;
    ^PitchShift.multiNew(this.rate, this, windowSize, pitchRatio, pitchDispersion, timeDispersion)
  }
  pluck {
    arg trig = 1.0, maxdelaytime = 0.2, delaytime = 0.2, decaytime = 1.0, coef = 0.5;
    ^Pluck.multiNew(this.rate, this, trig, maxdelaytime, delaytime, decaytime, coef)
  }
  pulseCount {
    arg reset = 0.0;
    ^PulseCount.multiNew(this.rate, this, reset)
  }
  pulseDivider {
    arg div = 2.0, start = 0.0;
    ^PulseDivider.multiNew(this.rate, this, div, start)
  }
  rhpf {
    arg freq = 440.0, rq = 1.0;
    ^RHPF.multiNew(this.rate, this, freq, rq)
  }
  rlpf {
    arg freq = 440.0, rq = 1.0;
    ^RLPF.multiNew(this.rate, this, freq, rq)
  }
  resonz {
    arg freq = 440.0, bwr = 1.0;
    ^Resonz.multiNew(this.rate, this, freq, bwr)
  }
  ringz {
    arg freq = 440.0, decaytime = 1.0;
    ^Ringz.multiNew(this.rate, this, freq, decaytime)
  }
  runningMax {
    arg trig = 0.0;
    ^RunningMax.multiNew(this.rate, this, trig)
  }
  rtScramble {
    arg inputs = 0.0;
    ^RTScramble.multiNew(this.rate, this, inputs)
  }
  slope {
    ^Slope.multiNew(this.rate, this)
  }
  stepper {
    arg reset = 0.0, min = 0.0, max = 7.0, step = 1.0, resetval = 0.0;
    ^Stepper.multiNew(this.rate, this, reset, min, max, step, resetval)
  }
  sweep {
    arg rate = 1.0;
    ^Sweep.multiNew(this.rate, this, rate)
  }
  tExpRand {
    arg lo = 1.0e-2, hi = 1.0;
    ^TExpRand.multiNew(this.rate, lo, hi, this)
  }
  timer {
    ^Timer.multiNew(this.rate, this)
  }
  tiRand {
    arg lo = 0.0, hi = 127.0;
    ^TIRand.multiNew(this.rate, lo, hi, this)
  }
  toggleFF {
    ^ToggleFF.multiNew(this.rate, this)
  }
  tRand {
    arg lo = 0.0, hi = 1.0;
    ^TRand.multiNew(this.rate, lo, hi, this)
  }
  trig {
    arg dur = 0.1;
    ^Trig.multiNew(this.rate, this, dur)
  }
  trig1 {
    arg dur = 0.1;
    ^Trig1.multiNew(this.rate, this, dur)
  }

}
+ Array {
  allpassC {
    arg maxdelaytime = 0.2, delaytime = 0.2, decaytime = 1.0;
    ^AllpassC.multiNew(this.rate, this, maxdelaytime, delaytime, decaytime)
  }
  allpassL {
    arg maxdelaytime = 0.2, delaytime = 0.2, decaytime = 1.0;
    ^AllpassL.multiNew(this.rate, this, maxdelaytime, delaytime, decaytime)
  }
  allpassN {
    arg maxdelaytime = 0.2, delaytime = 0.2, decaytime = 1.0;
    ^AllpassN.multiNew(this.rate, this, maxdelaytime, delaytime, decaytime)
  }
  bBandPass {
    arg freq = 1200.0, bw = 1.0;
    ^BBandPass.multiNew(this.rate, this, freq, bw)
  }
  bBandStop {
    arg freq = 1200.0, bw = 1.0;
    ^BBandStop.multiNew(this.rate, this, freq, bw)
  }
  bLowPass {
    arg freq = 1200.0, rq = 1.0;
    ^BLowPass.multiNew(this.rate, this, freq, rq)
  }
  bpf {
    arg freq = 440.0, rq = 1.0;
    ^BPF.multiNew(this.rate, this, freq, rq)
  }
  bpz2 {
    ^BPZ2.multiNew(this.rate, this)
  }
  brf {
    arg freq = 440.0, rq = 1.0;
    ^BRF.multiNew(this.rate, this, freq, rq)
  }
  bufWr {
    arg bufnum = 0.0, phase = 0.0, loop = 1.0;
    "sc_filter_method: reordering not implemented: [3,0,1,2] ".error;
    ^BufWr.multiNew(this.rate, bufnum, phase, loop, this)
  }
  combC {
    arg maxdelaytime = 0.2, delaytime = 0.2, decaytime = 1.0;
    ^CombC.multiNew(this.rate, this, maxdelaytime, delaytime, decaytime)
  }
  combL {
    arg maxdelaytime = 0.2, delaytime = 0.2, decaytime = 1.0;
    ^CombL.multiNew(this.rate, this, maxdelaytime, delaytime, decaytime)
  }
  combN {
    arg maxdelaytime = 0.2, delaytime = 0.2, decaytime = 1.0;
    ^CombN.multiNew(this.rate, this, maxdelaytime, delaytime, decaytime)
  }
  decay {
    arg decayTime = 1.0;
    ^Decay.multiNew(this.rate, this, decayTime)
  }
  decay2 {
    arg attackTime = 1.0e-2, decayTime = 1.0;
    ^Decay2.multiNew(this.rate, this, attackTime, decayTime)
  }
  delayN {
    arg maxdelaytime = 0.2, delaytime = 0.2;
    ^DelayN.multiNew(this.rate, this, maxdelaytime, delaytime)
  }
  demand {
    arg reset = 0.0, demandUGens = 0.0;
    ^Demand.multiNew(this.rate, this, reset, demandUGens)
  }
  detectSilence {
    arg amp = 1.0e-4, time = 0.1, doneAction = 0.0;
    ^DetectSilence.multiNew(this.rate, this, amp, time, doneAction)
  }
  freeVerb {
    arg mix = 0.33, room = 0.5, damp = 0.5;
    ^FreeVerb.multiNew(this.rate, this, mix, room, damp)
  }
  freeVerb2 {
    arg in2 = 0.0, mix = 0.33, room = 0.5, damp = 0.5;
    ^FreeVerb2.multiNew(this.rate, this, in2, mix, room, damp)
  }
  gVerb {
    arg roomsize = 10.0, revtime = 3.0, damping = 0.5, inputbw = 0.5, spread = 15.0, drylevel = 1.0, earlyreflevel = 0.7, taillevel = 0.5, maxroomsize = 300.0;
    ^GVerb.multiNew(this.rate, this, roomsize, revtime, damping, inputbw, spread, drylevel, earlyreflevel, taillevel, maxroomsize)
  }
  hasher {
    ^Hasher.multiNew(this.rate, this)
  }
  hpf {
    arg freq = 440.0;
    ^HPF.multiNew(this.rate, this, freq)
  }
  hpz1 {
    ^HPZ1.multiNew(this.rate, this)
  }
  inRange {
    arg lo = 0.0, hi = 1.0;
    ^InRange.multiNew(this.rate, this, lo, hi)
  }
  klank {
    arg freqscale = 1.0, freqoffset = 0.0, decayscale = 1.0, specificationsArrayRef = 0.0;
    "sc_filter_method: reordering not implemented: [4,0,1,2,3] ".error;
    ^Klank.multiNew(this.rate, this, freqscale, freqoffset, decayscale, specificationsArrayRef)
  }
  lpf {
    arg freq = 440.0;
    ^LPF.multiNew(this.rate, this, freq)
  }
  lagUD {
    arg lagTimeU = 0.1, lagTimeD = 0.1;
    ^LagUD.multiNew(this.rate, this, lagTimeU, lagTimeD)
  }
  lag3UD {
    arg lagTimeU = 0.1, lagTimeD = 0.1;
    ^Lag3UD.multiNew(this.rate, this, lagTimeU, lagTimeD)
  }
  leakDC {
    arg coef = 0.995;
    ^LeakDC.multiNew(this.rate, this, coef)
  }
  limiter {
    arg level = 1.0, dur = 1.0e-2;
    ^Limiter.multiNew(this.rate, this, level, dur)
  }
  linExp {
    arg srclo = 0.0, srchi = 1.0, dstlo = 1.0, dsthi = 2.0;
    ^LinExp.multiNew(this.rate, this, srclo, srchi, dstlo, dsthi)
  }
  linPan2 {
    arg pos = 0.0, level = 1.0;
    ^LinPan2.multiNew(this.rate, this, pos, level)
  }
  localOut {
    ^LocalOut.multiNew(this.rate, this)
  }
  mantissaMask {
    arg bits = 3.0;
    ^MantissaMask.multiNew(this.rate, this, bits)
  }
  modDif {
    arg y = 0.0, mod = 1.0;
    ^ModDif.multiNew(this.rate, this, y, mod)
  }
  moogFF {
    arg freq = 100.0, gain = 2.0, reset = 0.0;
    ^MoogFF.multiNew(this.rate, this, freq, gain, reset)
  }
  moogLadder {
    arg ffreq = 440.0, res = 0.0;
    ^MoogLadder.multiNew(this.rate, this, ffreq, res)
  }
  normalizer {
    arg level = 1.0, dur = 1.0e-2;
    ^Normalizer.multiNew(this.rate, this, level, dur)
  }
  onePole {
    arg coef = 0.5;
    ^OnePole.multiNew(this.rate, this, coef)
  }
  out {
    arg bus = 0.0;
    ^Out.multiNew(this.rate, bus, this)
  }
  pan2 {
    arg pos = 0.0, level = 1.0;
    ^Pan2.multiNew(this.rate, this, pos, level)
  }
  pitchShift {
    arg windowSize = 0.2, pitchRatio = 1.0, pitchDispersion = 0.0, timeDispersion = 0.0;
    ^PitchShift.multiNew(this.rate, this, windowSize, pitchRatio, pitchDispersion, timeDispersion)
  }
  pluck {
    arg trig = 1.0, maxdelaytime = 0.2, delaytime = 0.2, decaytime = 1.0, coef = 0.5;
    ^Pluck.multiNew(this.rate, this, trig, maxdelaytime, delaytime, decaytime, coef)
  }
  pulseCount {
    arg reset = 0.0;
    ^PulseCount.multiNew(this.rate, this, reset)
  }
  pulseDivider {
    arg div = 2.0, start = 0.0;
    ^PulseDivider.multiNew(this.rate, this, div, start)
  }
  rhpf {
    arg freq = 440.0, rq = 1.0;
    ^RHPF.multiNew(this.rate, this, freq, rq)
  }
  rlpf {
    arg freq = 440.0, rq = 1.0;
    ^RLPF.multiNew(this.rate, this, freq, rq)
  }
  resonz {
    arg freq = 440.0, bwr = 1.0;
    ^Resonz.multiNew(this.rate, this, freq, bwr)
  }
  ringz {
    arg freq = 440.0, decaytime = 1.0;
    ^Ringz.multiNew(this.rate, this, freq, decaytime)
  }
  runningMax {
    arg trig = 0.0;
    ^RunningMax.multiNew(this.rate, this, trig)
  }
  rtScramble {
    arg inputs = 0.0;
    ^RTScramble.multiNew(this.rate, this, inputs)
  }
  slope {
    ^Slope.multiNew(this.rate, this)
  }
  stepper {
    arg reset = 0.0, min = 0.0, max = 7.0, step = 1.0, resetval = 0.0;
    ^Stepper.multiNew(this.rate, this, reset, min, max, step, resetval)
  }
  sweep {
    arg rate = 1.0;
    ^Sweep.multiNew(this.rate, this, rate)
  }
  tExpRand {
    arg lo = 1.0e-2, hi = 1.0;
    ^TExpRand.multiNew(this.rate, lo, hi, this)
  }
  timer {
    ^Timer.multiNew(this.rate, this)
  }
  tiRand {
    arg lo = 0.0, hi = 127.0;
    ^TIRand.multiNew(this.rate, lo, hi, this)
  }
  toggleFF {
    ^ToggleFF.multiNew(this.rate, this)
  }
  tRand {
    arg lo = 0.0, hi = 1.0;
    ^TRand.multiNew(this.rate, lo, hi, this)
  }
  trig {
    arg dur = 0.1;
    ^Trig.multiNew(this.rate, this, dur)
  }
  trig1 {
    arg dur = 0.1;
    ^Trig1.multiNew(this.rate, this, dur)
  }

}
