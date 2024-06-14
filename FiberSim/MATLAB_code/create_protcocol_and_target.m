function create_protcocol_and_target
% Function creates a protocol and a target file from experimental data

% Variables
data_file_string = '../expt_data/horslen_fiber_18dec2017a_summary.mat';
f_scaling_factor = 1e3;
initial_hsl = 1300;
pre_points = 750;
protocol_folder = '../cMyoSim/protocols';
target_file_string = '../cMyoSim/target_data/target_forces.txt';

condition_indices = [7 5 3 2 1]

% Code
expt_data = load(data_file_string);

no_of_conditions = numel(expt_data.pCas);

% Clean out the protocols folder
try
    delete(fullfile(protocol_folder, '*'))
end

% Prep the target_force array
target_force = [];

% Make a figure
figure(1);
clf;
no_of_rows = 5;
no_of_cols = 1;
color_map = parula(no_of_conditions);

% Unpack record
for i = 1 : numel(condition_indices)
    
    % Build out the experimental data record
    d.time_s = expt_data.Ti;
    d.pCa = expt_data.pCas(condition_indices(i)) * ones(numel(d.time_s), 1);
    d.force = f_scaling_factor * expt_data.Fi(:, condition_indices(i));
    d.fl = expt_data.Li(:, condition_indices(i));

    % Calculate the delta_hs_length
    d.hs_length = initial_hsl * d.fl ./ d.fl(1);
    d.delta_hs_length = [0 ; diff(d.hs_length)];

    % Store the data for pCa
    pd(1).pCa(i) = d.pCa(1);
    pd(1).y(i) = d.force(1);
    pd(1).y_error(i) = 0;

    % Store the target force
    target_force = [target_force d.force];

    % Set the protocol table
    prot = [];
    dt = d.time_s(2) - d.time_s(1);
    prot.dt = dt * ones(pre_points + numel(d.time_s), 1);
    prot.pCa = d.pCa(1) * ones(pre_points + numel(d.time_s), 1);
    prot.delta_hsl = [zeros(pre_points, 1) ; d.delta_hs_length];
    prot.mode = -2 * ones(numel(prot.dt), 1);

    % Convert to table
    prot = columnize_structure(prot);
    prot = struct2table(prot);

    % Save to disk
    prot_file_string = fullfile(protocol_folder, ...
                        sprintf('prot_pCa_%.0f.txt', 10*d.pCa(1)));
    writetable(prot, prot_file_string, 'Delimiter', '\t');

    % Display
    subplot(no_of_rows, no_of_cols, 1);
    hold on;
    plot(d.time_s, d.pCa, '-', 'Color', color_map(i,:));

    subplot(no_of_rows, no_of_cols, 2);
    hold on;
    plot(d.time_s, d.force, '-', 'Color', color_map(i,:));

    subplot(no_of_rows, no_of_cols, 3);
    hold on;
    plot(d.time_s, d.fl, '-', 'Color', color_map(i,:));

    subplot(no_of_rows, no_of_cols, 4);
    hold on;
    plot(d.time_s, d.hs_length, '-', 'Color', color_map(i,:));

    subplot(no_of_rows, no_of_cols, 5);
    hold on;
    plot(d.time_s, d.delta_hs_length, '-', 'Color', color_map(i,:));
end

writematrix(target_force, target_file_string, 'Delimiter', '\t');

[pd(1).pCa_50, pd(1).n_H, ~, ~, ~, pd(1).x_fit, pd(1).y_fit] = ...
    fit_Hill_curve(pd(1).pCa, pd(1).y);

figure(2);
clf
plot_pCa_data_with_y_errors(pd)

pd(1).pCa