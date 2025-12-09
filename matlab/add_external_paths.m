function add_external_paths()
%ADD_EXTERNAL_PATHS Add external toolboxes to MATLAB path (matlabnpy, Open Ephys)
%   This helper adds the `external/` toolboxes to MATLAB's path. It assumes
%   the repository layout where `matlab/` is a subfolder of the repo root.

root = fileparts(fileparts(mfilename('fullpath')));
external_dir = fullfile(root, 'external');

paths_added = {};
if isfolder(fullfile(external_dir, 'matlabnpy'))
    addpath(genpath(fullfile(external_dir, 'matlabnpy')));
    paths_added{end+1} = 'matlabnpy';
end
if isfolder(fullfile(external_dir, 'open-ephys-analysis'))
    addpath(genpath(fullfile(external_dir, 'open-ephys-analysis')));
    paths_added{end+1} = 'open-ephys-analysis';
end

if isempty(paths_added)
    warning('No external toolboxes found in %s. Run scripts/setup_external_toolboxes.sh first.', external_dir);
else
    fprintf('Added external toolboxes to MATLAB path: %s\n', strjoin(paths_added, ', '));
    fprintf('Run savepath() if you want to persist these changes for future sessions.\n');
end
end
