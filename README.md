# EEGViewer

Electroencephalography signal analysis and visualization

## Basic Usage

### Simple procedure

1. Input Data

    ```matlab
    viewer = EEGViewer('path/to/your/data.edf');
    ```

    or

    ```matlab
    viewer = EEGViewer();
    viewer.Load('path/to/your/data.edf')
    ```

2. Filtering (Optional)

    ```matlab
    viewer.FIRfiltering(1, 30); % Band-pass FIR filter of 1~30 Hz
    ```

3. Plot

    ```matlab
    viewer.PlotSingleSignal(channel)            % Plot single signal spectrum
    viewer.PlotSingleSignalReuse(channel)       % Plot single signal spectrum (reuse some data to make it more dense)
    viewer.PlotDoubleSignal(channel1, channel2) % Plot two signal spectrum symmetrically
    ```

* Quick view of data

    ```matlab
    viewer.ScrollView()
    ```

## EEG Notes

### Wave Patterns

* Delta: 1~3 Hz
* Theta: 4~7 Hz
* Alpha: 8~13 Hz
* Beta: 14~30 Hz
* Gamma: 30~100 Hz

### Terminology

* EEG - Electroencephalography
* ICA - Independent Component Analysis
* Component
* Epoch
* Event
* FIR Filter - Finite Impulse Response Filter
* ERP - Event-Related Potential

## TODO

- [X] Load data (Other's function)
- [X] Plot single signal
- [X] Plot two signal symmetrically
- [X] Add channel label
- [X] Add FIR Filter (EEGLAB function)
- [X] Add quick data viewer (EEGLAB function)

## Other's function used

* read_edf.m - *.edf data loader

### EEGLAB

* eegfilt.m - FIR Filter
* eegplot.m - Scroll view on raw data
* textsc.m - Places text in screen coordinates
* fastif.m - Fast if

## Related Links

### EEG with Matlab

* [MATLAB Progamming for Medical Signal Analysis](http://www.ym.edu.tw/~cflu/CFLu_course_matlabsig.html)
    * [醫學訊號分析原理與MATLAB程式應用實作](https://www.youtube.com/playlist?list=PLx_IWc-RN82uKOdafF4v4U5R_u4qmYaiu)
        * [EEGLAB處理流程1](https://youtu.be/jAbcW0FKkw0)
        * [EEGLAB處理流程2](https://www.youtube.com/watch?v=z3RBvj1x344)

* [MATLAB Graphic User Interface for Biomedical Signal Analysis](http://www.ym.edu.tw/~cflu/CFLu_course_matlabgui.html)
    * [MATLAB圖形使用者介面應用於生醫訊號分析](https://www.youtube.com/playlist?list=PLx_IWc-RN82smDOJpZAi8K8eWytMa6oh0)

### EEGLAB

* [EEGLAB](https://sccn.ucsd.edu/eeglab/index.php)
* [Wiki Tutorial](https://sccn.ucsd.edu/wiki/EEGLAB_TUTORIAL_OUTLINE)
