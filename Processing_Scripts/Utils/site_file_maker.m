clear all
clc
close all


LIST = {...
    'US-Dmg',...
    'US-EDN',...
    'US-EKH',...
    'US-EKP',...
    'US-EKY',...
    'US-Hsm',...
    'US-Myb',...
    'US-Sne',...
    'US-Srr',...
    'US-Tw1',...
    'US-Tw4',...
};

directory = 'C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Raw_Observations\Site_file\';
filename = 'site_data.xlsx';
fullpath = fullfile(directory, filename);

% Loop over the codes in LIST
for i = 1:length(LIST)
    code = LIST{i};
    
    siteInfo = extractSiteInfo(code);
    
    % Convert locationName to a cell array of character vectors
    siteInfo.locationName = {siteInfo.locationName};
    
    % Extract names and email addresses from relevant people
    piName = '';
    piEmail = '';
    fluxContactName = '';
    fluxContactEmail = '';
    dataManagerName = '';
    dataManagerEmail = '';
    technicianName = '';
    technicianEmail = '';
    
    if isfield(siteInfo.people, 'PI')
        piInfo = split(siteInfo.people.PI, ' ');
        piName = join(piInfo(1:2), ' ');
        piEmail = extractBetween(siteInfo.people.PI, 'mailto:', '">');
    end
    
    if isfield(siteInfo.people, 'FluxContact')
        fluxContactInfo = split(siteInfo.people.FluxContact, ' ');
        fluxContactName = join(fluxContactInfo(1:2), ' ');
        fluxContactEmail = extractBetween(siteInfo.people.FluxContact, 'mailto:', '">');
    end
    
    if isfield(siteInfo.people, 'DataManager')
        dataManagerInfo = split(siteInfo.people.DataManager, ' ');
        dataManagerName = join(dataManagerInfo(1:2), ' ');
        dataManagerEmail = extractBetween(siteInfo.people.DataManager, 'mailto:', '">');
    end
    
    if isfield(siteInfo.people, 'Technician')
        technicianInfo = split(siteInfo.people.Technician, ' ');
        technicianName = join(technicianInfo(1:2), ' ');
        technicianEmail = extractBetween(siteInfo.people.Technician, 'mailto:', '">');
    end
    
    % Create a table from the siteInfo structure
    data = table(string(siteInfo.locationName), string(code), siteInfo.latitude, siteInfo.longitude, ...
        siteInfo.elevation, siteInfo.temperature, siteInfo.yearFrom, siteInfo.yearTo, ...
        string(piName), string(piEmail), string(fluxContactName), string(fluxContactEmail), ...
        string(dataManagerName), string(dataManagerEmail), string(technicianName), string(technicianEmail), ...
        'VariableNames', {'LocationName', 'LocationCode', 'Latitude', 'Longitude', 'Elevation', ...
        'Temperature', 'YearFrom', 'YearTo', 'PIName', 'PIEmail', ...
        'FluxContactName', 'FluxContactEmail', 'DataManagerName', 'DataManagerEmail', ...
        'TechnicianName', 'TechnicianEmail'});
    
    % Append the table to the Excel spreadsheet
    if i == 1
        writetable(data, fullpath, 'Sheet', 1, 'FileType', 'spreadsheet');
    else
        writetable(data, fullpath, 'Sheet', 1, 'FileType', 'spreadsheet', 'WriteMode', 'append');
    end

end
