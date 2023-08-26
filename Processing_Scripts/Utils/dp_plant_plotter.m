% Clear workspace, command window, and close all figures
clearvars
clc
% close all

% Load NetCDF file and extract time data
fname = '1_dp.nc';
raw_time = ncread(fname, 'time');
time = datetime(raw_time, 'ConvertFrom', 'posixtime');

% Get the variable names from the NetCDF file
ncinfo_struct = ncinfo(fname);
variable_names = {ncinfo_struct.Variables.Name};
variable_names = variable_names(~strcmp(variable_names, 'time'));








% Determine the number of variables and the number of plots
num_variables = length(variable_names);
num_rows = 5;
num_cols = 4;

% Create a new figure to plot all variables against time
figure;

for i = 1:num_variables
    % Read the data for the current variable
    var_data = ncread(fname, variable_names{i});
    
    % Extract attributes for the current variable
    attrs = ncinfo(fname, variable_names{i}).Attributes;
    
    % Convert struct array to cell array of names
    attr_names = arrayfun(@(x) x.Name, attrs, 'UniformOutput', false);
    
    % Check if 'long_name' and 'units' attributes exist for the variable
    if ismember('long_name', attr_names)
        long_name = ncreadatt(fname, variable_names{i}, 'long_name');
    else
        long_name = variable_names{i};
    end
    
    if ismember('units', attr_names)
        units = ncreadatt(fname, variable_names{i}, 'units');
    else
        units = '';
    end

    % Create a subplot for the current variable
    subplot(num_rows, num_cols, i);

    % Plot the variable against time
    plot(time, var_data);

    % Add a title for the subplot
    if ~isempty(long_name)
        title(long_name, 'Interpreter', 'none');
    else
        title(variable_names{i}, 'Interpreter', 'none');
    end

    % Add x label. Only add y label if 'units' exist and are not empty
    xlabel('Time');
    if ~isempty(units)
        ylabel(units);
    end
end






% Adjust the spacing between subplots for better visualization
spacing = 0.03;
set(gcf, 'Units', 'Normalized', 'Position', [0, 0, 1, 1]);
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0, 1, 1]);
ha = axes('Position', [0, 0, 1, 1], 'Visible', 'off');
set(gcf, 'CurrentAxes', ha);
text(0.5, 1, 'Multiple Variables Plotted Against Time', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'FontSize', 16, 'FontWeight', 'bold');











% Create a new figure for pcolor plots of NH4_depth and NO3_depth
% figure;

% Subplot for pcolor plot of NH4_depth
% subplot(3, 1, 1);
% pcolor(time, -z, ECND_depth');
% shading flat;
% colormap jet;
% colorbar;
% xlabel('Time');
% ylabel('Depth');
% title('ECND');

% % Subplot for pcolor plot of NO3_depth
% subplot(2, 1, 1);
% pcolor(time, -z, DNS_depth');
% shading flat;
% colormap jet;
% colorbar;
% xlabel('Time');
% ylabel('Depth');
% title('DNS');





% Function to find depth indices for variables containing a specific string
function depth_inds = depth_ind_finder(variable_names, varname)
% Find indices of variables containing varname
ind1 = contains(variable_names, varname);

% Find indices of variables containing [varname,'RES']
ind2 = contains(variable_names, [varname, 'LITTER']);

% Subtract the 'RES' indices from the variable indices
depth_inds = ind1 - ind2;

% Convert the result to logical indices
depth_inds = logical(depth_inds);
end

% Function to concatenate variables along the depth dimension
function var_depth = cat_depth(fname, varnames)
% Initialize the variable to store the concatenated data
var_depth = [];

% Loop through each variable in varnames and extract data
for i = 1:numel(varnames)
    % Get the variable name for the current depth bin
    var_name = varnames{i};

    % Read the data for the current variable
    var_data = ncread(fname, var_name);

    % Concatenate the data along the depth dimension
    var_depth = cat(2, var_depth, var_data);
end
end
