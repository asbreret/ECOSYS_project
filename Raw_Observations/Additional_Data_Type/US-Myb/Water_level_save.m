clearvars
clc
close all

varname = 'WaterLevel_cm';

% Load data
load website_data.mat

% Extract data for WaterLevel_cm
ind = contains(HEADER, varname);
Water_level = DATA{ind};

time = TIME{ind};

% Remove zeros and replace them with NaN
Water_level(Water_level==0) = nan;

% Remove outliers
ind = isoutlier(Water_level,'movmedian',480);
Water_level(ind) = nan;

% Plot the data
plot(time, Water_level)

% Remove data at 30 minutes intervals
A = minute(time);
time(A==30) = [];
Water_level(A==30) = [];

time(isnan(Water_level)) = [];
Water_level(isnan(Water_level)) = [];


% Convert time to the required format
formatted_time = datestr(time,'yyyymmddHH'); % yyyyddhh format isn't standard. yyyyMMddHH is used instead.

% Saving data to ASCII format
filename = 'output_data.txt';
fileID = fopen(filename, 'w');

% Write header
fprintf(fileID, '%s\t%s\n', 'Time', varname);

% Write data
for i=1:length(time)
    fprintf(fileID, '%s\t%f\n', formatted_time(i,:), Water_level(i));
end

fclose(fileID);

% Clear temporary variables
clearvars -except time Water_level



% Convert MATLAB datetime to POSIX time (seconds since 1970-01-01 00:00:00 UTC)
posix_time = posixtime(time);

% Create a new NetCDF file
nc_filename = 'Water_level.nc';

% Define dimensions
nccreate(nc_filename, 'time', 'Dimensions', {'time', numel(posix_time)}, 'Datatype', 'double');
nccreate(nc_filename, 'Water_level', 'Dimensions', {'time', numel(posix_time)}, 'Datatype', 'double');

% Write data to the NetCDF file
ncwrite(nc_filename, 'time', posix_time);
ncwrite(nc_filename, 'Water_level', Water_level);

% Add attributes to variables (optional, but useful for clarification)
ncwriteatt(nc_filename, 'time', 'units', 'seconds since 1970-01-01 00:00:00 UTC');
ncwriteatt(nc_filename, 'Water_level', 'units', 'cm');

% Clear temporary variables
clearvars -except time Water_level

