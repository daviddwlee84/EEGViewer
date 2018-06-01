classdef EEGViewer < handle
    %EEGViewer Electroencephalography signal analysis and visualization
    %   Detailed explanation goes here...
    
    
    properties
        %> Data
        Data
        
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
        end
        
        % ======================================================================
        %> @brief Scroll view on data
        %>
        % ======================================================================
        function ScrollView(obj)
            eegplot(obj.Data, 'srate', obj.Fs, 'title', 'Scroll View', 'plottitle', ['Scroll view on data of ', obj.Filename], 'xgrid', 'on', 'ygrid', 'on')
        end
        
        % ======================================================================
        %> @brief Band-pass filter data using two-way least-squares FIR filtering
        %>
        %> @param obj instance of the EEGViewer class.
        %> @param min_filter instance of the EEGViewer class.
        %> @param max_filter instance of the EEGViewer class.
        % ======================================================================
        function FIRfiltering(obj, min_filter, max_filter)
            obj.Data = eegfilt(obj.Data, obj.Fs, min_filter, max_filter);
        end
        
        % ======================================================================
        %> @brief Process FFT on data
        %>
        %> @param obj instance of the EEGViewer class.
        %> @retval ret return value of this method
        % ======================================================================
        function ret = DataProcess(obj)
            Y = zeros(1, obj.L/obj.rng, obj.rng); % channel time length
            P2 = zeros(1, obj.L/obj.rng, obj.rng);
            P1 = zeros(1, obj.L/obj.rng, obj.rng/2+1);
            obj.totalrun = obj.L/obj.rng; % Total iteration
            for channel = 1:obj.numchannels
                for i = 1:obj.totalrun
                    Y(channel, i, :) = fft(obj.Data(channel, 1+obj.rng*(i-1):obj.rng*i));
                    P2(channel, i, :) = abs(Y(channel, i, :));
                    P1(channel, i, :) = P2(channel, i, 1:obj.rng/2+1);
                    P1(channel, i, 2:end-1) = 2*P1(channel, i, 2:end-1);
                    P1(channel, i, 1) = 0; % Get rid of 0Hz data
                end
            end
            ret = P1;
        end
        
        % ======================================================================
        %> @brief Process Reuse version FFT on data
        %>
        %> @param obj instance of the EEGViewer class.
        %> @retval ret return value of this method
        % ======================================================================
        function ret = DataProcessReuse(obj)
            Y = zeros(obj.numchannels, obj.totalrun, obj.rng); % channel time length
            P2 = zeros(obj.numchannels, obj.totalrun, obj.rng);
            P1 = zeros(obj.numchannels, obj.totalrun, obj.rng/2+1);
            obj.totalrun = obj.L/obj.rng*2-1; % Total iteration
            for channel = 1:obj.numchannels
                for i = 1:obj.totalrun
                    Y(channel, i, :) = fft(obj.Data(channel, 1+obj.rng*((i-1)/2):obj.rng*(i-1)/2+1000));
                    P2(channel, i, :) = abs(Y(channel, i, :));
                    P1(channel, i, :) = P2(channel, i, 1:obj.rng/2+1);
                    P1(channel, i, 2:end-1) = 2*P1(channel, i, 2:end-1);
                    P1(channel, i, 1) = 0; % Get rid of 0Hz data
                end
            end
            ret = P1;
        end
        

        
        % ======================================================================
        %> @brief Plot Signal Signal
        %>
        %> @param obj instance of the EEGViewer class.
        %> @param channel the specific channel to plot.
        % ======================================================================
        function PlotSingleSignal(obj, channel)
            if channel > obj.numchannels
                error('No such channel')
            end
            
            fftdata = obj.DataProcess;
            
            f = obj.Fs*(0:(obj.rng/2))/obj.rng;

            [xx, yy] = meshgrid(f(1:31), 1:obj.totalrun);

            zz = fftdata(channel, 1:end, 1:31);
            zz = reshape(zz, [obj.L/obj.rng, 31]);

            figure
            s = surf(xx, yy, zz);
            title(['Single-Sided Amplitude Spectrum of channel ', obj.channelNames(channel, 1:3)])
            xlabel('f (Hz)')
            ylabel('t (sec)')
            zlabel('|P1(f)|')
            colorbar
            s.EdgeColor = 'none';
            colormap Jet
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
        %> @brief Plot Single Signal (Reuse the same half data of last process)
        %>
        %> @param obj instance of the EEGViewer class.
        %> @param channel the specific channel to plot.
        % ======================================================================
        function PlotSingleSignalReuse(obj, channel)
            if channel > obj.numchannels
                error('No such channel')
            end
            
            fftdata = obj.DataProcessReuse;
            
            f = obj.Fs*(0:(obj.rng/2))/obj.rng;

            [xx, yy] = meshgrid(f(1:31), 1:0.5:(obj.totalrun+1)/2);

            zz = fftdata(channel, 1:end, 1:31);
            zz = reshape(zz, [obj.totalrun, 31]);

            figure
            s = surf(xx, yy, zz);
            title(['Single-Sided Amplitude Spectrum of channel ', obj.channelNames(channel, 1:3), ' (Reuse version)'])
            xlabel('f (Hz)')
            ylabel('t (sec)')
            zlabel('|P1(f)|')
            colorbar
            colormap Jet
            s.EdgeColor = 'none';
            grid on
            hold on

            % f(1) is 0Hz
            %delta
            [x_delta, y_delta] = meshgrid(1:3, 1:(obj.totalrun+1)/2);
            plot(x_delta, y_delta, 'b')
            %theta
            [x_theta, y_theta] = meshgrid(4:7, 1:(obj.totalrun+1)/2);
            plot(x_theta, y_theta, 'g')
            %alpha
            [x_alpha, y_alpha] = meshgrid(8:12, 1:(obj.totalrun+1)/2);
            plot(x_alpha, y_alpha, 'r')
            %beta
            [x_beta, y_beta] = meshgrid(13:30, 1:(obj.totalrun+1)/2);
            plot(x_beta, y_beta, 'y')
            
            hold off
        end
        
        % ======================================================================
        %> @brief Plot Double Signal Symmetrically
        %>
        %> @param obj instance of the EEGViewer class.
        %> @param channel1 the first specific channel to plot.
        %> @param channel2 the second specific channel to plot.
        % ======================================================================
        function PlotDoubleSignal(obj, channel1, channel2)
            if channel1 > obj.numchannels || channel2 > obj.numchannels
                error('No such channel')
            end
            
            fftdata = obj.DataProcess;
            
            f = obj.Fs*(-(obj.rng/2):(obj.rng/2))/obj.rng;

            [xx, yy] = meshgrid(f((obj.rng/2-29):(obj.rng/2+31)), 1:obj.totalrun);

            zz1 = fftdata(channel1, 1:end, 2:31);
            zz2 = fftdata(channel2, 1:end, 2:31);
            zz1 = reshape(zz1, [obj.L/obj.rng, 30]);
            zz2 = reshape(zz2, [obj.L/obj.rng, 30]);
            zz1 = fliplr(zz1);
            zz = [zz1, zeros(obj.totalrun, 1), zz2];

            figure
            s = surf(xx, yy, zz);
            title(['Comparison of channel ', obj.channelNames(channel1, 1:3), ' and ', obj.channelNames(channel2, 1:3)])
            xlabel('f (Hz)')
            ylabel('t (sec)')
            zlabel('|P1(f)|')
            colorbar
            s.EdgeColor = 'none';
            colormap Jet
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
    end
    
end

