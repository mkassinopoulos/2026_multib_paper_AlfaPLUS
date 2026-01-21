%-----------------------------------------------------------------------
% Job saved on 10-Oct-2023 00:29:53 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------



load('tmp_workspace_correlate_varA_varB.mat')


matlabbatch{1}.spm.stats.factorial_design.dir = {path_output};
%%
matlabbatch{1}.spm.stats.factorial_design.des.mreg.scans = input_imgs;
%%
%%
matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov.c = cov_interest.values;
%%
matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov.cname = cov_interest.label;
matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov.iCC = 1;
matlabbatch{1}.spm.stats.factorial_design.des.mreg.incint = 1;
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
matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));

matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'Positive correlation';
vector_weights = zeros(1,n_confounds+2); vector_weights(2) = 1;
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = vector_weights;
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';

vector_weights = zeros(1,n_confounds+2); vector_weights(2) = -1;
matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'Negative correlation';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = vector_weights;
matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';

matlabbatch{3}.spm.stats.con.delete = 0;
matlabbatch{4}.spm.stats.results.spmmat(1) = cfg_dep('Contrast Manager: SPM.mat File', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{4}.spm.stats.results.conspec.titlestr = 'Positive correlation';
matlabbatch{4}.spm.stats.results.conspec.contrasts = 1;
matlabbatch{4}.spm.stats.results.conspec.threshdesc = 'none';
matlabbatch{4}.spm.stats.results.conspec.thresh = 0.001;
matlabbatch{4}.spm.stats.results.conspec.extent = 50;
matlabbatch{4}.spm.stats.results.conspec.conjunction = 1;
matlabbatch{4}.spm.stats.results.conspec.mask.none = 1;
matlabbatch{4}.spm.stats.results.units = 1;
matlabbatch{4}.spm.stats.results.export{1}.ps = true;
matlabbatch{4}.spm.stats.results.export{2}.tspm.basename = 'none_p0.001_k50';
matlabbatch{5}.cfg_basicio.var_ops.cfg_save_vars.name = 'XPM_pos_none_p001_k50';
matlabbatch{5}.cfg_basicio.var_ops.cfg_save_vars.outdir = {path_output};
matlabbatch{5}.cfg_basicio.var_ops.cfg_save_vars.vars.vname = 'XPM_pos';
matlabbatch{5}.cfg_basicio.var_ops.cfg_save_vars.vars.vcont(1) = cfg_dep('Results Report: xSPM Variable', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','xSPMvar'));
matlabbatch{5}.cfg_basicio.var_ops.cfg_save_vars.saveasstruct = false;
matlabbatch{6}.spm.stats.results.spmmat(1) = cfg_dep('Contrast Manager: SPM.mat File', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{6}.spm.stats.results.conspec.titlestr = 'Negative correlation';
matlabbatch{6}.spm.stats.results.conspec.contrasts = 2;
matlabbatch{6}.spm.stats.results.conspec.threshdesc = 'none';
matlabbatch{6}.spm.stats.results.conspec.thresh = 0.001;
matlabbatch{6}.spm.stats.results.conspec.extent = 50;
matlabbatch{6}.spm.stats.results.conspec.conjunction = 1;
matlabbatch{6}.spm.stats.results.conspec.mask.none = 1;
matlabbatch{6}.spm.stats.results.units = 1;
matlabbatch{6}.spm.stats.results.export{1}.ps = true;
matlabbatch{6}.spm.stats.results.export{2}.tspm.basename = 'none_p0.001_k50';
matlabbatch{7}.cfg_basicio.var_ops.cfg_save_vars.name = 'XPM_neg_none_p001_k50';
matlabbatch{7}.cfg_basicio.var_ops.cfg_save_vars.outdir = {path_output};
matlabbatch{7}.cfg_basicio.var_ops.cfg_save_vars.vars.vname = 'XPM_neg';
matlabbatch{7}.cfg_basicio.var_ops.cfg_save_vars.vars.vcont(1) = cfg_dep('Results Report: xSPM Variable', substruct('.','val', '{}',{6}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','xSPMvar'));
matlabbatch{7}.cfg_basicio.var_ops.cfg_save_vars.saveasstruct = false;
