# workbench_commands.ps1
# PowerShell commands for extracting SCAN, separating left/right metrics,
# and resampling SimNIBS E-field from fsaverage 164k to fsLR 32k.

# ------------------------------------------------------
# 0. Go to Connectome Workbench directory
# ------------------------------------------------------
cd C:\Users\solei039\Downloads\workbench-windows64-v2.1.0\workbench\bin_windows64

# ------------------------------------------------------
# 1. Extract SCAN / parcel 18 from CIFTI label file
# ------------------------------------------------------
.\wb_command.exe -cifti-label-to-roi "C:\Users\solei039\Documents\Motormapping\sub-CLM07_ses-1_task-restMENORDICrmnoisevols_space-fsLR_den-91k_desc-interpolated_bold_spatially_interpolated_template_matched_Zscored_scanthresh3_recolored.dlabel.nii" "C:\Users\solei039\Documents\Motormapping\sub-CLM07_SCAN18.dscalar.nii" -key 18

# ------------------------------------------------------
# 2. Separate SCAN into left/right fsLR metrics
# ------------------------------------------------------
.\wb_command.exe -cifti-separate "C:\Users\solei039\Documents\Motormapping\sub-CLM07_SCAN18.dscalar.nii" COLUMN -metric CORTEX_LEFT "C:\Users\solei039\Documents\Motormapping\sub-CLM07_SCAN18_L.func.gii" -metric CORTEX_RIGHT "C:\Users\solei039\Documents\Motormapping\sub-CLM07_SCAN18_R.func.gii"

# ------------------------------------------------------
# 3. Resample left hemisphere E-field: fsaverage 164k -> fsLR 32k
# ------------------------------------------------------
.\wb_command.exe -metric-resample "D:\TMS_MetaModeling\Simulation\Sim_1\fsavg_overlays\lh_E_magn_fsaverage164k.func.gii" "C:\Users\solei039\Documents\Motormapping\ToMalte\fsaverage_std_sphere.L.164k_fsavg_L.surf.gii" "C:\Users\solei039\Documents\Motormapping\ToMalte\fs_LR-deformed_to-fsaverage.L.sphere.32k_fs_LR.surf.gii" BARYCENTRIC "D:\TMS_MetaModeling\Simulation\Sim_1\fsavg_overlays\lh_E_magn_fsLR32k.func.gii"

# ------------------------------------------------------
# 4. Resample right hemisphere E-field: fsaverage 164k -> fsLR 32k
# ------------------------------------------------------
.\wb_command.exe -metric-resample "D:\TMS_MetaModeling\Simulation\Sim_1\fsavg_overlays\rh_E_magn_fsaverage164k.func.gii" "C:\Users\solei039\Documents\Motormapping\ToMalte\fsaverage_std_sphere.R.164k_fsavg_R.surf.gii" "C:\Users\solei039\Documents\Motormapping\ToMalte\fs_LR-deformed_to-fsaverage.R.sphere.32k_fs_LR.surf.gii" BARYCENTRIC "D:\TMS_MetaModeling\Simulation\Sim_1\fsavg_overlays\rh_E_magn_fsLR32k.func.gii"

# ------------------------------------------------------
# 5. Optional: open Workbench viewer
# ------------------------------------------------------
.\wb_view.exe
