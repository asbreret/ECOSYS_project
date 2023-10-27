% Clear workspace, command window, and close all figures
clearvars
clc

% Load NetCDF file and extract time data
fname = '0_dw.nc';
raw_time = ncread(fname, 'time');
time = datetime(raw_time, 'ConvertFrom', 'posixtime');

% Get the variable names from the NetCDF file
ncinfo_struct = ncinfo(fname);
variable_names = {ncinfo_struct.Variables.Name};
variable_names = variable_names(~strcmp(variable_names, 'time'));

% List of variables you want to keep
desired_variables = {'WTR_TBL', 'ET', 'PRECN', 'RUNOFF', 'SURF_ELEV', 'WATER'};

% Filter the variable names to only include desired variables
variable_names = intersect(variable_names, desired_variables, 'stable');

% Determine the number of variables and the number of plots
num_variables = length(variable_names);
num_rows = 3; % Adjusted for general cases
num_cols = 2;

% Create a new figure to plot all variables against time
figure;

for i = 1:num_variables
    % Read the data for the current variable
    var_data = ncread(fname, variable_names{i});
    
    % Get the long_name attribute for the current variable
    % If the attribute does not exist, use the variable name as a fallback
    try
        var_title = ncreadatt(fname, variable_names{i}, 'long_name');
    catch
        var_title = variable_names{i};
    end
    
    % Get the units attribute for the current variable
    % If the attribute does not exist, use an empty string as a fallback
    try
        var_units = ncreadatt(fname, variable_names{i}, 'units');
    catch
        var_units = '';
    end
    
    % Create a subplot for the current variable
    subplot(num_rows, num_cols, i);
    
    % Plot the variable against time
    plot(time, var_data, 'LineWidth',3);
    
    % Add a title for the subplot with the long_name attribute
    title(var_title, 'Interpreter', 'none');
    
    % Add x and y axis labels
    xlabel('Time');
    ylabel(var_units); % Here you use the variable units as y-axis label

    set(gca,'FontSize',14)
end

% Adjust the spacing between subplots for better visualization
spacing = 0.03;
set(gcf, 'Units', 'Normalized', 'Position', [0, 0, 1, 1]);
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0, 1, 1]);
ha = axes('Position', [0, 0, 1, 1], 'Visible', 'off');
set(gcf, 'CurrentAxes', ha);
% text(0.5, 1, 'Selected Variables Plotted Against Time', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'FontSize', 16, 'FontWeight', 'bold');
