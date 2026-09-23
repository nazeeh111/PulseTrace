![PulseTrace](docs/banner.svg)

# PulseTrace

Offline MATLAB research workflows for radio-frequency physiological sensing, respiration, cardiac signals, and reference-signal comparison.

> **Development history:** Developed locally using Git before publication. These projects were published to GitHub together, so similar upload dates do not indicate when development began.

## Quick start

Open MATLAB in this repository, then use the branded entry point:

```matlab
crossings = pulse_trace(signal, sample_rate, struct('minTime', 0));
```

The entry point preserves the existing function's arguments, errors, and numerical output. Existing script and function names remain available for compatibility. No sensor starts when you open this repository.

## Inputs and workflows

The facade returns zero-crossing indices and direction. Complete study scripts use experiment-specific recordings, absolute paths, Signal Processing Toolbox and acquisition software. No clinical performance or new participant study is claimed. Two archived rmse.m files are unfinished in the baseline and are not used by the checked entry point; they remain excluded from the supported path. Separately supplied TDMS, ECG and Bland-Altman utilities retain their own terms.

## Verification

Run `run('tests/smoke_test.m')` from the repository root. See [verification details](docs/VERIFICATION.md) for the tested scope and unavailable checks. Computational source and bundled scientific assets are retained byte-for-byte; the added facade and documentation provide the new presentation.

## License

MIT covers authorized first-party code and new presentation. Embedded and nested third-party licenses continue to apply.
