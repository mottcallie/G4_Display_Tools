% make_func_alternating_sweep_G4
% Function generator that creates a function for sweeping visual objects across
% a specified range and at a specified velocity.
%
% INPUTS:
%   funcN - Function number for saving the generated function.
%   sweepRange - Specifies the sweep range in degrees, centered at midline.
%   sweepRate - Specifies the sweep velocity in degrees/sec.
%   objSize - Size of the object, used to center the sweep.
%
% OUTPUTS:
%   Saves the generated function data and lookup table to the specified 
%   paths, along with a header for the function file.
%
% Created: 10/25/2021 - MC
% Updated: 12/01/2021 - MC separated range and velocity.
%
function make_func_alternating_sweep_G4(funcN, sweepRange, sweepRate, objSize)

%% load settings
userSettings
funcFreq = 500;

%% generate function data 
%convert from degrees to pixels
range_px = (sweepRange/360) * 192;
velocity_px = (sweepRate/360) * 192;

%set center
center = 88 - (objSize/2);
sweepAway = 0:1:range_px/2;
sweepBack = range_px/2-1:-1:1;

sweep = [(center-sweepBack) (center+sweepAway) (center+sweepBack) (center-sweepAway) ];

%stretch according to sweep velocity and function frequency
sample_rate = round(funcFreq/velocity_px);
sweepVelocity_actual = round((360*funcFreq)/(sample_rate*192)); %adjust

%set function
func = repelem(sweep,sample_rate);

%set function data
pfnparam.func = func;
pfnparam.size = length(func);
pfnparam.dur = length(func)/funcFreq;

%set lookup table
funlookup.name = ['oscillate_' sprintf('%03d', sweepRange) 'arc_at_' sprintf('%03d', sweepRate) 'ds_' sprintf('%02d', objSize) 'pxo'];
funlookup.sweepRange = sweepRange;
funlookup.sweepRangePx = range_px;
funlookup.sweepRate = sweepVelocity_actual;
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

