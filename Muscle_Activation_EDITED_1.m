%Pseudocode outlining how to find ECG R peaks with Matlab
%Submit the IBI for each condition

%% Step 1: Import or access relevant data
ecg_signal = Subject6_3mphWalk{1,1};

sampling_frequency = 1200;
%CHANGED FROM 1000 TO 1200
baud_rate = 230400;

%Plotting Raw Data
data1 = ecg_signal{:,2};
time_stamp = ecg_signal{:,1};
time_stamp = time_stamp - (time_stamp(1));
y = time_stamp(length(time_stamp));
step = time_stamp(length(time_stamp))/length(time_stamp);
time = (0:step:y)';
time = time(1:length(time)-1);
% PUT ABOVE 3 LINES BACK IN BECAUSE IT WAS ERRORING 

% figure
% plot(time_stamp, data1);
% title('Raw Data')

%Convert to Voltage
data1 = data1.*(5/1023);

figure
plot(time_stamp, data1);
title('Raw Data')
ylabel('Voltage')

%Step 2: Copy signal values into a column vector and truncate
% change the truncation according to which data is being processed
ecg_signal_timestamp = time_stamp;
ecg_activation = data1;
%ecg_signal_redline = ecg_signal(:,3);

%change what we are dividing by accordingly based off the time of the condition
start = time_stamp(length(time_stamp)) - (time_stamp(length(time_stamp)-time_stamp(1))); %change based off of time measured
mask = time_stamp >= start;
ecg_signal_timestamp = ecg_signal_timestamp(mask);
ecg_activation = ecg_activation(mask);

%% Step 3: Create time column vector for each sample (signal value) using the
%relevant sampling frequency

time = (1/sampling_frequency) * (0:height(time)-1);
time_activation = (1/sampling_frequency) * (0:height(ecg_activation)-1);
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
removed_data = ecg_activation - movmean(ecg_activation, sampling_frequency);

% Low-pass Butterworth filter
fc = 200;  % Cutoff frequency (Hz)
[b, a] = butter(6, fc/(sampling_frequency/2));  % 6th-order Butterworth filter

% Apply the filter
removed_data = filter(b, a, removed_data);

% figure
% plot(time_stamp, removed_data)
% title('Processed Data')

% Rectifying Signal
removed_data = abs(removed_data);

%% Step 5: Apply findpeaks function to the filtered signal
%   Suggestions:
%       - Read the documentation on findpeaks
%       - Take advantage of the various parameters to improve R-peak
%       identification

[peaks, ind] = findpeaks(removed_data, 'MinPeakHeight', 0.38, 'MinPeakDistance', 4*sampling_frequency);

% plot peaks found as red dots to verify that peaks are found correctly 
figure
plot(time_stamp, removed_data)
hold on
scatter(time_stamp(ind), (peaks), 'Linewidth', 1.5, 'Marker','.', 'Color', 'r')
hold off
title('Processed and Rectified Data')

% time = time_stamp;
% maxTime = time(length(time));
% step = 1/sampling_frequency;
% array = time;
% x = 4.8;
% while x <= maxTime
%     mask = time>=x & time<=x+0.4;
%     array = [array subArray];
%     x = x+5;
% end
% inds = find(ecg_signal_timestamp,array);

%% Finding the right indices

% _s in seconds, _i is indices

%max_s = timestamp(end); % replace this line for line below after extracting
%x column of raw data, which should be in seconds?
max_s = 59; % arbitrary value for now

sampleFreq = 1200;
secondsPerSample = 1/sampleFreq;
width_s = 0.1; % how long each shoulder shrug last
arrayToAdd_s = 0:secondsPerSample:width_s; % array of base timestamp values to add per shoulder shrug
timestampToExtract_s = []; % output array with timestamps that we would extract

%n = floor(max_s/5); number of shoulder shrugs
startTimes_s = ind'/sampling_frequency - width_s/2; % array with start timestamps for each shrug

for x = startTimes_s 
    numsToAdd_s = arrayToAdd_s + x; % add start timestamp to base timestamp values
    timestampToExtract_s = [timestampToExtract_s numsToAdd_s]; % add to output array 
end

%numIndicesPer = width/secondsPerSample;
%arrayToAdd_i = 0:1:numIndicesPer;
%startIndices = ()
indicesToExtract_i = sampleFreq * timestampToExtract_s; % multiply by sample frequency to get indices 
indicesToExtract_i = round(indicesToExtract_i);

mask = indicesToExtract_i < length(removed_data) & indicesToExtract_i > 0;
% ADDED ANOTHER CONDITION IN CASE IT IS NEGATIVE 
indicesToExtract_i = indicesToExtract_i(mask);

activation_values = removed_data(indicesToExtract_i);

figure
plot(1:length(activation_values),activation_values);
title('Activated Data')

%% Calculating RMS

RMS = sqrt((mean(activation_values.^2)))



