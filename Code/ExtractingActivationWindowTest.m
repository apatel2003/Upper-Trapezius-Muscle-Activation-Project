% _s in seconds, _i is indices

%max_s = timestamp(end); % replace this line for line below after extracting
%x column of raw data, which should be in seconds?
max_s = 25; % arbitrary value for now

sampleFreq = 1000;
secondsPerSample = 1/sampleFreq;
width_s = 0.5; % how long each shoulder shrug last
arrayToAdd_s = 0:0.001:width_s; % array of base timestamp values to add per shoulder shrug
timestampToExtract_s = []; % output array with timestamps that we would extract

n = floor(max_s/5); % number of shoulder shrugs
startTimes_s = (5:5:max_s) - 0.5/2; % array with start timestamps for each shrug

for x = startTimes_s 
    numsToAdd_s = arrayToAdd_s + x; % add start timestamp to base timestamp values
    timestampToExtract_s = [timestampToExtract_s numsToAdd_s]; % add to output array 
end

%numIndicesPer = width/secondsPerSample;
%arrayToAdd_i = 0:1:numIndicesPer;
%startIndices = ()
indicesToExtract_i = sampleFreq * timestampToExtract_s; % multiply by sample frequency to get indices 

