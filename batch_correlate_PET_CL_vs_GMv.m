
% Correlate varA with varB accounting for confounds (SPM)

clear, clc, close all

%% Paths / data
path_batches = 'D:\Projects\2023_multib\MK_multi_b\Scripts';
cd(path_batches)

% load('Table_demographics_biomarkers_2024_04_09.mat')
load('Table_297_subjs_demographics_biomarkers_2024_05_03.mat')
n_subjects = size(T_subjects,1);

% path_stats_group = 'D:\Projects\2023_multib\MK_multi_b\Stats_group_level\';
path_stats_group = 'D:\Projects\2023_multib\MK_multi_b\Stats_group_level_297_subjs\';
sample = 'all_subjs';   % 'A-T-' or 'all_subjs'

%% Load fluid biomarkers and attach missing variables
path_fluid_biomarkers = '..\Biomarkers\f_bmk_long_09_05_23.xlsx';
T_fluid_biomarkers    = readtable(path_fluid_biomarkers);

list_subject_IDs = str2double(T_subjects.Subject_ID);
list_B           = T_fluid_biomarkers.IdParticipante;
[found, idx]     = ismember(list_subject_IDs, list_B, 'rows');
T_subjects.Ab42_elecsys = T_fluid_biomarkers.Ab42_CSFNC_RocheElecsys_BL(idx);

%% Variable of interest
close all
phys_variable = 'GMv';
disp(phys_variable)

% phys_variable = 'tissueFraction';  % alt: slow_ADC, fast_ADC, slow_signal_portion, tissueFraction

confound      = [];
confound{1}   = 'age';
confound{2}   = 'sex';
confound{3}   = 'apoe4';
confound{4}   = 'TIV';
n_confounds   = length(confound);

%% Select subject indices
switch sample
    case 'A-T-'
        ind_subjs = find(strcmp(T_subjects.AT_status, 'A-T-'));
        n_subjs_group = length(ind_subjs);
        fprintf('Group of subjects: A-T- (N=%d)\n', n_subjs_group)
    case 'all_subjs'
        ind_subjs = 1:n_subjects;
        n_subjs_group = n_subjects;
        fprintf('Group of subjects: All subjects (N=%d)\n', n_subjs_group)
end

%% Covariates and biomarker-derived variables
cov_Ab40.values = cell2mat(T_subjects.Ab40(ind_subjs));   % reference for normalization

cov_age.label   = 'age';   cov_age.values   = str2double(T_subjects.Age_V1S1(ind_subjs));
cov_sex.label   = 'sex';   cov_sex.values   = str2double(T_subjects.Sex(ind_subjs));
cov_apoe4.label = 'apoe4'; cov_apoe4.values = str2double(T_subjects.APOE4(ind_subjs));
cov_TIV.label   = 'TIV';   cov_TIV.values   = T_subjects.eTIV(ind_subjs);


cov_Ab4240.label  = 'Ab4240';
cov_Ab4240.values = cell2mat(T_subjects.Ab4240(ind_subjs));  % CSF 42/40 (NTK)

temp_Ab42_elecsys           = T_subjects.Ab42_elecsys(ind_subjs);
cov_Ab4240_elecsys.label    = 'Ab4240_elecsys';
cov_Ab4240_elecsys.values   = temp_Ab42_elecsys ./ cov_Ab40.values;


cov_PET_CLs.label  = 'PET_CLs';
cov_PET_CLs.values = T_subjects.PET_CLs(ind_subjs);
ind = find(cov_PET_CLs.values > 30);     % cap extreme PET CLs
cov_PET_CLs.values(ind) = NaN;

cov_AT_1vs2.label  = 'AT_1vs2';
tmp = NaN(n_subjs_group,1);
ind = strcmp(T_subjects.AT_status, 'A-T-'); tmp(ind) = 1;
ind = strcmp(T_subjects.AT_status, 'A+T-'); tmp(ind) = 2;
cov_AT_1vs2.values = tmp;

% Choose variable of interest (uncomment one of the lines below as needed)
cov_interest = cov_PET_CLs;
% cov_interest = cov_Ab4240;
% cov_interest = cov_Ab4240_elecsys;

var_of_interest = cov_interest.label;

%% Build confounds struct + suffix for output path
clear confounds
path_output_string_confounds = [];
for k = 1:n_confounds
    eval(sprintf('confounds(%d) = cov_%s;', k, confound{k}))
    path_output_string_confounds = [path_output_string_confounds, '_', confounds(k).label];
end

%% Image paths (GMv maps) and output

path_phys_maps = 'X:\ALFA+_Cross_Sectional_V1_GM_maps_MNI\';

path_output = [path_stats_group, 'Stats_group_', phys_variable, '\Stats_', ...
               sample, '_correl_', phys_variable, '_', var_of_interest, ...
               '_c', path_output_string_confounds];

%% Build image list and record missing files
clear input_imgs
input_imgs{1} = [];
ind_subjs_missing_GMv = [];

for subj = 1:n_subjs_group
    subject = T_subjects.Subject_ID{ind_subjs(subj)};
    fprintf(' Subject: %s\n', subject)
    path_temp = [path_phys_maps, 's6mwc1_', subject, '.nii'];
    input_imgs{subj,1} = path_temp;

    if isfile(path_temp) == 0
        ind_subjs_missing_GMv(end+1) = subj; %#ok<SAGROW>
    end
end

%% Exclude NaNs/outliers in cov_interest and TIV; drop missing GMv
ind_v1 = find(isnan(cov_interest.values));
ind_v2 = find(isnan(confounds(4).values));  % NaN in TIV
ind     = unique([ind_v1; ind_subjs_missing_GMv(:); ind_v2]);

cov_interest.values(ind) = [];
for k = 1:n_confounds
    confounds(k).values(ind) = [];
end
input_imgs(ind) = [];
fprintf('Number of subjects (after excl outliers): %d\n', size(input_imgs,1))

%% Create temp files and (optionally) submit SPM job
if 0
    cd(path_batches)

    list_confound_files{1} = [];
    for k = 1:n_confounds
        filename = sprintf('tmp_confound_%d.txt', k);
        list_confound_files{k,1} = filename;
        writematrix(confounds(k).values, filename);
    end

    writecell(input_imgs, 'inp_imgs.txt')
    writematrix(cov_interest.values, 'cov_interest.txt')

    save('tmp_workspace_correlate_varA_varB.mat', ...
         'input_imgs','path_output','cov_interest','n_confounds','list_confound_files')

    % jobfile = {'batch_correlate_vars_job.m'};
    jobfile = {'batch_correlate_PET_CL_vs_GMv_job.m'};
    jobs = repmat(jobfile, 1, 1);
    inputs = cell(0, 1);
    spm('defaults', 'FMRI'); spm_jobman('run', jobs, inputs{:});

    cd(path_batches)
    delete('tmp_workspace_correlate_varA_varB.mat')

    for k = 1:n_confounds
        delete(sprintf('tmp_confound_%d.txt', k))
    end
end
``
