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

3. Re-Reference (Optional)

    ```matlab
    viewer.AverageReReference();
    ```

4. Plot

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

## Math Notes

### Signal Smoothing Methods

* [Signal Smoothing (Matlab Signal Processing Toolbox Document)](http://ww2.mathworks.cn/help/signal/examples/signal-smoothing.html)
    * Moving Average Filter (+ Filter Delay)
    * Extracting Average Differences
    * Extracting Peak Envelope
    * Weighted Moving Average Filters
    * Savitzky-Golay Filters
    * Resampling
    * Median Filter
    * Outlier Removal via Hampel Filter

* [2D Interpolation - interp2 (Matlab)](https://www.mathworks.com/help/matlab/ref/interp2.html)
    * linear (Default)
    * cubic
    * spline (Requires four points in each dimension)
    * ...

* [About Smoothing Surfaces (AutoCAD)](https://forums.autodesk.com/t5/civil-3d/ct-p/4003)
    * [Natural Neighbor Interpolation (NNI)](https://knowledge.autodesk.com/support/civil-3d/learn-explore/caas/CloudHelp/cloudhelp/2018/ENU/Civil3D-UserGuide/files/GUID-C5B0D4A3-B1DC-406E-A5B9-E3DEA2547FF1-htm.html)
    * [Kriging methods](https://www.wikiwand.com/en/Kriging)
        * [A MATLAB Kriging Toolbox](http://www2.imm.dtu.dk/projects/dace/dace.pdf)
        * [Ordinary Kriging (Matlab)](https://www.mathworks.com/matlabcentral/fileexchange/29025-ordinary-kriging)
        * [mGstat : A Geostatistical Matlab toolbox](http://mgstat.sourceforge.net/)

## TODO

- [X] Load data (Other's function)
- [X] Plot single signal
- [X] Plot two signal symmetrically
- [X] Add channel label
- [X] Add FIR Filter (EEGLAB function)
- [X] Add quick data viewer (EEGLAB function)
- [X] Average Re-reference
- [X] Log version of Plot
- [X] Make plot smoother

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
