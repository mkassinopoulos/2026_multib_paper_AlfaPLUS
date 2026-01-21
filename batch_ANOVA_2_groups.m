
% Correlate varA with varB accounting for confounds (SPM setup)

clear, clc, close all

%% Paths / data
path_batches = 'D:\Projects\2023_multib\MK_multi_b\Scripts';
cd(path_batches)

load('Table_297_subjs_demographics_biomarkers_2024_05_03.mat')
n_subjects     = size(T_subjects,1);
path_stats_grp = 'D:\Projects\2023_multib\MK_multi_b\Stats_group_level_297_subjs\';

%% Settings
group_comparison = 2;                     % 1: AT stages (CSF), 2: Amyloid PET neg/pos
phys_variable    = 'slow_signal_portion'; % slow_ADC, fast_ADC, slow_signal_portion, tissueFraction

confound = [];
confound{1} = 'age';
confound{2} = 'sex';
confound{3} = 'apoe4';
n_confounds  = length(confound);

%% Select groups and indices
if group_comparison == 1
    group_A = 'A-T-';  group_B = 'A+T-';
    ind_subjs_A = find(strcmp(T_subjects.AT_status, group_A));
    nA = length(ind_subjs_A);
    fprintf('Group %s: (N=%d)\n', group_A, nA)

    ind_subjs_B = find(strcmp(T_subjects.AT_status, group_B));
    nB = length(ind_subjs_B);
    fprintf('Group %s: (N=%d)\n', group_B, nB)
elseif group_comparison == 2
    group_A = 'PET_neg'; group_B = 'PET_pos';
    ind_subjs_A = find(T_subjects.PET_CLs < 12);
    nA = length(ind_subjs_A);
    fprintf('Group %s: (N=%d)\n', group_A, nA)

    ind_subjs_B = find(T_subjects.PET_CLs > 12);
    nB = length(ind_subjs_B);
    fprintf('Group %s: (N=%d)\n', group_B, nB)
end
ind_subjs_A_B = [ind_subjs_A; ind_subjs_B];

%% Confounds (age, sex, APOE4) for A∪B
cov_age.label   = 'age';   cov_age.values   = str2double(T_subjects.Age_V1S1(ind_subjs_A_B));
cov_sex.label   = 'sex';   cov_sex.values   = str2double(T_subjects.Sex(ind_subjs_A_B));
cov_apoe4.label = 'apoe4'; cov_apoe4.values = str2double(T_subjects.APOE4(ind_subjs_A_B));

clear confounds
path_output_string_confounds = [];
for k = 1:n_confounds
    eval(sprintf('confounds(%d) = cov_%s;', k, confound{k}));
    path_output_string_confounds = [path_output_string_confounds, '_', confounds(k).label];
end

%% Paths to input images
path_phys_maps = ['D:\Projects\2023_multib\MK_multi_b\Stats_single_level\Stats_', ...
                  phys_variable, '\s10bwnl2t1_', phys_variable, '_'];

path_output = [path_stats_grp, 'Stats_group_', phys_variable, '\Stats_', ...
               group_A, '_vs_', group_B, '_ANOVA2_', phys_variable, ...
               '_c', path_output_string_confounds, '_2024M11'];

%% Build image lists for each group
clear input_imgs_group_A
input_imgs_group_A{1} = [];
for subj = 1:nA
    subject = T_subjects.Subject_ID{ind_subjs_A(subj)};
    fprintf(' Subject: %s\n', subject)
    input_imgs_group_A{subj,1} = [path_phys_maps, subject, '.nii'];
end

clear input_imgs_group_B
input_imgs_group_B{1} = [];
for subj = 1:nB
    subject = T_subjects.Subject_ID{ind_subjs_B(subj)};
    fprintf(' Subject: %s\n', subject)
    input_imgs_group_B{subj,1} = [path_phys_maps, subject, '.nii'];
end

%% Write temporary confound files for SPM batch
list_confound_files{1} = [];
for k = 1:n_confounds
    filename = sprintf('tmp_confound_%d.txt', k);
    list_confound_files{k,1} = filename;
    writematrix(confounds(k).values, filename);
end

%% Save workspace for batch, run SPM job, clean up
save('tmp_workspace_batch_ANOVA_2_groups.mat', 'input_imgs_group_A','input_imgs_group_B', ...
     'path_output','n_confounds','list_confound_files')

jobfile = {'batch_ANOVA_2_groups_job.m'};
jobs = repmat(jobfile, 1, 1);
inputs = cell(0, 1);
spm('defaults', 'FMRI'); spm_jobman('run', jobs, inputs{:});

cd(path_batches)
delete('tmp_workspace_batch_ANOVA_2_groups.mat')

for k = 1:n_confounds
    delete(sprintf('tmp_confound_%d.txt', k))
end
