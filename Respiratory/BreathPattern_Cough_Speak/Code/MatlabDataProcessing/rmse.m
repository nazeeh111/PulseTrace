function err = rmse(dataTrue,dataMeas)
%RMSE Return [root-mean-square error, sample std of signed measurement error].
% Inputs are paired finite real vectors; row/column orientation may differ.
% The second value describes error spread, not uncertainty of the RMSE.
validateattributes(dataTrue, {'numeric'}, {'real','finite','vector','nonempty'});
validateattributes(dataMeas, {'numeric'}, {'real','finite','vector','nonempty'});
if numel(dataTrue) ~= numel(dataMeas)
    error('PulseTrace:SizeMismatch','Inputs must contain the same number of paired samples.');
end
d = double(dataMeas(:))-double(dataTrue(:));
err = [norm(d)/sqrt(numel(d)), std(d)];
end
