viewer = EEGViewer('Example/testdata.edf');
viewer.FIRfiltering(1, 60);
% FFT raw data
viewer.SaveCSV('testdata_fft') % will auto append .csv extension
% Statistics     ('filename', LRChannel:[left channel; right channel])
% (Will generate two output file: filename_stat, filename_gfp)
viewer.Statistics('testdata', [1, 2, 3, 4; 5, 6, 7, 8]) % don't assign GFPLRChannel => use LRChannel
% Show top-N differential timing
viewer.DifferentialTopN(10)

viewer = EEGViewer('Example/OpenBCI_testdata.txt');
viewer.FIRfiltering(1, 60);
viewer.SetChannelLocationName('F3', 'F4', 'C3', 'C4', 'O1', 'O2', 'TP9', 'TP10')
% FFT raw data
viewer.SaveCSV('OpenBCI_testdata_fft') % will auto append .csv extension
% Statistics     ('filename', LRChannel:[left channel; right channel], GFPLRChannel:[left channel; right channel])
% (Will generate two output file: filename_stat, filename_gfp)
viewer.Statistics('OpenBCI_testdata', [1, 3, 5, 7; 2, 4, 6, 8], [1, 3, 5; 2, 4, 6]) % assign GFPLRChannel
% Show top-N differential timing
viewer.DifferentialTopN(10)