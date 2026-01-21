
% Correlate varA with varB accounting for confounds (SPM)

clear, clc, close all

%% Paths / data
path_batches = 'D:\Projects\2023_multib\MK_multi_b\Scripts';
cd(path_batches)

load('Table_297_subjs_demographics_biomarkers_2024_05_03.mat')
n_subjects      = size(T_subjects,1);
path_stats_group = 'D:\Projects\2023_multib\MK_multi_b\Stats_group_level_297_subjs\';

sample = 'all_subjs';   % 'A-T-' or 'all_subjs'
list_phys_variables = {'slow_ADC'; 'fast_ADC'; 'slow_signal_portion'; 'tissueFraction'};

%% Variables of interest (biomarkers / composites)
list_vars_of_interest = { ...
    'Ab4240'; 'pTau'; 'pTau_norm2Ab40'; 'PET_CLs'; 'PET_CLs_excl_outliers'; ...
    'NfL'; 'NfL_norm2Ab40'; 'TIV_hippocVol'; 'ADsignature'; ...
    'sTREM2'; 'YKL40'; 'S100'; 'IL6'; ...
    'sTREM2_norm2Ab40'; 'YKL40_norm2Ab40'; 'S100_norm2Ab40'; 'IL6_norm2Ab40'; ...
    'GFAP_CSF'; 'GFAP_norm2Ab40'; ...
    'GFAP_plasma'; 'GFAP_plasmaF_Simoa'; 'GFAP_plasmaF_SimoaNP4E'; 'GFAP_plasmaNF_SimoaNP4E'};

