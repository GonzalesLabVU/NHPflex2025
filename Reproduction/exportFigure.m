function exportFigure(fig,baseName)
outDir = fullfile(fileparts(mfilename('fullpath')),'output');
if exist(outDir,'dir') ~= 7
    mkdir(outDir);
end

base = fullfile(outDir,baseName);
savefig(fig,[base '.fig']);
exportgraphics(fig,[base '.png'],'Resolution',600);
try
    exportgraphics(fig,[base '.svg'],'ContentType','vector');
catch
    print(fig,[base '.svg'],'-dsvg','-r600');
end
end
