# Reading the respiratory workflow

The historical respiratory scripts compare near-field coherent sensing (NCS)
with Hexoskin reference signals. They show how RF amplitude and phase become
respiration and heartbeat waveforms, event timings, rate estimates and calibrated
volume estimates. This guide maps the recorded implementation; it does not add a
new measurement method or establish physiological accuracy.

The source below is in
[`Respiratory/BreathPattern_Cough_Speak/Code/MatlabDataProcessing`](../Respiratory/BreathPattern_Cough_Speak/Code/MatlabDataProcessing).
The comparison script needs study-specific paths, recordings, manual alignment,
polarity and calibration choices. Two helper versions called by that script are
absent from the tracked repository, so it is not a complete runnable example.
For a self-contained synthetic example, use the
[offline airflow workflow](../README.md#offline-airflow-measurements-base-matlab).

## Follow the data

| Stage | Source | What it supplies |
| --- | --- | --- |
| Import NCS | [`saveTDMStoMAT.m`](../Respiratory/BreathPattern_Cough_Speak/Code/MatlabDataProcessing/saveTDMStoMAT.m), [`readNcsData.m`](../Respiratory/BreathPattern_Cough_Speak/Code/MatlabDataProcessing/readNcsData.m) | TDMS conversion creates a MAT file; the reader expects `ampPh` and `dateTime`. |
| Import reference | [`readHxData.m`](../Respiratory/BreathPattern_Cough_Speak/Code/MatlabDataProcessing/readHxData.m) | Selects a named CSV channel, returns its values, declared sample rate and absolute date vectors. |
| Align and crop | [`ncsHxRawSync.m`](../Respiratory/BreathPattern_Cough_Speak/Code/MatlabDataProcessing/ncsHxRawSync.m) | Applies the supplied start, duration and manual time offset; keeps NCS and reference sampling grids separate. |
| Separate waveforms | [`postProcess.m`](../Respiratory/BreathPattern_Cough_Speak/Code/MatlabDataProcessing/postProcess.m) | Applies amplitude/phase polarity, optional high-pass and low-pass filtering. The caller then detrends respiration and resamples for reference comparison. |
| Detect events | [`peakDetAMPD.m`](../Respiratory/BreathPattern_Cough_Speak/Code/MatlabDataProcessing/peakDetAMPD.m), [`findInhaleExhale.m`](../Respiratory/BreathPattern_Cough_Speak/Code/MatlabDataProcessing/findInhaleExhale.m) | Finds minima/maxima, removes repeated indices and selects among consecutive events of the same type. |
| Estimate quantities | [`ncsEstBR.m`](../Respiratory/BreathPattern_Cough_Speak/Code/MatlabDataProcessing/ncsEstBR.m), [`ncsEstHR.m`](../Respiratory/BreathPattern_Cough_Speak/Code/MatlabDataProcessing/ncsEstHR.m), [`ncsEstTV.m`](../Respiratory/BreathPattern_Cough_Speak/Code/MatlabDataProcessing/ncsEstTV.m), [`ncsEstTiTt.m`](../Respiratory/BreathPattern_Cough_Speak/Code/MatlabDataProcessing/ncsEstTiTt.m) | Implement rate, calibrated tidal volume and fractional inspiratory time helpers. The BR/TV files are the available unversioned implementations, not substitutes for the missing versions below. |
| Compare and present | [`ncsHxCompare.m`](../Respiratory/BreathPattern_Cough_Speak/Code/MatlabDataProcessing/ncsHxCompare.m), [`plotPublication.m`](../Respiratory/BreathPattern_Cough_Speak/Code/MatlabDataProcessing/plotPublication.m), [`plotBlandAltman_HR_BR_TV.m`](../Respiratory/BreathPattern_Cough_Speak/Code/MatlabDataProcessing/plotBlandAltman_HR_BR_TV.m) | Orchestrate the historical study and consume its workspace variables or separately saved result matrices. |

## Input contracts that matter

- **NCS MAT files:** `ampPh` is an N-by-2 matrix ordered as amplitude, phase.
  `dateTime` is parsed with `dd-mmm-yyyy HH:MM:SS`. The sample rate comes from
  the caller; the reader does not infer it from the file.
- **Reference CSV files:** `readHxData` skips one header row and interprets the
  first two columns as time and value. Its channel table declares 128 Hz for
  respiratory waveforms, 256 Hz for ECG, 1 Hz for several summary signals and
  zero for uneven event sampling. Its historical epoch/time correction is
  explicit source behavior, not a generally verified clock conversion.
- **Alignment:** `ncsHxCompare` supplies a manually observed offset and assumes
  the chosen reference recording starts before the NCS recording. The sync
  helper selects the first reference sample strictly after each crop boundary.
  Filtering and resampling happen later in the caller.
- **Events:** detector outputs are two-column matrices of sample index and
  event indicator. The helper labels 1 as end of inhalation and 0 as end of
  exhalation. Signal polarity and these labels affect the inspiratory-time
  ratio; the caller's comments contain older conflicting descriptions.
- **Calibration and selection:** the comparison script specifies frequency
  ranges, fit choice and time windows. The available volume helper fits
  amplitude/phase contributions against reference volume. The Bland–Altman
  script also selects particular recordings and channels. These choices belong
  to the historical study and are not automatically inferred or revalidated.

## Resolve before attempting a study run

`ncsHxCompare` calls **`ncsEstTV2`** and **`ncsEstBR2`**. Neither implementation
is present among the tracked files. The supplied `ncsEstTV` and `ncsEstBR` have
different argument lists. Renaming them or dropping the extra arguments would
choose behavior that the repository does not establish.

`findInhaleExhale.m` declares its primary function as `findInhaleExhale2`, while
callers use the filename. That naming mismatch remains in the retained source;
this guide makes no claim about its resolution in a particular MATLAB release.
The heartbeat branch also uses `wavedecrec1`, with copies in other directories.
Confirm the selected helper and its signature rather than adding every folder
to the MATLAB path and relying on search order.

The scripts use filtering, resampling, curve-fitting and wavelet functions beyond
the base MATLAB airflow example. Import conversion and Bland–Altman utilities
retain their own dependencies and terms. Plotting scripts rely on study workspace
variables and fixed ranges; they do not load and validate a complete experiment.
`saveTDMStoMAT` writes a named MAT file, while `plotPublication` creates figures.
Inspect the configured inputs and destinations before executing these scripts.

This map comes from source inspection. No participant files, acquisition device,
legacy study run, calibration result or clinical claim was validated for it.
