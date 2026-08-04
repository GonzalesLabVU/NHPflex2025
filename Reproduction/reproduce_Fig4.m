function reproduce_Fig4()
clear; clc;
setupFigureDefaults();

THeat = loadSourceSheet("Fig4B_Heatmap");
TNet = loadSourceSheet("Fig4C_NetDrift_Boxplot");
TVel = loadSourceSheet("Fig4C_Velocity5min_Boxplot");

timeMin = double(THeat.Time_min);
sessionNames = string(THeat.Properties.VariableNames(2:end));
D = double(THeat{:,2:end});
nSessions = size(D,2);
sessionGroups = strings(nSessions,1);
for i = 1:nSessions
    sessionGroups(i) = classifyProbeFromName(sessionNames(i));
end

figB = figure('Color','w','Units','inches','Position',[1 1 9.0 5.4]);
axB = axes('Position',[0.09 0.16 0.84 0.76]);
imagesc(axB,1:nSessions,timeMin,D);
set(axB,'YDir','normal');
colormap(axB,blueWhiteRed(256));

finiteD = D(isfinite(D));
lim = max(abs(prctile(finiteD,[2 98])));
if ~isfinite(lim) || lim == 0
    lim = max(abs(finiteD));
end
if ~isfinite(lim) || lim == 0
    lim = 1;
end
caxis(axB,[-lim lim]);

cb = colorbar(axB);
cb.Label.String = 'Drift displacement (\mum)';
xlabel(axB,'Recording session');
ylabel(axB,'Time (min)');
title(axB,'Drift displacement across recording sessions');
set(axB,'XTick',[]);
styleAxes(axB);

changes = [1; find(sessionGroups(2:end) ~= sessionGroups(1:end-1)) + 1; nSessions + 1];
for k = 1:numel(changes) - 1
    lo = changes(k);
    hi = changes(k + 1) - 1;
    mid = mean([lo hi]);
    if k > 1
        xline(axB,lo - 0.5,'k-','LineWidth',1.2);
    end
    label = sessionGroups(lo);
    if strlength(label) == 0
        label = "Other";
    end
    text(axB,mid,max(timeMin) + 0.035 * range(timeMin),label, ...
        'HorizontalAlignment','center','VerticalAlignment','bottom', ...
        'FontWeight','bold','Clipping','off');
end
text(axB,-0.075,1.04,'B','Units','normalized','FontSize',14,'FontWeight','bold');
exportFigure(figB,'Fig4B_drift_heatmap');

groupOrder = ["Plexon","DBC","Flex"];
groupColors = [
    0.33 0.65 0.86
    0.67 0.43 0.72
    0.93 0.55 0.43
    ];

Net = standardizeMetricTable(TNet,'NetDrift_um');
Vel = standardizeMetricTable(TVel,'Velocity5min_um');
Net = Net(ismember(Net.probe_group,groupOrder),:);
Vel = Vel(ismember(Vel.probe_group,groupOrder),:);

figC = figure('Color','w','Units','inches','Position',[1 1 9.2 4.8]);
tl = tiledlayout(figC,1,2,'TileSpacing','compact','Padding','compact');
ax1 = nexttile(tl,1);
plotDriftBoxPanel(ax1,Net,groupOrder,groupColors,'Net drift (\mum)','Net displacement');
ax2 = nexttile(tl,2);
plotDriftBoxPanel(ax2,Vel,groupOrder,groupColors,'Mean 5-min drift (\mum/5 min)','Mean 5-min drift');
text(ax1,-0.16,1.06,'C','Units','normalized','FontSize',14,'FontWeight','bold');
exportFigure(figC,'Fig4C_drift_boxplots');
end

function Out = standardizeMetricTable(T,metricName)
names = string(T.Properties.VariableNames);
probeIdx = find(strcmpi(names,'ProbeType'),1);
metricIdx = find(strcmpi(names,metricName),1);
Out = table();
Out.probe_group = normalizeProbeGroups(string(T.(names(probeIdx))));
Out.value = double(T.(names(metricIdx)));
Out = Out(strlength(Out.probe_group) > 0 & isfinite(Out.value),:);
end

function plotDriftBoxPanel(ax,T,groupOrder,colors,yLabelText,titleText)
hold(ax,'on');
for i = 1:numel(groupOrder)
    vals = T.value(T.probe_group == groupOrder(i));
    vals = vals(isfinite(vals));
    if isempty(vals)
        continue;
    end
    drawBox(ax,i,vals,colors(i,:),0.48);
    offsets = linspace(-0.10,0.10,numel(vals))';
    scatter(ax,i + offsets,vals,34,colors(i,:), ...
        'filled','MarkerFaceAlpha',0.72, ...
        'MarkerEdgeColor',[0.15 0.15 0.15],'LineWidth',0.45);
    scatter(ax,i,median(vals),44,'k','filled');
    text(ax,i,max(vals) + 0.04 * max(1,range(localYLim(T.value))),sprintf('n=%d',numel(vals)), ...
        'HorizontalAlignment','center','FontSize',9);
end
set(ax,'XTick',1:numel(groupOrder), ...
    'XTickLabel',cellstr(groupOrder), ...
    'XTickLabelRotation',20);
ylabel(ax,yLabelText);
title(ax,titleText);
xlim(ax,[0.45 numel(groupOrder) + 0.55]);
grid(ax,'on');
styleAxes(ax);
ylim(ax,localYLim(T.value));
end

function yl = localYLim(v)
v = v(isfinite(v));
if isempty(v)
    yl = [0 1];
    return;
end
lo = min(0,min(v));
hi = max(v);
yl = [lo hi + 0.16 * max(eps,hi - lo)];
end
