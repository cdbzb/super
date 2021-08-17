Ndef.put

(
Ndef(\xer).play;
Ndef(\xer).prime(\default);
Ndef(\xer).send;
Ndef(\xer).put(100,\set -> [degree:Pwhite(-10,10.0)+15.rand].p)	;
Ndef(\xer).put(101,\set -> [pan:Pwhite(-1,1),dur:Pwhite(0.1,1.0)].p)
)
s.reboot
NodeProxy
