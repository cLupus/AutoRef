% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function res = extract_area_around_point(img, coordinates, area, name)
    %% Description
    % This function takes a image coordinate ([x, y]) from the given image
    % and a given area, for example 40 x 30 pixles, around the given
    % coordinate. The given image coordinate will be in the centre.
    % To specify a name or path for the image, the name parameter is used.
    % If the name is blank, the area will not be saved to disk, but rather
    % just returned.
    
    %% Getting limits
    x_min = coordinates(1) - round(area(1) / 2);
    x_max = coordinates(1) + round(area(1) / 2);
    
    y_min = coordinates(2) - round(area(2) / 2);
    y_max = coordinates(2) + round(area(2) / 2);
    
    img_size = size(img);
    num_bands = img_size(3);
    
    %% Error cheching
    if (x_min < 0 || x_max > img_size(1) || y_min < 0 || y_max > img_size(2))
        error('The given coordinate, and area is outside of the area of the image');
    end
    
    %% Getting the area of the image
    res = img(y_min:y_max, x_min:x_max, :);
    
    %% Saving the result
    if (max(size(name)) > 0)
        imwrite(res, name);
    end
end
        