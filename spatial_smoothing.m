
% Run SPM spatial smoothing for all Dartel images in folder

clear, clc, close all

%% Paths
path_Dartel_NAS = 'X:\ALFA_plus_v1_T1_Dartel_Unsmoothed\';

%% List subjects/files
list_subjects = dir(path_Dartel_NAS);
list_subjects = {list_subjects.name}.';
list_subjects(1:2) = [];                     % remove '.' and '..'
n_subjects = numel(list_subjects);

%% Process each subject
for subj = 1:n_subjects
    subject = list_subjects{subj};
    fprintf(' Subject: %s\n', subject)

    path_nii = [path_Dartel_NAS, subject];
    % path_nii_spm = [path_nii, ',1'];       % not used downstream; kept here if needed

    if isfile(path_nii)
        % Pass input to SPM job via workspace file
        save('tmp_jobs/workspace_spatial_smoothing.mat', 'path_nii')

        jobfile = {'D:\Projects\2023_multib\MK_multi_b\Scripts\spatial_smoothing_job.m'};
        jobs   = repmat(jobfile, 1, 1);
        inputs = cell(0, 1);
        spm('defaults', 'FMRI');
        spm_jobman('run', jobs, inputs{:});
    end
end
``
