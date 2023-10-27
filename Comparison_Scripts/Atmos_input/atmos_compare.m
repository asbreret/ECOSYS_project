clearvars
clc
close all

% Define the path to the weather files
directory = 'C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Inputs\Weather_Files\US-Dmg';
files = dir(fullfile(directory, 'weather_*.txt'));

% Initialize storage variables
timestamps = [];
temps = [];
humidity = [];
wind_speed = [];
precip = [];
solar_rad = [];

% Iterate through each file and extract data
for file = files'
    filename = fullfile(file.folder, file.name);
    data = importdata(filename, ',', 4);
    year = data.data(:,1);
    day = data.data(:,2);
    hour = data.data(:,3);
    
    % Convert the year, day, and hour into datetime format
    timestamps = [timestamps; datetime(year,1,day,hour,0,0)];
    temps = [temps; data.data(:,4) - 273.15]; % Convert K to °C
    humidity = [humidity; data.data(:,5)];
    wind_speed = [wind_speed; data.data(:,6) * 60 * 60 * 24 / 1000]; % Convert m/s to km/day
    precip = [precip; data.data(:,7)*24]; % Convert to daily totals
    solar_rad = [solar_rad; data.data(:,8)]; % Convert w/m^2 to MJ m^-2 d^-1
end


% Convert data to a timetable
tt = timetable(timestamps, temps, humidity, wind_speed, precip, solar_rad);

% Resample the timetable to get daily averages
daily_tt = retime(tt, 'daily', 'mean');

% Read netCDF data including time
output_path = 'C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Model_Outputs\US-Dmg\0_dh.nc';
posix_time_out = ncread(output_path, 'time');
wind_out = ncread(output_path, 'WIND');
radn_out = ncread(output_path, 'RADN');
prec_out = ncread(output_path, 'PRECN');
temp_max_out = ncread(output_path, 'TMAX_AIR');
temp_min_out = ncread(output_path, 'TMIN_AIR');

% Convert POSIX time to MATLAB datetime format
timestamps_out = datetime(double(posix_time_out), 'ConvertFrom', 'posixtime');

% Plot and Overlay
% [Your plotting code should remain unchanged]



% Plot and Overlay
figure;

% Temperature
subplot(5,1,1);
plot(daily_tt.timestamps, daily_tt.temps, 'b-'); 
hold on;
plot(timestamps_out, temp_max_out, 'r--');
plot(timestamps_out, temp_min_out, 'r--');
xlabel('Date & Time');
ylabel('Temperature (°C)');
title('Temperature vs Time');
legend('Original', 'Model Output');

% Humidity
subplot(5,1,2);
plot(daily_tt.timestamps, daily_tt.humidity);
xlabel('Date & Time');
ylabel('Humidity (%)');
title('Humidity vs Time');

% Wind Speed
subplot(5,1,3);
plot(daily_tt.timestamps, daily_tt.wind_speed, 'b-');
hold on;
plot(timestamps_out, wind_out, 'r--');
xlabel('Date & Time');
ylabel('Wind Speed (km/d)');
title('Wind Speed vs Time');
legend('Original', 'Model Output');

% Precipitation
subplot(5,1,4);
plot(daily_tt.timestamps, daily_tt.precip, 'b-');
hold on;
plot(timestamps_out, prec_out, 'r--');
xlabel('Date & Time');
ylabel('Precipitation (mm/d)');
title('Precipitation vs Time');
legend('Original', 'Model Output');

% Solar Radiation
subplot(5,1,5);
plot(daily_tt.timestamps, daily_tt.solar_rad *0.0864 / 5, 'b');
hold on;
plot(timestamps_out, radn_out, 'r');
xlabel('Date & Time');
ylabel('Solar Radiation (MJ m^-2 d^-1)');
title('Solar Radiation vs Time');
legend('Original', 'Model Output');


