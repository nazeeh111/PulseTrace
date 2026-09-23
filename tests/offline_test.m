% Independent analytic checks of airflow integration and cycle timing.
root = fileparts(fileparts(mfilename('fullpath'))); addpath(root);
fs=100; f=.25; amp=.4; t=(0:1/fs:40)';
r=pulse_trace_airflow(amp*sin(2*pi*f*t)+.07,fs,struct('baseline',.07));
assert(height(r.cycles)>=8);
rateError=max(abs(r.cycles.ratePerMinute-60*f));
volumeError=max(abs(r.cycles.inspiredLiters-amp/(pi*f)));
assert(rateError<1e-10 && volumeError<2e-5);
assert(max(abs(r.cycles.expiredLiters-amp/(pi*f)))<2e-5);
% No circular final-to-first crossing; no crossings from a zero touch.
r=pulse_trace_airflow([1;0;1;2],10); assert(isempty(r.crossings));
r=pulse_trace_airflow([-1;0;0;1;0;-1;0;1],1,struct('minPhaseSeconds',0));
assert(isequal(r.crossings.timeSeconds,[1.5;4;6]));
assert(height(r.cycles)==1 && abs(r.cycles.ratePerMinute-60/4.5)<1e-12);
assert(isempty(pulse_trace_airflow(zeros(100,1),10).cycles));
r=pulse_trace_airflow(sin(2*pi*2*t),fs); assert(isempty(r.cycles)&&r.rejectedCycles>0);
for value={NaN,Inf,[]}
    failed=false; try, pulse_trace_airflow(value{1},fs); catch, failed=true; end
    assert(failed);
end
% Archived function contract now executes; no baseline implementation existed.
legacy=fullfile(root,'Respiratory','BreathPattern_Cough_Speak','Code','MatlabDataProcessing');
for folder={legacy,fullfile(legacy,'CodeStyle_Old')}
    addpath(folder{1},'-begin'); clear rmse;
    e=rmse([1 2 3],[2 0 5]);
    assert(max(abs(e-[sqrt(3),std([1 -2 2])]))<1e-12);
    assert(isequal(rmse([1;2],[1;2]),[0 0]));
    failed=false; try, rmse([1 2],1); catch, failed=true; end; assert(failed);
    rmpath(folder{1}); clear rmse;
end
fprintf('PASS PulseTrace offline: rate error %.3g /min; volume error %.3g L\n',rateError,volumeError);
