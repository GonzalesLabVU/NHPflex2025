function reproduce_FigS7()
clear; clc;
setupFigureDefaults();

T = loadSourceSheet("FigS5_7_snr_amp_vs_imp");
T.probe_design = lower(strtrim(string(T.probe_design)));
T = T(ismember(T.probe_design,["checkerboard","linear"]),:);

groups = ["checkerboard","linear"];
labels = ["Checkerboard","Linear"];
colors = [0.55 0.55 0.55; 0.93 0.55 0.43];

fig = figure('Color','w','Units','inches','Position',[1 1 10 4.7]);
tl = tiledlayout(fig,1,2,'TileSpacing','compact','Padding','compact');

ax1 = nexttile(tl,1);
hold(ax1,'on');
plotCorrelationPanel(ax1,T,'median_snr','Median channel SNR','A',groups,labels,colors);

ax2 = nexttile(tl,2);
hold(ax2,'on');
plotCorrelationPanel(ax2,T,'median_amplitude_uV','Median spike amplitude (\muV)','B',groups,labels,colors);

exportFigure(fig,'FigS7_impedance_vs_recording_quality');
end

function plotCorrelationPanel(ax,T,yName,yLabel,panel,groups,labels,colors)
for i = 1:2
    idx = T.probe_design == groups(i) & isfinite(T.impedance_1k_MOhm) & isfinite(T.(yName));
    x = double(T.impedance_1k_MOhm(idx));
    y = double(T.(yName)(idx));
    scatter(ax,x,y,38,colors(i,:),'filled','MarkerFaceAlpha',0.7, ...
        'MarkerEdgeColor',[0.15 0.15 0.15],'LineWidth',0.4);
end
xlabel(ax,'1 kHz impedance (M\Omega)');
ylabel(ax,yLabel);
grid(ax,'on');
styleAxes(ax);
legend(ax,cellstr(labels),'Location','best','Box','off');
text(ax,-0.14,1.04,panel,'Units','normalized','FontWeight','bold','FontSize',14);
title(ax,'Impedance relationship');
end
