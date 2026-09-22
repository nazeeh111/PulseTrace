% Offline checks; run from repository root.
root = fileparts(fileparts(mfilename('fullpath')));
addpath(root);
addpath(fullfile(root,'MassStudy2019','Matlab'));
signal=sin(2*pi*0.7*((0:999)/100)+0.1);
for interval=[0 .3]
    options=struct('minTime',interval);
    actual=pulse_trace(signal,100,options);
    expected=zeroCrossDet(signal,100,options);
    assert(isequaln(actual,expected));
    assert(size(actual,2)==2 && size(actual,1)>8);
    assert(all(diff(actual(:,1))>0));
    assert(all(ismember(actual(:,2),[-1 1])));
end
disp('PASS PulseTrace: zero-crossing facade parity, sorted indices and crossing directions');
