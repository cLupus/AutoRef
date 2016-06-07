function plot_gcps(orthophoto, CM, scale, ST)

if nargin == 2
    scale = 1;
end

imshow(orthophoto(1:scale:end,1:scale:end,:));
hold on;

if nargin == 4 && (size(CM, 2) == 6 || size(CM, 2) == 4)
    % Plot both image points, and transformed points
    ST_inv = invert(ST);
    [R, t, s] = extract_parameters_from_similarity_transform(ST_inv);
    transformed = transform_points(CM(:, (size(CM, 2)/2 + 1):end), R, t, s);
    plot(CM(:, 1)/scale, CM(:, 2)/scale, 'x', 'MarkerSize', 10, 'LineWidth', 1.5);
    plot(transformed(:, 1)/scale, transformed(:, 2)/scale, '+', 'MarkerSize', 10, 'LineWidth', 1.5);
    legend('Image points', 'Transformed points');
elseif nargin == 3 || (size(CM, 2) == 2 || size(CM, 2) == 3)
    % Plot only image points
    plot(CM(:,1)/scale, CM(:,2)/scale, 'o', 'MarkerSize', 10);
    plot(CM(:,1)/scale, CM(:,2)/scale, '+', 'MarkerSize', 7, 'LineWidth', 1.5);
else
    error('Invalid inputs');
end

end
