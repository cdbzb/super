-- count_tempo_markers = reaper.CountTempoTimeSigMarkers(0)
--reaper.Main_OnCommand(40182,0); --select all items
--reaper.Main_OnCommand(42375,0); --set items to autostretch
for i = 0, #durs - 1 do


	retval, pos, measure_pos, beat_pos, bpm, timesig_num, timesig_denom, lineartempoOut = reaper.GetTempoTimeSigMarker(0, i)

	reaper.SetTempoTimeSigMarker(0,--ReaProject proj, 
	-1,--integer ptidx, 
	-1, --number timepos, 
	measure_pos,--measures, --integer measurepos, 
	beat_pos,--obj[i].beat, --number beatpos, 
	60/durs[i+1],
	0,--integer timesig_num, 
	0,--integer timesig_denom, 
	false) --boolean lineartempo)]] 
end

reaper.UpdateTimeline()
--reaper.Main_OnCommand(42375,0)
