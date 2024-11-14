%% one-way ANOVA

% names = {"LeftStand", "RightStand", "LeftWalk", "RightWalk"};

% will extract the first 18 participants because some data is missing for
% some conditions
LeftStand = [RMS_Left_10cm(1:18, :), RMS_Left_20cm(1:18, :), RMS_Left_30cm(1:18, :)]
RightStand = [RMS_Right_10cm(1:18, :), RMS_Right_20cm(1:18, :), RMS_Right_30cm(1:18, :)]
LeftWalk = [RMS_Left_1mph(1:18, :), RMS_Left_2mph(1:18, :), RMS_Left_3mph(1:18, :)]
RightWalk = [RMS_Right_1mph(1:18, :), RMS_Right_2mph(1:18, :), RMS_Right_3mph(1:18, :)]

% one analysis per stand/walk per left/right
[p,tbl,stats] = anova1(LeftStand)
[p,tbl,stats] = anova1(RightStand)
[p,tbl,stats] = anova1(LeftWalk)
[p,tbl,stats] = anova1(RightWalk)