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
        %> Reused data
        reuse
        
        %> Data per seconds
        dps
        %> Total iteration
        totalrun

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
            obj.reuse = obj.rng/2;

            obj.dps = obj.Fs/obj.rng/2; % Data per seconds
            
            obj.numchannels = header.numchannels; % Number of channels
            obj.channelNames = header.channels;   % Channel names
            
            obj.mindrop = 0; % Drop min
            obj.fftdatamax = inf; % Maximum data value
            obj.maxrange = inf; % Manual maximum value
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
            Y = zeros(1, obj.L/obj.rng, obj.rng); % channel time length
            P2 = zeros(1, obj.L/obj.rng, obj.rng);
            P1 = zeros(1, obj.L/obj.rng, obj.rng/2+1);
            obj.totalrun = obj.L/obj.rng; % Total iteration
            for channel = 1:obj.numchannels
                for i = 1:obj.totalrun
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
        %> @brief Plot Signal Signal
        %>        If obj.mindrop has set (~=0), shift to xy-plane.
        %>        If obj.maxrange has set and greater obj.fftdatamax, set max colormap as it.
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

            [xx, yy] = meshgrid(f(1:31), 1:obj.totalrun);

            zz = fftdata(channel, 1:end, 1:31); % 1 x TotalSecond x 31
            zz = reshape(zz, [obj.L/obj.rng, 31]); % TotalSecond x 31
            
            % Interpolation
            newF = obj.Fs*(0:0.1:(obj.rng/2))/obj.rng;
            [Xq, Yq] = meshgrid(newF(1:301), 1:0.1:obj.totalrun);
            Zq = interp2(xx, yy, zz, Xq, Yq, 'cubic');

            % if fftdata < mindrop => set to mindrop
            if obj.mindrop > 0
                indices = Zq <= obj.mindrop;
                Zq(indices) = obj.mindrop;
            end
            if shift
                Zq = Zq - obj.mindrop;
            end
            
            figure
            s = surf(Xq, Yq, Zq);
            
            title(['Single-Sided Amplitude Spectrum of channel ', obj.channelNames(channel, 1:3)])
            xlabel('f (Hz)')
            ylabel('t (sec)')
            zlabel('10*log_{10}(|P1(f)|) (\muV^{2}/Hz)')
            colorbar
            s.EdgeColor = 'none';

            % Set colormap max color to red
            colormap jet
            clm = colormap;
            clm(end-7:end, 1) = 1;
            colormap(clm)

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

            % f(1) is 0Hz
            %delta
            [x_delta, y_delta] = meshgrid(1:3, 1:obj.totalrun);
            plot(x_delta, y_delta, 'b')
            %theta
            [x_theta, y_theta] = meshgrid(4:7, 1:obj.totalrun);
            plot(x_theta, y_theta, 'g')
            %alpha
            [x_alpha, y_alpha] = meshgrid(8:12, 1:obj.totalrun);
            plot(x_alpha, y_alpha, 'r')
            %beta
            [x_beta, y_beta] = meshgrid(13:30, 1:obj.totalrun);
            plot(x_beta, y_beta, 'y') 
            
            hold off
            
            
        end
        % ======================================================================
        %> @brief Double Signal Processing
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

            [xx, yy] = meshgrid(f((obj.rng/2-29):(obj.rng/2+31)), 1:obj.totalrun);

            zz1 = fftdata(channel1, 1:end, 2:31);
            zz2 = fftdata(channel2, 1:end, 2:31);
            
            % 0Hz Value
            zeroHz(1:obj.totalrun) = (mean(mean(zz1)) + mean(mean(zz2)))/2;
            zeroHz = zeroHz';

            zz1 = reshape(zz1, [obj.L/obj.rng, 30]);
            zz2 = reshape(zz2, [obj.L/obj.rng, 30]);
            zz1 = fliplr(zz1);
            
            zz = [zz1, zeroHz, zz2];
            
            % Interpolation
            newF = obj.Fs*(-(obj.rng/2):0.1:(obj.rng/2))/obj.rng;
            [Xq, Yq] = meshgrid(newF((obj.rng*10/2-299):(obj.rng*10/2+301)), 1:0.1:obj.totalrun);
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
        %>        If obj.mindrop has set (~=0), shift to xy-plane.
        %>        If obj.maxrange has set and greater obj.fftdatamax, set max colormap as it.
        %>
        %> @param obj instance of the EEGViewer class.
        %> @param channel1 the first specific channel to plot.
        %> @param channel2 the second specific channel to plot.
        % ======================================================================
        function PlotDoubleSignal(obj, channel1, channel2)

            [Xq, Yq, Zq] = obj.ProcessDoubleSignal(channel1, channel2);
            
            figure
            s = surf(Xq, Yq, Zq);

            title(['Comparison of channel ', obj.channelNames(channel1, 1:3), ' and ', obj.channelNames(channel2, 1:3)])
            xlabel('f (Hz)')
            ylabel('t (sec)')
            zlabel('10*log_{10}(|P1(f)|) (\muV^{2}/Hz)')
            colorbar
            s.EdgeColor = 'none';

            % Set colormap max color to RED
            colormap Jet
            clm = colormap;
            clm(end-7:end, 1) = 1;
            colormap(clm)
            
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

            % f(1) is 0Hz
            %delta
            [x_delta, y_delta] = meshgrid(1:3, 1:obj.totalrun);
            plot(x_delta, y_delta, 'b')
            [x_delta, y_delta] = meshgrid(-1:-1:-3, 1:obj.totalrun);
            plot(x_delta, y_delta, 'b')
            %theta
            [x_theta, y_theta] = meshgrid(4:7, 1:obj.totalrun);
            plot(x_theta, y_theta, 'g')
            [x_theta, y_theta] = meshgrid(-4:-1:-7, 1:obj.totalrun);
            plot(x_theta, y_theta, 'g')
            %alpha
            [x_alpha, y_alpha] = meshgrid(8:12, 1:obj.totalrun);
            plot(x_alpha, y_alpha, 'r')
            [x_alpha, y_alpha] = meshgrid(-8:-1:-12, 1:obj.totalrun);
            plot(x_alpha, y_alpha, 'r')
            %beta
            [x_beta, y_beta] = meshgrid(13:30, 1:obj.totalrun);
            plot(x_beta, y_beta, 'y')
            [x_beta, y_beta] = meshgrid(-13:-1:-30, 1:obj.totalrun);
            plot(x_beta, y_beta, 'y') 
            
            hold off

        end
        
        % ======================================================================
        %> @brief Animated Plot Double Signal
        %>        If obj.mindrop has set (~=0), shift to xy-plane.
        %>        If obj.maxrange has set and greater obj.fftdatamax, set max colormap as it.
        %>
        %> @param obj instance of the EEGViewer class.
        %> @param channel1 the first specific channel to plot.
        %> @param channel2 the second specific channel to plot.
        % ======================================================================
        function AnimatedDoubleSignal(obj, channel1, channel2)
            
            [Xq, Yq, Zq] = obj.ProcessDoubleSignal(channel1, channel2);
            
            figure
            s = surf(Xq(1:2, :), Yq(1:2, :), Zq(1:2, :)); % surface must be a matrix (can't be a line)
            
            title(['Comparison of channel ', obj.channelNames(channel1, 1:3), ' and ', obj.channelNames(channel2, 1:3)])
            xlabel('f (Hz)')
            ylabel('t (sec)')
            zlabel('10*log_{10}(|P1(f)|) (\muV^{2}/Hz)')
            colorbar
            s.EdgeColor = 'none';

            % Set colormap max color to RED
            colormap Jet
            clm = colormap;
            clm(end-7:end, 1) = 1;
            colormap(clm)
            
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
            view(200,15)         % set viewpoint
            grid on
            hold on
            
            % f(1) is 0Hz
            %delta
            [x_delta, y_delta] = meshgrid(1:3, 1:obj.totalrun);
            plot(x_delta, y_delta, 'b')
            [x_delta, y_delta] = meshgrid(-1:-1:-3, 1:obj.totalrun);
            plot(x_delta, y_delta, 'b')
            %theta
            [x_theta, y_theta] = meshgrid(4:7, 1:obj.totalrun);
            plot(x_theta, y_theta, 'g')
            [x_theta, y_theta] = meshgrid(-4:-1:-7, 1:obj.totalrun);
            plot(x_theta, y_theta, 'g')
            %alpha
            [x_alpha, y_alpha] = meshgrid(8:12, 1:obj.totalrun);
            plot(x_alpha, y_alpha, 'r')
            [x_alpha, y_alpha] = meshgrid(-8:-1:-12, 1:obj.totalrun);
            plot(x_alpha, y_alpha, 'r')
            %beta
            [x_beta, y_beta] = meshgrid(13:30, 1:obj.totalrun);
            plot(x_beta, y_beta, 'y')
            [x_beta, y_beta] = meshgrid(-13:-1:-30, 1:obj.totalrun);
            plot(x_beta, y_beta, 'y') 
            
            a = annotation('textbox', [0.15 0.15 0.3 0.15],...
                'String', ['Time: ', num2str(obj.totalrun/length(Xq(:, 1))*2), 'Sec'],...
                'FontSize',14, 'FitBoxToText','on');
            
            % 3 => already plot 2
            for time = 3:length(Xq(:, 1)) % 3:obj.totalrun*10
                a.String = ['Time: ', sprintf('%3.2f', (obj.totalrun/length(Xq(:, 1)))*time), ' (second)']; % sec/10
                s.XData = Xq(1:time, :);    % replace surface x values
                s.YData = Yq(1:time, :);    % replace surface y values
                s.ZData = Zq(1:time, :);    % replace surface z values
                pause(obj.totalrun/length(Xq(:, 1))) % 0.1
            end
            
        end
    end
    
end

