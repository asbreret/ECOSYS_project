function variables = soil_depth_properties(url)

% url = 'https://ncsslabdatamart.sc.egov.usda.gov/rptExecute.aspx?p=69917&r=1&';
htmlCode = webread(url);

% Create a DOM object from the HTML code
dom = htmlTree(htmlCode);

% Find all the table rows (tr) in the HTML
tableRows = findElement(dom, 'tr');

% Process the table rows and extract the data you need
for i = 1:numel(tableRows)
    % Extract data from each table cell (td) within the row
    tableCells = findElement(tableRows(i), 'td');

    % Initialize an empty array to store cell contents
    rowData = cell(1, numel(tableCells));

    % Process each cell and store its content in the rowData array
    for j = 1:numel(tableCells)
        cellContent = char(extractHTMLText(tableCells(j)));
        data(i).rowData{j} = cellContent;
    end



end



% Iterate over the elements in data
for i = 1:numel(data)
    % Check if rowData contains the desired values
    if strcmp(data(i).rowData{1}, 'PSDA & Rock Fragments')

        match_1 = i+10;

    elseif strcmp(data(i).rowData{1}, 'Bulk Density & Moisture')

        match_2 = i+9;

    elseif strcmp(data(i).rowData{1}, 'Carbon & Extractions')

        match_3 = i+8;


    end

end

len_1 = length(data(match_1).rowData);
len_2 = length(data(match_2).rowData);
len_3 = length(data(match_3).rowData);

ind_1 = ind_find(data,match_1,len_1);
ind_2 = ind_find(data,match_2,len_2);
ind_3 = ind_find(data,match_3,len_3);



count = 0;

for i = ind_1

    count = count+1;

    depthStr = data(i).rowData{2};

    % Split the string at the hyphen
    depthParts = strsplit(depthStr, '-');

    % Extract the numbers and convert them to numeric values
    depthValues = str2double(depthParts);

    % Calculate the average depth
    variables.averageDepth(count) = mean(depthValues);
    variables.clay(count)         = str2double(   data(i).rowData{6}  );
    variables.silt(count)         = str2double(   data(i).rowData{7}  );
    variables.sand(count)         = str2double(   data(i).rowData{8}  );

end




count = 0;

for i = ind_2

    count = count+1;

    variables.bulk_33(count)              = str2double(   data(i).rowData{5}  );
    variables.bulk_oven(count)            = str2double(   data(i).rowData{6}  );
    variables.water_content_33(count)     = str2double(   data(i).rowData{10} );
    variables.water_content_1500(count)   = str2double(   data(i).rowData{11} );
    variables.WRD(count)                  = str2double(   data(i).rowData{15} );

end



count = 0;

for i = ind_3

    count = count+1;

    variables.Total_C(count)              = str2double(   data(i).rowData{5}  );
    variables.Total_N(count)              = str2double(   data(i).rowData{6}  );

end










    function [ind] = ind_find(data,match,len)

        cond = 0;
        count = 0;

        while cond==0
            count = count+1;
            if length(data(match+count).rowData)~=len
                cond=1;
            end
        end

        ind = match : (match+count-1);

    end

end
