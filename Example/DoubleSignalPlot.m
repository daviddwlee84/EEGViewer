% close all figure
close all

viewer = EEGViewer('Example/testdata.edf');


viewer.FIRfiltering(1, 30);

viewer.AverageReReference();

%viewer.ScrollView(); % After ReReference

%viewer.SetMinDrop(30);
%viewer.SetMaxRange(50);

viewer.PlotDoubleSignal(1, 2);
viewer.PlotDoubleSignal(3, 6);
viewer.PlotDoubleSignal(4, 5);
viewer.PlotDoubleSignal(7, 8);

% show all signal
% for i = 1:2:viewer.numchannels
%     viewer.PlotDoubleSignal(i, i+1);
% end