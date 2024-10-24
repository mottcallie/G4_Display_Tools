% make_patt_verticalbar_G4
% Pattern generator that creates a single vertical bar for the G4 display.
%
% INPUTS:
%   pattN - Pattern number for saving the generated pattern.
%   objWidth - Size of the bar in pixels.
%   objPolar - Set polarity to 'dark' for a dark bar on a bright background 
%              or 'bright' for a bright bar on a dark background.
%   maxGS - Maximum grayscale value for the bar and background.
%
% OUTPUTS:
%   Saves the generated pattern data, lookup table, and pattern file to the specified 
%   paths.
%
% Created: 10/25/2021 - MC
% Updated: 10/29/2021 - MC added blank functionality.
%
function  make_patt_verticalbar_G4(pattN, objWidth, objPolar, maxGS)

%% set meta data

userSettings

pattern.x_num = 192; 	
pattern.y_num = 2;

pattern.num_panels = NumofRows*NumofColumns; 	
pattern.gs_val = 4; %1 or 4
pattern.stretch = zeros(pattern.x_num, pattern.y_num); %match frames
frameN = 16*NumofRows; %px per row
frameM = 16*NumofColumns; %px per col

%initialize pattern data
Pats = zeros(frameN, frameM, pattern.x_num, pattern.y_num);

%set brightness and object polarity
if contains(objPolar,'d') %dark bar on bright background
    objGS = 1; %object
    bckGS = maxGS; %background
else %bright bar on dark background
    objGS = maxGS; %object
    bckGS = 0; %background
end


%% generate pattern data

bckImage = ones(frameN, frameM) * bckGS; %initialize

% bar only
barImage = bckImage; 
barImage(:,1:objWidth) = objGS;
Pats(:, :, 1, 1) = barImage;
% background only
Pats(:, :, 1, 2) = bckImage;

%save lookup table
patlookup.fullname = [num2str(objWidth) 'px_' num2str(objGS) 'gs' objPolar '_bar_' num2str(bckGS) 'gsbck'];
patlookup.name = [num2str(objWidth) 'px_' objPolar 'bar'];
patlookup.size = num2str(objWidth);
patlookup.object = 'bar';
patlookup.objgs = objGS;
patlookup.bckgs = bckGS;

for x = 2:frameM
    Pats(:,:,x,1) = ShiftMatrix(Pats(:,:,x-1,1),1,'r','y');
    Pats(:,:,x,2) = ShiftMatrix(Pats(:,:,x-1,2),1,'r','y');
end

%store pattern data
pattern.Pats = Pats;
%get the vector data
pattern.data = make_pattern_vector_g4(pattern);


%% save pattern data

%set and save pattern data
pattName = [sprintf('%04d', pattN) '_' sprintf('%02d', objWidth) 'px_' objPolar 'bar'];
matFileName = fullfile([exp_path, '\Patterns'], [pattName, '.mat']);
save(matFileName, 'pattern');

%save pattern lookup table
pattLookUp = ['patt_lookup_' sprintf('%04d', pattN)];
matFileName = fullfile(pattern_path, [pattLookUp, '.mat']);
save(matFileName, 'patlookup');

%save pat file
patFileName = fullfile([exp_path, '\Patterns'], ['pat', sprintf('%04d', pattN), '.pat']);
fileID = fopen(patFileName,'w');
fwrite(fileID, pattern.data);
fclose(fileID);
end

