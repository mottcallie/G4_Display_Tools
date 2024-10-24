% generate_patt_and_func_G4
%
% Generates a series of patterns and functions for the G4 display.
% 
% This script performs the following tasks:
% 1. Clears previous patterns and functions from specified directories.
% 2. Creates a variety of visual patterns including blank backgrounds, 
%    dark and bright bars, boxes, and gratings with specified sizes and 
%    brightness.
% 3. Generates functions for the G4 display, including holding patterns, 
%    oscillating sweeps, motion pulses, and alternating positions.
%
% INPUTS:
%   None (settings are loaded from an external file).
%
% OUTPUTS:
%   Generated patterns and functions are saved to specified folders.
%
%% Initialize
clear
close all
% load settings
userSettings

%% Generate patterns
disp('generating g4 patterns...')

% clear patterns folder contents
delete([exp_path '\Patterns\*'])
delete([pattern_path '\patt_lookup*'])
p = 1; %initialize counter

% set pattern object sizes
barWidths = [6 12 18 24]; %px
boxWidths = [6 12 18 24]; %px
vgrtWidths = [8 12]; %px
hgrtWidths = 16; %px

% set brightness variables
gs_max = 6;
gs_max2 = 7;
gs_grt = 0;

% blank bright background
make_patt_blank_G4(p, gs_max)
p = p+1;

% dark bars
for db = 1:length(barWidths)
    thisbar = barWidths(db);
    make_patt_verticalbar_G4(p, thisbar, 'dark', gs_max)
    p = p+1;
end

% bright bars
barWidths = [4 12 18 24]; %px
for bb = 1:length(barWidths)
    thisbar = barWidths(bb);
    make_patt_verticalbar_G4(p, thisbar, 'bright', gs_max2)
    p = p+1;
end

% dark boxes 
barHeights = [6 5 2 1];
for bx = 1:length(boxWidths)
    thisbox = boxWidths(bx);
    thishigh = barHeights(bx);
    make_patt_box_G4(p, thisbox, 'dark', thishigh, gs_max)
    p = p+1;
end

% vertical grating
for vg = 1:length(vgrtWidths)
    thisgrt = vgrtWidths(vg);
    make_patt_verticalgrating_G4(p, thisgrt, gs_grt, gs_max)
    p = p+1;
end

%horizontal grating
for hg = 1:length(hgrtWidths)
    thisgrt = hgrtWidths(hg);
    make_patt_horizontalgrating_G4(p, thisgrt, gs_grt, gs_max)
    p = p+1;
end

% blank dark background
maxGS = 15;
make_patt_onoff_blank_G4(p, maxGS)
p = p+1;


%% Generate functions
disp('generating g4 functions...')

% clear functions folder contents
delete([exp_path '\Functions\*'])
delete([function_path '\func_lookup*'])

% set variables
f = 1; %initialize counter
sweepLength = [75 120 180 300];
sweepVelocity = [15 35 55 75 95 115];
objs = barWidths;

% hold center
for o = 1:length(objs)
    make_func_hold_center_G4(f,objs(o))
    f = f+1;
end

% oscillating sweeps
% for each sweep length
% for each object sweep speed
% for each object size (must adjust center)
for s = 1:length(sweepLength)
    for o = 1:length(objs)
        for v = 1:length(sweepVelocity)
            make_func_alternating_sweep_G4(f,sweepLength(s),sweepVelocity(v),objs(o))
            f = f+1;
        end
    end
end

% additional sweep speeds
sweepVelocity_slow = [5 10 15 20 25 30 35];
for v = 1:length(sweepVelocity_slow)
    make_func_alternating_sweep_G4(f,75,sweepVelocity_slow(v),6)
    f = f+1;
end

% motion pulse sweeps
pulse_range = 180;
pulse_speeds = [25 75];
for bs = 1:10
    make_func_motion_pulse_G4(f, pulse_range, pulse_speeds, 6)
    f = f+1;
end

% motion pulse sweeps
pulse_range = 180;
for bs = 1:10
    make_func_stationary_pulse_G4(f, pulse_range, 6)
    f = f+1;
end

% % optomotor reflex
% for v = 1:length(sweepVelocity)
%     make_func_optomotor_sweep_G4(f, sweepVelocity(v))
%     f = f+1;
% end
% 
% % coherent path
% sweepRange = 100; %deg
% funcDur = 60; %sec
% objSize = 6; %px
% for cp = 1:25
%     make_func_coherentpath_G4(f, sweepRange, funcDur, objSize)
%     f = f+1;
% end

% alternating holds
make_func_alternating_pos_G4(f)
f = f+1;

% motion pulse sweeps
pulse_range = 270;
pulse_speeds = [25 75];
for bs = 1:10
    make_func_motion_pulse_G4(f, pulse_range, pulse_speeds, 6)
    f = f+1;
end

% motion pulse sweeps
pulse_range = 180;
pulse_speeds = 25;
for bs = 1:10
    make_func_motion_pulse_G4(f, pulse_range, pulse_speeds, 6)
    f = f+1;
end

%% store current experiment data
create_currentExp(exp_path)

%% end
disp('complete!')
close all
clear


