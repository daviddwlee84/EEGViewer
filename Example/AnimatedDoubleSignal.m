% close all figure
close all

viewer = EEGViewer('Example/testdata.edf');

viewer.FIRfiltering(1, 30);
viewer.AverageReReference();
viewer.SetMinDrop(30);
viewer.SetMaxRange(40);

viewer.AnimatedDoubleSignal(1, 2)