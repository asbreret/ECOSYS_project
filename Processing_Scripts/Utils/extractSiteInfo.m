function siteInfo = extractSiteInfo(code)

url = ['https://ameriflux.lbl.gov/sites/siteinfo/',code];

% Read the website content
html = webread(url);

% Initialize the siteInfo structure
siteInfo = struct();

% Extract latitude and longitude using regular expressions
latLonPattern = '<td>Lat, Long:</td>\s+<td>(-?\d+\.\d+), (-?\d+\.\d+)</td>';
latLonMatches = regexp(html, latLonPattern, 'tokens');

% Extract elevation using regular expressions
elevationPattern = '<td>Elevation\(m\): </td>\s+<td>(-?\d+\.?\d*)</td>';
elevationMatches = regexp(html, elevationPattern, 'tokens');

% Extract temperature using regular expressions
temperaturePattern = '<td>Mean Annual Temp \(°C\): </td>\s+<td>(-?\d+\.?\d*)</td>';
temperatureMatches = regexp(html, temperaturePattern, 'tokens');

% Extract people using regular expressions
peoplePattern = '<tr class="team"><td>([^:]+): </td><td>(.*?)</td></tr>';
peopleMatches = regexp(html, peoplePattern, 'tokens', 'dotall');

% Extract years of data collection using regular expressions
yearsPattern = '<td>Years Data Collected:</td>\s+<td>\s+(.*?)\s+</td>';
yearsMatches = regexp(html, yearsPattern, 'tokens', 'once');

% Extract location name using regular expressions
locationPattern = '<h1 class="page-title entry-title" itemprop="headline">(.*?)</h1>';
locationMatches = regexp(html, locationPattern, 'tokens', 'once');

% Check if any matches were found for latitude and longitude
if ~isempty(latLonMatches)
    siteInfo.latitude = str2double(latLonMatches{1}{1});
    siteInfo.longitude = str2double(latLonMatches{1}{2});
else
    siteInfo.latitude = NaN;
    siteInfo.longitude = NaN;
end

% Check if any matches were found for elevation
if ~isempty(elevationMatches)
    siteInfo.elevation = str2double(elevationMatches{1}{1});
else
    siteInfo.elevation = 0;
end

% Check if any matches were found for temperature
if ~isempty(temperatureMatches)
    siteInfo.temperature = str2double(temperatureMatches{1}{1});
else
    siteInfo.temperature = 15;
end

% Check if any matches were found for people
if ~isempty(peopleMatches)
    siteInfo.people = struct();
    for i = 1:numel(peopleMatches)
        role = peopleMatches{i}{1};
        name = peopleMatches{i}{2};
        siteInfo.people.(role) = name;
    end
else
    siteInfo.people = struct();
end

% Check if a match was found for years of data collection
if ~isempty(yearsMatches)
    yearsDataCollected = strtrim(yearsMatches{1});
    yearsSplit = strsplit(yearsDataCollected, '-');
    siteInfo.yearFrom = str2double(yearsSplit{1});
    siteInfo.yearTo = str2double(yearsSplit{2});
else
    siteInfo.yearFrom = NaN;
    siteInfo.yearTo = NaN;
end

% Check if a match was found for the location name
if ~isempty(locationMatches)
    fullLocationName = locationMatches{1};
    cleanedLocationName = regexprep(fullLocationName, '<.*?>', ''); % Remove HTML tags
    siteInfo.locationName = strtrim(strrep(cleanedLocationName, [code ':'], ''));
else
    siteInfo.locationName = '';
end
end
