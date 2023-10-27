% Clear workspace, command window, and close all figures
clearvars
clc
% close all

% Load NetCDF file and extract time data
fname = '0_dw.nc';
raw_time = ncread(fname, 'time');
time = datetime(raw_time, 'ConvertFrom', 'posixtime');

% Get the variable names from the NetCDF file
ncinfo_struct = ncinfo(fname);
variable_names = {ncinfo_struct.Variables.Name};
variable_names = variable_names(~strcmp(variable_names, 'time'));

% Find indices of variables containing 'NH4_' and 'NO3_' respectively
ICE_depth_inds = depth_ind_finder(variable_names, 'ICE_');
PSI_depth_inds = depth_ind_finder(variable_names, 'PSI_');
WTR_depth_inds = depth_ind_finder(variable_names, 'WTR_');

% Get the variable names for 'NH4' and 'NO3' depth data
ICE_depth_vars = variable_names(ICE_depth_inds);
PSI_depth_vars = variable_names(PSI_depth_inds);
WTR_depth_vars = variable_names(WTR_depth_inds);

% Concatenate data for 'NH4' and 'NO3' variables along the depth dimension
ICE_depth = cat_depth(fname, ICE_depth_vars);
PSI_depth = cat_depth(fname, PSI_depth_vars);
WTR_depth = cat_depth(fname, WTR_depth_vars);

z = zeros(1,19);
N = size(ICE_depth,2); % amount of depth layers
fac = 2/3;
z(1:N) = 0.01*exp((1:N)*fac) / exp(fac);

ind = logical(nanstd(PSI_depth));

ICE_depth = ICE_depth(:,ind);
PSI_depth = PSI_depth(:,ind);
WTR_depth = WTR_depth(:,ind);

z = z(ind);



% remove depth variables
variable_names( ICE_depth_inds | PSI_depth_inds | WTR_depth_inds ) = [];
variable_names{end+1} = 'WTR_TBL';



% Determine the number of variables and the number of plots
num_variables = length(variable_names);
num_rows = 5;
num_cols = 3;

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
    plot(time, var_data);
    
    % Add a title for the subplot with the long_name attribute
    title(var_title, 'Interpreter', 'none');
    
    % Add x and y axis labels
    xlabel('Time');
    ylabel(var_units); % Here you use the variable units as y-axis label
end

% Adjust the spacing between subplots for better visualization
spacing = 0.03;
set(gcf, 'Units', 'Normalized', 'Position', [0, 0, 1, 1]);
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0, 1, 1]);
ha = axes('Position', [0, 0, 1, 1], 'Visible', 'off');
set(gcf, 'CurrentAxes', ha);
text(0.5, 1, 'Multiple Variables Plotted Against Time', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'FontSize', 16, 'FontWeight', 'bold');









% 
% 
% % Create a new figure for pcolor plots of NH4_depth and NO3_depth
% figure;
% 
% % Subplot for pcolor plot of NH4_depth
% subplot(3, 1, 1);
% pcolor(time, -z, ICE_depth');
% shading flat;
% colormap jet;
% colorbar;
% xlabel('Time');
% ylabel('Depth');
% title('ICE');
% 
% % Subplot for pcolor plot of NO3_depth
% subplot(3, 1, 2);
% pcolor(time, -z, PSI_depth');
% shading flat;
% colormap jet;
% colorbar;
% xlabel('Time');
% ylabel('Depth');
% title('PSI');
% 
% % Subplot for pcolor plot of NO3_depth
% subplot(3, 1, 3);
% pcolor(time, -z, WTR_depth');
% shading flat;
% colormap jet;
% colorbar;
% xlabel('Time');
% ylabel('Depth');
% title('WTR');
% 
% 


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
