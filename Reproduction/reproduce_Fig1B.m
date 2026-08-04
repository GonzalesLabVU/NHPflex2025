function reproduce_Fig1B()
clear; clc;
setupFigureDefaults();

T = loadSourceSheet("Fig1B_impedance_all_307");
z = double(T.impedance_1k_MOhm) .* 1000;
z = z(isfinite(z) & z > 0);

fig = figure('Color','w','Units','inches','Position',[1 1 3.6 5.2]);
ax = axes('Position',[0.22 0.12 0.70 0.82]);
hold(ax,'on');

gold = [0.90 0.60 0.00];
rng(7);

drawBox(ax,1,z,gold,0.34);
xj = 1 + (rand(size(z)) - 0.5) .* 0.20;
scatter(ax,xj,z,16,gold,'filled','MarkerFaceAlpha',0.65,'MarkerEdgeColor','none');
errorbar(ax,1,mean(z),std(z), ...
    'ko','MarkerFaceColor','w','MarkerSize',8,'LineWidth',2,'CapSize',11);

xlim(ax,[0.6 1.4]);
ylim(ax,[200 1800]);
set(ax,'XTick',1,'XTickLabel',{'Electrodes'});
ylabel(ax,'1 kHz Impedance (k\Omega)');
grid(ax,'on');
styleAxes(ax);

yl = ylim(ax);
text(ax,1,yl(2) - 0.07 * range(yl),sprintf('n=%d',numel(z)), ...
    'HorizontalAlignment','center','VerticalAlignment','top','FontSize',11);

exportFigure(fig,'Fig1B_impedance_boxplot');
end
