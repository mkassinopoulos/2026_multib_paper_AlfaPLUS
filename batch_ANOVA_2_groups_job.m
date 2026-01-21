%-----------------------------------------------------------------------
% Job saved on 11-Oct-2023 10:43:05 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------

load('tmp_workspace_batch_ANOVA_2_groups.mat')

disp(path_output)

matlabbatch{1}.spm.stats.factorial_design.dir = {path_output};
%%
matlabbatch{1}.spm.stats.factorial_design.des.anova.icell(1).scans = input_imgs_group_A;
%%
%%
matlabbatch{1}.spm.stats.factorial_design.des.anova.icell(2).scans = input_imgs_group_B;
%%
matlabbatch{1}.spm.stats.factorial_design.des.anova.dept = 0;
matlabbatch{1}.spm.stats.factorial_design.des.anova.variance = 1;
matlabbatch{1}.spm.stats.factorial_design.des.anova.gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.anova.ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov.files = list_confound_files;
matlabbatch{1}.spm.stats.factorial_design.multi_cov.iCFI = 1;
matlabbatch{1}.spm.stats.factorial_design.multi_cov.iCC = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 0;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {'D:\Projects\2023_multib\MK_multi_b\Masks\brainmask_multib_def.nii'};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{3}.spm.stats.con.consess{1}.fcon.name = 'F:any_difference';
matlabbatch{3}.spm.stats.con.consess{1}.fcon.weights = [1 -1];
matlabbatch{3}.spm.stats.con.consess{1}.fcon.sessrep = 'none';

matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'T: G1>G2';
vector_weights = zeros(1,n_confounds+2); vector_weights(1) = 1; vector_weights(2) = -1;
matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = vector_weights;
matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';

matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'T: G2>G1';
vector_weights = zeros(1,n_confounds+2); vector_weights(1) = -1; vector_weights(2) = 1;
matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = vector_weights;
matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';

matlabbatch{3}.spm.stats.con.delete = 0;
matlabbatch{4}.spm.stats.results.spmmat(1) = cfg_dep('Contrast Manager: SPM.mat File', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{4}.spm.stats.results.conspec(1).titlestr = 'F:any_difference';
matlabbatch{4}.spm.stats.results.conspec(1).contrasts = 1;
matlabbatch{4}.spm.stats.results.conspec(1).threshdesc = 'none';
matlabbatch{4}.spm.stats.results.conspec(1).thresh = 0.001;
matlabbatch{4}.spm.stats.results.conspec(1).extent = 50;
matlabbatch{4}.spm.stats.results.conspec(1).conjunction = 1;
matlabbatch{4}.spm.stats.results.conspec(1).mask.none = 1;
matlabbatch{4}.spm.stats.results.conspec(2).titlestr = 'T:G1>G2';
matlabbatch{4}.spm.stats.results.conspec(2).contrasts = 2;
matlabbatch{4}.spm.stats.results.conspec(2).threshdesc = 'none';
matlabbatch{4}.spm.stats.results.conspec(2).thresh = 0.001;
matlabbatch{4}.spm.stats.results.conspec(2).extent = 50;
matlabbatch{4}.spm.stats.results.conspec(2).conjunction = 1;
matlabbatch{4}.spm.stats.results.conspec(2).mask.none = 1;
matlabbatch{4}.spm.stats.results.conspec(3).titlestr = 'T:G2>G1';
matlabbatch{4}.spm.stats.results.conspec(3).contrasts = 3;
matlabbatch{4}.spm.stats.results.conspec(3).threshdesc = 'none';
matlabbatch{4}.spm.stats.results.conspec(3).thresh = 0.001;
matlabbatch{4}.spm.stats.results.conspec(3).extent = 50;
matlabbatch{4}.spm.stats.results.conspec(3).conjunction = 1;
matlabbatch{4}.spm.stats.results.conspec(3).mask.none = 1;
matlabbatch{4}.spm.stats.results.units = 1;
matlabbatch{4}.spm.stats.results.export{1}.ps = true;
matlabbatch{4}.spm.stats.results.export{2}.tspm.basename = 'none_p0.001_k50';
matlabbatch{5}.cfg_basicio.var_ops.cfg_save_vars.name = 'XPM_anova_none_p001_k50';
matlabbatch{5}.cfg_basicio.var_ops.cfg_save_vars.outdir = {path_output};
matlabbatch{5}.cfg_basicio.var_ops.cfg_save_vars.vars(1).vname = 'XPM_anova';
matlabbatch{5}.cfg_basicio.var_ops.cfg_save_vars.vars(1).vcont(1) = cfg_dep('Results Report: xSPM Variable', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','xSPMvar'));
matlabbatch{5}.cfg_basicio.var_ops.cfg_save_vars.vars(2).vname = 'tabdat_ancova';
matlabbatch{5}.cfg_basicio.var_ops.cfg_save_vars.vars(2).vcont(1) = cfg_dep('Results Report: TabDat Variable', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','TabDatvar'));
matlabbatch{5}.cfg_basicio.var_ops.cfg_save_vars.saveasstruct = false;
