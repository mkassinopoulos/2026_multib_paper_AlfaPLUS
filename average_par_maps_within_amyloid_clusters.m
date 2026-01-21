
% Extract mean DWI parameters and GM volume within significant clusters

clear, clc, close all

%% Load subjects and prune
load('Table_297_subjs_demographics_biomarkers_2024_05_03.mat')
list_subjs_to_remove = [47,69,135];
T_subjects(list_subjs_to_remove,:) = [];
n_subjects = size(T_subjects,1);

%% Paths and settings
path_stats_group = 'D:\Projects\2023_multib\MK_multi_b\Stats_group_level\';
sample           = 'all_subjs';   % 'A-T-' or 'all_subjs' (not used below, kept for context)

list_phys_variables = { ...
    'slow_ADC'; ...
    'fast_ADC'; ...
    'slow_signal_portion'; ...
    'tissueFraction'; ...
    'mean_diffusivity'};

% Cluster maps (masks with GM differences)
path_nii_GM_diffs = 'D:\Projects\2023_multib\MK_multi_b\Stats_group_level_297_subjs\Stats_group_GM_changes_v2\';
path_export       = 'D:\Projects\2023_multib\MK_multi_b\Stats_group_level_297_subjs\cluster_analysis\';
list_stat_maps    = {'PET_CLs_group_p0.005.nii'; 'Ab4240_elecsys_continuous_p0.005.nii'};
n_stat_maps       = length(list_stat_maps);

%% Loop over cluster maps (currently only first; set 1:n_stat_maps to process all)
for id_stat_map = 1   % change to: 1:n_stat_maps
    stat_map_clusters = list_stat_maps{id_stat_map};
    path_nii_stat_map = [path_nii_GM_diffs, stat_map_clusters];

    % Build voxel index for cluster mask (> 0.5)
    nii_stat_map = load_untouch_nii(path_nii_stat_map);
    ind_mask = find(nii_stat_map.img(:) > 0.5);

    %% Average DWI parameters within significant clusters
    mean_par_all_subjs = nan(n_subjects, 5);
    for i_phys = 1:5
        phys_variable = list_phys_variables{i_phys};
        disp(phys_variable); close all

        if i_phys == 5
            % Mean diffusivity has a different filename pattern
            path_phys_maps = ['D:\Projects\2023_multib\MK_multi_b\Stats_single_level\Stats_MD', ...
                              '\wnl2t1_MD_'];
        else
            path_phys_maps = ['D:\Projects\2023_multib\MK_multi_b\Stats_single_level\Stats_', ...
                              phys_variable, '\s10bwnl2t1_', phys_variable, '_'];
        end

        for subj = 1:n_subjects
            subject = T_subjects.Subject_ID{subj};
            fprintf(' Subject: %s\n', subject)
            path_temp = [path_phys_maps, subject, '.nii'];

            if isfile(path_temp)
                nii_sub = load_nii(path_temp);            % keep load_nii as in original block
                img_sub = nii_sub.img;
                mean_par_all_subjs(subj, i_phys) = mean(img_sub(ind_mask));
            end
        end
    end

    %% Average GM volume within significant clusters
    mean_GM_all_subjs = zeros(n_subjects,1);
    for subj = 1:n_subjects
        subject = T_subjects.Subject_ID{subj};
        fprintf(' Subject: %s\n', subject)
        % path_temp = ['X:\ALFA+_Cross_Sectional_V1_GM_maps_MNI\s6mwc1_',subject,'.nii'];
        path_temp = ['D:\Data_XNAT\ALFA_PLUS_V1_T1_Dartel_smoothed\s12_mwc1_', subject, '.nii'];

        if isfile(path_temp)
            nii_sub = load_untouch_nii(path_temp);
            img_sub = nii_sub.img;
            mean_GM_all_subjs(subj) = mean(img_sub(ind_mask));
        else
            mean_GM_all_subjs(subj) = nan;
        end
    end

    %% Save table with per-subject means
    T_DWI_pars = table;
    T_DWI_pars.Subject_ID                = T_subjects.Subject_ID;
    T_DWI_pars.DWI_slow_ADC              = mean_par_all_subjs(:,1);
    T_DWI_pars.DWI_fast_ADC              = mean_par_all_subjs(:,2);
    T_DWI_pars.DWI_slow_signal_portion   = mean_par_all_subjs(:,3);
    T_DWI_pars.DWI_tissueFraction        = mean_par_all_subjs(:,4);
    T_DWI_pars.DWI_meanDiffusivity       = mean_par_all_subjs(:,5);
    T_DWI_pars.GMvol                     = mean_GM_all_subjs;

    save([path_export, 'DWI_pars_signif_ROIs_all_subjs_', stat_map_clusters, '.mat'], 'T_DWI_pars')
end
