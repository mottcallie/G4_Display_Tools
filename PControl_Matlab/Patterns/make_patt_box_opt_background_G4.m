% make_patt_box_opt_background_G4
% pattern generator, creates a single box +/- background grating

% INPUTS:
% pattN - pattern number when saving
% objWidth - size of box
% grtWidth - size of grating
% grtSelect - 0 no grating, 1 with grating, -1 against grating
% objPolar - set polarity to dark or bright vs background
% grtGS - grating intensity
% bckGS - background intensity

% 10/29/2021 - MC created
% 12/01/2021 - MC added grating gs

function  make_patt_box_opt_background_G4(pattN, objWidth, grtWidth, grtSelect, objPolar, grtGS, maxGS)

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
h = 3; %px to drop obj down from top by
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
boxImage((end-h-objWidth):(end-h),1:objWidth) = objGS;

grtImage = repmat([ones(frameN,grtWidth)*grtGS ones(frameN,grtWidth)*bckGS],1,frameM/(grtWidth*2));


%generate pattern image based on selection
switch grtSelect
    case 0 %no grating
        patImage = boxImage;
        Pats(:, :, 1, 1) = patImage;
        
        %rotate
        for x = 2:frameM
            Pats(:,:,x,1) = ShiftMatrix(Pats(:,:,x-1,1),1,'r','y');
        end
        
        %save lookup table
        patlookup.fullname = [num2str(objWidth) 'px_' num2str(objGS) 'gs' objPolar '_box_' num2str(bckGS) 'gsbck'];
        patlookup.name = [num2str(objWidth) 'px_' objPolar 'box_only'];
        patlookup.size = num2str(objWidth);
        patlookup.object = 'box';
        patlookup.objgs = objGS;
        patlookup.grtgs = 0;
        patlookup.bckgs = bckGS;
        


    case 1 %with grating
        patImage = grtImage;
        patImage((end-h-objWidth):(end-h),1:objWidth) = objGS;
        Pats(:, :, 1, 1) = patImage;
        
        %rotate
        for x = 2:frameM
            Pats(:,:,x,1) = ShiftMatrix(Pats(:,:,x-1,1),1,'r','y');
        end
        
        %save lookup table
        patlookup.fullname = [num2str(objWidth) 'px_' num2str(objGS) 'gs' objPolar 'box' '_with_' num2str(grtWidth) 'px_' num2str(grtGS) 'gs' 'grating' num2str(bckGS) 'gsbck'];
        patlookup.name = [num2str(objWidth) 'px_' objPolar 'box' '_with_' num2str(grtWidth) 'px_' 'grating'];
        patlookup.size = num2str(objWidth);
        patlookup.object = 'box + grating';
        patlookup.objgs = objGS;
        patlookup.grtgs = grtGS;
        patlookup.bckgs = bckGS;
        
    case -1 %against stationary grating
        boxLogical = logical(boxImage<bckGS);
        for x = 1:frameM
            patImage = grtImage; %stationary
            patImage(boxLogical) = objGS; %add object
            Pats(:,:,x,1) = patImage;
            
            %rotate
            boxLogical = ShiftMatrix(boxLogical,1,'r','y');
        end
        
        %save lookup table
        patlookup.fullname = [num2str(objWidth) 'px_' num2str(objGS) 'gs' objPolar 'box' '_against_' num2str(grtWidth) 'px_' num2str(grtGS) 'gs' 'grating' num2str(bckGS) 'gsbck'];
        patlookup.name = [num2str(objWidth) 'px_' objPolar 'box' '_against_' num2str(grtWidth) 'px_' 'grating'];
        patlookup.size = num2str(objWidth);
        patlookup.object = 'box - grating';
        patlookup.objgs = objGS;
        patlookup.grtgs = grtGS;
        patlookup.bckgs = bckGS;
end


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

