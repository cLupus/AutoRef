% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%            Copyright (c) 2016 Sindre Nistad
function plot_distance(gcp_data)

n_dim = size(gcp_data, 2);

means = mean(gcp_data);
stds = std(gcp_data);

mins = min(gcp_data);
maxs = max(gcp_data);

std_max_factor = max(max([abs(means - maxs) ./ stds; abs(means - mins) ./ stds]));

x = 0:0.001:std_max_factor;
Y_upp = zeros(numel(x), n_dim);
Y_low = Y_upp;

for i=1:n_dim
    Y_upp(:,i) = means(i) + x .* stds(i);
    Y_low(:,i) = means(i) - x .* stds(i);
end

distances_upp = mahal(Y_upp, gcp_data);
distances_low = mahal(Y_low, gcp_data);

plot(x, distances_upp);
xlabel('Antal standardavvik fra gjennomsnittet');
ylabel('Mahalanobisavstanden fra gjennomsnittet')


figure
plot(x, distances_upp - distances_low);
xlabel('Antal standardavvik fra gjennomsnittet');
ylabel('Forskjell i Mahalanobisavstanden')

fprintf('Den maksimale avstanden mellom nedre og øvre grense er %e\n', max(abs(distances_upp - distances_low)));

end
