function reproduce_FigS2()
clear; clc;
setupFigureDefaults();

TA = loadSourceSheet("FigS2A_heatmap");
TB = loadSourceSheet("FigS2B_impedance_boxplot");
TC = loadSourceSheet("FigS2C_impedance_depth");

groupOrder = ["Flex checkerboard","Flex linear","Plexon","DBC"];
groupColors = [
    0.55 0.55 0.55
    0.93 0.55 0.43
    0.52 0.67 0.88
    0.68 0.47 0.72
    ];

figA = figure('Color','w','Units','inches','Position',[1 1 7.2 5.6]);
tlA = tiledlayout(figA,1,2,'TileSpacing','compact','Padding','compact');
designs = ["checkerboard","linear"];
clim = [min(double(TA.impedance_MOhm),[],'omitnan') max(double(TA.impedance_MOhm),[],'omitnan')];

for i = 1:2
    ax = nexttile(tlA,i);
    idx = strcmpi(string(TA.probe_design),designs(i));
    T = TA(idx,:);
    scatter(ax,double(T.x_um),double(T.y_um),360,double(T.impedance_MOhm), ...
        'filled','MarkerEdgeColor','k','LineWidth',0.6);
    hold(ax,'on');
    for r = 1:height(T)
        text(ax,double(T.x_um(r)),double(T.y_um(r)),string(T.channel(r)), ...
            'HorizontalAlignment','center','VerticalAlignment','middle', ...
            'FontSize',7,'Color','k');
    end
    caxis(ax,clim);
    colormap(ax,parula(256));
    axis(ax,'equal');
    set(ax,'YDir','reverse');
    xlabel(ax,'Lateral position (\mum)');
    ylabel(ax,'Distance from probe tip (\mum)');
    title(ax,capitalizeFirst(designs(i)));
    grid(ax,'on');
    styleAxes(ax);
end
annotation(figA,'textbox',[0.005 0.94 0.04 0.04],'String','A','LineStyle','none','FontSize',14,'FontWeight','bold');
exportFigure(figA,'FigS2A_impedance_heatmaps');

probeClass = normalizeS2Groups(string(TB.probe_class));
zB = double(TB.impedance_1k_MOhm);
keep = ismember(probeClass,groupOrder) & isfinite(zB);
probeClass = probeClass(keep);
zB = zB(keep);

figB = figure('Color','w','Units','inches','Position',[1 1 5.8 5.2]);
axB = axes('Position',[0.14 0.15 0.82 0.79]);
hold(axB,'on');
for i = 1:numel(groupOrder)
    vals = zB(probeClass == groupOrder(i));
    vals = vals(isfinite(vals));
    if isempty(vals)
        continue;
    end
    drawBox(axB,i,vals,groupColors(i,:),0.48);
    offsets = linspace(-0.10,0.10,numel(vals))';
    scatter(axB,i + offsets,vals,18,groupColors(i,:), ...
        'filled','MarkerFaceAlpha',0.55,'MarkerEdgeColor','none');
    scatter(axB,i,mean(vals),40,'k','filled');
end
set(axB,'XTick',1:numel(groupOrder), ...
    'XTickLabel',cellstr(["Checkerboard","Linear","Plexon","DBC"]), ...
    'XTickLabelRotation',20);
ylabel(axB,'1 kHz impedance (M\Omega)');
xlim(axB,[0.45 4.55]);
grid(axB,'on');
styleAxes(axB);
text(axB,-0.14,1.04,'B','Units','normalized','FontSize',14,'FontWeight','bold');
exportFigure(figB,'FigS2B_impedance_boxplot');

probeC = normalizeS2Groups(string(TC.probe_class));
depthC = double(TC.depth_um);
zC = double(TC.impedance_1k_MOhm);
keep = ismember(probeC,["Flex checkerboard","Flex linear"]) & isfinite(depthC) & isfinite(zC);
probeC = probeC(keep);
depthC = depthC(keep);
zC = zC(keep);

figC = figure('Color','w','Units','inches','Position',[1 1 6.0 4.8]);
axC = axes('Position',[0.14 0.16 0.80 0.76]);
hold(axC,'on');
for i = 1:2
    g = groupOrder(i);
    idx = probeC == g;
    scatter(axC,depthC(idx),zC(idx),26,groupColors(i,:), ...
        'filled','MarkerFaceAlpha',0.60,'MarkerEdgeColor','none');
    uDepth = unique(depthC(idx));
    meanZ = nan(size(uDepth));
    semZ = nan(size(uDepth));
    for d = 1:numel(uDepth)
        vals = zC(idx & depthC == uDepth(d));
        meanZ(d) = mean(vals);
        semZ(d) = std(vals) / sqrt(max(1,numel(vals)));
    end
    [uDepth,ord] = sort(uDepth);
    errorbar(axC,uDepth,meanZ(ord),semZ(ord), ...
        'Color',groupColors(i,:),'LineWidth',1.4, ...
        'Marker','o','MarkerFaceColor',groupColors(i,:), ...
        'MarkerEdgeColor','k','CapSize',4);
end
xlabel(axC,'Distance from probe tip (\mum)');
ylabel(axC,'1 kHz impedance (M\Omega)');
grid(axC,'on');
styleAxes(axC);
legend(axC,{'Checkerboard points','Checkerboard mean \pm SEM','Linear points','Linear mean \pm SEM'}, ...
    'Location','best','Box','off');
text(axC,-0.14,1.04,'C','Units','normalized','FontSize',14,'FontWeight','bold');
exportFigure(figC,'FigS2C_impedance_vs_depth');
end

function out = normalizeS2Groups(raw)
s = lower(strtrim(string(raw)));
out = strings(size(s));
out(contains(s,'checker')) = "Flex checkerboard";
out(contains(s,'linear')) = "Flex linear";
out(contains(s,'plexon')) = "Plexon";
out(contains(s,'dbc') | contains(s,'deep array')) = "DBC";
end

function s = capitalizeFirst(s)
s = string(s);
if strlength(s) > 0
    s = upper(extractBefore(s,2)) + extractAfter(s,1);
end
end
