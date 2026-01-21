
% Load parametric maps for all subjects and correlate with MD maps

clear, clc, close all

%% Paths / data
path_batches = 'D:\Projects\2023_multib\MK_multi_b\Scripts';
cd(path_batches)

load('Table_297_subjs_demographics_biomarkers_2024_05_03.mat')
n_subjects     = size(T_subjects,1);
path_stats_grp = 'D:\Projects\2023_multib\MK_multi_b\Stats_group_level\';


%% Loop across subjects and parameters
list_phys_variables = {'slow_ADC'; 'fast_ADC'; 'slow_signal_portion'; 'tissueFraction'};
r_all_subjs = nan(n_subjects, 4);

for k = 1:length(list_phys_variables)               % slow_ADC, fast_ADC, slow_signal_portion, tissueFraction
    phys_variable = list_phys_variables{k};

    path_phys_maps = ['D:\Projects\2023_multib\MK_multi_b\Stats_single_level\Stats_', ...
                      phys_variable, '\s10bwnl2t1_', phys_variable, '_'];

    path_folder_MD_maps = 'D:\Projects\2023_multib\MK_multi_b\Stats_single_level\Stats_MD\';

    for subj = 1:n_subjects
        subject = T_subjects.Subject_ID{subj};
        fprintf(' Subject: %s\n', subject)

        % Parametric map
        path_param = [path_phys_maps, subject, '.nii'];
        nii_param  = load_untouch_nii(path_param);
        img_param  = nii_param.img;

        % MD map
        path_MD = [path_folder_MD_maps, 'wnl2t1_MD_', subject, '.nii'];
        if isfile(path_MD)
            nii_MD  = load_untouch_nii(path_MD);
            img_MD  = nii_MD.img;

            ind_MD  = find(img_MD(:) > 1e-4);         % avoid background
            r_subj  = corr(img_MD(ind_MD), img_param(ind_MD));
            r_all_subjs(subj, k) = r_subj;
        end
    end
end

%% Quick boxplot (simple)
figure('Position',[855 838 328 257])
boxplot(r_all_subjs)
ylabel('Correlation')
xlabel('Diffusion parameter')
xticks(1:4); xticklabels(list_phys_variables)
set(gca,'XGrid','off','YGrid','on')

%% Styled boxplots
bp_x = r_all_subjs;
bp_g = [ones(n_subjects,1); 2*ones(n_subjects,1); 3*ones(n_subjects,1); 4*ones(n_subjects,1)];

figure('Position',[1012 604 407 355])
boxplot(bp_x, bp_g, 'Widths',0.6, 'color',['k','k'], 'Symbol',''); hold on

colors = repmat([0.6 0.6 0.6], 4, 1);
h = findobj(gca,'Tag','Box');
for j = 1:length(h)
    patch(get(h(j),'XData'), get(h(j),'YData'), colors(j,:), 'FaceAlpha', 1);
end
boxplot(bp_x, bp_g, 'Widths',0.6, 'color',['k','k'], 'Symbol',''); hold on
set(findobj(gca,'type','line'), 'linew', 1.5)

xticks(1:4)
xticklabels({'Slow ADC','Fast ADC','SSP','Perfusion fraction'})
set(gca,'XGrid','off','YGrid','on')
ylabel('Correlation with MD map (n.u.)')
xlabel('Diffusion model parameter')







