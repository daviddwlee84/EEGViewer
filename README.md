# EEGViewer

Electroencephalography signal analysis and visualization

## Basic Usage

1. Input Data

    ```matlab
    [data, header] = read_edf('path/to/your/data.edf');
    viewer = EEGViewer(data, header);
    ```
2. Plot

    ```matlab
    PlotSingleSignal(channel)            % Plot single signal spectrum
    PlotSingleSignalReuse(channel)       % Plot single signal spectrum (reuse some data to make it more dense)
    PlotDoubleSignal(channel1, channel2) % Plot two signal spectrum symmetrically
    ```

## EEG Notes

### Wave Patterns

* Delta: 1~3 Hz
* Theta: 4~7 Hz
* Alpha: 8~13 Hz
* Beta: 14~30 Hz
* Gamma: 30~100 Hz

## TODO

- [X] Load data
- [X] Plot single signal
- [X] Plot two signal symmetrically
- [X] Add channel label

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
