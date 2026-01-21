
%% Section A: Load data
clear, clc, close all

load('Table_297_subjs_demographics_biomarkers_2024_05_03.mat')
n_subjs = size(T_subjects, 1);

% (Loop below is a no-op; kept for context)
for s = 1:n_subjs
    subj = T_subjects.Subject_ID{s}; 
end

%% Create table with demographic and CSF variables
T = table;

T_labels = { ...
    'Sample size N'; 'Age (years)'; 'Sex'; 'APOE-ε4 carriers n/N (%)'; ...
    'CSF Aβ42/40'; 'CSF p-Tau'; 'Aβ PET (CL)'; ...
    'TIV-adjusted hippocampal volume (mm^2)'; 'AD signature (mm)'; ...
    'PACC (z-score)'; 'MMSE score'};

N_labels = numel(T_labels);
T.labels = T_labels;
empty_str_col = repmat("", [N_labels, 1]);

% group_1: A-T-, group_2: A+T-, group_3: A+T+
T.group_1 = empty_str_col;
T.group_2 = empty_str_col;
T.group_3 = empty_str_col;

T.p_group1_group2 = nan(N_labels,1);
T.p_group1_group3 = nan(N_labels,1);
T.p_group2_group3 = nan(N_labels,1);

ind_group_1 = strcmp(T_subjects.AT_status, 'A-T-');
ind_group_2 = strcmp(T_subjects.AT_status, 'A+T-');
ind_group_3 = strcmp(T_subjects.AT_status, 'A+T+');
ind_group_4_excl = strcmp(T_subjects.AT_status, 'A-T+'); 

