# Verification

Tested locally with MATLAB R2026a Update 5 (26.1.0.3346908), using base MATLAB. Only MATLAB, Simulink and System Composer were installed; additional research toolboxes were not assumed available.

## Passed

Two minimum-spacing settings for a synthetic respiration-like waveform matched the legacy zero-crossing function exactly, with sorted indices and valid crossing directions.

In the original presentation-only verification, the 234 retained source and asset files in [SOURCE-MANIFEST.json](SOURCE-MANIFEST.json) are SHA-256 identical to the pre-rebrand snapshot. That historical check established source and asset preservation, not full scientific replication. In the current offline extension, 232 remain identical; the two non-executable `rmse.m` stubs have been completed. New wrappers and smoke checks are separate from those files. The original zero-crossing implementation remains unchanged.

## Reproduce

From the repository root in MATLAB:

```matlab
run('tests/smoke_test.m')
```

The test uses only local synthetic inputs or bundled data. It does not acquire or transmit signals. Assertions fail if a checked condition is not satisfied.

## Limits

Full acquisition, clinical validation, study replication, and preprocessing requiring Signal Processing Toolbox were not run. The two historical RMSE stubs are now implemented and tested with an explicit paired-vector contract.

The facade restores the MATLAB search path after a call. Legacy figure output and computational behavior are preserved. This release has new branding, documentation, artwork, and an entry-point facade; it does not claim a new underlying research algorithm.

## Offline extension, 2026-09-23

`tests/offline_test.m` passed in MATLAB R2026a using base MATLAB. Analytic 15/min airflow cycles have zero observed rate error and maximum volume error 1.05e-5 L, with plateau/no-wrap/rejection cases and both RMSE implementations checked. See [method and limits](OFFLINE-ANALYSIS.md). No participant dataset or clinical accuracy is asserted.
