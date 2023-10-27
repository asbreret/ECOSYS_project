clearvars
clc
close all


input_dir = 'C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Raw_Observations\Site_file\';
output_dir = 'C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Inputs\Site_Files\';
fname = 'site_data.xlsx';
data = readtable([input_dir,fname]);

% Create the site_parameters structure
site_parameters.latitude = 38.1; % degrees
site_parameters.altitude = 0.5; % meters above mean sea level
site_parameters.temperature = 10.0; % oC (deep soil boundary temperature)
site_parameters.water_table_flag = 0; % 0: No water table, 1: Water table present

% Atmospheric Characteristics
site_parameters.o2_concentration = 210000.0; % µmol mol-1
site_parameters.n2_concentration = 780000.0; % µmol mol-1
site_parameters.co2_concentration = 296; % µmol mol-1
site_parameters.ch4_concentration = 1.8; % µmol mol-1
site_parameters.n2o_concentration = 0.3; % µmol mol-1
site_parameters.nh3_concentration = 0.005; % µmol mol-1

% Site Characteristics
site_parameters.experimental_conditions = 0; % Natural conditions
site_parameters.soil_ph_and_salinity = 0; % pH and solute considerations
site_parameters.soil_erosion = 0; % soil erosion
site_parameters.grid_cell_interconnected = 1; % Grid cells interconnected (choice: 1.3)
site_parameters.external_water_table_height = 0; % Depth of external water table (meters)
site_parameters.artificial_drainage_depth = -1.0; % Depth for artificial drainage (meters)
site_parameters.water_table_slope = 0.0; % Water table slope (choice: 0.0)

% Boundary Conditions
site_parameters.sbc_north = 0.0; % Northern surface boundary runoff (choice: 0.0)
site_parameters.sbc_east = 1.0; % Eastern surface boundary runoff (choice: 0.1)
site_parameters.sbc_south = 0.0; % Southern surface boundary runoff (choice: 0.0)
site_parameters.sbc_west = 0.0; % Western surface boundary runoff (choice: 0.0)
site_parameters.water_table_dist_north = 0.0; % Distance to external water table from the northern boundary (meters)
site_parameters.water_table_dist_east = 0.0; % Distance to external water table from the eastern boundary (meters)
site_parameters.water_table_dist_south = 0.0; % Distance to external water table from the southern boundary (meters)
site_parameters.water_table_dist_west = 0.0; % Distance to external water table from the western boundary (meters)
site_parameters.lbc_north = 0.0; % Northern subsurface boundary movement (choice: 0.0)
site_parameters.lbc_east = 1.0; % Eastern subsurface boundary movement (choice: 0.0)
site_parameters.lbc_south = 0.0; % Southern subsurface boundary movement (choice: 0.0)
site_parameters.lbc_west = 0.0; % Western subsurface boundary movement (choice: 0.0)
site_parameters.lower_boundary_downward = 0.0; % Downward transfer of water, heat, etc. (choice: 1.0)
site_parameters.lower_boundary_upward = 0.0; % Upward transfer of water, heat, etc. (choice: 1.0)

% Grid Parameters
site_parameters.width_x = 1.0; % E-W gridbox width
site_parameters.width_y = 1.0; % N-S gridbox width


% Extract latitude, elevation, and temperature from each site
latitude = data.Latitude;
elevation = data.Elevation;
temperature = data.Temperature;
code = data.LocationCode;

elevation(isnan(elevation)) = 0;
temperature(isnan(temperature)) =  mean(temperature, 'omitnan');



for i = 1:length(code)

% Update site_parameters with the extracted values
site_parameters.latitude = latitude(i);
site_parameters.altitude = elevation(i);
site_parameters.temperature = temperature(i);
site_filename = [output_dir,code{i},'\','site_',code{i},'.txt'];

% Call the function with the filename and site_parameters
Generate_site_file(site_filename, site_parameters);

end