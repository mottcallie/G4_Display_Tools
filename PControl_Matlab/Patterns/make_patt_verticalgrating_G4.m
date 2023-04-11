% make_patt_verticalgrating_G4
% pattern generator, creates a vertical grating

% INPUTS:
% pattN - pattern number when saving
% objWidth - size of bar
% grtGS - grating intensity
% bckGS - background intensity

% 10/25/2021 - MC created
% 10/29/2021 - MC added blank
% 12/01/2021 - MC added grating gs

function  make_patt_verticalgrating_G4(pattN, objWidth, grtGS, bckGS)

%% set meta data

userSettings

pattern.x_num = 192; 	
pattern.y_num = 2;

pattern.num_panels = NumofRows*NumofColumns; 	
pattern.gs_val = 4; %1 or 4
pattern.stretch = zeros(pattern.x_num, pattern.y_num); %match frames
frameN = 16*NumofRows; %px per row
frameM = 16*NumofColumns; %px per col

%initialize pattern data1
Pats = zeros(frameN, frameM, pattern.x_num, pattern.y_num);


%% generate pattern data

% grating only
grtImage = repmat([ones(frameN,objWidth)*grtGS ones(frameN,objWidth)*bckGS],1,frameM/(objWidth*2));
Pats(:, :, 1, 1) = grtImage;
% background only
bckImage = ones(frameN, frameM) * bckGS; %initialize
Pats(:, :, 1, 2) = bckImage;

%save lookup table
patlookup.fullname = [num2str(objWidth) 'px_' num2str(grtGS) 'gs' 'vgrating_' num2str(bckGS) 'gsbck'];
patlookup.name = [num2str(objWidth) 'px_vgrating_only'];
patlookup.size = num2str(objWidth);
patlookup.object = 'vgrating';
patlookup.objgs = 0;
patlookup.grtgs = grtGS;
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
pattName = [sprintf('%04d', pattN) '_' sprintf('%02d', objWidth) 'px_vgrating'];
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

