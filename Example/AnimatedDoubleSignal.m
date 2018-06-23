% close all figure
close all

viewer = EEGViewer('Example/testdata.edf');

viewer.FIRfiltering(1, 30);
viewer.AverageReReference();
viewer.SetMinDrop(30);
viewer.SetMaxRange(40);

viewer.AnimatedDoubleSignal(1, 2)

%channels = [1, 2, 3, 6, 4, 5, 7, 8];
%viewer.AnimatedMultipleSignal(channels)