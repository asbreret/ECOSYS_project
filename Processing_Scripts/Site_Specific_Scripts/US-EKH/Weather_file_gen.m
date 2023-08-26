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

% Plotting section
subplot(5,1,1)
plot(time,Temp)
subplot(5,1,2)
plot(time,WS)
subplot(5,1,3)
plot(time,SW_IN)
subplot(5,1,4)
plot(time,P)
subplot(5,1,5)
plot(time,RH)

% Calculate some variables:
Temp_kelvin = Temp + 273.15;

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
    writematrix(Matrix, [inputdir,filename], 'WriteMode', 'append');
end

end
