function filledData = gapFill(data, time)
    filledData = data;

    % Determine the number of intervals that make up a year.
    year_intervals = sum(year(time(1)) == year(time));

    % Identify where the NaN sequences start and end
    nanStart = find(diff([0; isnan(data); 0]) == 1);
    nanEnd = find(diff([0; isnan(data); 0]) == -1) - 1;

    for n = 1:length(nanStart)
        % Fill gaps using nearest day's data (or days' multiple away)
        if nanStart(n) > 1 && nanEnd(n) < length(data)
            for i = nanStart(n):nanEnd(n)
                backSearch = i - 24: -24 : max(1, i - 24 * 7);
                prev_valid = backSearch(find(~isnan(filledData(backSearch)), 1, 'first'));

                forwardSearch = i + 24: 24 : min(length(data), i + 24 * 7);
                next_valid = forwardSearch(find(~isnan(filledData(forwardSearch)), 1, 'first'));

                if isempty(prev_valid)
                    filledData(i) = filledData(next_valid);
                elseif isempty(next_valid)
                    filledData(i) = filledData(prev_valid);
                elseif (i - prev_valid) <= (next_valid - i)
                    filledData(i) = filledData(prev_valid);
                else
                    filledData(i) = filledData(next_valid);
                end
            end
        end
    end

    % Fill gaps using data from exactly 1 year ago or 1 year into the future
    for i = 1:length(filledData)
        if isnan(filledData(i))
            past_year_index = i - year_intervals;
            future_year_index = i + year_intervals;

            if past_year_index > 0 && ~isnan(filledData(past_year_index))
                filledData(i) = filledData(past_year_index);
            elseif future_year_index <= length(filledData) && ~isnan(filledData(future_year_index))
                filledData(i) = filledData(future_year_index);
            end
        end
    end

    % Check and fill the initial chunk of data if they are NaNs
    startIdx = find(~isnan(filledData), 1, 'first');
    if startIdx > 1
        for i = 1:startIdx-1
            future_year_index = i + year_intervals;
            if future_year_index <= length(filledData) && ~isnan(filledData(future_year_index))
                filledData(i) = filledData(future_year_index);
            end
        end
    end

    % Check and fill the last chunk of data if they are NaNs
    endIdx = find(~isnan(filledData), 1, 'last');
    if endIdx < length(filledData)
        for i = length(filledData):-1:endIdx+1
            past_year_index = i - year_intervals;
            if past_year_index > 0 && ~isnan(filledData(past_year_index))
                filledData(i) = filledData(past_year_index);
            end
        end
    end
end
