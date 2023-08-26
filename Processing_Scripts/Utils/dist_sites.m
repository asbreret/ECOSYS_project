clearvars
clc
close all



% Read the data
data = readtable('site_data.xlsx');

% Extract latitude and longitude
latitudes = data.Latitude;
longitudes = data.Longitude;

% Compute the distance matrix
numSites = height(data);
distance_matrix = zeros(numSites, numSites);
for i = 1:numSites
    for j = 1:numSites
        coord1 = [latitudes(i), longitudes(i)];
        coord2 = [latitudes(j), longitudes(j)];
        distance_matrix(i, j) = distance(coord1, coord2);
    end
end
% Convert from degrees to kilometers (assuming Earth's radius as 6371 km)
distance_matrix = distance_matrix .* (pi/180) * 6371;

% Find the closest site for each site (excluding itself)
[~, closestSiteIdx] = min(distance_matrix + diag(Inf * ones(1, numSites)), [], 2);

% ... [The rest of your script above this remains unchanged]

% Create a heatmap
figure;


h = heatmap(distance_matrix, 'ColorbarVisible', 'on');
h.XDisplayLabels = data.LocationCode;
h.YDisplayLabels = data.LocationCode;

colormap jet

title('Pairwise Distances between Sites (in km)');
