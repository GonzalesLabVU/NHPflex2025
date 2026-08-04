function T = loadSourceSheet(sheetName)
persistent sheets

if isempty(sheets)
    sourceFile = sourceMatPath();
    S = load(sourceFile,'AllSheets');
    sheets = S.AllSheets;
end

if ~isfield(sheets,sheetName)
    error('Sheet "%s" not found in source MAT file.',sheetName);
end

T = sheets.(sheetName);
end
