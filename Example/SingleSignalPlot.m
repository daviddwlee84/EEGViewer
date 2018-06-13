close all

viewer = EEGViewer('Example/testdata.edf');

viewer.FIRfiltering(1, 30);

viewer.AverageReReference();
viewer.SetMinDrop(30);
%viewer.SetMaxRange(50);

viewer.PlotSingleSignal(3);