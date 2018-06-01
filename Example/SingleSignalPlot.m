close all

viewer = EEGViewer('Example/testdata.edf');

viewer.FIRfiltering(1, 30);

viewer.PlotSingleSignal(3);
viewer.PlotSingleSignalReuse(3);