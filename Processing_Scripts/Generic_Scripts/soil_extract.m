function variables = soil_extract(url)

% url = 'https://casoilresource.lawr.ucdavis.edu/soil_web/property_with_depth_table.php?&cokey=22732732';

html = webread(url);

numhead = 16;

% Extract table data from HTML string
pattern = '<td>(.*?)</td>';
matches = regexp(html, pattern, 'tokens');

% Filter out empty cells
nonEmptyCells = ~cellfun(@isempty, matches);
tableData = cell(size(matches));
tableData(nonEmptyCells) = cellfun(@(x) x{1}, matches(nonEmptyCells), 'UniformOutput', false);

tableData = reshape(tableData,[numhead length(tableData)/numhead])';


for i = 2:size(tableData,1)
    depthStr = tableData(i,1);

    % Split the string at the hyphen
    depthParts = strsplit(depthStr{1}, '-');

    % Extract the numbers and convert them to numeric values
    depthValues = str2double(depthParts);

    % Calculate the average depth
    variables.averageDepth(i-1) = mean(depthValues);

end

% Extract properties from the second row
% properties = tableData(2, :);

% Assign properties to variables

variables.cationExchange = cellfun(@str2double, tableData(2:end,13));
% cationExchange = str2double(properties{13});
variables.anionExchange = 0.7 * variables.cationExchange; % Assuming anion exchange is 70% of cation exchange

variables.Ksat = cellfun(@str2double, tableData(2:end,8));
% Ksat = str2double(properties{8});

variables.clay =  cellfun(@str2double, tableData(2:end,3));
variables.sand =  cellfun(@str2double, tableData(2:end,4));
% clay = str2double(properties{3});
% sand = str2double(properties{4});

variables.AWC = cellfun(@str2double, tableData(2:end,5));
variables.wiltingPoint = cellfun(@str2double, tableData(2:end,14));
% fieldCapacity = str2double(properties{5});
% wiltingPoint = str2double(properties{14});

variables.organicMatter = cellfun(@str2double, tableData(2:end,6));

% totalOrganicC = str2double(properties{6})*(17/18);
% totalOrganicN = str2double(properties{6})*(1/18);
% totalOrganicP = str2double(properties{6})*(1/180);

end