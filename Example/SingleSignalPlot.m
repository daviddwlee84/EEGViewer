[data, header] = read_edf('Example/testdata.edf');

viewer = EEGViewer(data, header);

viewer.FIRfiltering(1, 30);

viewer.PlotSingleSignal(3);
viewer.PlotSingleSignalReuse(3);