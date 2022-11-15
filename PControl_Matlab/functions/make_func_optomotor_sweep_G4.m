% make_func_alternating_sweep_G4
% function generator - makes a function for sweeping vertical gratings in
% order to generate an optomotor reflex. Pauses, then sweeps CW, pauses,
% then sweeps CCW, pauses, etc.
%
% INPUTS
% funcN - specify function # to save as
% sweepRate - specifies sweep velocity in degrees/sec
%
% Created 09/05/2022 - MC
% Updated 10/05/2022 - MC adjusted sweep/break times
%

function make_func_optomotor_sweep_G4(funcN, sweepRate)

%% load settings
userSettings
funcFreq = 500;

breakDur = 4; %sec, time between spins
sweepDur = 0.5; %sec, time of each CW/CCW spin

%% generate function data

%set sample rate
velocity_px = (sweepRate/360) * 192;
sample_rate = round(funcFreq/velocity_px);
%create baseline sweep
sweepBase = 1:192;
sweepBase_sr = repelem(sweepBase,sample_rate); %base frequency at target sweep rate

%create first pause epoch
func_pause1 = ones(1,(breakDur/2)*funcFreq);
%create CW spin
func_optoCW = sweepBase_sr(1:sweepDur*funcFreq);
px_end = max(func_optoCW); %px value at end of spin to be held during pause
%create second pause epoch
func_pause2 = ones(1,breakDur*funcFreq).*px_end;
%create CCW spin
func_optoCCW = sweepBase_sr(sweepDur*funcFreq:-1:sample_rate);

%put everything together
func = [func_pause1 func_optoCW func_pause2 func_optoCCW func_pause1];

%set function data
pfnparam.func = func;
pfnparam.size = length(func);
pfnparam.dur = length(func)/funcFreq;

%set lookup table
funlookup.name = ['optomotor_at_' num2str(sweepRate) 'degsec'];
funlookup.sweepDur = sweepDur;
funlookup.breakDur = breakDur;
funlookup.sweepRange = 0;
funlookup.sweepRangePx = 0;
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

