function result = pulse_trace_airflow(airflow, fs, opts)
%PULSE_TRACE_AIRFLOW Offline cycle measurements from calibrated airflow (L/s).
% Positive flow is inspiration. Complete positive-negative-positive cycles
% only. No filtering, calibration, missing-data imputation, or diagnosis is
% implicit. opts.baseline (L/s, default 0) is subtracted before measurement.
% opts.minPhaseSeconds (default 0.3) rejects short phases, not merges them.
% Outputs: cycles table (seconds, breaths/min, liters), crossings table,
% correctedFlow and timeSeconds. Empty cycles means insufficient valid data.
if nargin < 3, opts = struct; end
validateattributes(airflow, {'numeric'}, {'real','finite','vector','nonempty'});
validateattributes(fs, {'numeric'}, {'real','finite','scalar','positive'});
if ~isstruct(opts) || ~isscalar(opts), error('PulseTrace:Options','opts must be a scalar struct.'); end
unknown = setdiff(fieldnames(opts), {'baseline','minPhaseSeconds'});
if ~isempty(unknown), error('PulseTrace:Options','Unknown option: %s',unknown{1}); end
if ~isfield(opts,'baseline'), opts.baseline = 0; end
if ~isfield(opts,'minPhaseSeconds'), opts.minPhaseSeconds = 0.3; end
validateattributes(opts.baseline, {'numeric'}, {'real','finite','scalar'});
validateattributes(opts.minPhaseSeconds, {'numeric'}, {'real','finite','scalar','nonnegative'});
x = double(airflow(:)) - double(opts.baseline);
t = (0:numel(x)-1)' / double(fs);
% Compare successive NONZERO values. Exact-zero plateaus crossing sign are
% represented by their midpoint; touches without sign reversal are ignored.
nz = find(x ~= 0);
left = nz(1:end-1); right = nz(2:end);
change = sign(x(left)) ~= sign(x(right));
left = left(change); right = right(change);
tCross = zeros(numel(left),1);
for j = 1:numel(left)
    a = left(j); b = right(j);
    if b == a+1
        tCross(j) = t(a) - x(a)*(t(b)-t(a))/(x(b)-x(a));
    else
        tCross(j) = (t(a+1)+t(b-1))/2;
    end
end
direction = sign(x(right));
rows = zeros(0,7); rejected = 0;
for j = 1:numel(tCross)-2
    if ~isequal(direction(j:j+2), [1;-1;1]), continue; end
    phase = diff(tCross(j:j+2));
    if any(phase < opts.minPhaseSeconds), rejected = rejected + 1; continue; end
    start = tCross(j); turn = tCross(j+1); stop = tCross(j+2);
    % Add exact zero-valued boundaries to the sampled trapezoidal integral.
    inside = t > start & t < turn;
    inspired = trapz([start;t(inside);turn], [0;x(inside);0]);
    inside = t > turn & t < stop;
    expired = -trapz([turn;t(inside);stop], [0;x(inside);0]);
    rows(end+1,:) = [start,stop,phase',60/(stop-start),inspired,expired]; %#ok<AGROW>
end
result.cycles = array2table(rows, 'VariableNames', {'startSeconds','endSeconds', ...
    'inspirationSeconds','expirationSeconds','ratePerMinute','inspiredLiters','expiredLiters'});
result.crossings = table(tCross,direction,'VariableNames',{'timeSeconds','direction'});
result.timeSeconds = t;
result.correctedFlow = x;
result.rejectedCycles = rejected;
result.options = opts;
end
