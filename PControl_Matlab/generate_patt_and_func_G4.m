% generate_patt_and_func_G4
% generate a series of patterns and functions for the G4 display

% load settings
userSettings


%% Generate patterns
disp('generating g4 patterns...')

% clear patterns folder contents
delete([exp_path '\Patterns\*'])
delete([pattern_path '\patt_lookup*'])
p = 1; %initialize counter


% courtship experiments
% set variables
barWidth = 6; %px
boxWidth = 16; %px

bckGS = 6;
grtGS = 0;

%blank background
make_patt_blank_G4(p, bckGS)
p = p+1;

%dark bar
make_patt_verticalbar_G4(p, barWidth, 'dark', bckGS)
p = p+1;
%bright bar
make_patt_verticalbar_G4(p, barWidth, 'bright', bckGS)
p = p+1;
%dark box only 
make_patt_box_opt_background_G4(p, boxWidth, 4, 0, 'dark', grtGS, bckGS)
p = p+1;

%vertical grating
grtWidth = 8; %px
make_patt_verticalgrating_G4(p, grtWidth, grtGS, bckGS)
p=p+1;
%vertical grating
grtWidth = 12; %px
make_patt_verticalgrating_G4(p, grtWidth, grtGS, bckGS)
p=p+1;

%horizontal grating
grtWidth = 16; %px
make_patt_horizontalgrating_G4(p, grtWidth, grtGS, bckGS)
p=p+1;



%% Generate functions
disp('generating g4 functions...')

% clear functions folder contents
delete([exp_path '\Functions\*'])
delete([function_path '\func_lookup*'])

% set variables
f = 1; %initialize counter
sweepLength = [75 120 180 300];
sweepVelocity = [25 50 75];
objs = [6 16];

% hold center
for o = 1:length(objs)
    make_func_hold_center_G4(f,objs(o))
    f = f+1;
end

% alternating sweep
for s = 1:length(sweepLength)
    for v = 1:length(sweepVelocity)
        for o = 1:length(objs)
            make_func_alternating_sweep_G4(f,sweepLength(s),sweepVelocity(v),objs(o))
            f = f+1;
        end
    end
end

% optomotor reflex
for v = 1:length(sweepVelocity)
    make_func_optomotor_sweep_G4(f, sweepVelocity(v))
    f = f+1;
end

% set variables
sweepLength = 75;
sweepVelocity = [50 75];
objs = [6 16];

% alternating sweep
for s = 1:length(sweepLength)
    for v = 1:length(sweepVelocity)
        for o = 1:length(objs)
            make_func_pause_alternating_sweep_G4(f,sweepLength(s),sweepVelocity(v),objs(o))
            f = f+1;
        end
    end
end

% % % coherent path
% sweepRange = 110; %deg
% funcDur = 120; %sec
% objSize = 6; %px
% for cp = 1:10
%     make_func_coherentpath_G4(f, sweepRange, funcDur, objSize)
%     f = f+1;
% end



%% store current experiment data
create_currentExp(exp_path)

%% end
disp('complete!')
close all
clear