%% Select variable of interest (adjust loop bounds to run all)
for v = 5    % change to: 1:length(list_vars_of_interest)
    var_of_interest = list_vars_of_interest{v};

    for i_phys = 1:4
        phys_variable = list_phys_variables{i_phys};
        disp(phys_variable); close all

        %% Confounds
        confound = [];
        confound{1} = 'age';
        confound{2} = 'sex';
        confound{3} = 'apoe4';
        n_confounds = length(confound);

        %% Select subjects
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

        %% Covariates and biomarkers (per subject)
        cov_Ab40.values = cell2mat(T_subjects.Ab40(ind_subjs));  % normalization reference

        cov_age.label   = 'age';   cov_age.values   = str2double(T_subjects.Age_V1S1(ind_subjs));
        cov_sex.label   = 'sex';   cov_sex.values   = str2double(T_subjects.Sex(ind_subjs));
        cov_apoe4.label = 'apoe4'; cov_apoe4.values = str2double(T_subjects.APOE4(ind_subjs));

        cov_pTau.label  = 'pTau';
        cov_pTau.values = cell2mat(T_subjects.pTau_181(ind_subjs));

        cov_pTau_norm2Ab40.label  = 'pTau_norm2Ab40';
        cov_pTau_norm2Ab40.values = cell2mat(T_subjects.pTau_181(ind_subjs)) ./ cov_Ab40.values;

        cov_Ab4240.label  = 'Ab4240';
        cov_Ab4240.values = cell2mat(T_subjects.Ab4240(ind_subjs));

        cov_sTREM2.label  = 'sTREM2';
        cov_sTREM2.values = cell2mat(T_subjects.sTREM2(ind_subjs));

        cov_sTREM2_norm2Ab40.label  = 'sTREM2_norm2Ab40';
        cov_sTREM2_norm2Ab40.values = cell2mat(T_subjects.sTREM2(ind_subjs)) ./ cov_Ab40.values;

        cov_PET_CLs.label  = 'PET_CLs';
        cov_PET_CLs.values = T_subjects.PET_CLs(ind_subjs);

        cov_PET_CLs_excl_outliers.label  = 'PET_CLs_excl_outliers';
        cov_PET_CLs_excl_outliers.values = T_subjects.PET_CLs(ind_subjs);
        ind = find(cov_PET_CLs_excl_outliers.values > 30);
        cov_PET_CLs_excl_outliers.values(ind) = NaN;

        cov_YKL40.label  = 'YKL40';
        cov_YKL40.values = cell2mat(T_subjects.YKL40(ind_subjs));

        cov_YKL40_norm2Ab40.label  = 'YKL40_norm2Ab40';
        cov_YKL40_norm2Ab40.values = cell2mat(T_subjects.YKL40(ind_subjs)) ./ cov_Ab40.values;

        cov_S100.label  = 'S100';
        cov_S100.values = cell2mat(T_subjects.S100(ind_subjs));

        cov_S100_norm2Ab40.label  = 'S100_norm2Ab40';
        cov_S100_norm2Ab40.values = cell2mat(T_subjects.S100(ind_subjs)) ./ cov_Ab40.values;

        cov_IL6.label  = 'IL6';
        cov_IL6.values = cell2mat(T_subjects.IL6(ind_subjs));

        cov_IL6_norm2Ab40.label  = 'IL6_norm2Ab40';
        cov_IL6_norm2Ab40.values = cell2mat(T_subjects.IL6(ind_subjs)) ./ cov_Ab40.values;

        cov_NfL.label  = 'NfL';
        cov_NfL.values = cell2mat(T_subjects.NfL(ind_subjs));

        cov_NfL_norm2Ab40.label  = 'NfL_norm2Ab40';
        cov_NfL_norm2Ab40.values = cell2mat(T_subjects.NfL(ind_subjs)) ./ cov_Ab40.values;

        cov_GFAP_CSF.label  = 'GFAP_CSF';
        cov_GFAP_CSF.values = cell2mat(T_subjects.GFAP_CSF(ind_subjs));

        cov_GFAP_norm2Ab40.label  = 'GFAP_norm2Ab40';
        cov_GFAP_norm2Ab40.values = cell2mat(T_subjects.GFAP_CSF(ind_subjs)) ./ cov_Ab40.values;

        cov_GFAP_plasma.label  = 'GFAP_plasma';
        cov_GFAP_plasma.values = cell2mat(T_subjects.GFAP_plasmaF_RocheNTK(ind_subjs));

        cov_GFAP_plasmaF_Simoa.label  = 'GFAP_plasmaF_Simoa';
        cov_GFAP_plasmaF_Simoa.values = cell2mat(T_subjects.GFAP_plasmaF_Simoa(ind_subjs));

        cov_GFAP_plasmaF_SimoaNP4E.label  = 'GFAP_plasmaF_SimoaNP4E';
        cov_GFAP_plasmaF_SimoaNP4E.values = cell2mat(T_subjects.GFAP_plasmaF_SimoaNP4E(ind_subjs));

        cov_GFAP_plasmaNF_SimoaNP4E.label  = 'GFAP_plasmaNF_SimoaNP4E';
        cov_GFAP_plasmaNF_SimoaNP4E.values = cell2mat(T_subjects.GFAP_plasmaNF_SimoaNP4E(ind_subjs));

        cov_ADsignature.label  = 'ADsignature';
        cov_ADsignature.values = T_subjects.jack_true_thickAvg(ind_subjs);

        cov_TIV_hippocVol.label  = 'TIV_hippocVol';
        cov_TIV_hippocVol.values = T_subjects.TIV_adj_hippoc_vol(ind_subjs);

        eval(sprintf('cov_interest = cov_%s;', var_of_interest))

        %% Assemble confounds and suffix for output
        clear confounds
        path_output_string_confounds = [];
        for k = 1:n_confounds
            eval(sprintf('confounds(%d) = cov_%s;', k, confound{k}))
            path_output_string_confounds = [path_output_string_confounds, '_', confounds(k).label];
        end

        %% Input images and output
        path_phys_maps = ['D:\Projects\2023_multib\MK_multi_b\Stats_single_level\Stats_', ...
                          phys_variable, '\s10bwnl2t1_', phys_variable, '_'];

        path_output = [path_stats_group, 'Stats_group_', phys_variable, '\Stats_', ...
                       sample, '_correl_', phys_variable, '_', var_of_interest, ...
                       '_c', path_output_string_confounds];

        clear input_imgs
        input_imgs{1} = [];
        for subj = 1:n_subjs_group
            subject = T_subjects.Subject_ID{ind_subjs(subj)};
            input_imgs{subj,1} = [path_phys_maps, subject, '.nii'];
        end

        %% Remove NaNs in cov_interest (and align lists)
        ind = find(isnan(cov_interest.values));
        cov_interest.values(ind) = [];
        for k = 1:n_confounds
            confounds(k).values(ind) = [];
        end
        input_imgs(ind) = [];

        %% Temp files + run SPM batch
        list_confound_files{1} = [];
        for k = 1:n_confounds
            filename = sprintf('tmp_confound_%d.txt', k);
            list_confound_files{k,1} = filename;
            writematrix(confounds(k).values, filename);
        end

        save('tmp_workspace_correlate_varA_varB.mat', ...
             'input_imgs','path_output','cov_interest','n_confounds','list_confound_files')

        jobfile = {'batch_correlate_varA_varB_c_varC_varD_job.m'};
        jobs = repmat(jobfile, 1, 1); inputs = cell(0, 1);
        spm('defaults', 'FMRI'); spm_jobman('run', jobs, inputs{:});

        cd(path_batches)
        delete('tmp_workspace_correlate_varA_varB.mat')
        for k = 1:n_confounds
            delete(sprintf('tmp_confound_%d.txt', k))
        end
    end
end
