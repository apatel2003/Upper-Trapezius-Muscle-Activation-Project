%Pseudocode outlining how to find ECG R peaks with Matlab
%Submit the IBI for each condition

%% Step 1: Import or access relevant data
ecg_signal = Sakina_PNS1; %change test 1 to saved name%

%Plotting Raw Data
data1 = ecg_signal{:,2};
time_stamp = ecg_signal{:,1};
time_stamp = time_stamp - (time_stamp(1));
%figure
% plot(time_stamp, data1);

%Step 2: Copy signal values into a column vector and truncate
% change the truncation according to which data is being processed
ecg_signal_timestamp = time_stamp;
ecg_signal_heartbeat = data1;
%ecg_signal_redline = ecg_signal(:,3);

%change what we are dividing by accordingly based off the time of the condition
start = time_stamp(length(time_stamp)) - 90;
mask = time_stamp >= start;
ecg_signal_timestamp = ecg_signal_timestamp(mask);
ecg_signal_heartbeat = ecg_signal_heartbeat(mask);

%% Step 3: Create time column vector for each sample (signal value) using the
%relevant sampling frequency
sampling_frequency = 10000;


time_vector_timestamp = (1/sampling_frequency) * (0:height(ecg_signal_timestamp)-1);
time_vector_heartbeat = (1/sampling_frequency) * (0:height(ecg_signal_heartbeat)-1);
%time_vector_redline = (1/sampling_frequency) * (r/4:height(ecg_signal_redline)-1);

% creating a frequency vector (not the same as the time that was initially
% measured)

%% Step 4: Remove low frequency drift in the signal
%   Suggestions:
%       - Look at the to assess highest frequency of drift
%       - Consider lowest frequency of interest for isolating R peaks
%       - Look at movmean function as a simple way pull out the low
%       frequency portion of the signal

%ecg_signal_heartbeat = ecg_signal_heartbeat(:, :);
removed_data = ecg_signal_heartbeat - movmean(ecg_signal_heartbeat, sampling_frequency);

figure
plot(ecg_signal_timestamp, removed_data)

%% Step 5: Apply findpeaks function to the filtered signal
%   Suggestions:
%       - Read the documentation on findpeaks
%       - Take advantage of the various parameters to improve R-peak
%       identification

[peaks, ind] = findpeaks(removed_data, 'MinPeakHeight', 97, 'MinPeakDistance', 0.5);
%[peaks, ind] = findpeaks(removed_data, 'MinPeakHeight', 1, 'MinPeakDistance', sampling_frequency/2);
% It might be worth adding a threshold

%% Step 6: Find IBI from peak times output from findpeaks
%       - IBI is the time difference between subsequent peaks
%       - diff function is the simplest way to achieve this

indices = ecg_signal_timestamp(ind);
IBI = diff(indices);

avg = mean(IBI);
IQR = iqr(IBI);
for y = 1:length(IBI)
    if  IBI(y)< avg-1.5*(IQR)
        IBI(y) = -1;
    end
end
mask2 = IBI == -1;
IBI = IBI(~mask2);

%You may wish to plot your peak times against the raw data to assess how
%accurate your algorithm is.

figure
x = 1:length(IBI);
plot(x, IBI);

figure
plot(ecg_signal_timestamp, ecg_signal_heartbeat, 'b')
hold on
scatter(ecg_signal_timestamp(ind), (peaks + 500), 'Linewidth', 1.5, 'Marker','.', 'Color', 'r')
hold off