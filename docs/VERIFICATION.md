# Verification

Tested locally with MATLAB R2026a Update 5 (26.1.0.3346908), using base MATLAB. Only MATLAB, Simulink and System Composer were installed; additional research toolboxes were not assumed available.

## Passed

Two minimum-spacing settings for a synthetic respiration-like waveform matched the legacy zero-crossing function exactly, with sorted indices and valid crossing directions.

The 234 retained source and asset files in [SOURCE-MANIFEST.json](SOURCE-MANIFEST.json) are SHA-256 identical to the pre-rebrand snapshot. This establishes source and asset preservation, not full scientific replication. New wrappers and smoke checks are separate from those files. No computational core was rewritten.

## Reproduce

From the repository root in MATLAB:

```matlab
run('tests/smoke_test.m')
```

The test uses only local synthetic inputs or bundled data. It does not acquire or transmit signals. Assertions fail if a checked condition is not satisfied.

## Limits

Full acquisition, clinical validation, study replication, and preprocessing requiring Signal Processing Toolbox were not run. The two archived rmse.m stubs under Respiratory/BreathPattern_Cough_Speak/Code/MatlabDataProcessing (including CodeStyle_Old) are incomplete in the baseline and outside the supported facade path.

The facade restores the MATLAB search path after a call. Legacy figure output and computational behavior are preserved. This release has new branding, documentation, artwork, and an entry-point facade; it does not claim a new underlying research algorithm.
