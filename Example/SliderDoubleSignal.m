% close all figure
close all

viewer = EEGViewer('Example/testdata.edf');

viewer.FIRfiltering(1, 30);
viewer.SetMinDrop(30);
viewer.SetMaxRange(40);

viewer.SliderDoublePlot(1, 2, 10) % Data range is 10 sec