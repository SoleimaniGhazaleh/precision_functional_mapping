%% dice_calculation.m
% Calculate Dice overlap between individualized SCAN network and
% SimNIBS E-field after both have been converted to fsLR 32k space.
%
% Required inputs:
%   sub-CLM07_SCAN18_L.func.gii
%   sub-CLM07_SCAN18_R.func.gii
%   lh_E_magn_fsLR32k.func.gii
%   rh_E_magn_fsLR32k.func.gii
%
% Note:
%   This script assumes SCAN and E-field are already in matching fsLR 32k space.

clear; clc;

%% -----------------------------
% User paths
% ------------------------------
scanL_file = 'C:\Users\solei039\Documents\Motormapping\sub-CLM07_SCAN18_L.func.gii';
scanR_file = 'C:\Users\solei039\Documents\Motormapping\sub-CLM07_SCAN18_R.func.gii';

efieldL_file = 'D:\TMS_MetaModeling\Simulation\Sim_1\fsavg_overlays\lh_E_magn_fsLR32k.func.gii';
efieldR_file = 'D:\TMS_MetaModeling\Simulation\Sim_1\fsavg_overlays\rh_E_magn_fsLR32k.func.gii';

outFile = 'D:\TMS_MetaModeling\Simulation\Sim_1\fsavg_overlays\sub-CLM07_SCAN_Efield_Dice_results.mat';

%% -----------------------------
% Load GIFTI files
% ------------------------------
SCAN_L = double(gifti(scanL_file).cdata);
SCAN_R = double(gifti(scanR_file).cdata);

E_L = double(gifti(efieldL_file).cdata);
E_R = double(gifti(efieldR_file).cdata);

%% -----------------------------
% Combine hemispheres
% ------------------------------
SCAN = logical([SCAN_L; SCAN_R] > 0);
E = [E_L; E_R];

%% -----------------------------
% Threshold E-field
% ------------------------------
% Common choice: 50% of maximum E-field.
% Change this value if you want a different E-field threshold.
thr_fraction = 0.50;
thr = thr_fraction * max(E);

E_mask = E >= thr;

%% -----------------------------
% Dice overlap
% ------------------------------
overlap = SCAN & E_mask;

dice = 2 * sum(overlap) / (sum(SCAN) + sum(E_mask));

%% -----------------------------
% Additional metrics
% ------------------------------
meanE_in_SCAN = mean(E(SCAN));
maxE_in_SCAN  = max(E(SCAN));

percent_E_inside_SCAN = 100 * sum(overlap) / sum(E_mask);
percent_SCAN_covered_by_E = 100 * sum(overlap) / sum(SCAN);

%% -----------------------------
% Print results
% ------------------------------
fprintf('\n--- SCAN x SimNIBS E-field overlap ---\n');
fprintf('E-field threshold fraction: %.2f\n', thr_fraction);
fprintf('E-field threshold: %.4f V/m\n', thr);
fprintf('SCAN vertices: %d\n', sum(SCAN));
fprintf('E-field mask vertices: %d\n', sum(E_mask));
fprintf('Overlap vertices: %d\n', sum(overlap));
fprintf('Dice coefficient: %.4f\n', dice);
fprintf('Mean E-field inside SCAN: %.4f V/m\n', meanE_in_SCAN);
fprintf('Max E-field inside SCAN: %.4f V/m\n', maxE_in_SCAN);
fprintf('Percent of E-field mask inside SCAN: %.2f%%\n', percent_E_inside_SCAN);
fprintf('Percent of SCAN covered by E-field mask: %.2f%%\n', percent_SCAN_covered_by_E);

%% -----------------------------
% Save results
% ------------------------------
save(outFile, ...
    'dice', 'thr', 'thr_fraction', ...
    'meanE_in_SCAN', 'maxE_in_SCAN', ...
    'percent_E_inside_SCAN', 'percent_SCAN_covered_by_E', ...
    'SCAN', 'E', 'E_mask', 'overlap');

fprintf('\nSaved results to:\n%s\n', outFile);
