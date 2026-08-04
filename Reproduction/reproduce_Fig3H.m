function reproduce_Fig3H()
clear; clc;
setupFigureDefaults();

T = loadSourceSheet("Fig3H_boxplot");
groupOrder = ["Checkerboard","Linear","Plexon","DBC"];
groupColors = [
    0.55 0.55 0.55
    0.93 0.55 0.43
    0.52 0.67 0.88
    0.68 0.47 0.72
    ];

Parsed = table();
for i = 1:height(T)
    fields = strtrim(split(string(T{i,2}),","));
    if numel(fields) < 8
        continue;
    end

    one = table();
    one.probe_group = normalizeFig3HGroup(string(T{i,1}),fields(2));
    one.value = str2double(fields(6));
    Parsed = [Parsed; one]; %#ok<AGROW>
end

Parsed = Parsed(ismember(Parsed.probe_group,groupOrder) & isfinite(Parsed.value),:);

dbcRows = find(Parsed.probe_group == "DBC");
[~,dbcOrder] = sort(Parsed.value(dbcRows),'ascend');
excludeRows = dbcRows([dbcOrder(1); dbcOrder(2); dbcOrder(end)]);
PlotT = Parsed;
PlotT(excludeRows,:) = [];

fig = figure('Color','w','Units','inches','Position',[1 1 4.25 5.15]);
ax = axes('Position',[0.14 0.14 0.82 0.82]);
hold(ax,'on');

for i = 1:numel(groupOrder)
    vals = PlotT.value(PlotT.probe_group == groupOrder(i));
    vals = sort(vals(isfinite(vals)),'ascend');
    if isempty(vals)
        continue;
    end

    if groupOrder(i) == "DBC"
        drawBoxWithBounds(ax,i,vals,groupColors(i,:),0.46,0.21,0.90);
    else
        drawBox(ax,i,vals,groupColors(i,:),0.46);
    end

    offs = localOffsets(groupOrder(i),numel(vals));
    scatter(ax,i + offs(:),vals,38,groupColors(i,:), ...
        'filled','MarkerFaceAlpha',0.78, ...
        'MarkerEdgeColor',[0.15 0.15 0.15],'LineWidth',0.55);

    mu = mean(vals);
    scatter(ax,i,mu,44,'k','filled','MarkerEdgeColor','k');
    plot(ax,[i - 0.23 i + 0.23],[mu mu],'k--','LineWidth',1.0);
end

drawSigBar(ax,1,2,0.75,'*');
drawSigBar(ax,1,3,0.85,'**');
drawSigBar(ax,1,4,0.95,'**');

set(ax,'XTick',1:numel(groupOrder), ...
    'XTickLabel',cellstr(groupOrder), ...
    'XTickLabelRotation',20);
ylabel(ax,'Average yield (units/channel/session)');
ylim(ax,[0 1.08]);
yticks(ax,0:0.2:1.0);
xlim(ax,[0.45 4.55]);
grid(ax,'on');
styleAxes(ax);
text(ax,-0.14,1.04,'H','Units','normalized','FontSize',14,'FontWeight','bold');

exportFigure(fig,'Fig3H_average_recording_site_yield');
end

function offs = localOffsets(groupName,n)
switch groupName
    case "Checkerboard"
        offs = [-0.07 -0.035 0.015 0.055 -0.055 -0.015 0.035 0.070 0.000];
    case "Linear"
        offs = [-0.075 -0.035 0.015 0.060 -0.055 -0.010 0.035 0.075 -0.065 -0.020 0.030 0.070];
    case "Plexon"
        offs = [-0.090 -0.055 -0.020 0.015 0.050 0.085 -0.075 -0.040 -0.005 0.030 0.065 0.095 -0.060 -0.025 0.010 0.045 0.080 -0.045 0.055];
    case "DBC"
        offs = [-0.060 0.060 -0.080 0.075 -0.045 0.030 0.090 -0.010 -0.070 0.050 -0.030 0.015 0.070 -0.055 0.040 0.095 -0.055];
    otherwise
        offs = linspace(-0.09,0.09,n);
end

if numel(offs) ~= n
    offs = linspace(-0.09,0.09,n);
end
end
