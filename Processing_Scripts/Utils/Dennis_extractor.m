function [columnHeaders, dataCellArray] = Dennis_extractor(url)

columnHeaders = {};
dataCellArray = {};

% Send an HTTP request and retrieve the website content
options = weboptions('Timeout', 30); % Set timeout value if needed

try
    htmlContent = webread(url, options);
    
    % Find the table containing the data using regular expressions
    pattern = '<table border=1>(.*?)<\/table>';
    dataTable = regexp(htmlContent, pattern, 'tokens', 'once');

    if ~isempty(dataTable)
        % Extract the rows of the table
        rows = regexp(dataTable{1}, '<tr>(.*?)<\/tr>', 'tokens');

        % Extract column headers from the first row
        columns = regexp(rows{1}{1}, '<th>(.*?)<\/th>', 'tokens');

        % Process the column headers and remove any empty cells or tags
        columnHeaders = {};
        for j = 1:length(columns)
            header = strtrim(regexprep(columns{j}{1}, '<.*?>', ''));
            if ~isempty(header)
                columnHeaders{end+1} = header;
            end
        end

        % Initialize a cell array to store the data
        dataCellArray = cell(length(rows)-1, length(columnHeaders));

        % Process the data rows and extract the data as before
        for i = 2:length(rows) % Start from 2 to skip the header row
            % Extract columns from each row
            dataColumns = regexp(rows{i}{1}, '<td>(.*?)<\/td>', 'tokens');

            % Extract individual data values and process them as needed
            for j = 1:length(dataColumns)
                data = strtrim(regexprep(dataColumns{j}{1}, '<.*?>', ''));
                dataCellArray{i-1, j} = data;
            end
        end
    else
        disp('Data table not found in the HTML content.');
    end

catch ME
    % Handle exceptions here
    disp(['Error occurred: ', ME.message]);
    % Optionally, you can return early if an error happens
    return;
end

end
