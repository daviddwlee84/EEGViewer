% close all figure
close all

viewer = EEGViewer('Example/testdata.edf');

%viewer.FIRfiltering(1, 30);
%viewer.AverageReReference();
viewer.SetMinDrop(30);
viewer.SetMaxRange(40);
viewer.SetAnimateMaxLength(0.1); % 6 sec

channels = [1, 2, 3, 6, 4, 5, 7, 8];
viewer.AnimatedMultipleSignal(channels) % Default 2 time speed
%viewer.AnimatedMultipleSignal(channels, 1) % Play in normal speed (x1)