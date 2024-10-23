% make_func_stationary_pulse_G4
% Function generator that creates a function for producing a stationary
% pulse stimulus with alternating positions and velocities. The object
% will populate a specified sweep range with broken-up sweeps of a 
% specified length and speed, randomized for each presentation.
%
% INPUTS:
%   funcN - Function number for saving the generated function.
%   sweepRange - Total sweep range in degrees.
%   objSize - Size of the object, used to center the sweep.
%
% OUTPUTS:
%   Saves the generated function data and lookup table to the specified 
%   paths, along with a header for the function file.
%
% Created: 02/19/2023 - MC
% Updated: 04/27/2023 - MC updated to include speed range.
%
function make_func_stationary_pulse_G4(funcN, sweepRange, objSize)

%% load settings
userSettings
funcFreq = 500;

pulseDur = 1; %second
breakDur = 1; %second
px_center = 88 - (objSize/2); %set sweep center
px_hidden = 184 - (objSize/2); %set hidden position (empty column)

%% generate function data

% set parameters for broken sweeps
px_increment = objSize; %increment between each broken sweep start position

% determine all broken sweep start/stop positions
px_range = (sweepRange/360) * 192; %convert range to px
px_max = px_center + px_range/2; %set max position
px_min = px_center - px_range/2; %set min position

px_pos = px_min:px_increment:px_max; %set all broken sweep start positions

%generate pulse array
pulse_sr = repmat(px_pos,pulseDur*funcFreq,1);
% generate break array
breaks_sr = ones(1,(breakDur/2)*funcFreq)*px_hidden; %breaks place obj in empty column (hidden)

% randomize sweeps and add break arrays before/after each
totalPos = length(px_pos);
func = []; %initialize
for rp = randperm(totalPos)
    thisSweep = pulse_sr(:,rp)'; %pull sweep
    func = [func breaks_sr thisSweep breaks_sr]; %combine
end
% add extra break buffer
func = [repmat(breaks_sr,1,5) func repmat(breaks_sr,1,5)];

%set function data
pfnparam.func = func;
pfnparam.size = length(func);
pfnparam.dur = length(func)/funcFreq;

%set lookup table
funlookup.name = ['stationarypulse_' sprintf('%02d', px_increment) 'pxspacers_' sprintf('%02d', objSize) 'pxo'];
funlookup.sweepRange = sweepRange;
funlookup.sweepRangePx = px_range;
funlookup.sweepSpacers = px_increment;
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

