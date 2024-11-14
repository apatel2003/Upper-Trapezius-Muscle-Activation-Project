%% GRAPHS

%% BOXPLOTS

% RMS Right Walk
% Combine all data into one array and create a grouping variable
figure
RMS_data = [RMS_Right_1mph; RMS_Right_2mph; RMS_Right_3mph];
group = [repmat("1 mph", length(RMS_Right_1mph), 1); 
         repmat("2 mph", length(RMS_Right_2mph), 1); 
         repmat("3 mph", length(RMS_Right_3mph), 1)];

% Create the box plot with grouped data
subplot(2,2,1)
h = boxplot(RMS_data, group, 'Colors', ['m', 'b', 'k']);
title('RMS Data for Different Speeds (Right Side)');
xlabel('Speed');
ylabel('RMS Value');

% Set the line width for all boxplot components (boxes, whiskers, etc.)
for k = 1:7
    set(h(k,:), 'LineWidth', 1);
end

% RMS Left Walk
RMS_data = [RMS_Left_1mph; RMS_Left_2mph; RMS_Left_3mph];
group = [repmat("1 mph", length(RMS_Right_1mph), 1); 
         repmat("2 mph", length(RMS_Right_2mph), 1); 
         repmat("3 mph", length(RMS_Right_3mph), 1)];

% Create the box plot with grouped data
subplot(2,2,2)
h = boxplot(RMS_data, group, 'Colors', ['m', 'b', 'k']);
title('RMS Data for Different Speeds (Left Side)');
xlabel('Speed');
ylabel('RMS Value');

% Set the line width for all boxplot components (boxes, whiskers, etc.)
for k = 1:7
    set(h(k,:), 'LineWidth', 1);
end

% RMS Right Stand
RMS_data = [RMS_Right_10cm; RMS_Right_20cm; RMS_Right_30cm];
group = [repmat("10 cm", length(RMS_Right_1mph), 1); 
         repmat("20 cm", length(RMS_Right_2mph), 1); 
         repmat("30 cm", length(RMS_Right_3mph), 1)];

% Create the box plot with grouped data
subplot(2,2,3)
h = boxplot(RMS_data, group, 'Colors', ['m', 'b', 'k']);
title('RMS Data for Different Strap Lengths (Right Side)');
xlabel('Strap Length');
ylabel('RMS Value');

% Set the line width for all boxplot components (boxes, whiskers, etc.)
for k = 1:7
    set(h(k,:), 'LineWidth', 1);
end

% RMS Left Stand
RMS_data = [RMS_Left_10cm; RMS_Left_20cm; RMS_Left_30cm];
group = [repmat("10 cm", length(RMS_Right_1mph), 1); 
         repmat("20 cm", length(RMS_Right_2mph), 1); 
         repmat("30 cm", length(RMS_Right_3mph), 1)];

% Create the box plot with grouped data
subplot(2,2,4)
h = boxplot(RMS_data, group, 'Colors', ['m', 'b', 'k']);
title('RMS Data for Different Strap Lengths (Left Side)');
xlabel('Strap Length');
ylabel('RMS Value');

% Set the line width for all boxplot components (boxes, whiskers, etc.)
for k = 1:7
    set(h(k,:), 'LineWidth', 1);
end

%% Percent Graphs

% Initialize arrays to store percent differences for all subjects
percent_diff_stand_10_20_R = [];
percent_diff_stand_20_30_R = [];
percent_diff_stand_10_20_L = [];
percent_diff_stand_20_30_L = [];

percent_diff_walk_1_2_R = [];
percent_diff_walk_2_3_R = [];
percent_diff_walk_1_2_L = [];
percent_diff_walk_2_3_L = [];

% Initialize arrays for storing non-empty RMS values for each condition
filtered_RMS = struct('Stand10cm', [], 'Stand20cm', [], 'Stand30cm', [], ...
                      'Walk1mph', [], 'Walk2mph', [], 'Walk3mph', []);

% Iterate through each condition in the structure
fields = fieldnames(data_structR);

