
% Correlate varA with varB accounting for confounds (SPM)

clear, clc, close all

%% Paths / data
path_batches = 'D:\Projects\2023_multib\MK_multi_b\Scripts';
cd(path_batches)

% load('Table_demographics_biomarkers_2024_04_09.mat')
load('..\Biomarkers\XCPD_analysis\Table_demographics_biomarkers_2024_10_29.mat')
n_subjects    = size(T_subjects, 1);

path_stats_group = 'D:\Projects\2023_multib\MK_multi_b\Stats_group_level_all_AlfaPLUS_subjs\';

%% Settings
group_A = 'A-T-';    % alternatives: 'A-T-'
group_B = 'A+T-';    % alternatives: 'A+T-' or 'A+T+'
phys_variable = 'GMv_12mm';

confound = [];
confound{1} = 'age';
confound{2} = 'sex';
confound{3} = 'apoe4';
confound{4} = 'TIV';
n_confounds = length(confound);

%% Group indices (A vs B)
ind_subjs_A = find(strcmp(T_subjects_V1.AT_status, group_A));
n_subjs_group_A = length(ind_subjs_A);
fprintf('Group %s: (N=%d) \n', group_A, n_subjs_group_A)

ind_subjs_B = find(strcmp(T_subjects_V1.AT_status, group_B));
n_subjs_group_B = length(ind_subjs_B);
fprintf('Group %s: (N=%d) \n', group_B, n_subjs_group_B)

ind_subjs_A_B = [ind_subjs_A; ind_subjs_B];

%% Confounds for A∪B (as vectors)
cov_age.label   = 'age';   cov_age.values   = T_subjects.Age_V1S1(ind_subjs_A_B);
cov_sex.label   = 'sex';   cov_sex.values   = str2double(T_subjects.Sex(ind_subjs_A_B));
cov_apoe4.label = 'apoe4'; cov_apoe4.values = str2double(T_subjects.APOE4(ind_subjs_A_B));
cov_TIV.label   = 'TIV';   cov_TIV.values   = T_subjects_V1.eTIV(ind_subjs_A_B);

%% Collect confounds into struct array + output label suffix
clear confounds
path_output_string_confounds = [];
for k = 1:n_confounds
    eval(sprintf('confounds(%d) = cov_%s;', k, confound{k}));
    path_output_string_confounds = [path_output_string_confounds, '_', confounds(k).label];
end

%% Input images (GMv maps)
% Spatial smoothing: 12 mm FWHM
path_phys_maps = 'D:\Data_XNAT\ALFA_PLUS_V1_T1_Dartel_smoothed\';

path_output = [path_stats_group, 'Stats_group_', phys_variable, '\Stats_', ...
               group_A, '_vs_', group_B, '_ANOVA2_', phys_variable, ...
               '_c', path_output_string_confounds];

%% Build lists of image paths for each group
clear input_imgs_group_A
input_imgs_group_A{1} = [];
for subj = 1:n_subjs_group_A
    subject = T_subjects.Subject_ID{ind_subjs_A(subj)};
    fprintf(' Subject: %s\n', subject)
    input_imgs_group_A{subj,1} = [path_phys_maps, subject, '.nii'];
end

clear input_imgs_group_B
input_imgs_group_B{1} = [];
for subj = 1:n_subjs_group_B
    subject = T_subjects.Subject_ID{ind_subjs_B(subj)};
    fprintf(' Subject: %s\n', subject)
    input_imgs_group_B{subj,1} = [path_phys_maps, subject, '.nii'];
end

%% Find and remove outliers in cov_interest (kept as in original)
% NOTE: Assumes cov_interest, ind_subjs_missing_GMv, and input_imgs exist upstream.
ind_v1 = find(isnan(cov_interest.values));
ind_v2 = find(isnan(confounds(4).values));   % NaN in TIV

ind = unique([ind_v1; ind_subjs_missing_GMv(:); ind_v2]);

cov_interest.values(ind) = [];
for k = 1:n_confounds
    confounds(k).values(ind) = [];
end
input_imgs(ind) = [];

fprintf('Number of subjects (after excl outliers): %d \n', size(input_imgs, 1))

%% Write temporary confound files, run SPM batch, and clean up
cd(path_batches)

list_confound_files{1} = [];
for k = 1:n_confounds
    filename = sprintf('tmp_confound_%d.txt', k);
    list_confound_files{k,1} = filename;
    writematrix(confounds(k).values, filename);
end

save('tmp_workspace_batch_ANOVA_2_groups.mat', ...
     'input_imgs_group_A','input_imgs_group_B','path_output', ...
     'n_confounds','list_confound_files')

jobfile = {'batch_ANOVA_2_groups_job.m'};
jobs = repmat(jobfile, 1, 1);
inputs = cell(0, 1);
spm('defaults', 'FMRI'); spm_jobman('run', jobs, inputs{:});

cd(path_batches)
delete('tmp_workspace_batch_ANOVA_2_groups.mat')

for k = 1:n_confounds
    delete(sprintf('tmp_confound_%d.txt', k))
end
``
