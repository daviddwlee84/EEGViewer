# EEGViewer

Electroencephalography signal analysis and visualization

## Demo

![SliderDoubleSignal](demo/SliderDoubleSignal.png) ![Animated](demo/Animated.gif) ![DoubleSignal](demo/DoubleSignal.png)

## Basic Usage

### Simple procedure

1. Input Data

    * Now support regular *.edf and OpenBCI format *.txt

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

4. SetMinDrop / SetMaxRange (Optional)

    ```matlab
    viewer.SetMinDrop(minimum) % Default is 0 (don't drop)
    ```
    ```matlab
    viewer.SetMaxRange(maximum) % Default is the maximum of all channel's FFT data
    ```

5. Static Plot

    ```matlab
    viewer.PlotSingleSignal(channel)                % Plot single signal spectrum
    viewer.PlotDoubleSignal(channel1, channel2)     % Plot two signal spectrum symmetrically
    ```

6. Animated Plot Setting (Optional)

    ```matlab
    viewer.SetAnimateMaxLength(minutes) % Show only the range of the time period on screen
    ```

7. Animated Plot

    ```matlab
    viewer.AnimatedDoubleSignal(channel1, channel2, speed) % Plot animated two signal symmetrically. (default speed is 2)
    viewer.AnimatedMultipleSignal(channelList, speed) % Plot all animated signal in channelList (must be even number, default speed is 2)
    ```

8. Slider Double Singal Plot

    ```matlab
    viewer.SliderDoublePlot(channel1, channel2, secLength) % Show only the range of time period on screen
    ```
    Ps. It share the animatemaxlength global variable and same setting of Animated Plot function in AddAuxiliaryInformation for now.

* Quick view of data

    ```matlab
    viewer.ScrollView()
    ```

* Add channel location name (for OpenBCI) (Optional)

    ```matlab
    viewer.SetChannelLocationName(ch1, ch2, ch3, ch4, ch5, ch6, ch7, ch8)
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

* [Curve and surface smoothing without shrinkage](https://ieeexplore.ieee.org/document/466848/)

### Plot Axis

* [Axis](https://www.mathworks.com/help/matlab/ref/axis.html)
    * axis style - `axis tight`
    * axis limits - `axis([xmin xmax ymin ymax zmin zmax])`

### Animated Plot

* [Animating a Surface](https://www.mathworks.com/help/matlab/examples/animating-a-surface.html)
* [Matlab Tutorial - Animated Plot in 2D](https://youtu.be/6yIuy-r0mi4)
* [Matlab Animation](https://www.mathworks.com/help/matlab/animation-1.html)

### Annotation (e.g. TextBox in a figure)

[Matlab Annotation](http://www.mathworks.com/help/matlab/ref/annotation.html) - Textbox

### Plot settings

#### Colormap

* [Matlab caxis](https://www.mathworks.com/help/matlab/ref/caxis.html) - set colormap limits
* [Matlab colormap](https://www.mathworks.com/help/matlab/ref/colormap.html)

#### Background color

* Set background color to black - `set(gca,'Color','k')`

### Figure (window)

* [Matlab figure](https://www.mathworks.com/help/matlab/ref/figure.html)
* [Matlab Figure Properties](https://www.mathworks.com/help/matlab/ref/matlab.ui.figure-properties.html) - set position

### Sundries

* Compare string recommand use strcmp() - `strcmp(string, 'to_compare')`

* Convert a decimal to an integer
    * fix to strip all the decimals - `fix  (1.9) % 1`
    * round can change the integer part - `round(1.9) % 2`

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
- [X] Animated 3D Surface
- [X] Color map / Drop low value / Set max
- [X] Deprecate ori version of Plot (non-log version and non-interpolation version and reuse version)
- [X] Demo on README
- [X] Change background color to black
- [X] Slider for double signal plot
- [X] Support *.txt format (for OpenBCI)
- [X] Set Channel Location Name and Color (for OpenBCI)
- [ ] Change `surface` variable name
- [ ] 3D brain heat map
- [ ] Play video in specific range
- [ ] Slider for animated plot
- [ ] Accelerate button for animated plot
- [X] Multiple animated plot at same time
- [X] Maximum range period showed on screen
- [ ] Advantage dot plot
- [ ] Average bar plot
- [ ] Average distribute pie chart
- [ ] Spectrum report
- [ ] Event label
- [ ] Seperate private and public [methods](https://www.mathworks.com/help/matlab/matlab_oop/method-attributes.html) / [properties](https://www.mathworks.com/help/matlab/matlab_oop/properties.html)
- [ ] Improve multiple animated plot efficiency
- [ ] Better Demo

## Other function used

* readOpenBCItxt.m - load *.txt output from OpenBCI's machine
* read_edf.m - *.edf data loader

### from EEGLAB

* eegfilt.m - FIR Filter
* eegplot.m - Scroll view on raw data
* textsc.m - Places text in screen coordinates
* fastif.m - Fast if

## Popular Matlab Toolbox

### EEGLAB

* [EEGLAB](https://sccn.ucsd.edu/eeglab/index.php)
* [Wiki Tutorial](https://sccn.ucsd.edu/wiki/EEGLAB_TUTORIAL_OUTLINE)

### BCILAB

Open Source Matlab Toolbox for Brain-Computer Interface research

* [BCILAB](https://sccn.ucsd.edu/wiki/BCILAB)

### ERPLAB

* [ERPLAB](https://erpinfo.org/erplab/)

### FieldTrip

* [FieldTrip](http://www.fieldtriptoolbox.org/)

## Related Links

### EEG with Matlab

* [MATLAB Progamming for Medical Signal Analysis](http://www.ym.edu.tw/~cflu/CFLu_course_matlabsig.html)
    * [醫學訊號分析原理與MATLAB程式應用實作](https://www.youtube.com/playlist?list=PLx_IWc-RN82uKOdafF4v4U5R_u4qmYaiu)
        * [EEGLAB處理流程1](https://youtu.be/jAbcW0FKkw0)
        * [EEGLAB處理流程2](https://www.youtube.com/watch?v=z3RBvj1x344)

* [MATLAB Graphic User Interface for Biomedical Signal Analysis](http://www.ym.edu.tw/~cflu/CFLu_course_matlabgui.html)
    * [MATLAB圖形使用者介面應用於生醫訊號分析](https://www.youtube.com/playlist?list=PLx_IWc-RN82smDOJpZAi8K8eWytMa6oh0)

### MOOCs

* [NTHU Scientific Computing](http://ocw.nthu.edu.tw/ocw/index.php?page=course&cid=53)
    * [**Scientific Computing**](http://mirlab.org/jang/courses/scientificComputing/)
        * [Using Python within Matlab](https://www.mathworks.com/help/matlab/getting-started-with-python.html)
        * [Some Matlab Toolboxes](http://mirlab.org/jang/matlab/toolbox/)
    * [Professor](http://mirlab.org/jang/)

### OpenBCI

* [OpenBCI Documentation](http://docs.openbci.com/)
    * [Doc Github](https://github.com/openbci/docs)
    * [3rd Party Software - Matlab](http://docs.openbci.com/3rd%20Party%20Software/01-Matlab)

### Python EEG

* [Pbrain repository](https://github.com/nipy/pbrain)
