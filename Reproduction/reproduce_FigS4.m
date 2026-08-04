function reproduce_FigS4()
clear; clc;
setupFigureDefaults();

T = loadSourceSheet("FigS4_flex_depth_yield");
probe = lower(strtrim(string(T.probe_class)));
depth = double(T.depth_mid_um);
meanYield = double(T.mean_units_per_channel);
semYield = double(T.sem_units_per_channel);

groupOrder = ["Flex checkerboard","Flex linear"];
groupColors = [
    0.55 0.55 0.55
    0.93 0.55 0.43
    ];

probeGroup = strings(size(probe));
probeGroup(contains(probe,'checker')) = "Flex checkerboard";
probeGroup(contains(probe,'linear')) = "Flex linear";

keep = ismember(probeGroup,groupOrder) & isfinite(depth) & isfinite(meanYield) & isfinite(semYield);
probeGroup = probeGroup(keep);
depth = depth(keep);
meanYield = meanYield(keep);
semYield = semYield(keep);

fig = figure('Color','w','Units','inches','Position',[1 1 6.3 4.8]);
ax = axes('Position',[0.14 0.16 0.80 0.76]);
hold(ax,'on');

for i = 1:numel(groupOrder)
    idx = probeGroup == groupOrder(i);
    x = depth(idx);
    y = meanYield(idx);
    e = semYield(idx);
    [x,ord] = sort(x);
    errorbar(ax,x,y(ord),e(ord), ...
        'Color',groupColors(i,:),'LineWidth',1.8, ...
        'Marker','o','MarkerSize',6, ...
        'MarkerFaceColor',groupColors(i,:), ...
        'MarkerEdgeColor','k','CapSize',5);
end

xlabel(ax,'Distance from probe tip (\mum)');
ylabel(ax,'Average yield (units/channel/session)');
xlim(ax,[0 1800]);
ylim(ax,[0 0.72]);
xticks(ax,0:200:1800);
grid(ax,'on');
styleAxes(ax);
legend(ax,{'Checkerboard','Linear'},'Location','best','Box','off');
text(ax,-0.13,1.04,'S4','Units','normalized','FontSize',14,'FontWeight','bold');

exportFigure(fig,'FigS4_flex_depth_yield');
end
