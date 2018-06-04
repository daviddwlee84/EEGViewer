% close all figure
close all

viewer = EEGViewer('Example/testdata.edf');

%viewer.ScrollView(); % Before Filtering
viewer.FIRfiltering(1, 30);
%viewer.ScrollView(); % After Filtering

viewer.AverageReReference();
%viewer.ScrollView(); % After ReReference

% same signal
viewer.PlotDoubleSignal(3, 3);

% show all signal
for i = 1:2:viewer.numchannels
    viewer.PlotDoubleSignal(i, i+1);
end