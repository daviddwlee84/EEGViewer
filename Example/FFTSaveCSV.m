viewer = EEGViewer('Example/testdata.edf');
viewer.FIRfiltering(1, 60);
% FFT raw data
viewer.SaveCSV('testdata_fft') % will auto append .csv extension
% Statistics     ('filename', [left channel; right channel])
viewer.Statistics('testdata_stat', [1, 2, 3, 4; 5, 6, 7, 8])

viewer = EEGViewer('Example/OpenBCI_testdata.txt');
viewer.FIRfiltering(1, 60);
viewer.SetChannelLocationName('F3', 'F4', 'C3', 'C4', 'O1', 'O2', 'TP9', 'TP10')
% FFT raw data
viewer.SaveCSV('OpenBCI_testdata_fft') % will auto append .csv extension
% Statistics     ('filename', [left channel; right channel])
viewer.Statistics('OpenBCI_testdata_stat', [1, 3, 5, 7; 2, 4, 6, 8])