%% Step 1: Import or access relevant data
directory = dir('Subject*');
filenames = {directory(:).name}';

% Step 2: Extract condition keywords from each filename for sorting
conditions = cellfun(@(x) regexp(x, '\d+mph|\d+cm', 'match'), filenames, 'UniformOutput', false);

% Step 3: Convert conditions to sortable numbers (to make sorting more precise)
condition_numbers = cellfun(@(c) str2double(regexp(c{1}, '\d+', 'match')), conditions);

% Step 4: Sort filenames based on extracted condition numbers
[~, order] = sort(condition_numbers);
filenames = filenames(order);

% Initialize RMS arrays
RMS_Left_1mph = [];
RMS_Right_1mph = [];
RMS_Left_2mph = [];
RMS_Right_2mph = [];
RMS_Left_3mph = [];
RMS_Right_3mph = [];
RMS_Left_10cm = [];
RMS_Right_10cm = [];
RMS_Left_20cm = [];
RMS_Right_20cm = [];
RMS_Left_30cm = [];
RMS_Right_30cm = [];
data_structR = struct('Stand10cm',[],'Stand20cm',[],'Stand30cm',[],'Walk1mph',[], ...
                        'Walk2mph',[],'Walk3mph',[]);
data_structL = struct('Stand10cm',[],'Stand20cm',[],'Stand30cm',[],'Walk1mph',[], ...
                        'Walk2mph',[],'Walk3mph',[]);

for i = 1:length(filenames)
    % Load the data from the file
    loadedData = load(filenames{i});
    filename = fieldnames(loadedData);  % Get the structure field name dynamically
    ecg_signal_cell = loadedData.(filename{1});

    % Process each condition (Left/Right)
    for z = 1:2
        ecg_signal = ecg_signal_cell{1,z};
        sampling_frequency = 1200;
        baud_rate = 230400;

        % Plotting Raw Data (optional)
        data1 = ecg_signal{:,2};
        time_stamp = ecg_signal{:,1};
        time_stamp = time_stamp - (time_stamp(1));
        y = time_stamp(length(time_stamp));
        step = time_stamp(length(time_stamp))/length(time_stamp);
        time = (0:step:y)';
        time = time(1:length(time)-1);

        % Convert to Voltage
        data1 = data1 .* (5 / 1023);

        % Apply signal processing
        ecg_signal_timestamp = time_stamp;
        ecg_activation = data1;
        start = time_stamp(length(time_stamp)) - (time_stamp(length(time_stamp)-time_stamp(1)));
        mask = time_stamp >= start;
        ecg_signal_timestamp = ecg_signal_timestamp(mask);
        ecg_activation = ecg_activation(mask);

        %% Step 3: Create time column vector for each sample (signal value)
        time = (1/sampling_frequency) * (0:height(time)-1);
        time_activation = (1/sampling_frequency) * (0:height(ecg_activation)-1);

        %% Step 4: Remove noise in the signal
        removed_data = ecg_activation - movmean(ecg_activation, sampling_frequency);
        fc = 65;  % Cutoff frequency (Hz)
        [b, a] = butter(6, fc / (sampling_frequency / 2));
        removed_data = filter(b, a, removed_data);
        removed_data = abs(removed_data);
        time_stamp = time_stamp((length(time_stamp)/6)+1:end-(length(time_stamp)/6));
        removed_data = removed_data((length(removed_data)/6)+1:end-(length(removed_data)/6));

        %% Step 5: Apply findpeaks function to the filtered signal
        [peaks, ind] = findpeaks(removed_data, 'MinPeakHeight', max(removed_data) - 0.15, 'MinPeakDistance', 5 * sampling_frequency);

        %% Calculate RMS for the detected activation values
        activation_values = removed_data(ind);
        RMS = sqrt(mean(activation_values .^ 2));

        %% Step 6: Separate into categories based on the filename
        if contains(filenames{i}, 'Walk')
            % Walking conditions
            if contains(filenames{i}, '1mph')
                if z == 1
                    RMS_Right_1mph = [RMS_Right_1mph; RMS];
                    data_structR(i).Walk1mph = RMS;
                else
                    RMS_Left_1mph = [RMS_Left_1mph; RMS];
                    data_structL(i).Walk1mph = RMS;
                end
            elseif contains(filenames{i}, '2mph')
                if z == 1
                    RMS_Right_2mph = [RMS_Right_2mph; RMS];
                    data_structR(i).Walk2mph = RMS;
                else
                    RMS_Left_2mph = [RMS_Left_2mph; RMS];
                    data_structL(i).Walk2mph = RMS;
                end
            elseif contains(filenames{i}, '3mph')
                if z == 1
                    RMS_Right_3mph = [RMS_Right_3mph; RMS];
                    data_structR(i).Walk3mph = RMS;
                else
                    RMS_Left_3mph = [RMS_Left_3mph; RMS];
                    data_structL(i).Walk3mph = RMS;
                end
            end
        elseif contains(filenames{i}, 'Stand')
            % Standing conditions
            if contains(filenames{i}, '10cm')
                if z == 1
                    RMS_Right_10cm = [RMS_Right_10cm; RMS];
                    data_structR(i).Stand10cm = RMS;
                else
                    RMS_Left_10cm = [RMS_Left_10cm; RMS];
                    data_structL(i).Stand10cm = RMS;
                end
            elseif contains(filenames{i}, '20cm')
                if z == 1
                    RMS_Right_20cm = [RMS_Right_20cm; RMS];
                    data_structR(i).Stand20cm = RMS;
                else
                    RMS_Left_20cm = [RMS_Left_20cm; RMS];
                    data_structL(i).Stand20cm = RMS;
                end
            elseif contains(filenames{i}, '30cm')
                if z == 1
                    RMS_Right_30cm = [RMS_Right_30cm; RMS];
                    data_structR(i).Stand30cm = RMS;
                else
                    RMS_Left_30cm = [RMS_Left_30cm; RMS];
                    data_structL(i).Stand30cm = RMS;
                end
            end
        end
    end
end
