% make_func_motion_pulse_G4
% Function generator that creates a function for generating motion pulses 
% of visual objects across a specified range at a specified velocity. 
% The object will have pauses between sweeps to allow for optogenetic stimulation.
%
% INPUTS:
%   funcN - Function number for saving the generated function.
%   sweepRange - Specifies the total sweep range in degrees.
%   sweepRate - Specifies the sweep velocity in degrees/sec.
%   objSize - Size of the object, used to center the sweep.
%
% OUTPUTS:
%   Saves the generated function data and lookup table to the specified 
%   paths, along with a header for the function file.
%
% Created: 02/19/2023 - MC
% Updated: 04/27/2023 - MC updated to include speed range.
%
function make_func_motion_pulse_G4(funcN, sweepRange, sweepRate, objSize)

%% load settings
userSettings
funcFreq = 500;

breakDur = 1; %second
px_center = 88 - (objSize/2); %set sweep center
px_hidden = 184 - (objSize/2); %set hidden position (empty column)

%% generate function data

% set parameters for broken sweeps
px_increment = 12; %increment between each broken sweep start position
px_sweeplength = 12; %length of each broken sweep

% determine all broken sweep start/stop positions
px_range = (sweepRange/360) * 192; %convert range to px
px_max = px_center + px_range/2; %set max position
px_min = px_center - px_range/2; %set min position

px_starts = px_min:px_increment:px_max; %set all broken sweep start positions
px_R_end = px_starts+px_sweeplength; %set rightward broken sweep end positions
px_L_end = px_starts-px_sweeplength; %set leftward broken sweep end positions

% generate all broken sweeps within specified range
sweepsPerSpeed = length(px_starts);
base_sweeps = []; %initialize
for sw = 1:sweepsPerSpeed
    % generate both left and right sweeps for this start position
    thisRight = px_starts(sw):1:px_R_end(sw);
    thisLeft = px_starts(sw):-1:px_L_end(sw);
    % combine into stored sweep matrix
    base_sweeps = [base_sweeps thisRight' thisLeft'];
end

% stretch sweeps based on sweep velocity and function frequency
speedsPerExpt = length(sweepRate);
sweeps_final = {}; %initialize
for sp = 1:speedsPerExpt
    base_sweeps_sr = []; %initialize

    thisSpeed = sweepRate(sp); %select this speed
    thisSpeed_px = (thisSpeed/360) * 192; %convert from degrees to pixels
    px_dwelltime = round(funcFreq/thisSpeed_px); %px dwell time
    base_sweeps_sr = repelem(base_sweeps,px_dwelltime,1); %stretch

    % store each sweep as a cell for easy calling
    for sw = 1:size(base_sweeps_sr,2)
        sweeps_final{end+1} = base_sweeps_sr(:,sw);
    end
end

% generate break array
breaks_sr = ones(1,(breakDur/2)*funcFreq)*px_hidden; %breaks place obj in empty column (hidden)

% randomize sweeps and add break arrays before/after each
totalSweeps = size(sweeps_final,2);
func = []; %initialize
for rp = randperm(totalSweeps)
    thisSweep = sweeps_final{:,rp}'; %pull sweep
    func = [func breaks_sr thisSweep breaks_sr]; %combine
end
% add extra break buffer
func = [func repmat(breaks_sr,1,1)];

%set function data
pfnparam.func = func;
pfnparam.size = length(func);
pfnparam.dur = length(func)/funcFreq;

%set lookup table
funlookup.name = ['motionpulse_' sprintf('%02d', px_increment) 'pxspacers_with_' sprintf('%02d', px_sweeplength) 'pxsweeps_at_' sprintf('%03d', sweepRate) 'ds_' sprintf('%02d', objSize) 'pxo'];
funlookup.sweepRange = sweepRange;
funlookup.sweepRangePx = px_range;
funlookup.sweepSpacers = px_increment;
funlookup.sweepLengths = px_sweeplength;
funlookup.sweepRate = round((360*funcFreq)/(px_dwelltime*192));
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

