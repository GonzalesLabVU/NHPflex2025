function p = sourceMatPath()
localCopy = fullfile(fileparts(mfilename('fullpath')),'workbook_all_sheets.mat');
sharedCopy = 'F:\000-NHP_flex_2026-000\Revision\github_release\SourceData_Audit\workbook_all_sheets.mat';

if exist(localCopy,'file') == 2
    p = localCopy;
elseif exist(sharedCopy,'file') == 2
    p = sharedCopy;
else
    error('workbook_all_sheets.mat was not found.');
end
end
