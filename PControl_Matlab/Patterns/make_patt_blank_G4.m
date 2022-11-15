% make_patt_verticalbar_G4
% pattern generator, creates a single bar

% INPUTS:
% pattN - pattern number when saving

% 11/05/2021 - MC created

function  make_patt_blank_G4(pattN,bckGS)

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


%% generate pattern data

bckImage = ones(frameN, frameM) * bckGS; %initialize

% background only
for x = 1:frameM
    Pats(:,:,x,1) = bckImage;
end

%save lookup table
patlookup.fullname = [num2str(bckGS) 'gs_background'];
patlookup.name = 'background';
patlookup.size = 0;
patlookup.object = 0;
patlookup.objgs = 0;
patlookup.bckgs = bckGS;

%store pattern data
pattern.Pats = Pats;
%get the vector data
pattern.data = make_pattern_vector_g4(pattern);


%% save pattern data

%set and save pattern data
pattName = [sprintf('%04d', pattN) '_' 'background'];
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

