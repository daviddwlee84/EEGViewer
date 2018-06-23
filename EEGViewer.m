classdef EEGViewer < handle
    %EEGViewer Electroencephalography signal analysis and visualization
    %   Detailed explanation goes here...
    
    
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
        
        %> Min drop
        mindrop
        %> Max range
        maxrange
        
        %> FFT Data Max
        fftdatamax
        
        %> Animate max length (ms)
        animatemaxlength
        
        
    end
    
    methods
        % ======================================================================
        %> @brief Class constructor
        %>
        %> @param path (Optional) Path to the *.edf file.
        %> @return instance of the EEGViewer class.
        % ======================================================================
        function obj = EEGViewer(path)
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
            
            [data, header] = read_edf(path);
            
            obj.Data = data;
            
            [obj.Filepath, obj.Filename] = fileparts(path);
            
            % Initial properties
            obj.Fs = header.samplingrate;   % Sampling frequency
            obj.T = 1/obj.Fs;               % Sampling period (1 us)
            obj.L = header.numtimeframes;   % Length of signal
            obj.t = (0:obj.L-1)*obj.T;      % Time vector

            obj.rng = 1000; % Proceed fft every rng data
            obj.totalsecond = obj.L/obj.rng; % Total iteration
            
            obj.numchannels = header.numchannels; % Number of channels
            obj.channelNames = header.channels;   % Channel names
            
            obj.mindrop = 0; % Drop min
            obj.fftdatamax = inf; % Maximum data value
            obj.maxrange = inf; % Manual maximum value
            
            obj.animatemaxlength = 3*60; % Maximum time length of animated plot (Default 3 mins)
        end
        
        % ======================================================================
        %> @brief Scroll view on data (Optional)
        %>
        % ======================================================================
        function ScrollView(obj)
            eegplot(obj.Data, 'srate', obj.Fs, 'title', 'Scroll View', 'plottitle', ['Scroll view on data of ', obj.Filename], 'xgrid', 'on', 'ygrid', 'on')
        end
        
        % ======================================================================
        %> @brief Band-pass filter data using two-way least-squares FIR filtering (Optional)
        %>
        %> @param obj instance of the EEGViewer class.
        %> @param min_filter instance of the EEGViewer class.
        %> @param max_filter instance of the EEGViewer class.
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
            
            if strcmp(type, 'Single')
                title(['Single-Sided Amplitude Spectrum of channel ', obj.channelNames(channel1, 1:3)])
                xlabel('f (Hz)')
                ylabel('t (sec)')
                zlabel('10*log_{10}(|P1(f)|) (\muV^{2}/Hz)')
                colorbar
                surface.EdgeColor = 'none';

                % Set colormap max color to red
                colormap jet
                clm = colormap;
                clm(end-7:end, 1) = 1;
                colormap(clm)
                
                % Set background colot to black
                set(gca,'Color','k')

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
                
                title(['Comparison of channel ', obj.channelNames(channel1, 1:3), ' and ', obj.channelNames(channel2, 1:3)])
                xlabel('f (Hz)')
                ylabel('t (sec)')
                zlabel('10*log_{10}(|P1(f)|) (\muV^{2}/Hz)')
                colorbar
                surface.EdgeColor = 'none';
                
                % Set colormap max color to RED
                colormap Jet
                clm = colormap;
                clm(end-7:end, 1) = 1;
                colormap(clm)
                
                % Set background colot to black
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
                view(180,15)         % set viewpoint
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
            end
            
            fig = figure('Name', ' Plot Single Signal');
            surface = surf(Xq, Yq, Zq);
            
            
            obj.AddAuxiliaryInformation(fig, surface, 'Single', channel)
            
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
                % Cover hole?!
                %Zq(1, :) = obj.mindrop;
                %Zq(end, :) = obj.mindrop;
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
            
            fig = figure('Name', ' Plot Double Signal');
            surface = surf(Xq, Yq, Zq);
            
            obj.AddAuxiliaryInformation(fig, surface, 'Double', channel1, channel2)

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
    end
    
end

