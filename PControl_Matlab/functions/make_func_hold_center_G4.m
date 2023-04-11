% make_func_hold_center_G4
% function generator - makes a function for holding at the center position

% INPUTS
% funcN - specify function # to save as
% altSweep - specifies both the range and sweep rate (1Hz)
% objSize - centers sweep

% 10/25/2021 - MC created

function make_func_hold_center_G4(funcN,objSize)

%% load settings
userSettings
funcFreq = 500;

%% generate function data 

%set center
center = 88 - (objSize/2);

%set function
func = ones(1,100) * center;

%set function data
pfnparam.func = func;
pfnparam.size = length(func);
pfnparam.dur = length(func)/funcFreq;

%set lookup table
funlookup.name = ['holdcenter_' sprintf('%02d',objSize) 'pxo'];
funlookup.sweepRange = 0;
funlookup.sweepRangePx = 0;
funlookup.sweepRate = 0;
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

