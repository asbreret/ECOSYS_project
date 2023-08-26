function [nc_fname] = netcdf_convert_ELK(fname)

% Read CSV file into a table, skipping the first row
T = readtable(fname, 'HeaderLines', 2);

% Define the selected variables and their metadata
selected_vars = {'ATemp', 'WSpd', 'TotPAR', 'TotPrcp', 'RH'};
meta = struct();
meta.ATemp = struct('long_name', 'Average Air Temperature', 'units', 'degrees Celsius (C)');
meta.WSpd = struct('long_name', 'Average Wind Speed', 'units', 'meters per second (m/s)');
meta.TotPAR = struct('long_name', 'Photosynthetically Active Radiation', 'units', 'millimoles per square meter (total flux integrated over 15-minute interval)');
meta.TotPrcp = struct('long_name', 'Total Precipitation', 'units', 'millimeters (mm)');
meta.RH = struct('long_name', 'Average Relative Humidity', 'units', 'percent saturation (%)');

% Extract date_time
time_start = datetime(T.DateTimeStamp, 'InputFormat', 'MM/dd/yyyy HH:mm');

% Filter data between 2010 and 2021, inclusive
within_range_indices = (year(time_start) >= 2010) & (year(time_start) <= 2021);
T = T(within_range_indices, :);
time_start = time_start(within_range_indices);

% Filter the table for on-the-hour data
minute_values = minute(time_start);
on_the_hour_indices = (minute_values == 0);
T = T(on_the_hour_indices, :);  % Filter the entire table

% Convert the filtered time_start to POSIX time
posix_time = posixtime(datetime(T.DateTimeStamp, 'InputFormat', 'MM/dd/yyyy HH:mm'));

% Create a new netCDF file
nc_fname = strrep(fname, '.csv', '.nc');
if exist(nc_fname, 'file')
    delete(nc_fname);
end

% Define dimensions
nccreate(nc_fname, 'time', 'Dimensions', {'time', numel(T.DateTimeStamp)});

% Add attributes to the time variable
ncwriteatt(nc_fname, 'time', 'long_name', 'time');
ncwriteatt(nc_fname, 'time', 'units', 'seconds since 1970-01-01 00:00:00');

% Write time data
ncwrite(nc_fname, 'time', posix_time);

% Iterate through selected data columns
for i = 1:length(selected_vars)
    var_name = selected_vars{i};
    data = T.(var_name);

    % Check if the data is a cell
    if iscell(data)
        data_num = cellfun(@(x) str2double(x), data); % Convert each cell to double
        data_num(data_num == -9999) = nan; % Replace -9999 with NaN
        data = data_num; % Update data variable
    else
        data(data == -9999) = nan;
    end

    % Define variables in netCDF
    nccreate(nc_fname, var_name, 'Dimensions', {'time', numel(data)});

    % Add metadata attributes to the variables
    ncwriteatt(nc_fname, var_name, 'long_name', meta.(var_name).long_name);
    ncwriteatt(nc_fname, var_name, 'units', meta.(var_name).units);

    % Write data to netCDF
    ncwrite(nc_fname, var_name, data);
end

end
