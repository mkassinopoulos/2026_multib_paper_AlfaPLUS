
% Compute mean parametric maps averaged across all subjects

clear, clc, close all

%% Paths
path_batches     = 'D:\Projects\2023_multib\MK_multi_b\Scripts';
cd(path_batches)

load('Table_demographics_biomarkers_2023_10_23.mat')   % loads T_subjects
n_subjects       = size(T_subjects,1);

path_stats_group = 'D:\Projects\2023_multib\MK_multi_b\Stats_group_level\';
phys_variable    = 'tissueFraction';   % slow_ADC, fast_ADC, slow_signal_portion, tissueFraction

path_phys_maps = ['D:\Projects\2023_multib\MK_multi_b\Stats_single_level\Stats_', ...
                  phys_variable, '\s10bwnl2t1_', phys_variable, '_'];

%% Load template NIfTI (first subject) to get header and dimensions
path_template = [path_phys_maps, T_subjects.Subject_ID{1}, '.nii']
nii_template  = load_untouch_nii(path_template);
img0          = single(nii_template.img);
[NX,NY,NZ]    = size(img0);

%% Load all subject maps
par_map_all = zeros(NX,NY,NZ,n_subjects);

for subj = 1:n_subjects
    subject = T_subjects.Subject_ID{subj};
    fprintf('Subject: %s\n', subject)
    nii_sub  = load_untouch_nii([path_phys_maps, subject, '.nii']);
    par_map_all(:,:,:,subj) = nii_sub.img;
end

%% Compute mean map and save
nii_template.img = mean(par_map_all, 4);
save_untouch_nii(nii_template, ...
    [path_stats_group, 'Mean_', phys_variable, '_all_subjs']);