%% Fill table row by row
for i = 1:N_labels
    variable = T_labels{i};

    switch variable
        case 'Sample size N'
            T.group_1(i) = num2str(sum(ind_group_1));
            T.group_2(i) = num2str(sum(ind_group_2));
            T.group_3(i) = num2str(sum(ind_group_3));

        case 'Age (years)'
            x = str2double(T_subjects.Age_V1S1);
            x_CU    = x(ind_group_1);
            x_preAD = x(ind_group_2);
            x_AD    = x(ind_group_3);

            T.group_1(i) = sprintf('%2.1f (%2.1f) [%2.0f, %2.0f]', mean(x_CU),    std(x_CU),    min(x_CU),    max(x_CU));
            T.group_2(i) = sprintf('%2.1f (%2.1f) [%2.0f, %2.0f]', mean(x_preAD), std(x_preAD), min(x_preAD), max(x_preAD));
            T.group_3(i) = sprintf('%2.1f (%2.1f) [%2.0f, %2.0f]', mean(x_AD),    std(x_AD),    min(x_AD),    max(x_AD));

            [~,p_12] = ttest2(x_CU, x_preAD, 'Vartype','unequal');
            [~,p_13] = ttest2(x_CU, x_AD,    'Vartype','unequal');
            [~,p_23] = ttest2(x_preAD, x_AD, 'Vartype','unequal');

            fprintf('Age — p12=%2.3f, p13=%2.3f, p23=%2.3f\n', p_12, p_13, p_23)
            T.p_group1_group2(i) = p_12; T.p_group1_group3(i) = p_13; T.p_group2_group3(i) = p_23;

        case 'Sex'
            % 1: male, 2: female
            x = str2double(T_subjects.Sex);
            x_CU    = x(ind_group_1);
            x_preAD = x(ind_group_2);
            x_AD    = x(ind_group_3);

            % Percent women per group
            fmt_group = @(v) sprintf('%d (%2.1f%%)', sum(v==2), 100*sum(v==2)/numel(v));
            T.group_1(i) = fmt_group(x_CU);
            T.group_2(i) = fmt_group(x_preAD);
            T.group_3(i) = fmt_group(x_AD);

            % Group comparisons (chi-square via crosstab)
            [~,~,p] = crosstab([x_CU; x_preAD], [zeros(size(x_CU)); ones(size(x_preAD))]); T.p_group1_group2(i) = p;
            [~,~,p] = crosstab([x_CU; x_AD],    [zeros(size(x_CU)); ones(size(x_AD))]);    T.p_group1_group3(i) = p;
            [~,~,p] = crosstab([x_preAD; x_AD], [zeros(size(x_preAD)); ones(size(x_AD))]); T.p_group2_group3(i) = p;

        case 'APOE-ε4 carriers n/N (%)'
            % CU
            tmp = T_subjects.APOE4(ind_group_1);
            n1  = sum(strcmp(tmp,'1')); n0 = sum(strcmp(tmp,'0'));
            T.group_1(i) = sprintf('%d/%d (%2.1f%%)', n1, n1+n0, 100*n1/(n1+n0));
            x_CU = [zeros(n0,1); ones(n1,1)];

            % preAD
            tmp = T_subjects.APOE4(ind_group_2);
            n1  = sum(strcmp(tmp,'1')); n0 = sum(strcmp(tmp,'0'));
            T.group_2(i) = sprintf('%d/%d (%2.1f%%)', n1, n1+n0, 100*n1/(n1+n0));
            x_preAD = [zeros(n0,1); ones(n1,1)];

            % AD
            tmp = T_subjects.APOE4(ind_group_3);
            n1  = sum(strcmp(tmp,'1')); n0 = sum(strcmp(tmp,'0'));
            T.group_3(i) = sprintf('%d/%d (%2.1f%%)', n1, n1+n0, 100*n1/(n1+n0));

            [~,~,p] = crosstab([x_CU; x_preAD], [zeros(size(x_CU)); ones(size(x_preAD))]); T.p_group1_group2(i) = p;
            [~,~,p] = crosstab([x_CU; x_AD],    [zeros(size(x_CU)); ones(size(x_AD))]);    T.p_group1_group3(i) = p;
            [~,~,p] = crosstab([x_preAD; x_AD], [zeros(size(x_preAD)); ones(size(x_AD))]); T.p_group2_group3(i) = p;

        case 'CSF Aβ42/40'
            x = cell2mat(T_subjects.Ab4240);
            x_CU = x(ind_group_1); x_preAD = x(ind_group_2); x_AD = x(ind_group_3);

            T.group_1(i) = sprintf('%2.3f (%2.3f)', nanmean(x_CU),    nanstd(x_CU));
            T.group_2(i) = sprintf('%2.3f (%2.3f)', nanmean(x_preAD), nanstd(x_preAD));
            T.group_3(i) = sprintf('%2.3f (%2.3f)', nanmean(x_AD),    nanstd(x_AD));

            [~,p_12] = ttest2(x_CU,x_preAD,'Vartype','unequal');
            [~,p_13] = ttest2(x_CU,x_AD,'Vartype','unequal');
            [~,p_23] = ttest2(x_preAD,x_AD,'Vartype','unequal');
            fprintf('CSF Aβ42/40 — p12=%2.3f, p13=%2.3f, p23=%2.3f\n', p_12, p_13, p_23)
            T.p_group1_group2(i) = p_12; T.p_group1_group3(i) = p_13; T.p_group2_group3(i) = p_23;

        case 'CSF p-Tau'
            x = cell2mat(T_subjects.pTau_181);
            x_CU = x(ind_group_1); x_preAD = x(ind_group_2); x_AD = x(ind_group_3);

            T.group_1(i) = sprintf('%2.1f (%2.1f)', nanmean(x_CU),    nanstd(x_CU));
            T.group_2(i) = sprintf('%2.1f (%2.1f)', nanmean(x_preAD), nanstd(x_preAD));
            T.group_3(i) = sprintf('%2.1f (%2.1f)', nanmean(x_AD),    nanstd(x_AD));

            [~,p_12] = ttest2(x_CU,x_preAD,'Vartype','unequal');
            [~,p_13] = ttest2(x_CU,x_AD,'Vartype','unequal');
            [~,p_23] = ttest2(x_preAD,x_AD,'Vartype','unequal');
            fprintf('CSF p-Tau — p12=%2.3f, p13=%2.3f, p23=%2.3f\n', p_12, p_13, p_23)
            T.p_group1_group2(i) = p_12; T.p_group1_group3(i) = p_13; T.p_group2_group3(i) = p_23;

        case 'TIV-adjusted hippocampal volume (mm^2)'
            x = T_subjects.TIV_adj_hippoc_vol;
            x_CU = x(ind_group_1); x_preAD = x(ind_group_2); x_AD = x(ind_group_3);

            T.group_1(i) = sprintf('%2.1f (%2.1f)', nanmean(x_CU),    nanstd(x_CU));
            T.group_2(i) = sprintf('%2.1f (%2.1f)', nanmean(x_preAD), nanstd(x_preAD));
            T.group_3(i) = sprintf('%2.1f (%2.1f)', nanmean(x_AD),    nanstd(x_AD));

            [~,p_12] = ttest2(x_CU,x_preAD,'Vartype','unequal');
            [~,p_13] = ttest2(x_CU,x_AD,'Vartype','unequal');
            [~,p_23] = ttest2(x_preAD,x_AD,'Vartype','unequal');
            fprintf('TIV-adj. hippocampal vol — p12=%2.3f, p13=%2.3f, p23=%2.3f\n', p_12, p_13, p_23)
            T.p_group1_group2(i) = p_12; T.p_group1_group3(i) = p_13; T.p_group2_group3(i) = p_23;

        case {'CSF pTau/Ab40','CSF NfL/Ab40','AD signature (mm)', ...
              'Hippocampal volume (mm^3)','CSF sTREM2/Ab40','CSF S100B/Ab40', ...
              'CSF YKL40/Ab','IL6/Ab40','Aβ PET (CL)','PACC (z-score)'}
            % Precompute composites
            cov_Ab40 = cell2mat(T_subjects.Ab40);
            cov_Ab4240 = cell2mat(T_subjects.Ab4240);
            cov_pTau_norm2Ab40 = cell2mat(T_subjects.pTau_181)./cov_Ab40;
            cov_TIV_hippocVol = T_subjects.TIV_adj_hippoc_vol;
            cov_ADsignature = T_subjects.jack_true_thickAvg;
            cov_PET_CLs = T_subjects.PET_CLs;

            % Choose series + formatting per label
            if variable == "CSF Aβ42/40"
                x = cov_Ab4240;                   strf = '%2.3f (%2.3f)';
            elseif strcmp(variable,'CSF pTau/Ab40')
                x = cov_pTau_norm2Ab40;           strf = '%2.3f (%2.3f)';
            elseif strcmp(variable,'CSF NfL/Ab40')
                x = cov_NfL_norm2Ab40;            strf = '%2.3f (%2.3f)';
            elseif strcmp(variable,'AD signature (mm)')
                x = cov_ADsignature;              strf = '%2.3f (%2.3f)';
            elseif strcmp(variable,'Hippocampal volume (mm^3)')
                x = cov_TIV_hippocVol;            strf = '%2.3f (%2.3f)';
            elseif strcmp(variable,'CSF sTREM2/Ab40')
                x = cov_sTREM2_norm2Ab40;         strf = '%2.3f (%2.3f)';
            elseif strcmp(variable,'CSF S100B/Ab40')
                x = cov_S100_norm2Ab40;           strf = '%2.3f (%2.3f)';
            elseif strcmp(variable,'CSF YKL40/Ab')
                x = cov_YKL40_norm2Ab40;          strf = '%2.3f (%2.3f)';
            elseif strcmp(variable,'IL6/Ab40')
                x = cov_IL6_norm2Ab40;            strf = '%2.3f (%2.3f)';
            elseif strcmp(variable,'Aβ PET (CL)')
                x = cov_PET_CLs;                  strf = '%2.1f (%2.1f)';
            elseif strcmp(variable,'PACC (z-score)')
                x = T_subjects.cognition_v1_PACC; strf = '%2.1f (%2.1f)';
            end

            x_CU = x(ind_group_1); x_preAD = x(ind_group_2); x_AD = x(ind_group_3);
            T.group_1(i) = sprintf(strf, nanmean(x_CU),    nanstd(x_CU));
            T.group_2(i) = sprintf(strf, nanmean(x_preAD), nanstd(x_preAD));
            T.group_3(i) = sprintf(strf, nanmean(x_AD),    nanstd(x_AD));

            [~,p_12] = ttest2(x_CU,x_preAD,'Vartype','unequal');
            [~,p_13] = ttest2(x_CU,x_AD,'Vartype','unequal');
            [~,p_23] = ttest2(x_preAD,x_AD,'Vartype','unequal');
            fprintf('%s — p12=%2.3f, p13=%2.3f, p23=%2.3f\n', variable, p_12, p_13, p_23)
            T.p_group1_group2(i) = p_12; T.p_group1_group3(i) = p_13; T.p_group2_group3(i) = p_23;

        case 'MMSE score'
            x = cell2mat(T_subjects.mmse);
            x_CU = x(ind_group_1); x_preAD = x(ind_group_2); x_AD = x(ind_group_3);

            T.group_1(i) = sprintf('%2.1f (%2.1f) [%2.0f, %2.0f]', mean(x_CU),    std(x_CU),    min(x_CU),    max(x_CU));
            T.group_2(i) = sprintf('%2.1f (%2.1f) [%2.0f, %2.0f]', mean(x_preAD), std(x_preAD), min(x_preAD), max(x_preAD));
            T.group_3(i) = sprintf('%2.1f (%2.1f) [%2.0f, %2.0f]', mean(x_AD),    std(x_AD),    min(x_AD),    max(x_AD));

            [~,p_12] = ttest2(x_CU,x_preAD,'Vartype','unequal');
            [~,p_13] = ttest2(x_CU,x_AD,'Vartype','unequal');
            [~,p_23] = ttest2(x_preAD,x_AD,'Vartype','unequal');
            fprintf('MMSE — p12=%2.3f, p13=%2.3f, p23=%2.3f\n', p_12, p_13, p_23)
            T.p_group1_group2(i) = p_12; T.p_group1_group3(i) = p_13; T.p_group2_group3(i) = p_23;
    end
end

%% Export
writetable(T, 'Table_group_demographics_biomarkers_2025_01_22.xlsx')
