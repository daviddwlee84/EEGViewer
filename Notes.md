# Notes

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

```matlab
ax = gca % get current axes
ax.parameter = new_value

fig = gcf % get current figure
fig.parameter = new_value
```

### Sundries

* Compare string recommand use strcmp() - `strcmp(string, 'to_compare')`

* Convert a decimal to an integer
    * fix to strip all the decimals - `fix  (1.9) % 1`
    * round can change the integer part - `round(1.9) % 2`

## Links

### EEG with Matlab

EEGLAB

* [MATLAB Progamming for Medical Signal Analysis](http://www.ym.edu.tw/~cflu/CFLu_course_matlabsig.html)
    * [醫學訊號分析原理與MATLAB程式應用實作](https://www.youtube.com/playlist?list=PLx_IWc-RN82uKOdafF4v4U5R_u4qmYaiu)
        * [EEGLAB處理流程1](https://youtu.be/jAbcW0FKkw0)
        * [EEGLAB處理流程2](https://www.youtube.com/watch?v=z3RBvj1x344)

Matlab GUI

* [MATLAB Graphic User Interface for Biomedical Signal Analysis](http://www.ym.edu.tw/~cflu/CFLu_course_matlabgui.html)
    * [MATLAB圖形使用者介面應用於生醫訊號分析](https://www.youtube.com/playlist?list=PLx_IWc-RN82smDOJpZAi8K8eWytMa6oh0)

### MOOCs

* [NTHU Scientific Computing](http://ocw.nthu.edu.tw/ocw/index.php?page=course&cid=53)
    * [**Scientific Computing**](http://mirlab.org/jang/courses/scientificComputing/)
        * [Using Python within Matlab](https://www.mathworks.com/help/matlab/getting-started-with-python.html)
        * [Some Matlab Toolboxes](http://mirlab.org/jang/matlab/toolbox/)
    * [Professor](http://mirlab.org/jang/)
