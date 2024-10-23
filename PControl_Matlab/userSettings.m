% Configuration script for G4 Display Tools
%
% This script sets up the necessary paths and configuration variables
% for controlling the G4 display and its related functions.
%
% Paths are defined for various components of the G4 display system, 
% including the controller, functions, analog output functions, patterns, 
% and experiment data. It also configures the arena dimensions and GUI 
% display settings.
%
% INPUTS:
%   None (paths are set as absolute paths).
%
% OUTPUTS:
%   Configuration variables for G4 display usage.
%
% Parameters:
%   root_path - Root directory for G4 display tools.
%   controller_path - Path to the controller directory.
%   function_path - Path to the functions directory.
%   aofunction_path - Path to the analog output functions directory.
%   pattern_path - Path to the patterns directory.
%   default_exp_path - Default path for experiment data.
%   exp_path - Current experiment path (initialized to default).
%   NumofColumns - Number of columns in the arena configuration.
%   NumofRows - Number of rows in the arena configuration.
%   flipUpDown - GUI setting to flip pattern display vertically (1 = yes, 0 = no).
%   flipLeftRight - GUI setting to flip pattern display horizontally (1 = yes, 0 = no).
%

root_path = 'C:\Users\wilson\Dropbox (HMS)\MATLAB\G4_Display_Tools\PControl_Matlab';

controller_path = fullfile(root_path, 'controller' );
function_path = fullfile(root_path, 'functions'); 
aofunction_path = fullfile(root_path, 'ao_functions\','MyAO');
pattern_path =  fullfile(root_path, 'Patterns');   
default_exp_path = fullfile(root_path, 'Experiment');
exp_path = default_exp_path;
%pattern_path =  fullfile(root_path, 'temp'); 

%Arena Config
NumofColumns = 12;
NumofRows = 2;

%GUI pattern display setting flipUpDown and flipLeftRight
%1 means pattern display flip accordingly in the GUI and 0 means no flip
flipUpDown = 0;
flipLeftRight = 0;