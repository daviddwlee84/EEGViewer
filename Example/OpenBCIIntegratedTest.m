% close all figure
close all

viewer = EEGViewer('Example/OpenBCI_testdata.txt');

% Quick view
viewer.ScrollView()

% Preprocess
viewer.FIRfiltering(1, 30);
viewer.SetMinDrop(20);
viewer.SetMaxRange(40);

% Single Signal
viewer.PlotSingleSignal(1);

% Double Signal
viewer.PlotDoubleSignal(2, 3);

% Animate Double Signal
viewer.SetAnimateMaxLength(0.1); % 6 sec
viewer.AnimatedDoubleSignal(4, 5) % Default 2 time speed

% Slider Double Signal
viewer.SliderDoublePlot(6, 7, 10) % Data range is 10 sec
