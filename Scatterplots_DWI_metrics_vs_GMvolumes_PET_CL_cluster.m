
%% Load data
clear, clc, close all
addpath('..')

path_DWI  = 'D:\Projects\2023_multib\MK_multi_b\Stats_group_level_297_subjs\Mediation_analysis\';

list_phys_variables = {'slow_ADC'; 'fast_ADC'; 'slow_signal_portion'; 'tissueFraction'; 'meanDiffusivity'};
list_phys_variables_long_name = { ...
    'Slow DC (a.u.)'; ...
    'Fast DC (a.u.)'; ...
    'SSP (a.u.)'; ...
    'Perfusion fraction (a.u.)'; ...
    'Mean diffusivity (10^{-3} mm²/s)'};

list_stat_maps = {'PET_CLs_group_p0.005.nii'; 'Ab4240_elecsys_continuous_p0.005.nii'};
n_stat_maps    = length(list_stat_maps); 

sample = 'all_subjs';   % 'A-T-' or 'all_subjs'
load('Table_297_subjs_demographics_biomarkers_2024_05_03.mat')
n_subjects = size(T_subjects,1); 

%% Load fluid biomarkers and attach missing fields
path_fluid_biomarkers = '..\..\Biomarkers\f_bmk_long_09_05_23.xlsx';
T_fluid_biomarkers    = readtable(path_fluid_biomarkers);

list_subject_IDs = str2double(T_subjects.Subject_ID);
list_B           = T_fluid_biomarkers.IdParticipante;
[found, idx]     = ismember(list_subject_IDs, list_B, 'rows'); 
T_subjects.Ab42_elecsys = T_fluid_biomarkers.Ab42_CSFNC_RocheElecsys_BL(idx);

%% Scatterplots (GM volume vs diffusion metrics)
close all, clc

id_stat_map = 4;   % 1: Ab PET (group), 4: Ab CSF continuous (elecsys)
disp(list_stat_maps{id_stat_map})

path_DWI_stat = [path_DWI, 'DWI_pars_signif_ROIs_all_subjs_', list_stat_maps{id_stat_map}, '.mat'];
load(path_DWI_stat)  % loads T_DWI_pars

% Group indices
ind_AmTm = find(strcmp(T_subjects.AT_status,'A-T-'));
ind_ApTm = find(strcmp(T_subjects.AT_status,'A+T-'));
ind_ApTp = find(strcmp(T_subjects.AT_status,'A+T+'));

T_Stats = nan(5,2);  % [r, p] per parameter

for i_phys = 1:5
    phys_variable = list_phys_variables{i_phys};
    fprintf('------------------------- \n')
    disp(phys_variable)

    % x: DWI parameter within significant clusters; y: GM volume
    eval(sprintf('x = T_DWI_pars.DWI_%s;', phys_variable))
    y = T_DWI_pars.GMvol;
    if i_phys == 5, x = x*1000; end    % scale MD to 10^{-3} mm²/s

    % Remove outliers in x only (as in original)
    ind_outliers = isoutlier(x);
    x(ind_outliers) = nan;

    n_samples_test = length(x) - sum(isnan(x));
    fprintf('Sample size N: %d \n', n_samples_test)

    % Scatter + LS fit (overall)
    figure('Position',[652 692 328 283])
    scatter(x, y, 5, 'filled', 'k'); hold on
    xlabel(list_phys_variables_long_name{i_phys}, 'Interpreter','tex');
    ylabel('GM volume (a.u.)')
    h = lsline;  h.LineWidth = 2; h.Color = [0.5 0.5 0.5];
    grid on

    [corr_r, corr_p] = corr(x, y, 'rows','complete');
    fprintf('Corr: %3.2f, p-value: %3.3f \n', corr_r, corr_p)
    T_Stats(i_phys,1) = corr_r;
    T_Stats(i_phys,2) = corr_p;

    % Overlay groups with shapes/colors
    par_size = 20; par_linewidth = 0.1; par_edge_colour = [0.2 0.2 0.2];
    scatter(x(ind_AmTm), y(ind_AmTm), par_size, [0.4660 0.6740 0.1880], 'filled', ...
            'MarkerEdgeColor', par_edge_colour, 'LineWidth', par_linewidth);
    scatter(x(ind_ApTm), y(ind_ApTm), par_size, [0 0.4470 0.7410], 's', 'filled', ...
            'MarkerEdgeColor', par_edge_colour, 'LineWidth', par_linewidth);
    scatter(x(ind_ApTp), y(ind_ApTp), par_size, [1 0 1], 'd', 'filled', ...
            'MarkerEdgeColor', par_edge_colour, 'LineWidth', par_linewidth);
end
