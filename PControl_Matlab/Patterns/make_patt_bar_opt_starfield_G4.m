% make_patt_bar_opt_starfield_G4
% pattern generator, creates a bar +/- starfield

% INPUTS:
% pattN - pattern number when saving
% objWidth - size of bar
% grtSelect - 0 no starfield, 1 with starfield, -1 against starfield
% starNumber - total number of stars, randomly distributed
% starGS - starfield intensity
% bckGS - background intensity

% 01/11/2022 - MC created

function  make_patt_bar_opt_starfield_G4(pattN, objWidth, starSelect, starNumber, starGS, bckGS)

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
objGS = 1;
objPolar = 'dark';


%% generate pattern data

%initialize images
bckImage = ones(frameN, frameM) * bckGS;

barImage = bckImage;
barImage(:,1:objWidth) = objGS;

starImage_preshuff = bckImage;
starImage_preshuff(1:starNumber) = starGS;
r = randperm(frameN * frameM);
rr = reshape(r,[frameN,frameM]);
starImage = starImage_preshuff(rr);

switch starSelect
    case 0 %no starfield
        patImage = barImage;
        Pats(:, :, 1, 1) = patImage;
        
        %rotate
        for x = 2:frameM
            Pats(:,:,x,1) = ShiftMatrix(Pats(:,:,x-1,1),1,'r','y');
        end
        
        %save lookup table
        patlookup.fullname = [num2str(objWidth) 'px_' num2str(objGS) 'gs' objPolar '_bar_' num2str(bckGS) 'gsbck'];
        patlookup.name = [num2str(objWidth) 'px_' objPolar 'bar_only'];
        patlookup.size = num2str(objWidth);
        patlookup.object = 'box';
        patlookup.objgs = objGS;
        patlookup.stargs = 0;
        patlookup.bckgs = bckGS;
        
    case 1 %with starfield
        patImage = starImage;
        patImage(:,1:objWidth) = objGS;
        Pats(:, :, 1, 1) = patImage;
        
        %rotate
        for x = 2:frameM
            Pats(:,:,x,1) = ShiftMatrix(Pats(:,:,x-1,1),1,'r','y');
        end
        
        %save lookup table
        patlookup.fullname = [num2str(objWidth) 'px_' num2str(objGS) 'gs' objPolar 'bar' '_with_' num2str(starGS) 'gs_' 'starfield_' num2str(bckGS) 'gsbck'];
        patlookup.name = [num2str(objWidth) 'px_' objPolar 'bar' '_with_' 'starfield'];
        patlookup.size = num2str(objWidth);
        patlookup.object = 'bar + starfield';
        patlookup.objgs = objGS;
        patlookup.stargs = starGS;
        patlookup.bckgs = bckGS;
        
    case -1 %against starfield
        boxLogical = logical(barImage<bckGS);
        for x = 1:frameM
            patImage = starImage; %stationary
            patImage(boxLogical) = objGS; %add object
            Pats(:,:,x,1) = patImage;
            
            %rotate
            boxLogical = ShiftMatrix(boxLogical,1,'r','y');
        end
        
        %save lookup table
        patlookup.fullname = [num2str(objWidth) 'px_' num2str(objGS) 'gs' objPolar 'bar' '_against_' num2str(starGS) 'gs_' 'starfield_' num2str(bckGS) 'gsbck'];
        patlookup.name = [num2str(objWidth) 'px_' objPolar 'bar' '_against_' 'starfield'];
        patlookup.size = num2str(objWidth);
        patlookup.object = 'bar - starfield';
        patlookup.objgs = objGS;
        patlookup.stargs = starGS;
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

