%% ========================================================================
% RE-PLOT DRIFT FIGURES FROM DriftPlotData_AS_PLOTTED.mat
% 
%
% Usage:
%   1) Run this script
%   2) Select DriftPlotData.mat (or hardcode path below)
%   3) Figures are recreated and saved as PNGs
%
%% ========================================================================

clear; clc; close all;

%% ---------------- HARDCODE (optional) ----------------
% matFile = 'F:\000-NHP_flex_2026-000\Fig 4\DriftPlotData.mat';

if ~exist('matFile','var') || isempty(matFile)
    [f,p] = uigetfile('*.mat','Select DriftPlotData.mat');
    if isequal(f,0), error('No file selected.'); end
    matFile = fullfile(p,f);
end

S = load(matFile,'plotData');
if ~isfield(S,'plotData')
    error('Selected .mat does not contain plotData.');
end
plotData = S.plotData;

%% ---------------- OUTPUT ROOT ----------------
% Default: save next to the MAT file in a timestamped folder
[parentDir,~,~] = fileparts(matFile);
timestamp = datestr(now,'yyyy-mm-dd_HHMMSS');
outRoot   = fullfile(parentDir, ['Replot_FROM_PLOTDATA_' timestamp]);
figDir    = fullfile(outRoot,'Figures');

if ~exist(outRoot,'dir'), mkdir(outRoot); end
if ~exist(figDir,'dir'), mkdir(figDir); end

fprintf('Saving figures to:\n%s\n', figDir);

%% ========================================================================
% HEATMAP
%% ========================================================================

tCenters   = plotData.heatmap.tCenters;
H          = plotData.heatmap.H;
peakPos    = plotData.heatmap.peakPos;
nP         = plotData.heatmap.nP;
nD         = plotData.heatmap.nD;

maxPlotMin  = plotData.params.maxPlotMin;
cLimHeatmap = plotData.params.cLimHeatmap;

figure('Position',[120 120 1100 750]);
ax = axes; hold(ax,'on');
set(ax,'YDir','reverse','Color',[0.55 0.55 0.55]);
imagesc(ax, tCenters, 1:size(H,1), H);

hImg = findobj(ax,'Type','image');
set(hImg,'AlphaData',~isnan(H),'AlphaDataMapping','none');

colormap(ax, orangewhiteblue_centered());
caxis(ax, [-cLimHeatmap cLimHeatmap]);

ax.Color = 'none';
set(gcf,'Color','none');

xlim(ax,[0 maxPlotMin]);

for i = 1:numel(peakPos)
    if ~isnan(peakPos(i))
        plot(ax,[peakPos(i) peakPos(i)],[i-0.4 i+0.4],'k','LineWidth',1);
    end
end

yline(ax,nP+0.5,'k','LineWidth',2);
yline(ax,nP+nD+0.5,'k','LineWidth',2);

xlabel(ax,'Time (min)');
ylabel(ax,'Recording Index');
title(ax, {'Full Recording Drift Heatmap — TRUE Drift', ...
           'Plexon (top), DBC (middle), Flex (bottom)'});
cb = colorbar(ax); ylabel(cb,'Drift (µm)');

print(gcf, fullfile(figDir,'Heatmap.png'), '-dpng','-r300');

%% ========================================================================
% BOX PLOTS
%% ========================================================================

plot_box_with_points( ...
    plotData.box.net.boxData, plotData.box.net.labels, ...
    'Net Drift (µm, display-scaled)', ...
    'Net Drift Distribution (Box plot + individual sessions)', ...
    fullfile(figDir,'BoxPlot_NetDrift.png'));

plot_box_with_points( ...
    plotData.box.med.boxDataMed, plotData.box.med.labels, ...
    'Median |Drift| (µm, display-scaled)', ...
    'Median Drift Distribution (Outliers Removed)', ...
    fullfile(figDir,'BoxPlot_MedianDrift_NoOutliers.png'));

plot_box_with_points( ...
    plotData.box.deriv.boxDataDeriv, plotData.box.deriv.labels, ...
    'Mean |Δ Drift| (µm / min)', ...
    'Drift Spikiness (Mean Absolute Temporal Derivative)', ...
    fullfile(figDir,'BoxPlot_DriftDerivative.png'));

plot_box_with_points( ...
    plotData.box.deriv5.boxDataDeriv5, plotData.box.deriv5.labels, ...
    'Mean |Δ Drift| (µm / 5 min)', ...
    'Drift Spikiness at 5-Minute Timescale', ...
    fullfile(figDir,'BoxPlot_DriftDerivative_5min.png'));

%% ========================================================================
% REPRESENTATIVE TRACES
%% ========================================================================

for r = 1:numel(plotData.rep)
    R = plotData.rep(r);

    figure('Position',[700 120 1000 520]); hold on;
    plot(R.tP, R.dP, 'k', 'LineWidth', 2);
    plot(R.tD, R.dD, 'b', 'LineWidth', 2);
    plot(R.tF, R.dF, 'r', 'LineWidth', 2);

    xlabel('Time (min)');
    ylabel('Drift (µm)');
    yticks(-300:50:300);

    if isfield(R,'labels') && ~isempty(R.labels)
        legend(R.labels, 'Location','best');
    else
        legend({'Plexon','DBC','Flex'}, 'Location','best');
    end

    title(sprintf(['Representative Drift Traces — %.0f%% Quantile\n' ...
        'Replotted from saved plot data'], R.q*100));

    grid on;

    print(gcf, fullfile(figDir, ...
        sprintf('RepresentativeTraces_Q%02d.png', round(R.q*100))), ...
        '-dpng','-r300');
end

fprintf('\n✓ Replot finished.\nFigures saved in:\n%s\n', figDir);

%% ========================================================================
% HELPERS
%% ========================================================================

function plot_box_with_points(boxData, boxLabels, ylab, ttl, outFile)
    figure('Position',[820 120 650 600]); hold on;

    boxplot( ...
        cell2mat(boxData'), ...
        repelem(1:numel(boxData), cellfun(@numel, boxData)), ...
        'Labels', boxLabels, ...
        'Whisker', 1.5, ...
        'Symbol', '' );

    cols = lines(max(numel(boxData),3));

    for i = 1:numel(boxData)
        d = boxData{i};
        x = i + 0.08*randn(size(d));   % same horizontal jitter style
        scatter(x, d, 28, cols(i,:), ...
            'filled', ...
            'MarkerFaceAlpha', 0.65, ...
            'MarkerEdgeColor','none');
    end

    ylabel(ylab);
    title(ttl);
    set(gca,'FontName','Arial','FontSize',12);
    grid on;

    print(gcf, outFile, '-dpng','-r300');
end

function cmap = orangewhiteblue_centered()
    n = 257; half = (n-1)/2;
    blue   = [38 93 171]/255;
    orange = [230 119 37]/255;
    white  = [1 1 1];

    neg = [linspace(blue(1),white(1),half);
           linspace(blue(2),white(2),half);
           linspace(blue(3),white(3),half)]';

    pos = [linspace(white(1),orange(1),half);
           linspace(white(2),orange(2),half);
           linspace(white(3),orange(3),half)]';

    cmap = [neg; white; pos];
end
