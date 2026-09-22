function varargout = pulse_trace(varargin)
% PulseTrace: Explore contactless physiological signals.
% Passes arguments and outputs directly to zeroCrossDet.
root = fileparts(mfilename('fullpath'));
previousPath = path;
cleanup = onCleanup(@() path(previousPath)); %#ok<NASGU>
addpath(root);
addpath(fullfile(root, 'MassStudy2019', 'Matlab'));
[varargout{1:nargout}] = zeroCrossDet(varargin{:});
end
