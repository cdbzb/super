import("stdfaust.lib");

// Cutoff frequency argument
freq=vslider("cutoff",500,20.0,20000,1);

amp= _ , vslider("amp",0.1,0,1,0.0001):*;

// Perform process on input sound
process= _: ve.wah4(freq) :amp: _;
