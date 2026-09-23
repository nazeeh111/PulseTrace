# Offline airflow measurement

`pulse_trace_airflow` extends the repository from zero-crossing facade checks to input-to-measurement analysis. The measurement model follows the original `MassStudy2019/Matlab/airflowToVol.m`: baseline-corrected airflow in L/s integrates to volume in L. This new function intentionally does not substitute an unvalidated filter for that script's toolbox filter.

A complete cycle has an upward sign crossing, a downward crossing, and the next upward crossing. Linear interpolation locates adjacent nonzero sign changes; an intervening zero plateau uses its midpoint. The function never compares the last sample to the first. Phase durations come from the crossing times, cycle rate is `60 / cycleDuration`, and positive/negative phase volumes are separate trapezoidal integrals including zero-valued interpolated boundaries. See MATLAB's [trapezoidal integration reference](https://www.mathworks.com/help/matlab/ref/trapz.html).

A zero plateau can represent a genuine pause. The midpoint convention assigns half that pause to each adjoining phase; use the returned crossing table to inspect this assumption. Short phases invalidate their complete cycle rather than silently joining distinct cycles. Leading/trailing incomplete cycles are excluded. No valid cycles means an empty table, not a zero rate.

The numerical test signal is `0.4*sin(2*pi*0.25*t)` L/s plus a known 0.07 L/s baseline, at 100 samples/s for 40 seconds. Its analytic rate is 15/min and inspired/expired volume is `0.4/(pi*0.25)` L. Local MATLAB tests recovered rate with zero observed error and volume with maximum absolute error approximately 0.0000105 L. These are numerical integration errors on a clean synthetic signal, not accuracy on participants or sensor data.

Historical RMSE files never had an executable implementation or callsites in this repository. Both now have an explicit contract: `[sqrt(mean((measured-true).^2)), std(measured-true)]`, using MATLAB's sample standard deviation. Row/column input orientation is normalized; unequal lengths, nonfinite values and empty inputs are rejected. The second number is signed-error spread, not a confidence interval or RMSE uncertainty.

Run `run('tests/offline_test.m')` for the analytic cycle, zero-plateau, no-wrap, short-phase, input-rejection and both RMSE checks. `run('tests/smoke_test.m')` still checks the unchanged historical facade.
