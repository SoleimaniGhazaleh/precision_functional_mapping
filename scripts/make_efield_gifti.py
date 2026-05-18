"""
make_efield_gifti.py

Convert SimNIBS FreeSurfer fsaverage E-field overlays (.E.magn)
to GIFTI functional metric files (.func.gii).

Input:
    lh/rh SimNIBS fsaverage E.magn files

Output:
    lh_E_magn_fsaverage164k.func.gii
    rh_E_magn_fsaverage164k.func.gii
"""

import nibabel as nib
from nibabel.freesurfer.io import read_morph_data
import numpy as np
from pathlib import Path

# -----------------------------
# User settings
# -----------------------------
base = Path(r"D:\TMS_MetaModeling\Simulation\Sim_1\fsavg_overlays")

lh_file = base / "lh.MNI152_TMS_1-0001_Magstim_70mm_Fig8_scalar.fsavg.E.magn"
rh_file = base / "rh.MNI152_TMS_1-0001_Magstim_70mm_Fig8_scalar.fsavg.E.magn"

lh_out = base / "lh_E_magn_fsaverage164k.func.gii"
rh_out = base / "rh_E_magn_fsaverage164k.func.gii"


def save_gifti(infile: Path, outfile: Path) -> None:
    """Read FreeSurfer morph data and save as GIFTI metric."""
    if not infile.exists():
        raise FileNotFoundError(f"Input file not found: {infile}")

    data = read_morph_data(str(infile)).astype(np.float32)

    gii = nib.gifti.GiftiImage()
    gii.add_gifti_data_array(nib.gifti.GiftiDataArray(data=data))
    nib.save(gii, str(outfile))

    print(f"Saved: {outfile}")
    print(f"Number of vertices: {data.shape[0]}")
    print(f"Min/Max: {np.min(data):.6f} / {np.max(data):.6f}")


if __name__ == "__main__":
    save_gifti(lh_file, lh_out)
    save_gifti(rh_file, rh_out)
