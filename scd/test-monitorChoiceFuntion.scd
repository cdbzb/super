(
Trek.load(2);
Stills.current.monitors = Stills.current.monitors.add(Display.at(1).bounds);
Part.current = Song.wideShot00_0;
Stills.monitorChoiceFunction_({2.rand})
)

Stills.monitorChoiceFunction_({|still| still.markerName.contains("argon").if{2}{1}})
