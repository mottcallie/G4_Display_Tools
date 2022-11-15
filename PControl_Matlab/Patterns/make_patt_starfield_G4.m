% make_patt_starfield_G4
% pattern generator, creates a starfield

% INPUTS:
% pattN - pattern number when saving
% starNumber - total number of stars, randomly distributed
% starGS - starfield intensity
% bckGS - background intensity

% 01/10/2022 - MC created

function  make_patt_starfield_G4(pattN, starNumber, starGS, bckGS)

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

%initialize images
preImage = ones(frameN, frameM) * bckGS;
preImage(1:starNumber) = starGS;

% randomize starfield
r = randperm(frameN * frameM);
rr = reshape(r,[frameN,frameM]);
starImage = preImage(rr);

%generate pattern image
Pats(:, :, 1, 1) = starImage;

%rotate
for x = 2:frameM
    Pats(:,:,x,1) = ShiftMatrix(Pats(:,:,x-1,1),1,'r','y');
end

%save lookup table
patlookup.fullname = [num2str(starGS) 'gs' '_starfield_' num2str(bckGS) 'gsbck'];
patlookup.name = 'starfield';
patlookup.size = num2str(1);
patlookup.object = 'starfield';
patlookup.objgs = starGS;
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

