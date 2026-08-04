function reproduce_FigS8()
clear; clc;
setupFigureDefaults();

TV = loadSourceSheet("S8_Velocity5min");
TN = loadSourceSheet("S8_NetDrift");

TV.group = normalizeS8Probe(string(TV.ProbeType));
TN.group = normalizeS8Probe(string(TN.ProbeType));
TV.value = double(TV.Velocity5min);
TN.value = double(TN.NetDrift_um);

groups = ["Flex","Plexon","DBC","Neuropixels"];
colors = [0.93 0.55 0.43; 0.52 0.67 0.88; 0.68 0.47 0.72; 0.45 0.72 0.52];

fig = figure('Color','w','Units','inches','Position',[1 1 9.4 4.8]);
tl = tiledlayout(fig,1,2,'TileSpacing','compact','Padding','compact');

ax1 = nexttile(tl,1);
plotBoxPanel(ax1,TV,groups,colors,'Mean 5-min drift (\mum/5 min)','A');

ax2 = nexttile(tl,2);
plotBoxPanel(ax2,TN,groups,colors,'Maximum displacement (\mum)','B');

exportFigure(fig,'FigS8_drift_all_probe_types');
end

function plotBoxPanel(ax,T,groups,colors,yLabelText,panel)
hold(ax,'on');
for i = 1:numel(groups)
    vals = T.value(T.group == groups(i));
    vals = vals(isfinite(vals));
    if isempty(vals)
        continue;
    end
    drawBox(ax,i,vals,colors(i,:),0.46);
    offs = linspace(-0.10,0.10,numel(vals))';
    scatter(ax,i + offs,vals,34,colors(i,:),'filled','MarkerFaceAlpha',0.7, ...
        'MarkerEdgeColor',[0.15 0.15 0.15],'LineWidth',0.4);
    scatter(ax,i,median(vals),42,'k','filled');
end
set(ax,'XTick',1:numel(groups),'XTickLabel',cellstr(groups),'XTickLabelRotation',20);
ylabel(ax,yLabelText);
grid(ax,'on');
styleAxes(ax);
text(ax,-0.15,1.04,panel,'Units','normalized','FontWeight','bold','FontSize',14);
end

function g = normalizeS8Probe(s)
s = lower(strtrim(s));
g = strings(size(s));
g(contains(s,'flex')) = "Flex";
g(contains(s,'plexon')) = "Plexon";
g(contains(s,'dbc')) = "DBC";
g(contains(s,'neuropixel') | strcmp(s,'np')) = "Neuropixels";
end
