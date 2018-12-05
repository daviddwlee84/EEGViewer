classdef EEGViewer < handle
    %EEGViewer Electroencephalography signal analysis and visualization
    %   Author: David D.W.Lee
    %   Github: https://github.com/daviddwlee84/EEGViewer
    
    properties
        %> Data
        Data
        
        %> FFT Data
        fftData
        
        %> File
        Filepath
        Filename
        
        %> Sampling frequency
        Fs
        %> Sampling period
        T
        %> Length of signal
        L
        %> Time vector
        t              

        %> Proceed fft every rng data
        rng

        %> Total iteration (for each second)
        totalsecond

        %> Number of channels
        numchannels

        %> Channel names
        channelNames

        % Channel location name (OpenBCI)
        channelLocationName
        
        %> Min drop
        mindrop
        %> Max range
        maxrange
        
        %> FFT Data Max
        fftdatamax
        
        %> Animate max length (ms)
        animatemaxlength

        %> Compress constant
        compress

        %> ZLim => use to compress graph down?!
        zlimBak
    end
    
    methods
        % ======================================================================
        %> @brief Class constructor
        %>
        %> @param path (Optional) Path to the *.edf file.
        %> @return instance of the EEGViewer class.
        % ======================================================================
        function obj = EEGViewer(path)
            
            % Set the axis background color to black, the axis lines and labels to white,
            % and the figure background color to dark gray.
            % And then it need to set every figure to black that I add in AddAuxiliaryInformation() at once.
            colordef black
            
            % Add ./functions subpath to PATH
            addpath(genpath(fullfile(pwd, 'functions')))
            if nargin == 1
                obj.Load(path);
            end;
        end
        
        % ======================================================================
        %> @brief Load *.edf Data
        %>
        %> @param path Path to the *.edf file.
        % ======================================================================        
        function Load(obj, path)
            
            % Determine the file type
            [~, ~, ext] = fileparts(path);
            
            if strcmp(ext, '.edf')
                % Regular *.edf file
                [data, header] = read_edf(path);
            elseif strcmp(ext, '.txt')
                % OpenBCI format *.txt file
                data = readOpenBCItxt(path);
                header.samplingrate = 250; % Default is 250Hz
                [m, n] = size(data);
                
                % Cut the data to multiple of single second
                header.numtimeframes = n - mod(n, header.samplingrate);
                data = data(:, 1:header.numtimeframes);
                
                header.numchannels = m;
                channels = cell(m, 1);
                for i = 1:m
                   channels{i} = num2str(i, '%03d');
                end
                channels_temp = cell2mat(channels);
                channels_temp(1:8, :) = ['Gy1'; ' P2'; ' B3'; ' G4'; ' Y5'; ' O6'; ' R7'; ' C8'];
                header.channels = channels_temp;
            else
                error('Unsupported data type! (current support edf and OpenBCI txt format)')
            end
            
            obj.Data = data;
            
            [obj.Filepath, obj.Filename] = fileparts(path);
            
            % Initial properties
            obj.Fs = header.samplingrate;   % Sampling frequency
            obj.T = 1/obj.Fs;               % Sampling period (1 us)
            obj.L = header.numtimeframes;   % Length of signal
            obj.t = (0:obj.L-1)*obj.T;      % Time vector

            obj.rng = obj.Fs; % Proceed fft every rng data (origin: 1000)
            obj.totalsecond = obj.L/obj.rng; % Total iteration
            
            obj.numchannels = header.numchannels; % Number of channels
            obj.channelNames = header.channels;   % Channel names
            
            obj.mindrop = 0; % Drop min
            obj.fftdatamax = inf; % Maximum data value
            obj.maxrange = inf; % Manual maximum value
            
            obj.animatemaxlength = 3*60; % Maximum time length of animated plot (Default 3 mins)

            obj.channelLocationName = false; % Initial false unless call SetChannelLocationName()

            obj.compress = 1; % Initial compress constant
        end
        
        % ======================================================================
        %> @brief Set channel location name (for OpenBCI)
        %>
        %> @param obj instance of the EEGViewer class.
        %> @param ch1 append channel 1 name after original channel color and number
        %> @param ch2 append channel 2 name after original channel color and number
        %> @param ch3 append channel 3 name after original channel color and number
        %> @param ch4 append channel 4 name after original channel color and number
        %> @param ch5 append channel 5 name after original channel color and number
        %> @param ch6 append channel 6 name after original channel color and number
        %> @param ch7 append channel 7 name after original channel color and number
        %> @param ch8 append channel 8 name after original channel color and number
        % ======================================================================
        function SetChannelLocationName(obj, ch1, ch2, ch3, ch4, ch5, ch6, ch7, ch8)
            channels = cell(8, 1);
            channels{1} = ch1;
            channels{2} = ch2;
            channels{3} = ch3;
            channels{4} = ch4;
            channels{5} = ch5;
            channels{6} = ch6;
            channels{7} = ch7;
            channels{8} = ch8;
            obj.channelLocationName = channels;
        end

        % ======================================================================
        %> @brief Compress graph down
        %>
        %> @param obj instance of the EEGViewer class.
        %> @param compress compress constant
        % ======================================================================
        function SetCompressConstant(obj, constant)
            if constant <= 1
                error('constant must greater than 1')
            end
            obj.compress = constant;
        end
        
        % ======================================================================
        %> @brief Scroll view on data (Optional)
        %>
        %> @param obj instance of the EEGViewer class.
        % ======================================================================
        function ScrollView(obj)
            eegplot(obj.Data, 'srate', obj.Fs, 'title', 'Scroll View', 'plottitle', ['Scroll view on data of ', obj.Filename], 'xgrid', 'on', 'ygrid', 'on')
        end
        
        % ======================================================================
        %> @brief Band-pass filter data using two-way least-squares FIR filtering (Optional)
        %>
        %> @param obj instance of the EEGViewer class.
        %> @param min_filter floor threshold (uaually be 1 Hz)
        %> @param max_filter ceiling threshold (usually be 30 Hz)
        % ======================================================================
        function FIRfiltering(obj, min_filter, max_filter)
            obj.Data = eegfilt(obj.Data, obj.Fs, min_filter, max_filter);
        end

        % ======================================================================
        %> @brief Average re-reference (Optional)
        %>
        %> @param obj instance of the EEGViewer class.
        % ======================================================================
        function AverageReReference(obj)
            obj.Data = obj.Data - mean(mean(obj.Data));
        end
        
        % ======================================================================
        %> @brief Process FFT on data
        %>
        %> @param obj instance of the EEGViewer class.
        %> @retval ret return logarithm value of this method
        % ======================================================================
        function ret = DataProcess(obj)
            Y = zeros(obj.numchannels, obj.totalsecond, obj.rng); % channel time length
            P2 = zeros(obj.numchannels, obj.totalsecond, obj.rng);
            P1 = zeros(obj.numchannels, obj.totalsecond, obj.rng/2+1);
            
            for channel = 1:obj.numchannels
                for i = 1:obj.totalsecond
                    Y(channel, i, :) = fft(obj.Data(channel, 1+obj.rng*(i-1):obj.rng*i));
                    P2(channel, i, :) = abs(Y(channel, i, :)); % Handle complex value
                    P1(channel, i, :) = P2(channel, i, 1:obj.rng/2+1);
                    P1(channel, i, 2:end-1) = 2*P1(channel, i, 2:end-1);
                    P1(channel, i, 1) = 0; % Get rid of 0Hz data
                end
            end   
            % Logarithm
            ret = 10*log10(P1);
        end
        
        % ======================================================================
        %> @brief FFT Transform
        %>
        %> @param obj instance of the EEGViewer class.
        % ======================================================================
        function fftTransform(obj)

            obj.fftData = obj.DataProcess();

            obj.fftdatamax = max(max(max(obj.fftData))); % Default maximum value

        end

        % ======================================================================
        %> @brief Saved FFT Transform as CSV
        %>
        %> @param obj instance of the EEGViewer class.
        %> @param filename file name without extension. (will auto append .csv)
        % ======================================================================
        function SaveCSV(obj, filename)
            if obj.numchannels > 8
                numchannels = 8;
            else
                numchannels = obj.numchannels;
            end

            obj.fftTransform();

            %% For column name =========================================
            columnNamesCell = cell(1, numchannels * 30 + numchannels * 4);
            for channel = 1:numchannels
                % Get channel name
                if(~iscell(obj.channelLocationName))
                    channelName = obj.channelNames(channel, 1:3);
                else
                    channelName = obj.channelLocationName{channel};
                end
                for hz = 1:30
                    columnNamesCell{(channel-1)*30 + hz} = [channelName, '_', int2str(hz), 'Hz'];
                end
                for avgHz = 1:4
                    switch avgHz
                        case 1
                            columnNamesCell{numchannels*30 + (channel-1)*4 + 1} = [channelName, 'D'];
                        case 2
                            columnNamesCell{numchannels*30 + (channel-1)*4 + 2} = [channelName, 'T'];
                        case 3
                            columnNamesCell{numchannels*30 + (channel-1)*4 + 3} = [channelName, 'A'];
                        case 4
                            columnNamesCell{numchannels*30 + (channel-1)*4 + 4} = [channelName, 'B'];
                    end
                end
            end

            %% For data =========================================
            % Regular
            outputData = zeros(obj.totalsecond, numchannels * 34);
            for channel = 1:numchannels
                for time = 1:obj.totalsecond
                    Delta = 0;
                    Theta = 0;
                    Alpha = 0;
                    Gamma = 0;
                    for hz = 1:30 % 1 is 0 Hz
                        currentValue = obj.fftData(channel, time, hz+1);
                        outputData(time, (channel-1)*30 + hz) = currentValue;
                        if hz < 4
                            Delta = Delta + currentValue;
                        elseif hz < 8
                            Theta = Theta + currentValue;
                        elseif hz < 13
                            Alpha = Alpha + currentValue;
                        else % hz = 13~30
                            Gamma = Gamma + currentValue;
                        end
                    end
                    % Average delta theta alpha gamma
                    if Delta == 0
                        avgDelta = 0;
                    else
                        avgDelta = Delta/3;
                    end
                    outputData(time, numchannels*30 + (channel-1)*4 + 1) = avgDelta;
                    if Theta == 0
                        avgTheta = 0;
                    else
                        avgTheta = Theta/3;
                    end
                    outputData(time, numchannels*30 + (channel-1)*4 + 2) = avgTheta/4;
                    if Alpha == 0
                        avgAlpha = 0;
                    else
                        avgAlpha = Alpha/3;
                    end
                    outputData(time, numchannels*30 + (channel-1)*4 + 3) = avgAlpha/5;
                    if Gamma == 0
                        avgGamma = 0;
                    else
                        avgGamma = Delta/3;
                    end
                    outputData(time, numchannels*30 + (channel-1)*4 + 4) = avgGamma/18;
                end
            end

            % Can't access Excel on Mac
            % status = xlswrite(filename, outputDataCell)
            % if status
            %     ['Successfully saved ', filename]
            % else
            %     error(['Faild to save ', filename])
            % end

            % construct header
            % (csvwrite doesn't support string or cell like xlswrite)
            textHeader = strjoin(columnNamesCell, ',');
            fid = fopen([filename, '.csv'], 'w'); 
            fprintf(fid, '%s\n', textHeader);
            fclose(fid);
            % write data to end of file
            dlmwrite([filename, '.csv'], outputData, '-append');
        end
        
        % ======================================================================
        %> @brief Set minimum drop value (Optional)
        %>
        %> @param obj instance of the EEGViewer class.
        %> @param mindrop minimum value to drop.
        % ======================================================================
        function SetMinDrop(obj, mindrop)
           obj.mindrop = mindrop; 
        end

        % ======================================================================
        %> @brief Set max range value (Optional)
        %>
        %> @param obj instance of the EEGViewer class.
        %> @param mindrop maximum value of scale.
        % ======================================================================
        function SetMaxRange(obj, maxrange)
            obj.maxrange = maxrange; 
        end
        
        % ======================================================================
        %> @brief Add auxiliary information on figure
        %>        If obj.mindrop has set (~=0), shift to xy-plane.
        %>        If obj.maxrange has set and greater than obj.fftdatamax, set max colormap as it.
        %> 
        %> @param obj instance of the EEGViewer class.
        %> @param fig figure object
        %> @param surface surf object
        %> @param type type of graph (Single, Double, Animated, AnimatedUpdate)
        %> @param channel1 Single's channel or channel 1 of Double
        %> @param channel2 Channel 2 of Double
        %> @param lastPlotBak plot object
        %> @param start_time start time of animate range
        %> @param end_time current time of animate
        %> @retval plotBak return plot object list
        % ======================================================================
        function plotBak = AddAuxiliaryInformation(obj, fig, surface, type, channel1, channel2, lastPlotBak, start_time, end_time)
            
            if obj.mindrop > 0
                shift = true; % shift minimum value to zero
            else
                shift = false;
            end
            
            % Switch to specific figure
            figure(fig);

            % Set background color to black
            fig.Color = 'k';
            
            if strcmp(type, 'Single')
                if(~iscell(obj.channelLocationName))
                    title(['Single-Sided Amplitude Spectrum of channel ', obj.channelNames(channel1, 1:3)])
                else
                    title(['Single-Sided Amplitude Spectrum of channel ', obj.channelNames(channel1, 1:3), '-', obj.channelLocationName{channel1}])
                end

                xlabel('f (Hz)')
                ylabel('t (sec)')
                zlabel('10\timeslog_{10}(|P1(f)|) (\muV^{2}/Hz)')
                colorbar
                surface.EdgeColor = 'none';

                % Set colormap max color to red
                colormap jet
                clm = colormap;
                clm(end-7:end, 1) = 1;
                colormap(clm)
                
                % Set background color to black
                set(gca,'Color','k') % gca = get current axis

                if ~shift
                    if obj.mindrop == 0
                        if obj.maxrange == inf
                            lim = caxis;
                            caxis([(lim(1)+lim(2))/2, obj.fftdatamax])
                        else
                            lim = caxis;
                            caxis([(lim(1)+lim(2))/2, obj.maxrange])
                        end
                    else
                        if obj.maxrange == inf
                            caxis([obj.mindrop, obj.fftdatamax])
                        else
                            caxis([obj.mindrop, obj.maxrange])
                        end
                    end
                else
                    if obj.maxrange == inf
                        caxis([0, obj.fftdatamax - obj.mindrop])
                    else
                        caxis([0, obj.maxrange - obj.mindrop])
                    end
                end
                
                axis tight

                % used to compress graph down
                if obj.compress > 1
                    current_zlim = zlim;
                    obj.zlimBak = current_zlim;
                    zlim([1, obj.compress] .* current_zlim);
                end

                grid on
                hold on

                %delta
                [x_delta, y_delta] = meshgrid(1:3, 1:obj.totalsecond);
                plot(x_delta, y_delta, 'b')
                %theta
                [x_theta, y_theta] = meshgrid(4:7, 1:obj.totalsecond);
                plot(x_theta, y_theta, 'g')
                %alpha
                [x_alpha, y_alpha] = meshgrid(8:12, 1:obj.totalsecond);
                plot(x_alpha, y_alpha, 'r')
                %beta
                [x_beta, y_beta] = meshgrid(13:30, 1:obj.totalsecond);
                plot(x_beta, y_beta, 'y') 

                hold off
            elseif strcmp(type, 'AnimatedUpdate')

                % used to compress graph down
                if obj.compress > 1
                    zlim([1, obj.compress] .* obj.zlimBak)
                end

                update_time_range = start_time:end_time+1;
                
                %delta
                for i = 1:3
                    [x_delta, y_delta] = meshgrid(1:3, update_time_range);
                    lastPlotBak(i).XData = x_delta(:, i);
                    lastPlotBak(i).YData = y_delta(:, i);
                end
                for i = 4:6
                    [x_delta, y_delta] = meshgrid(-1:-1:-3, update_time_range);
                    lastPlotBak(i).XData = x_delta(:, i-3);
                    lastPlotBak(i).YData = y_delta(:, i-3);
                end
                
                %theta
                for i = 7:10
                    [x_theta, y_theta] = meshgrid(4:7, update_time_range);
                    lastPlotBak(i).XData = x_theta(:, i-6);
                    lastPlotBak(i).YData = y_theta(:, i-6);
                end
                for i = 11:14
                    [x_theta, y_theta] = meshgrid(-4:-1:-7, update_time_range);
                    lastPlotBak(i).XData = x_theta(:, i-10);
                    lastPlotBak(i).YData = y_theta(:, i-10);
                end

                %alpha
                for i = 15:19
                    [x_alpha, y_alpha] = meshgrid(8:12, update_time_range);
                    lastPlotBak(i).XData = x_alpha(:, i-14);
                    lastPlotBak(i).YData = y_alpha(:, i-14);
                end
                for i = 20:24
                    [x_alpha, y_alpha] = meshgrid(-8:-1:-12, update_time_range);
                    lastPlotBak(i).XData = x_alpha(:, i-19);
                    lastPlotBak(i).YData = y_alpha(:, i-19);
                end
                
                %beta
                for i = 25:42
                    [x_beta, y_beta] = meshgrid(13:30, update_time_range);
                    lastPlotBak(i).XData = x_beta(:, i-24);
                    lastPlotBak(i).YData = y_beta(:, i-24);
                end
                for i = 43:60
                    [x_beta, y_beta] = meshgrid(-13:-1:-30, update_time_range);
                    lastPlotBak(i).XData = x_beta(:, i-42);
                    lastPlotBak(i).YData = y_beta(:, i-42);
                end

            else % Double or Animated initialization
                
                if(~iscell(obj.channelLocationName))
                    title(['Comparison of channel ', obj.channelNames(channel1, 1:3), ' and ', obj.channelNames(channel2, 1:3)])
                else
                    title(['Comparison of channel ', obj.channelNames(channel1, 1:3), '-', obj.channelLocationName{channel1},...
                                            ' and ', obj.channelNames(channel2, 1:3), '-', obj.channelLocationName{channel2}])
                end
                xlabel('f (Hz)')
                ylabel('t (sec)')
                zlabel('10\timeslog_{10}(|P1(f)|) (\muV^{2}/Hz)')
                colorbar
                surface.EdgeColor = 'none';
                
                % Set colormap max color to RED
                colormap Jet
                clm = colormap;
                clm(end-7:end, 1) = 1;
                colormap(clm)
                
                % Set background color to black
                set(gca,'Color','k')

                if obj.mindrop > 0
                    shift = true; % shift minimum value to zero
                else
                    shift = false;
                end

                if ~shift
                    if obj.mindrop == 0
                        if obj.maxrange == inf
                            lim = caxis;
                            caxis([(lim(1)+lim(2))/2, obj.fftdatamax])
                        else
                            lim = caxis;
                            caxis([(lim(1)+lim(2))/2, obj.maxrange])
                        end
                    else
                        if obj.maxrange == inf
                            caxis([obj.mindrop, obj.fftdatamax])
                        else
                            caxis([obj.mindrop, obj.maxrange])
                        end
                    end
                else
                    if obj.maxrange == inf
                        caxis([0, obj.fftdatamax - obj.mindrop])
                    else
                        caxis([0, obj.maxrange - obj.mindrop])
                    end
                end

                axis tight
                view(190,30)         % set viewpoint

                % used to compress graph down
                if obj.compress > 1
                    current_zlim = zlim;
                    obj.zlimBak = current_zlim;
                    zlim([1, obj.compress] .* current_zlim);
                end

                grid on
                hold on
                
                if strcmp(type, 'Double') || (strcmp(type, 'Animated') && obj.totalsecond < obj.animatemaxlength)
                    time_range = 1:obj.totalsecond;
                elseif strcmp(type, 'Animated') && obj.totalsecond > obj.animatemaxlength
                    time_range = 1:obj.animatemaxlength;
                end
                
                %delta
                [x_delta, y_delta] = meshgrid(1:3, time_range);
                p1 = plot(x_delta, y_delta, 'b');
                plotBak = p1;
                [x_delta, y_delta] = meshgrid(-1:-1:-3, time_range);
                p2 = plot(x_delta, y_delta, 'b');
                plotBak = [plotBak; p2];
                %theta
                [x_theta, y_theta] = meshgrid(4:7, time_range);
                p3 = plot(x_theta, y_theta, 'g');
                plotBak = [plotBak; p3];
                [x_theta, y_theta] = meshgrid(-4:-1:-7, time_range);
                p4 = plot(x_theta, y_theta, 'g');
                plotBak = [plotBak; p4];
                %alpha
                [x_alpha, y_alpha] = meshgrid(8:12, time_range);
                p5 = plot(x_alpha, y_alpha, 'r');
                plotBak = [plotBak; p5];
                [x_alpha, y_alpha] = meshgrid(-8:-1:-12, time_range);
                p6 = plot(x_alpha, y_alpha, 'r');
                plotBak = [plotBak; p6];
                %beta
                [x_beta, y_beta] = meshgrid(13:30, time_range);
                p7 = plot(x_beta, y_beta, 'y');
                plotBak = [plotBak; p7];
                [x_beta, y_beta] = meshgrid(-13:-1:-30, time_range);
                p8 = plot(x_beta, y_beta, 'y');
                plotBak = [plotBak; p8];
                hold off
            end
  
        end

        % ======================================================================
        %> @brief Add auxiliary information on subplots
        %>        If obj.mindrop has set (~=0), shift to xy-plane.
        %>        If obj.maxrange has set and greater than obj.fftdatamax, set max colormap as it.
        %> 
        %> @param obj instance of the EEGViewer class.
        %> @param fig figure object
        %> @param axs array of axis
        %> @param surfaces array of surf object
        %> @param type type of graph (DoubleSliderInit, DoubleSliderUpdate)
        %> @param channels all channels in list (must be even number)
        %> @param start_time start time of animate range
        %> @param end_time current time of animate
        %> @param lastSubplotBak all backuped subplot (to modify then plot)
        %> @retval subplotBak return list of plot object list
        % ======================================================================
        function subplotBak = AddAuxiliaryInformationSubplot(obj, fig, axs, surfaces, type, channels, start_time, end_time, lastSubplotBak)
            
            if obj.mindrop > 0
                shift = true; % shift minimum value to zero
            else
                shift = false;
            end
            
            % Switch to specific figure
            figure(fig);

            % Set background color to black
            fig.Color = 'k';

            if strcmp(type, 'DoubleSliderInit')
                % loop through every axises
                for i=1:length(axs)
                    % get current pairs channel number
                    channel1 = channels(i*2-1);
                    channel2 = channels(i*2);

                    subplot(axs(i)); % Make Subplot the Current Axes

                    %colorbar % show colorbar
                    % Set colormap max color to RED
                    colormap Jet
                    clm = colormap;
                    clm(end-7:end, 1) = 1;
                    colormap(clm)

                    if(~iscell(obj.channelLocationName))
                        title(['Comparison of channel ', obj.channelNames(channel1, 1:3), ' and ', obj.channelNames(channel2, 1:3)]);
                    else
                        title(['Comparison of channel ', obj.channelNames(channel1, 1:3), '-', obj.channelLocationName{channel1},...
                                               ' and ', obj.channelNames(channel2, 1:3), '-', obj.channelLocationName{channel2}]);
                    end
                    xlabel('f (Hz)');
                    ylabel('t (sec)');
                    zlabel('10\timeslog_{10}(|P1(f)|) (\muV^{2}/Hz)');
                    
                    surfaces(i).EdgeColor = 'none';
    
                    if obj.mindrop > 0
                        shift = true; % shift minimum value to zero
                    else
                        shift = false;
                    end
    
                    if ~shift
                        if obj.mindrop == 0
                            if obj.maxrange == inf
                                lim = caxis;
                                caxis([(lim(1)+lim(2))/2, obj.fftdatamax])
                            else
                                lim = caxis;
                                caxis([(lim(1)+lim(2))/2, obj.maxrange])
                            end
                        else
                            if obj.maxrange == inf
                                caxis([obj.mindrop, obj.fftdatamax])
                            else
                                caxis([obj.mindrop, obj.maxrange])
                            end
                        end
                    else
                        if obj.maxrange == inf
                            caxis([0, obj.fftdatamax - obj.mindrop])
                        else
                            caxis([0, obj.maxrange - obj.mindrop])
                        end
                    end
    
                    axis tight
                    axs(i).View = [180, 30];         % set viewpoint
                    % used to compress graph down
                    if obj.compress > 1
                        current_zlim = zlim;
                        obj.zlimBak = current_zlim;
                        zlim([1, obj.compress] .* current_zlim);
                    end
                    
                    grid on
                    hold on

                    time_range = start_time:end_time;
                    
                    %delta
                    [x_delta, y_delta] = meshgrid(1:3, time_range);
                    p1 = plot(x_delta, y_delta, 'b');
                    plotBak = p1;
                    [x_delta, y_delta] = meshgrid(-1:-1:-3, time_range);
                    p2 = plot(x_delta, y_delta, 'b');
                    plotBak = [plotBak; p2];
                    %theta
                    [x_theta, y_theta] = meshgrid(4:7, time_range);
                    p3 = plot(x_theta, y_theta, 'g');
                    plotBak = [plotBak; p3];
                    [x_theta, y_theta] = meshgrid(-4:-1:-7, time_range);
                    p4 = plot(x_theta, y_theta, 'g');
                    plotBak = [plotBak; p4];
                    %alpha
                    [x_alpha, y_alpha] = meshgrid(8:12, time_range);
                    p5 = plot(x_alpha, y_alpha, 'r');
                    plotBak = [plotBak; p5];
                    [x_alpha, y_alpha] = meshgrid(-8:-1:-12, time_range);
                    p6 = plot(x_alpha, y_alpha, 'r');
                    plotBak = [plotBak; p6];
                    %beta
                    [x_beta, y_beta] = meshgrid(13:30, time_range);
                    p7 = plot(x_beta, y_beta, 'y');
                    plotBak = [plotBak; p7];
                    [x_beta, y_beta] = meshgrid(-13:-1:-30, time_range);
                    p8 = plot(x_beta, y_beta, 'y');
                    plotBak = [plotBak; p8];
                    hold off

                    subplotBak(i, :) = plotBak;
                end
            elseif strcmp(type, 'DoubleSliderUpdate')
                for j=1:length(axs)

                    subplot(axs(j));

                    % used to compress graph down
                    if obj.compress > 1
                        zlim([1, obj.compress] .* obj.zlimBak)
                    end

                    update_time_range = start_time:end_time+1;
                
                    %delta
                    for i = 1:3
                        [x_delta, y_delta] = meshgrid(1:3, update_time_range);
                        lastSubplotBak(j, i).XData = x_delta(:, i);
                        lastSubplotBak(j, i).YData = y_delta(:, i);
                    end
                    for i = 4:6
                        [x_delta, y_delta] = meshgrid(-1:-1:-3, update_time_range);
                        lastSubplotBak(j, i).XData = x_delta(:, i-3);
                        lastSubplotBak(j, i).YData = y_delta(:, i-3);
                    end
                    
                    %theta
                    for i = 7:10
                        [x_theta, y_theta] = meshgrid(4:7, update_time_range);
                        lastSubplotBak(j, i).XData = x_theta(:, i-6);
                        lastSubplotBak(j, i).YData = y_theta(:, i-6);
                    end
                    for i = 11:14
                        [x_theta, y_theta] = meshgrid(-4:-1:-7, update_time_range);
                        lastSubplotBak(j, i).XData = x_theta(:, i-10);
                        lastSubplotBak(j, i).YData = y_theta(:, i-10);
                    end

                    %alpha
                    for i = 15:19
                        [x_alpha, y_alpha] = meshgrid(8:12, update_time_range);
                        lastSubplotBak(j, i).XData = x_alpha(:, i-14);
                        lastSubplotBak(j, i).YData = y_alpha(:, i-14);
                    end
                    for i = 20:24
                        [x_alpha, y_alpha] = meshgrid(-8:-1:-12, update_time_range);
                        lastSubplotBak(j, i).XData = x_alpha(:, i-19);
                        lastSubplotBak(j, i).YData = y_alpha(:, i-19);
                    end
                    
                    %beta
                    for i = 25:42
                        [x_beta, y_beta] = meshgrid(13:30, update_time_range);
                        lastSubplotBak(j, i).XData = x_beta(:, i-24);
                        lastSubplotBak(j, i).YData = y_beta(:, i-24);
                    end
                    for i = 43:60
                        [x_beta, y_beta] = meshgrid(-13:-1:-30, update_time_range);
                        lastSubplotBak(j, i).XData = x_beta(:, i-42);
                        lastSubplotBak(j, i).YData = y_beta(:, i-42);
                    end
                    
                end
            end
        end
        
        % ======================================================================
        %> @brief Plot Signal Signal
        %>        If obj.mindrop has set (~=0), shift to xy-plane.
        %>        If obj.maxrange has set and greater than obj.fftdatamax, set max colormap as it.
        %>
        %> @param obj instance of the EEGViewer class.
        %> @param channel the specific channel to plot.
        % ======================================================================
        function PlotSingleSignal(obj, channel)
            if channel > obj.numchannels
                error('No such channel')
            end

            if obj.mindrop > 0
                shift = true; % shift minimum value to zero
            else
                shift = false;
            end
            
            obj.fftTransform();
            fftdata = obj.fftData;
            
            f = obj.Fs*(0:(obj.rng/2))/obj.rng;

            [xx, yy] = meshgrid(f(1:31), 1:obj.totalsecond);

            zz = fftdata(channel, 1:end, 1:31); % 1 x TotalSecond x 31
            zz = reshape(zz, [obj.L/obj.rng, 31]); % TotalSecond x 31
            
            % Interpolation
            newF = obj.Fs*(0:0.1:(obj.rng/2))/obj.rng;
            [Xq, Yq] = meshgrid(newF(1:301), 1:0.1:obj.totalsecond);
            Zq = interp2(xx, yy, zz, Xq, Yq, 'cubic');

            % if fftdata < mindrop => set to mindrop
            if obj.mindrop > 0
                indices = Zq <= obj.mindrop;
                Zq(indices) = obj.mindrop;
            end
            if shift
                Zq = Zq - obj.mindrop;
                % Cover hole...
                hole = Zq <= 0.87; % hole
                Zq(hole) = 0.87;
            end
            
            fig = figure('Name', 'Plot Single Signal');

            surface = surf(Xq, Yq, Zq);
            
            obj.AddAuxiliaryInformation(fig, surface, 'Single', channel);
            
        end

        % ======================================================================
        %> @brief Double Signal Processing
        %>        If obj.mindrop has set (~=0), shift to xy-plane.
        %>        If obj.maxrange has set and greater than obj.fftdatamax, set max colormap as it.
        %>
        %> @param obj instance of the EEGViewer class.
        %> @param channel1 the first specific channel to process.
        %> @param channel2 the second specific channel to process.
        % ======================================================================
        function [Xq, Yq, Zq] = ProcessDoubleSignal(obj, channel1, channel2)
            
            if channel1 > obj.numchannels || channel2 > obj.numchannels
                error('No such channel')
            end
            
            if obj.mindrop > 0
                shift = true; % shift minimum value to zero
            else
                shift = false;
            end
            
            obj.fftTransform();
            fftdata = obj.fftData;
            
            f = obj.Fs*(-(obj.rng/2):(obj.rng/2))/obj.rng;

            [xx, yy] = meshgrid(f((obj.rng/2-29):(obj.rng/2+31)), 1:obj.totalsecond);

            zz1 = fftdata(channel1, 1:end, 2:31);
            zz2 = fftdata(channel2, 1:end, 2:31);
            
            % 0Hz Value
            zeroHz(1:obj.totalsecond) = (mean(mean(zz1)) + mean(mean(zz2)))/2;
            zeroHz = zeroHz';

            zz1 = reshape(zz1, [obj.L/obj.rng, 30]);
            zz2 = reshape(zz2, [obj.L/obj.rng, 30]);
            zz1 = fliplr(zz1);
            
            zz = [zz1, zeroHz, zz2];
            
            % Interpolation
            newF = obj.Fs*(-(obj.rng/2):0.1:(obj.rng/2))/obj.rng;
            [Xq, Yq] = meshgrid(newF((obj.rng*10/2-299):(obj.rng*10/2+301)), 1:0.1:obj.totalsecond);
            Zq = interp2(xx, yy, zz, Xq, Yq, 'cubic');

            % if fftdata < mindrop => set to mindrop
            if obj.mindrop > 0
                indices = Zq <= obj.mindrop;
                Zq(indices) = obj.mindrop;
            end
            if shift
                Zq = Zq - obj.mindrop;
                % Cover hole...
                hole = Zq <= 0.87; % hole
                Zq(hole) = 0.87;
            end
        end
        
        % ======================================================================
        %> @brief Plot Double Signal Symmetrically
        %>
        %> @param obj instance of the EEGViewer class.
        %> @param channel1 the first specific channel to plot.
        %> @param channel2 the second specific channel to plot.
        % ======================================================================
        function PlotDoubleSignal(obj, channel1, channel2)

            [Xq, Yq, Zq] = obj.ProcessDoubleSignal(channel1, channel2);
            
            fig = figure('Name', 'Plot Double Signal');
            surface = surf(Xq, Yq, Zq);
            
            obj.AddAuxiliaryInformation(fig, surface, 'Double', channel1, channel2);

        end

        % ======================================================================
        %> @brief Slider Double Plot
        %>
        %> @param obj instance of the EEGViewer class.
        %> @param channel1 the first specific channel to plot.
        %> @param channel2 the second specific channel to plot.
        %> @param range initial time length of the showing part (sec)
        % ======================================================================
        function SliderDoublePlot(obj, channel1, channel2, secLength)

            [Xq, Yq, Zq] = obj.ProcessDoubleSignal(channel1, channel2);

            unitTimeLength = obj.totalsecond/length(Xq(:, 1));
            dataPointLength = fix(secLength/unitTimeLength);

            obj.animatemaxlength = secLength; % Share the variable with animated plot)

            fig = figure('Name', 'Slider Double Signal Plot', 'visible', 'off');

            axes(fig, 'Position', [0.13, 0.39, 0.77, 0.54]); % Set the axes position

            surface = surf(Xq(1:dataPointLength, :), Yq(1:dataPointLength, :), Zq(1:dataPointLength, :));
            plotBak = obj.AddAuxiliaryInformation(fig, surface, 'Animated', channel1, channel2);

            panel = uipanel(fig, 'Position', [0.1, 0.1, 0.8, 0.2]); % UI Panel
            slider = uicontrol(panel, 'Style', 'slider', 'Position', [30, 30, 340, 23], ...
                                'min', secLength, 'max', obj.totalsecond, 'Callback', @surfrange); % Slider bar
            slider.Value = secLength;
            slabel1 = uicontrol(panel, 'Style', 'text', 'Position', [10, 30, 23, 23], 'String', 0); % Left Label
            slabel2 = uicontrol(panel, 'Style', 'text', 'Position', [380, 30, 23, 23], 'String', obj.totalsecond); % Right Label
            slabel3 = uicontrol(panel, 'Style', 'text', 'Position', [100, 10, 200, 23], ...,
                                'String', sprintf('Time Range: %5.2f ~ %5.2f (sec)', 0, secLength)); % Underside message
            
            fig.Visible = 'on'; % Show the figure when all the elements are loaded

            function surfrange(source, callbackdata)
                val = source.Value;
                slabel3.String = sprintf('Time Range: %5.2f ~ %5.2f (sec)', val-secLength, val);
                interpolationLength = length(Xq(:, 1));
                time = fix(interpolationLength*val/obj.totalsecond);
                dataPointLength = fix(secLength/unitTimeLength);

                % Fix the problem that starting point less than 1
                if time <= dataPointLength
                    startTime = 1;
                    time = dataPointLength+1;
                else
                    startTime = time - dataPointLength;
                end
                surface.XData = Xq(startTime:time, :);    % replace surface x values
                surface.YData = Yq(startTime:time, :);    % replace surface y values
                surface.ZData = Zq(startTime:time, :);    % replace surface z values
                obj.AddAuxiliaryInformation(fig, surface, 'AnimatedUpdate', channel1, channel2, plotBak, Yq(startTime+1, 1), unitTimeLength*time);
            end
        
        end

        % ======================================================================
        %> @brief Multiple Slider Double Plot
        %>
        %> @param obj instance of the EEGViewer class.
        %> @param channels the channel ids in pairs delivered in vector
        % ======================================================================
        function SliderMultiplePlot(obj, channels, secLength)
            if length(channels) > obj.numchannels
                error('Too many channels')
            end
            if mod(length(channels), 2) == 1
                error('Channels amount must be even number')
            end

            % define constant
            pairs = length(channels)/2;
            total_rows = max(floor(pairs/2), 1);
            total_cols = pairs/total_rows;
            graph_freq_length = length((obj.rng*10/2-299):(obj.rng*10/2+301));
            graph_time_length = length(1:0.1:obj.totalsecond);
            
            % Preallocating
            Xtemp = zeros(pairs, graph_time_length, graph_freq_length);
            Ytemp = zeros(pairs, graph_time_length, graph_freq_length);
            Ztemp = zeros(pairs, graph_time_length, graph_freq_length);
            
            % Store processed signal
            for i = 1:pairs
                [Xq, Yq, Zq] = obj.ProcessDoubleSignal(channels(i*2-1), channels(i*2));
                Xtemp(i, :, :) = Xq;
                Ytemp(i, :, :) = Yq;
                Ztemp(i, :, :) = Zq;
                if i == 1
                    % get some variable
                    interpolationLength = length(Xq(:, 1));
                    unitTimeLength = obj.totalsecond/interpolationLength;
                    dataPointLength = fix(secLength/unitTimeLength);
                end
            end
            
            fig = figure('Name', 'Multiple Double Signal with Slider', 'Visible', 'off');
            
            % resize the figure according to the subplot number
            width_height = fig.Position(3:4);
            width_height = width_height.*([total_cols, total_rows]);
            fig.Position(3:4) = width_height;

            % slider
            panel = uipanel(fig, 'Position', [0.01, 0.01, 0.4, 0.1]); % UI Panel
            slider = uicontrol(panel, 'Style', 'slider', 'Position', [30, 30, 340, 23], ...
                                'min', secLength, 'max', obj.totalsecond, 'Callback', @surfrange); % Slider bar
            slider.Value = secLength;
            slabel1 = uicontrol(panel, 'Style', 'text', 'Position', [10, 30, 23, 23], 'String', 0); % Left Label
            slabel2 = uicontrol(panel, 'Style', 'text', 'Position', [380, 30, 23, 23], 'String', obj.totalsecond); % Right Label
            slabel3 = uicontrol(panel, 'Style', 'text', 'Position', [100, 10, 200, 23], ...,
                                'String', sprintf('Time Range: %5.2f ~ %5.2f (sec)', 0, secLength)); % Underside message
            
            % Open subplot, initial surfaces
            for i = 1:pairs
                axs(i) = subplot(total_rows, total_cols, i);
                surfaces(i) = surf(reshape(Xtemp(i, 1:dataPointLength, :), [dataPointLength, graph_freq_length]), reshape(Ytemp(i, 1:dataPointLength, :), [dataPointLength, graph_freq_length]), reshape(Ztemp(i, 1:dataPointLength, :), [dataPointLength, graph_freq_length]));
                title(['subplot of ', int2str(i)])
            end
            
            subplotBak = obj.AddAuxiliaryInformationSubplot(fig, axs, surfaces, 'DoubleSliderInit', channels, 1, secLength);

            fig.Visible = 'on'; % Show the figure when all the elements are loaded

            function surfrange(source, callbackdata)
                val = source.Value;
                slabel3.String = sprintf('Time Range: %5.2f ~ %5.2f (sec)', val-secLength, val);
                time = fix(interpolationLength*val/obj.totalsecond);
                dataPointLength = fix(secLength/unitTimeLength);

                % Fix the problem that starting point less than 1
                if time <= dataPointLength
                    startTime = 1;
                    time = dataPointLength+1;
                else
                    startTime = time - dataPointLength;
                end
                for i = 1:pairs
                    surfaces(i).XData = reshape(Xtemp(i, startTime:time, :), [dataPointLength+1, graph_freq_length]);    % replace surface x values
                    surfaces(i).YData = reshape(Ytemp(i, startTime:time, :), [dataPointLength+1, graph_freq_length]);    % replace surface y values
                    surfaces(i).ZData = reshape(Ztemp(i, startTime:time, :), [dataPointLength+1, graph_freq_length]);    % replace surface z values
                    obj.AddAuxiliaryInformationSubplot(fig, axs, surfaces, 'DoubleSliderUpdate', channels, unitTimeLength*startTime, unitTimeLength*time, subplotBak);
                end
            end
        end

        % ======================================================================
        %> @brief Set Animate Maximum Time Length (ms)
        %>
        %> @param obj instance of the EEGViewer class.
        %> @param maxminutelength maximum time length of animated plot. (minute)
        % ======================================================================        
        function SetAnimateMaxLength(obj, maxminutelength)
            % Unit is second
            obj.animatemaxlength = maxminutelength * 60;
        end
        
        % ======================================================================
        %> @brief Animated Plot Double Signal
        %>
        %> @param obj instance of the EEGViewer class.
        %> @param channel1 the first specific channel to plot.
        %> @param channel2 the second specific channel to plot.
        %> @param speed default 2 times speed.
        % ======================================================================
        function AnimatedDoubleSignal(obj, channel1, channel2, speed)
            if nargin < 4
                % Default 2 times speed
                speed = 2;
            end
            
            [Xq, Yq, Zq] = obj.ProcessDoubleSignal(channel1, channel2);
            
            fig = figure('Name', 'Plot Animated Double Signal');
            surface = surf(Xq(1:2, :), Yq(1:2, :), Zq(1:2, :)); % surface must be a matrix (can't be a line)
            
            plotBak = obj.AddAuxiliaryInformation(fig, surface, 'Animated', channel1, channel2);
    
            unitTimeLength = obj.totalsecond/length(Xq(:, 1));

            a = annotation('textbox', [0.15 0.15 0.3 0.15],...
                'String', ['Time: ', num2str(unitTimeLength*2), 'Sec'],...
                'FontSize',14, 'FitBoxToText','on');
            
            dataPointAnimateLength = fix(obj.animatemaxlength/unitTimeLength);
            pauseTime = obj.totalsecond/length(Xq(:, 1))/speed;
            
            % 3 => already plot 2
            for time = 3:length(Xq(:, 1)) % 3:obj.totalsecond*10
                a.String = ['Time: ', sprintf('%3.2f', unitTimeLength*time), ' (second)']; % sec/10
                if time*unitTimeLength <= obj.animatemaxlength
                    surface.XData = Xq(1:time, :);    % replace surface x values
                    surface.YData = Yq(1:time, :);    % replace surface y values
                    surface.ZData = Zq(1:time, :);    % replace surface z values
                else
                    surface.XData = Xq(time-dataPointAnimateLength:time, :);    % replace surface x values
                    surface.YData = Yq(time-dataPointAnimateLength:time, :);    % replace surface y values
                    surface.ZData = Zq(time-dataPointAnimateLength:time, :);    % replace surface z values
                    obj.AddAuxiliaryInformation(fig, surface, 'AnimatedUpdate', channel1, channel2, plotBak, Yq(time-dataPointAnimateLength, 1), unitTimeLength*time);
                end
                pause(pauseTime)
            end

        end

        % ======================================================================
        %> @brief Animated Plot Double Signal for channels
        %>
        %> @param obj instance of the EEGViewer class.
        %> @param channels the channel ids in pairs delivered in vector
        %> @param speed default 2 times speed
        % ======================================================================
        function AnimatedMultipleSignal(obj, channels, speed)
            if length(channels) > obj.numchannels
                error('Too many channels')
            end
            if mod(length(channels), 2) == 1
                error('Channels amount must be even number')
            end
            if nargin < 4
                % Default 2 times speed
                speed = 2;
            end
            
            % Some constant
            pairs = length(channels)/2;
            graph_freq_length = length((obj.rng*10/2-299):(obj.rng*10/2+301));
            graph_time_length = length(1:0.1:obj.totalsecond);
            unitTimeLength = obj.totalsecond/graph_time_length;
            dataPointAnimateLength = fix(obj.animatemaxlength/unitTimeLength);
            pauseTime = obj.totalsecond/graph_time_length/speed;
            
            % Current support 8 pairs of channel
            positionList = [[660, 0, 640, 480];...
                            [660, 500, 640, 480];...
                            [0, 0, 640, 480];...
                            [0, 500, 640, 480];...
                            [650*2, 0, 640, 480];...
                            [650*2, 500, 640, 480];...
                            [650*3, 500, 640, 480];...
                            [650*3, 500, 640, 480]];
            
            
            % Preallocating
            Xtemp = zeros(pairs, graph_time_length, graph_freq_length);
            Ytemp = zeros(pairs, graph_time_length, graph_freq_length);
            Ztemp = zeros(pairs, graph_time_length, graph_freq_length);
            
            % Store processed signal
            for i = 1:pairs
                [Xq, Yq, Zq] = obj.ProcessDoubleSignal(channels(i*2-1), channels(i*2));
                Xtemp(i, :, :) = Xq;
                Ytemp(i, :, :) = Yq;
                Ztemp(i, :, :) = Zq;
            end
            
            
            % Open figures, initial surfaces and annotations
            for i = 1:pairs
                figTemp = figure('Name', 'Plot Animated Double Signal');
                % Set window positions
                if(i < 8)
                    figTemp.Position = positionList(i, :);
                else
                    % In case of too many channel
                    figTemp.Position = positionList(1, :);
                end
                surfTemp = surf(reshape(Xtemp(i, 1:2, :), [2, graph_freq_length]), reshape(Ytemp(i, 1:2, :), [2, graph_freq_length]), reshape(Ztemp(i, 1:2, :), [2, graph_freq_length]));
                annoTemp = annotation('textbox', [0.15 0.15 0.3 0.15],...
                    'String', ['Time: ', num2str(unitTimeLength*2), 'Sec'],...
                    'FontSize',14, 'FitBoxToText','on', 'Color', 'white');
                
                figs(i) = figTemp;
                surfaces(i) = surfTemp;
                plotBaks(:, i) = obj.AddAuxiliaryInformation(figTemp, surfTemp, 'Animated', channels(i*2-1), channels(i*2));
                annotations(i) = annoTemp;
            end
            
            % Refresh figure respectively
            for time = 3:graph_time_length
                for i = 1:pairs
                    annotations(i).String = ['Time: ', sprintf('%3.2f', unitTimeLength*time), ' (second)']; % sec/10
                    if time*unitTimeLength <= obj.animatemaxlength
                        surfaces(i).XData = reshape(Xtemp(i, 1:time, :), [time, graph_freq_length]);    % replace surface x values
                        surfaces(i).YData = reshape(Ytemp(i, 1:time, :), [time, graph_freq_length]);     % replace surface y values
                        surfaces(i).ZData = reshape(Ztemp(i, 1:time, :), [time, graph_freq_length]);     % replace surface z values
                    else
                        surfaces(i).XData = reshape(Xtemp(i, time-dataPointAnimateLength:time, :), [dataPointAnimateLength+1, graph_freq_length]);    % replace surface x values
                        surfaces(i).YData = reshape(Ytemp(i, time-dataPointAnimateLength:time, :), [dataPointAnimateLength+1, graph_freq_length]);    % replace surface y values
                        surfaces(i).ZData = reshape(Ztemp(i, time-dataPointAnimateLength:time, :), [dataPointAnimateLength+1, graph_freq_length]);    % replace surface z values
                        obj.AddAuxiliaryInformation(figs(i), surfaces(i), 'AnimatedUpdate', channels(i*2-1), channels(i*2), plotBaks(:, i), unitTimeLength*(time-dataPointAnimateLength), unitTimeLength*time);
                    end
                    pause(pauseTime)
                end
            end
            
        end
    end
    
end

