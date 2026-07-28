#!/usr/bin/env swift
//
// audio-latency.swift — report the CoreAudio output and input latency legs separately.
//
// AudioItem.measureRoundTrip can only ever measure L_out + L_in: a ping that leaves the
// DAC and returns through the ADC traverses both legs, so any in-the-box measurement
// yields the sum. Audio capture only needs that sum (a performer's voice reaches the file
// L_in late, and they were referencing monitoring that was L_out late — the two add to the
// round trip). MIDI capture needs the OUTPUT leg ALONE, because the press itself has no
// input latency: the performer aimed at what reached their ears, which is L_out beyond
// the server sound domain that EventList's play epoch is expressed in.
//
// The split is not observable from inside the box, so ask the OS. Per direction:
//   device latency + safety offset + buffer frame size + stream latency
//
// Usage:
//   bin/audio-latency.swift                     # default output + input devices
//   bin/audio-latency.swift --list              # every device, with stream counts
//   bin/audio-latency.swift --device Fireface   # pick by name substring (both directions)
//   bin/audio-latency.swift --roundtrip 0.047291666666667   # cross-check against loopback
//
import Foundation
import CoreAudio

func addr(_ selector: AudioObjectPropertySelector,
          _ scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal)
-> AudioObjectPropertyAddress {
	AudioObjectPropertyAddress(mSelector: selector, mScope: scope,
	                           mElement: kAudioObjectPropertyElementMain)
}

func value<T>(_ obj: AudioObjectID, _ address: AudioObjectPropertyAddress, _ fallback: T) -> T? {
	var address = address
	var size = UInt32(MemoryLayout<T>.size)
	var out = fallback
	let err = withUnsafeMutablePointer(to: &out) {
		AudioObjectGetPropertyData(obj, &address, 0, nil, &size, $0)
	}
	return err == noErr ? out : nil
}

func list<T>(_ obj: AudioObjectID, _ address: AudioObjectPropertyAddress, _ zero: T) -> [T] {
	var address = address
	var size: UInt32 = 0
	guard AudioObjectGetPropertyDataSize(obj, &address, 0, nil, &size) == noErr, size > 0
	else { return [] }
	var out = [T](repeating: zero, count: Int(size) / MemoryLayout<T>.size)
	let err = out.withUnsafeMutableBytes {
		AudioObjectGetPropertyData(obj, &address, 0, nil, &size, $0.baseAddress!)
	}
	return err == noErr ? out : []
}

func deviceName(_ dev: AudioObjectID) -> String {
	var address = addr(kAudioObjectPropertyName)
	var size = UInt32(MemoryLayout<CFString?>.size)
	var cf: CFString? = nil
	let err = withUnsafeMutablePointer(to: &cf) {
		AudioObjectGetPropertyData(dev, &address, 0, nil, &size, $0)
	}
	return (err == noErr ? cf as String? : nil) ?? "<unnamed>"
}

func sampleRate(_ dev: AudioObjectID) -> Double {
	value(dev, addr(kAudioDevicePropertyNominalSampleRate), Double(0)) ?? 0
}

func streamCount(_ dev: AudioObjectID, _ scope: AudioObjectPropertyScope) -> Int {
	list(dev, addr(kAudioDevicePropertyStreams, scope), AudioStreamID(0)).count
}

struct Leg {
	let label: String
	let device: AudioObjectID
	let deviceLatency: UInt32
	let safetyOffset: UInt32
	let bufferFrames: UInt32
	let streamLatency: UInt32
	// The four terms the driver stacks up in one direction. Buffer frames counts once
	// per direction: each leg waits a full period before its samples move.
	var frames: UInt32 { deviceLatency + safetyOffset + bufferFrames + streamLatency }
}

func measure(_ dev: AudioObjectID, scope: AudioObjectPropertyScope, label: String) -> Leg {
	let streams = list(dev, addr(kAudioDevicePropertyStreams, scope), AudioStreamID(0))
	return Leg(
		label: label,
		device: dev,
		deviceLatency: value(dev, addr(kAudioDevicePropertyLatency, scope), UInt32(0)) ?? 0,
		safetyOffset: value(dev, addr(kAudioDevicePropertySafetyOffset, scope), UInt32(0)) ?? 0,
		bufferFrames: value(dev, addr(kAudioDevicePropertyBufferFrameSize, scope), UInt32(0)) ?? 0,
		streamLatency: streams.first.flatMap {
			value($0, addr(kAudioStreamPropertyLatency), UInt32(0))
		} ?? 0)
}

func allDevices() -> [AudioObjectID] {
	list(AudioObjectID(kAudioObjectSystemObject),
	     addr(kAudioHardwarePropertyDevices), AudioObjectID(0))
}

func defaultDevice(_ selector: AudioObjectPropertySelector) -> AudioObjectID? {
	value(AudioObjectID(kAudioObjectSystemObject), addr(selector), AudioObjectID(0))
}

func ms(_ frames: UInt32, _ rate: Double) -> String {
	rate > 0 ? String(format: "%.3f ms", Double(frames) / rate * 1000) : "?"
}

// printf %s/%@ take C strings and NSObjects, not Swift Strings — pad by hand instead.
func pad(_ s: String, _ width: Int) -> String {
	s.count >= width ? s : s + String(repeating: " ", count: width - s.count)
}

func rpad(_ n: UInt32, _ width: Int) -> String {
	let s = String(n)
	return s.count >= width ? s : String(repeating: " ", count: width - s.count) + s
}

