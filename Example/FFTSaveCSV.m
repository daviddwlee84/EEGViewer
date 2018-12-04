viewer = EEGViewer('Example/testdata.edf');
viewer.FIRfiltering(1, 30);
viewer.SaveCSV('testdata_fft') % will auto append .csv extension

viewer = EEGViewer('Example/OpenBCI_testdata.txt');
viewer.FIRfiltering(1, 30);
viewer.SetChannelLocationName('F3', 'F4', 'C3', 'C4', 'O1', 'O2', 'TP9', 'TP10')
viewer.SaveCSV('OpenBCI_testdata_fft') % will auto append .csv extension
