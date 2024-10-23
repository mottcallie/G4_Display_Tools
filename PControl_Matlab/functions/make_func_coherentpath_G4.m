% make_func_coherentpath_G4
% Function generator that creates a function for moving a visual object 
% along a coherent, pseudorandom path.
%
% INPUTS:
%   funcN - Function number for saving the generated function.
%   sweepRange - Specifies the sweep range in degrees, centered at midline.
%   funcDur - Duration of the function in seconds.
%   objSize - Size of the object, used to center the sweep.
%
% OUTPUTS:
%   Saves the generated function data and lookup table to the specified 
%   paths, along with a header for the function file.
%
% Created: 08/05/2022 - MC
%
function make_func_coherentpath_G4(funcN, sweepRange, funcDur, objSize)

%% load in and set function settings
userSettings
funcFreq = 500; %hz

%set center
center = 88 - (objSize/2);

%% generate function data
sweepRange_px = (sweepRange/360) * 192;
sweepAmp_px = sweepRange_px/2;
sample_rate = funcFreq;

% generate path, with quality check
check = 'y';
while 1
    if strcmpi(check,'y')
        % plug values into coherent noise path generator
        path = coherent_pathgenerator(funcDur,sweepAmp_px,sample_rate);
        path_centered = path + center;
        
        % ensure object not exceeding display limits
        path_centered(path_centered>192) = 192;
        path_centered(path_centered<0) = 0;
        
        % quickly plot path and distribution
        t = 1/funcFreq:1/funcFreq:funcDur;
        clf('reset')
        subplot(3,1,1)
        plot(t,path_centered-center,'Color','#77AC30');axis tight
        axis tight;xlabel('time (sec)');ylabel('obj pos (deg)'); yline(0);
        subplot(3,1,2)
        histogram(path_centered-center,'FaceColor','#77AC30')
        axis tight; ylabel('position'); xline(0);
        subplot(3,1,3)
        histogram(diff(path_centered-center).*funcFreq,'FaceColor','#0072BD')
        axis tight; ylabel('velocity'); xline(0);
        
        %check = input('\nRun again? (y/n) ', 's');
        check = 'n';
    else
        disp('Path accepted!')
        break
    end
end

%set function data
func = path_centered;
pfnparam.func = func;
pfnparam.size = length(func);
pfnparam.dur = length(func)/funcFreq;

%set lookup table
funlookup.name = [num2str(sweepRange) 'deg_coherentpath_' num2str(objSize) 'pxo'];
funlookup.sweepRange = sweepRange;
funlookup.sweepRangePx = sweepRange_px;
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

