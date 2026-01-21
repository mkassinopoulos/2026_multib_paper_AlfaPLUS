%-----------------------------------------------------------------------
% Job saved on 16-Sep-2024 09:48:40 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------

load('tmp_jobs/workspace_spatial_smoothing.mat')

matlabbatch{1}.spm.spatial.smooth.data = {path_nii};
matlabbatch{1}.spm.spatial.smooth.fwhm = [12 12 12];
matlabbatch{1}.spm.spatial.smooth.dtype = 0;
matlabbatch{1}.spm.spatial.smooth.im = 0;
matlabbatch{1}.spm.spatial.smooth.prefix = 's12_';
