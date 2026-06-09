# precision_functional_mapping
PFM for motor mapping and SCAN network extraction (How to Overlap SCAN with SimNIBS)
# SCAN-SimNIBS Overlap Pipeline

This repository provides a surface-based workflow for:

- extracting individualized SCAN networks from CIFTI parcellations
- converting SimNIBS electric-field (E-field) overlays from fsaverage space to fsLR space
- visualizing networkâ€“E-field overlap in Connectome Workbench
- calculating Dice overlap and related quantitative metrics

This workflow integrates:
- individualized functional network mapping (SCAN)
- SimNIBS electric-field modeling
- HCP/DCAN-compatible fsLR surface workflows

---

# IMPORTANT CONCEPTUAL NOTES

## Surface spaces involved

### SCAN network
The SCAN network/parcellation exists in:

- fsLR 32k / CIFTI 91k space
- HCP/DCAN-compatible surface space

### SimNIBS E-field
SimNIBS fsavg overlays exist in:

- FreeSurfer fsaverage 164k space

These are NOT the same coordinate systems.

Therefore:

- DO NOT manually split the original 91k SCAN vector.
- DO NOT directly compare fsaverage E-fields to fsLR SCAN masks.

The correct approach is:

1. Extract SCAN into fsLR left/right metrics.
2. Resample SimNIBS E-fields from fsaverage 164k â†’ fsLR 32k.
3. Perform Dice calculations only after both are in fsLR 32k space.

---

# SOFTWARE REQUIREMENTS

## Required software

### Connectome Workbench

### MATLAB

### Python

### nibabel

Install with:

```bash
pip install nibabel
```

---

# STEP 1: Extract SCAN network from CIFTI label file

```powershell
cd C:\Users\solei039\Downloads\workbench-windows64-v2.1.0\workbench\bin_windows64
```

```powershell
.\wb_command.exe -cifti-label-to-roi "C:\Users\solei039\Documents\Motormapping\sub-CLM07_ses-1_task-restMENORDICrmnoisevols_space-fsLR_den-91k_desc-interpolated_bold_spatially_interpolated_template_matched_Zscored_scanthresh3_recolored.dlabel.nii" "C:\Users\solei039\Documents\Motormapping\sub-CLM07_SCAN18.dscalar.nii" -key 18
```

---

# STEP 2: Separate SCAN into left/right fsLR metrics

```powershell
.\wb_command.exe -cifti-separate "C:\Users\solei039\Documents\Motormapping\sub-CLM07_SCAN18.dscalar.nii" COLUMN -metric CORTEX_LEFT "C:\Users\solei039\Documents\Motormapping\sub-CLM07_SCAN18_L.func.gii" -metric CORTEX_RIGHT "C:\Users\solei039\Documents\Motormapping\sub-CLM07_SCAN18_R.func.gii"
```

---

# STEP 3: Convert SimNIBS overlays to GIFTI

```python
import nibabel as nib
from nibabel.freesurfer.io import read_morph_data
import numpy as np

base = r"D:\TMS_MetaModeling\Simulation\Sim_1\fsavg_overlays"

lh_file = base + r"\lh.MNI152_TMS_1-0001_Magstim_70mm_Fig8_scalar.fsavg.E.magn"
rh_file = base + r"\rh.MNI152_TMS_1-0001_Magstim_70mm_Fig8_scalar.fsavg.E.magn"

lh_out = base + r"\lh_E_magn_fsaverage164k.func.gii"
rh_out = base + r"\rh_E_magn_fsaverage164k.func.gii"

def save_gifti(infile, outfile):
    data = read_morph_data(infile).astype(np.float32)
    gii = nib.gifti.GiftiImage()
    gii.add_gifti_data_array(nib.gifti.GiftiDataArray(data=data))
    nib.save(gii, outfile)
    print("Saved:", outfile, "N =", data.shape[0])

save_gifti(lh_file, lh_out)
save_gifti(rh_file, rh_out)
```

---

# STEP 4: Resample SimNIBS E-fields from fsaverage 164k â†’ fsLR 32k

## LEFT hemisphere

```powershell
.\wb_command.exe -metric-resample "D:\TMS_MetaModeling\Simulation\Sim_1\fsavg_overlays\lh_E_magn_fsaverage164k.func.gii" "C:\Users\solei039\Documents\Motormapping\ToMalte\fsaverage_std_sphere.L.164k_fsavg_L.surf.gii" "C:\Users\solei039\Documents\Motormapping\ToMalte\fs_LR-deformed_to-fsaverage.L.sphere.32k_fs_LR.surf.gii" BARYCENTRIC "D:\TMS_MetaModeling\Simulation\Sim_1\fsavg_overlays\lh_E_magn_fsLR32k.func.gii"
```

## RIGHT hemisphere

```powershell
.\wb_command.exe -metric-resample "D:\TMS_MetaModeling\Simulation\Sim_1\fsavg_overlays\rh_E_magn_fsaverage164k.func.gii" "C:\Users\solei039\Documents\Motormapping\ToMalte\fsaverage_std_sphere.R.164k_fsavg_R.surf.gii" "C:\Users\solei039\Documents\Motormapping\ToMalte\fs_LR-deformed_to-fsaverage.R.sphere.32k_fs_LR.surf.gii" BARYCENTRIC "D:\TMS_MetaModeling\Simulation\Sim_1\fsavg_overlays\rh_E_magn_fsLR32k.func.gii"
```

---

# STEP 5: Dice overlap calculation in MATLAB

```matlab
clear; clc;

scanL_file = 'C:\Users\solei039\Documents\Motormapping\sub-CLM07_SCAN18_L.func.gii';
scanR_file = 'C:\Users\solei039\Documents\Motormapping\sub-CLM07_SCAN18_R.func.gii';

efieldL_file = 'D:\TMS_MetaModeling\Simulation\Sim_1\fsavg_overlays\lh_E_magn_fsLR32k.func.gii';
efieldR_file = 'D:\TMS_MetaModeling\Simulation\Sim_1\fsavg_overlays\rh_E_magn_fsLR32k.func.gii';

SCAN_L = double(gifti(scanL_file).cdata);
SCAN_R = double(gifti(scanR_file).cdata);

E_L = double(gifti(efieldL_file).cdata);
E_R = double(gifti(efieldR_file).cdata);

SCAN = logical([SCAN_L; SCAN_R] > 0);
E = [E_L; E_R];

thr = 0.50 * max(E);

E_mask = E >= thr;

overlap = SCAN & E_mask;

dice = 2 * sum(overlap) / (sum(SCAN) + sum(E_mask));

fprintf('Dice coefficient: %.4f\n', dice);
```
