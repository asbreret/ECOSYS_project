function [] = Weather_file_gen(fname, inputdir)

% Read the netCDF file information
ncInfo = ncinfo(fname);
ncVars = {ncInfo.Variables.Name};

% Specify variables of interest
Var_of_int = {'time', 'ATemp', 'WSpd', 'TotPAR', 'TotPrcp', 'RH'};

% Load data from the file
for i = 1:length(Var_of_int)
    if ismember(Var_of_int{i}, ncVars)
        Atmos_var.(Var_of_int{i}) = ncread(fname, Var_of_int{i});
    else
        Atmos_var.(Var_of_int{i}) = nan(size(Atmos_var.time));
    end
end

Atmos_var.time = datetime(Atmos_var.time, 'ConvertFrom', 'posixtime');
time = Atmos_var.time;

% Extract date and time components
yr = year(time);
mnth = month(time);
dy = day(time, "dayofyear");
hr = hour(time);
mn = minute(time);

% Remove half-hourly times (may consider averaging in future work)
halfHourIndices = mn == 30;
hr(halfHourIndices) = [];
dy(halfHourIndices) = [];
mnth(halfHourIndices) = [];
yr(halfHourIndices) = [];
time(halfHourIndices) = [];
Atmos_var.ATemp(halfHourIndices) = [];
Atmos_var.WSpd(halfHourIndices) = [];
Atmos_var.TotPAR(halfHourIndices) = [];
Atmos_var.TotPrcp(halfHourIndices) = [];
Atmos_var.RH(halfHourIndices) = [];

% Assuming you have a function named gapFill that does the desired gap filling
Temp = gapFill(Atmos_var.ATemp, time);
WS = gapFill(Atmos_var.WSpd, time);
SW_IN = gapFill(Atmos_var.TotPAR, time)/1.8;
P = gapFill(Atmos_var.TotPrcp, time);
RH = gapFill(Atmos_var.RH, time);



% Calculate some variables:
Temp_kelvin = Temp + 273.15;



figure;

subplot(5,1,1)
plot(time,Temp)
ylabel('Temp (°C)') % assuming Celsius; adjust if necessary
set(gca,'FontSize',14)

subplot(5,1,2)
plot(time,RH)
ylabel('RH (%)')
set(gca,'FontSize',14)

subplot(5,1,3)
plot(time,WS)
ylabel('Wind (m/s)') % assuming meters per second; adjust if necessary
set(gca,'FontSize',14)

subplot(5,1,4)
plot(time,P)
ylabel('Rain (mm)') % assuming millimeters; adjust if necessary
set(gca,'FontSize',14)

subplot(5,1,5)
plot(time,SW_IN)
ylabel('Solar (W/m^2)') % assuming Watts per square meter; adjust if necessary
set(gca,'FontSize',14)

sgtitle('Weather for US-EKH') % Overall title for the



% Write weather data per year
uniqueYears = unique(yr);
for i = 1:length(uniqueYears)
    ind = yr == uniqueYears(i);
    filename = ['weather_', num2str(uniqueYears(i))];
    header = ["HJ0305XDHTHWPR"; "KRSMW"];
    data = [10.00, 1.00, 19.99, 0.00, 0.00, 0.00, 0.00, 0.00;
        7.00, 0.09, 0.15, 0.00, 0.00, 0.00, 0.00, 0.00];
    writematrix(header, [inputdir,filename], 'FileType', 'text', 'WriteMode', 'overwrite');
    writematrix(data, [inputdir,filename], 'FileType', 'text', 'WriteMode', 'append', 'Delimiter', ',');

    Matrix = [yr(ind), dy(ind), hr(ind), Temp_kelvin(ind), RH(ind), ...
        WS(ind), P(ind), SW_IN(ind)];
    Matrix = round(Matrix, 2);

    % Check the day number in the last row
    lastDay = Matrix(end, 2);

    % If the last day is 365, duplicate the rows with day 365 and append
    if lastDay == 365
        rowsToCopy = Matrix(Matrix(:, 2) == 365, :);   % Extract rows with day 365
        rowsToCopy(:, 2) = 366;                        % Change the day number to 366
        Matrix = [Matrix; rowsToCopy];                 % Append to the main matrix
    end
    
    writematrix(Matrix, [inputdir,filename], 'WriteMode', 'append');
end

end
