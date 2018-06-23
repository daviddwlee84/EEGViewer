% close all figure
close all

viewer = EEGViewer('Example/testdata.edf');

%viewer.FIRfiltering(1, 30);
%viewer.AverageReReference();
viewer.SetMinDrop(30);
viewer.SetMaxRange(40);
viewer.SetAnimateMaxLength(0.1); % 6 sec

viewer.AnimatedDoubleSignal(1, 2) % Default 2 time speed
%viewer.AnimatedDoubleSignal(1, 2, 1) % Play in normal speed (x1)