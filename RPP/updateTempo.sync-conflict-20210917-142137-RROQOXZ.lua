obj = {130,115,110,30,222,223,224} -- table of tempi

count_tempo_markers = reaper.CountTempoTimeSigMarkers(0)

for i = 0, #obj - 1 do


  retval, pos, measure_pos, beat_pos, bpm, timesig_num, timesig_denom, lineartempoOut = reaper.GetTempoTimeSigMarker(0, i)

  reaper.SetTempoTimeSigMarker(0,--ReaProject proj, 
                                      -1,--integer ptidx, 
                                      pos, --number timepos, 
                                      -1,--measures, --integer measurepos, 
                                      -1,--obj[i].beat, --number beatpos, 
                                      obj[i + 1],
                                      0,--integer timesig_num, 
                                      0,--integer timesig_denom, 
                                      false) --boolean lineartempo)]] 
      end







      reaper.UpdateArrange() -- Update the arrangement (often needed)
   

