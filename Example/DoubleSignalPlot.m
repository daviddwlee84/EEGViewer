[data, header] = read_edf('Example/testdata.edf');

viewer = EEGViewer(data, header);

viewer.FIRfiltering(1, 30);

% same signal
viewer.PlotDoubleSignal(3, 3);

% show all signal
for i = 1:2:header.numchannels
    viewer.PlotDoubleSignal(i, i+1);
end