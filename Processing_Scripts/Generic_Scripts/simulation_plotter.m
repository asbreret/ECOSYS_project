clearvars
clc
close all


% Add utility path
addpath('C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Processing_Scripts\Utils')

% Temporarily set userpath to the current directory
userpath(pwd);

% Change working directory to where the files are
cd('C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Model_Outputs\sim_water_table_3');


% Your scripts
dc_plotter_subset
% dn_plotter
% dp_plotter
dw_plotter_subset
% dh_plotter
% 
% dc_plant_plotter
% dn_plant_plotter
% dp_plant_plotter
% dw_plant_plotter
% dh_plant_plotter

% Change back to the original directory using userpath
cd(userpath);


% Get all open figures
all_figs = findall(0, 'Type', 'figure');

% Loop through each figure and save it
for idx = 1:length(all_figs)
    fig = all_figs(idx);
    
    % Generate a file name based on the figure number
    filename = sprintf('figure_%d.jpeg', fig.Number);
    
    % Activate the figure (bring it to front)
    figure(fig);
    
    % Save the figure to a JPEG file
    saveas(fig, filename, 'jpeg');
end

