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