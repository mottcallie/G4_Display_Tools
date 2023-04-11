% make_func_alternating_sweep_G4
% function generator - makes a function for sweeping visual objects across
% a specified range and at a specified velocity, includes X sec pause at
% the start of each trial to allow for optogenetic stimulation

% INPUTS
% funcN - specify function # to save as
% sweepRange - specifies sweep range in degrees, centered at midline
% sweepRate - specifies sweep velocity in degrees/sec
% objSize - centers sweep

% 10/06/2022 - MC updated

function make_func_pause_alternating_sweep_G4(funcN, sweepRange, sweepRate, objSize)

%% load settings
userSettings
funcFreq = 500;

pauseDur = 5; %sec, pause preceding oscillation
% note: the pause duration here is a bit odd to account for the DAC/panel start delay
sweepDur = 60; %sec, total oscillation time

%% generate function data 
%convert from degrees to pixels
range_px = (sweepRange/360) * 192;
velocity_px = (sweepRate/360) * 192;

%create pause function
ctr = 88 - (objSize/2);
pause_func = ones(1,pauseDur*funcFreq).*ctr; %hold at center for duration

%create sweep function
amp = range_px/2;
sweepAway = 0:1:amp;
sweepBack = flip(sweepAway(2:end-1));
sweep = [(ctr+sweepAway) (ctr+sweepBack) (ctr-sweepAway) (ctr-sweepBack)]; %combine

% stretch sweep according to sweep speed
speed_sfq = round(funcFreq/velocity_px);
stimwave_single = repelem(sweep,speed_sfq);
stimwave_dur = length(stimwave_single);

% generate full target waveform
duration_sfq = sweepDur*funcFreq;
nsweeps = ceil(duration_sfq/stimwave_dur);          %rough # of sweeps given duration
wave_func = repmat(stimwave_single,1,nsweeps);      %repeat sweeps

%set function
func = [pause_func wave_func];

%set function data
pfnparam.func = func;
pfnparam.size = length(func);
pfnparam.dur = length(func)/funcFreq;

%set lookup table
funlookup.name = [num2str(sweepRange) 'deg_altsweeps_wpause_at_' num2str(sweepRate) 'degsec_' num2str(objSize) 'pxo'];
funlookup.sweepRange = sweepRange;
funlookup.sweepRangePx = range_px;
funlookup.sweepRate = sweepRate;
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

