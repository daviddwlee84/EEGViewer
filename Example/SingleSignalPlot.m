[data, header] = read_edf('Example/testdata.edf');

viewer = EEGViewer(data, header);

viewer.PlotSingleSignal(3);
viewer.PlotSingleSignalReuse(3);