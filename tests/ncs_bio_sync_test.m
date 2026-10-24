function ncs_bio_sync_test(sourceDirectory)
% Synthetic regression for the NCS thorax/abdomen offset, without toolboxes.
if nargin == 0
    repository = fileparts(fileparts(mfilename('fullpath')));
    sourceDirectory = fullfile(repository,'MassStudy2019','Matlab');
end
fixture = tempname;
mkdir(fixture);
originalPath = path;
originalVisibility = get(groot,'DefaultFigureVisible');
originalFigures = findall(groot,'Type','figure');
cleanup = onCleanup(@()restore(fixture,originalPath,originalVisibility,originalFigures)); %#ok<NASGU>
addpath(sourceDirectory,'-begin');
set(groot,'DefaultFigureVisible','off');
clear ncsBioSync readNcsData readBioData

n = (1:120)';
ch12345 = [n,2000+n,1000+n,3000+n,5000+n];
subjectInfo = repmat(struct('Value',0),1,10);
subjectInfo(4).Value = 2000;
subjectInfo(5).Value = 1;
subjectInfo(6).Value = 1;
save(fullfile(fixture,'ncs.mat'),'ch12345','subjectInfo');

% Unequal-rate offsets in both directions, then equal-rate compatibility.
settings = [10,0.5;10,-0.5;20,0.5];
for k = 1:size(settings,1)
    fsBio = settings(k,1);
    offset = settings(k,2);
    b = (1:6*fsBio)';
    data = [6000+b,7000+b,8000+b,9000+b];
    dateVector = [2000,1,1,0,0,0];
    save(fullfile(fixture,'bio.mat'),'data','dateVector');
    [ncs,bio,mic,fs,tNcs,tBio,fig] = ncsBioSync( ...
        [fixture,filesep],'ncs','bio',20,fsBio,[1,1],offset,0.1, ...
        [0,0],[20,fsBio],[-1,1,-1,1],[0,0]);
    thorax = (21:100)';
    abdomen = thorax - round(offset*20);
    assert(isequal(ncs,[-thorax,1000+thorax,-2000-abdomen,3000+abdomen]));
    assert(isequal(mic,5000+thorax));
    assert(isequal(bio,data(1+round(1.1*fsBio):round(5.1*fsBio),:)));
    assert(isequal(fs,[20,fsBio]));
    assert(isequal(tNcs,(0:79)'/20));
    assert(isequal(tBio,(0:4*fsBio-1)'/fsBio));
    assert(size(ncs,2)==4 && size(ncs,1)==80);
    close(fig);
end
fprintf('ncs_bio_sync_test: 3 synthetic cases passed.\n');
end

function restore(fixture,originalPath,visibility,originalFigures)
figures = findall(groot,'Type','figure');
for k = 1:numel(figures)
    if ~any(figures(k)==originalFigures)
        close(figures(k));
    end
end
set(groot,'DefaultFigureVisible',visibility);
path(originalPath);
if isfolder(fixture)
    rmdir(fixture,'s'); % Only this test's newly created temporary directory.
end
end
