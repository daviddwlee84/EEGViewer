% close all figure
close all

viewer = EEGViewer('Example/testdata.edf');

viewer.FIRfiltering(1, 30);
viewer.AverageReReference();

viewer.AnimatedDoubleSignal(3, 4)