func report(_ leg: Leg, _ rate: Double) {
	print("\(leg.label)  \(deviceName(leg.device))  @ \(Int(rate)) Hz")
	print("  device latency   \(rpad(leg.deviceLatency, 6)) frames")
	print("  safety offset    \(rpad(leg.safetyOffset, 6))")
	print("  buffer frames    \(rpad(leg.bufferFrames, 6))")
	print("  stream latency   \(rpad(leg.streamLatency, 6))")
	print("  TOTAL            \(rpad(leg.frames, 6)) frames   \(ms(leg.frames, rate))")
	print("")
}

// ---- args ----------------------------------------------------------------
var args = Array(CommandLine.arguments.dropFirst())
var wantList = false
var deviceMatch: String? = nil
var roundTrip: Double? = nil
while let arg = args.first {
	args.removeFirst()
	switch arg {
	case "--list": wantList = true
	case "--device": deviceMatch = args.first; if !args.isEmpty { args.removeFirst() }
	case "--roundtrip": roundTrip = args.first.flatMap(Double.init)
		if !args.isEmpty { args.removeFirst() }
	default:
		FileHandle.standardError.write("unknown argument: \(arg)\n".data(using: .utf8)!)
		exit(2)
	}
}

if wantList {
	for dev in allDevices() {
		let out = streamCount(dev, kAudioObjectPropertyScopeOutput)
		let inp = streamCount(dev, kAudioObjectPropertyScopeInput)
		print("\(pad(deviceName(dev), 44))  out streams: \(out)  in streams: \(inp)"
			+ "  @ \(Int(sampleRate(dev))) Hz")
	}
	exit(0)
}

// ---- pick devices --------------------------------------------------------
var outputDevice: AudioObjectID?
var inputDevice: AudioObjectID?

if let match = deviceMatch {
	let hits = allDevices().filter {
		deviceName($0).localizedCaseInsensitiveContains(match)
	}
	guard !hits.isEmpty else {
		FileHandle.standardError.write("no device matching \"\(match)\"\n".data(using: .utf8)!)
		exit(1)
	}
	outputDevice = hits.first { streamCount($0, kAudioObjectPropertyScopeOutput) > 0 }
	inputDevice = hits.first { streamCount($0, kAudioObjectPropertyScopeInput) > 0 }
} else {
	outputDevice = defaultDevice(kAudioHardwarePropertyDefaultOutputDevice)
	inputDevice = defaultDevice(kAudioHardwarePropertyDefaultInputDevice)
}

guard let outDev = outputDevice, let inDev = inputDevice else {
	FileHandle.standardError.write("could not resolve both an input and an output device\n"
		.data(using: .utf8)!)
	exit(1)
}

let outLeg = measure(outDev, scope: kAudioObjectPropertyScopeOutput, label: "OUTPUT")
let inLeg = measure(inDev, scope: kAudioObjectPropertyScopeInput, label: "INPUT ")
let rate = sampleRate(outDev)

report(outLeg, rate)
report(inLeg, sampleRate(inDev))

let sum = outLeg.frames + inLeg.frames
let share = sum > 0 ? Double(outLeg.frames) / Double(sum) : 0
print("L_out + L_in     \(rpad(sum, 6)) frames   \(ms(sum, rate))")
print("L_out share      " + String(format: "%.3f", share)
	+ "   (0.500 means the legs are symmetric, so rt/2 is sound)")
print("")

// The OS figures are authoritative for the RATIO but routinely understate the
// MAGNITUDE: drivers omit outboard converter delay (anything past ADAT/USB is
// invisible to CoreAudio) and often one period per direction. So take the split
// from the OS and the total from the loopback, which measures the real path.
if let rt = roundTrip, rate > 0 {
	let measured = UInt32((rt * rate).rounded())
	let residual = Int(measured) - Int(sum)
	print("loopback round trip        \(rpad(measured, 6)) frames   "
		+ String(format: "%.3f ms", rt * 1000))
	print("reported sum               \(rpad(sum, 6)) frames")
	print("residual (loopback - OS)   \(rpad(UInt32(abs(residual)), 6)) frames"
		+ "\(residual < 0 ? "  (NEGATIVE)" : "")   \(ms(UInt32(abs(residual)), rate))")
	if residual < 0 {
		print("  NEGATIVE: the OS claims more latency than the loopback measured.")
		print("  One of the two figures is wrong — do not derive a constant from this.")
	} else if Double(residual) > Double(sum) * 0.25 {
		print("  Large residual: the driver is not reporting the whole path (outboard")
		print("  converters, or an extra period per direction). Trust the OS for the")
		print("  SPLIT, the loopback for the TOTAL.")
	} else {
		print("  Small residual: the driver accounts for essentially the whole path.")
	}
	let outSeconds = rt * share
	print("")
	print("MIDI capture needs the OUTPUT leg only. Scaling the measured round trip")
	print("by the OS-reported split:")
	print("  AudioItem.outputLatency = " + String(format: "%.15f", outSeconds)
		+ ";   // " + String(format: "%.3f ms", outSeconds * 1000))
} else {
	print("MIDI capture needs the OUTPUT leg only. From the OS alone:")
	print("  AudioItem.outputLatency = "
		+ String(format: "%.15f", rate > 0 ? Double(outLeg.frames) / rate : 0)
		+ ";   // \(ms(outLeg.frames, rate))")
	print("  Re-run with --roundtrip <seconds> to scale this by a real loopback")
	print("  measurement — drivers commonly understate the true path.")
}
