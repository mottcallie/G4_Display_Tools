% make_func_alternating_sweep_G4
% function generator - makes a function for separating the position and
% velocity components of a stimulus. Object will populate a given sweep
% range with broken up sweeps of a specified length and speed in either
% direction. Presentation randomized each time.

% INPUTS
% funcN - specify function # to save as
% sweepRange - specifies total sweep range, in degree
% sweepRate - specifies sweep velocity, in degrees/sec
% objSize - centers sweep

% 02/19/2023 - MC created

function make_func_broken_sweep_G4(funcN, sweepRange, sweepRate, objSize)

%% load settings
userSettings
funcFreq = 500;

breakDur = 3;
px_center = 88 - (objSize/2); %set sweep center
px_hidden = 184 - (objSize/2); %set hidden position (empty column)

%% generate function data

% set parameters for broken sweeps
px_increment = 6; %increment between each broken sweep start position
px_sweeplength = 12; %length of each broken sweep

% determine all broken sweep start/stop positions
px_range = (sweepRange/360) * 192; %convert range to px
px_max = px_center + px_range/2; %set max position
px_min = px_center - px_range/2; %set min position

px_starts = px_min:px_increment:px_max; %set all broken sweep start positions
nSweeps = length(px_starts);
px_R_end = px_starts+px_sweeplength; %set rightward broken sweep end positions
px_L_end = px_starts-px_sweeplength; %set leftward broken sweep end positions

% generate all broken sweeps within specified range
base_sweeps = []; %initialize
for s = 1:nSweeps
    % generate both left and right sweeps for this start position
    thisRight = px_starts(s):1:px_R_end(s);
    thisLeft = px_starts(s):-1:px_L_end(s);
    % combine into stored sweep matrix
    base_sweeps = [base_sweeps thisRight' thisLeft'];
end

% stretch sweeps based on sweep velocity and function frequency
px_velocity = (sweepRate/360) * 192; %convert from degrees to pixels
sample_rate = round(funcFreq/px_velocity); %px dwell time
base_sweeps_sr = repelem(base_sweeps,sample_rate,1); %stretch

% generate break array
breaks_sr = ones(1,(breakDur/2)*funcFreq)*px_hidden; %breaks place obj in empty column (hidden)

% randomize sweeps and add break arrays before/after each
func = []; %initialize
for rp = randperm(nSweeps*2)
    thisSweep = base_sweeps_sr(:,rp)'; %pull sweep
    func = [func breaks_sr thisSweep breaks_sr]; %combine
end

%set function data
pfnparam.func = func;
pfnparam.size = length(func);
pfnparam.dur = length(func)/funcFreq;

%set lookup table
funlookup.name = ['broken_' sprintf('%02d', px_increment) 'pxspacers_with_' sprintf('%02d', px_sweeplength) 'pxsweeps_at_' sprintf('%03d', sweepRate) 'ds_' sprintf('%02d', objSize) 'pxo'];
funlookup.sweepRange = sweepRange;
funlookup.sweepRangePx = px_range;
funlookup.sweepSpacers = px_increment;
funlookup.sweepLengths = px_sweeplength;
funlookup.sweepRate = round((360*funcFreq)/(sample_rate*192));
funlookup.frequency = funcFreq;

%% save function data

%set and save function data
funcName = [sprintf('%04d', funcN) '_' funlookup.name];
matFileName = fullfile([exp_path, '\Functions'], [funcName, '.mat']);
save(matFileName, 'pfnparam');

%save function lookup table
funcLookUp = ['func_lookup_' sprintf('%04d', funcN)];
matFileName = fullfile(function_path, [funcLookUp, '.mat']);
save(matFileName, 'funlookup');


%save header in the first block
block_size = 512; % all data must be in units of block size
Header_block = zeros(1, block_size);
Header_block(1:4) = dec2char(length(func)*2, 4);     %each function datum is stored in two bytes in the currentFunc card
Header_block(5) = length(funcName);
Header_block(6: 6 + length(funcName) -1) = funcName;
%concatenate the header data with function data
functionData = signed_16Bit_to_char(func);     
Data_to_write = [Header_block functionData];

%write to the fun image file
fid = fopen(fullfile([exp_path '\Functions'], ['func', sprintf('%04d', funcN), '.pfn']), 'w');
fwrite(fid, Data_to_write(:),'uchar');
fclose(fid);



end

