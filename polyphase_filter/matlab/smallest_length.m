function smallest_length = find_smallest_length(vectors)
    % Initialize the smallest length with positive infinity
    smallest_length = Inf;

    % Loop through each vector in the input cell array
    for i = 1:length(vectors)
        % Get the length of the current vector
        current_length = numel(vectors{i});

        % Update the smallest_length if the current length is smaller
        if current_length < smallest_length
            smallest_length = current_length;
        end
    end
end