for i = 1:length(fields)
    % Check if field exists and has data
    if isfield(data_structR, fields{i}) && isfield(data_structL, fields{i})
        % Extract the current field data for right and left
        right_condition_data = [data_structR.(fields{i})];
        left_condition_data = [data_structL.(fields{i})];
        
        % Skip if both are completely empty
        if isempty(right_condition_data) && isempty(left_condition_data)
            warning('Field %s contains empty data for both right and left', fields{i});
            continue;
        end

        % Check if data is a cell array
        if iscell(right_condition_data) && iscell(left_condition_data)
            % Filter out empty cells if it's a cell array
            filtered_RMS.(fields{i}).Right = right_condition_data(~cellfun(@isempty, right_condition_data));
            filtered_RMS.(fields{i}).Left = left_condition_data(~cellfun(@isempty, left_condition_data));
            
        % Check if data is numeric (i.e., not in cell arrays)
        elseif isnumeric(right_condition_data) && isnumeric(left_condition_data)
            % Filter out zeros or NaNs if the data is a numeric array
            filtered_RMS.(fields{i}).Right = right_condition_data(right_condition_data ~= 0 & ~isnan(right_condition_data));
            filtered_RMS.(fields{i}).Left = left_condition_data(left_condition_data ~= 0 & ~isnan(left_condition_data));
            
        else
            % Log a warning if neither cell nor numeric, with type details
            warning('Unexpected data format for %s. Expected cell or numeric array, but got %s for right and %s for left.', ...
                    fields{i}, class(right_condition_data), class(left_condition_data));
        end
    else
        warning('Field %s does not exist in one of the structures or is empty', fields{i});
    end
end

% filtered_RMS should now contain cleaned data, regardless of format

% Assuming 'filtered_RMS' contains processed data with fields for each condition and level (Stand10cm, Walk10cm, etc.)

% Define the levels for comparison
levels = {'10cm', '20cm', '30cm';
            '1mph', '2mph', '3mph'};
conditions = {'Stand', 'Walk'};
sides = {'Left', 'Right'};

% Initialize structure to hold percent differences
percent_diffs_R = struct();
percent_diffs_L = struct();

for z = 1:length(conditions)
    for i = 1:length(levels)
        level = levels{z, i};
        if i < length(levels)
            level2 = levels{z, i+1};
            for j = 1:length(sides)
                side = sides{j};

                % Retrieve the relevant data for standing and walking conditions at this level
                data = filtered_RMS.([conditions{z} level]).(side);
                data2 = filtered_RMS.([conditions{z} level2]).(side);

                % Calculate mean values for each condition at this level and side
                mean1 = mean(data1);
                mean2 = mean(data2);

                % Calculate the percent difference
                percent_diff = ((mean2 - mean1) / mean1 ) * 100;

                % Store the percent difference
                namefield = ['Compare_' level '_' level2];
                if j == 2
                    percent_diffs_R.(conditions{z}).(namefield) = percent_diff;
                else
                    percent_diffs_L.(conditions{z}).(namefield) = percent_diff;
                end
            end
        end
    end
end

% Extract percent differences for left and right sides
left_diffs = [percent_diffs_L.Stand.('Compare_10cm_20cm'), percent_diffs_L.Stand.('Compare_20cm_30cm');
              percent_diffs_L.Walk.('Compare_1mph_2mph'), percent_diffs_L.Walk.('Compare_2mph_3mph')];
right_diffs = [percent_diffs_R.Stand.('Compare_10cm_20cm'), percent_diffs_R.Stand.('Compare_20cm_30cm');
              percent_diffs_R.Walk.('Compare_1mph_2mph'), percent_diffs_R.Walk.('Compare_2mph_3mph')  ];

left_diffs_avg_stand = (left_diffs(1,:))';
right_diffs_avg_stand = (right_diffs(1,:))';
left_diffs_avg_walk = (left_diffs(2,:))';
right_diffs_avg_walk = (right_diffs(2,:))';

stand_diffs = [left_diffs(1,:); right_diffs(1,:)];
walk_diffs = [left_diffs(2,:); right_diffs(2,:)];

stand_label = {'10cm to 20cm', '20cm to 30cm'};
walk_label = {'1mph to 2mph', '2mph to 3mph'};


% Plotting Stacked Bar Graphs
figure
subplot(2,1,1)
barData = bar(stand_diffs, 'grouped');
barData(1).FaceColor = 'magenta';
barData(2).FaceColor = 'blue';
for k = 1:length(barData)
    barData(k).EdgeColor = 'black';
end

xticklabels(stand_label);
ylabel('Average Percent Difference');
title('Average Percent Differences Between Strap Lengths');
legend('Left', 'Right');

subplot(2,1,2)
barData = bar(walk_diffs, 'grouped');
barData(1).FaceColor = 'magenta';
barData(2).FaceColor = 'blue';
for k = 1:length(barData)
    barData(k).EdgeColor = 'black';
end

xticklabels(stand_label);
ylabel('Average Percent Difference');
title('Average Percent Differences Between Speeds');
legend('Left', 'Right');
