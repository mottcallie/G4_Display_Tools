% make_patt_box_G4
% Pattern generator that creates a single box at a set height for the G4 display.
%
% INPUTS:
%   pattN - Pattern number for saving the generated pattern.
%   objWidth - Size of the box in pixels.
%   objPolar - Set polarity to 'dark' for a dark object on a bright background 
%              or 'bright' for a bright object on a dark background.
%   distFromTop - Distance of the object from the top of the arena in pixels.
%   maxGS - Maximum grayscale intensity for the background.
%
% OUTPUTS:
%   Saves the generated pattern data, lookup table, and pattern file to the specified 
%   paths.
%
% Created: 01/10/2021 - MC
%
function  make_patt_box_G4(pattN, objWidth, objPolar, distFromTop, maxGS)

%% set meta data

userSettings

pattern.x_num = 192; 	
pattern.y_num = 1;

pattern.num_panels = NumofRows*NumofColumns; 	
pattern.gs_val = 4; %1 or 4
pattern.stretch = zeros(pattern.x_num, pattern.y_num); %match frames
frameN = 16*NumofRows; %px per row
frameM = 16*NumofColumns; %px per col

%initialize pattern data
Pats = zeros(frameN, frameM, pattern.x_num, pattern.y_num);

%set object parameters
if contains(objPolar,'d') %dark obj on bright background
    objGS = 1; %object
    bckGS = maxGS; %background
else %bright obj on dark background
    objGS = maxGS; %object
    bckGS = 1; %background
end


%% generate pattern data

%initialize images
bckImage = ones(frameN, frameM) * bckGS;

boxImage = bckImage;
boxImage((end-distFromTop-objWidth):(end-distFromTop),1:objWidth) = objGS;

%generate pattern image based on selection
patImage = boxImage;
Pats(:, :, 1, 1) = patImage;

%rotate
for x = 2:frameM
    Pats(:,:,x,1) = ShiftMatrix(Pats(:,:,x-1,1),1,'r','y');
end

%save lookup table
patlookup.fullname = [sprintf('%02d', objWidth) 'px_' num2str(objGS) 'gs' objPolar '_box_' sprintf('%02d', distFromTop) 'high_' num2str(bckGS) 'gsbck'];
patlookup.name = [sprintf('%02d', objWidth) 'px_' objPolar 'box_' sprintf('%02d', distFromTop) 'high'];
patlookup.size = objWidth;
patlookup.height = distFromTop;
patlookup.object = 'box';
patlookup.objgs = objGS;
patlookup.bckgs = bckGS;
        

%store pattern data
pattern.Pats = Pats;
%get the vector data
pattern.data = make_pattern_vector_g4(pattern);


%% save pattern data

%set and save pattern data
pattName = [sprintf('%04d', pattN) '_' patlookup.name];
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

