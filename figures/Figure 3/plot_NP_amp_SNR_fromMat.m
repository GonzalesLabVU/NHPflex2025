function plot_NP_amp_SNR_fromMat()
% ------------------------------------------------------------
% Reproduce ALL figures & diagnostics from saved NP_amp_SNR_combined.mat
%
% Heatmap figures (single axes each):
%   - Amplitude (3col + Linear)
%   - SNR       (3col + Linear)
%   - Units/ch  (3col + Linear)
%
% ------------------------------------------------------------

%% ================= PATH =================
matFile = 'F:\Channel Map Center Edge\full_script\NP_amp_SNR_combined.mat';
assert(exist(matFile,'file')==2, 'MAT file not found');

S = load(matFile);

requiredVars = {'UT','UTsel','geom','maps','yieldTbl','countsFinal','meta'};
for v = requiredVars
    assert(isfield(S,v{1}), 'Missing variable: %s', v{1});
end

UT       = S.UT; %#ok<NASGU>
UTsel    = S.UTsel;
geom     = S.geom;
maps     = S.maps;
yieldTbl = S.yieldTbl;
countsFinal = S.countsFinal; %#ok<NASGU>
meta     = S.meta;

fprintf('\nLoaded MAT file:\n%s\n', matFile);
fprintf('Original script: %s\n', meta.script_name);
fprintf('Run timestamp:   %s\n', string(meta.run_timestamp));

%% ================= CONSTANTS =================
CAP_AMP_HARD_uV = 200;
CAP_SNR_HARD    = 8;
CNT_CLIM        = [0 11];

X_OFFSET_LINEAR = 250;   % µm horizontal separation between probes

cmap = hot(256);

%% ================= SESSION YIELD FIGURE =================
figure('Color','w','Name','Session yield (all units)');
boxplot(yieldTbl.nUnits, cellstr(yieldTbl.probe));
ylabel('Units per session (amp-qualified)');
title('Session yield (ALL units, no population enforcement)');
grid on;

%% ================= DIAGNOSTICS =================
fprintf('\n===== FINAL CHANNEL MAP DIAGNOSTICS (RAW VALUES) =====\n');

if ~isempty(maps.amp3)
    fprintf('\n3-COLUMN\n');
    fprintf(' Amp median %.1f | p95 %.1f | max %.1f\n', ...
        median(maps.amp3,'omitnan'), prctile(maps.amp3,95), max(maps.amp3,[],'omitnan'));
    fprintf(' SNR median %.2f | p95 %.2f | max %.2f\n', ...
        median(maps.snr3,'omitnan'), prctile(maps.snr3,95), max(maps.snr3,[],'omitnan'));
    fprintf(' Units/channel mean %.2f | max %d\n', ...
        mean(maps.cnt3), max(maps.cnt3));
end

if ~isempty(maps.ampL)
    fprintf('\nLINEAR\n');
    fprintf(' Amp median %.1f | p95 %.1f | max %.1f\n', ...
        median(maps.ampL,'omitnan'), prctile(maps.ampL,95), max(maps.ampL,[],'omitnan'));
    fprintf(' SNR median %.2f | p95 %.2f | max %.2f\n', ...
        median(maps.snrL,'omitnan'), prctile(maps.snrL,95), max(maps.snrL,[],'omitnan'));
    fprintf(' Units/channel mean %.2f | max %d\n', ...
        mean(maps.cntL), max(maps.cntL));
end

fprintf('\n Units/channel (MEAN ACROSS SESSIONS)\n');
fprintf('  3col:  mean %.2f | max %.2f\n', mean(maps.cnt3), max(maps.cnt3));
fprintf('  linear: mean %.2f | max %.2f\n', mean(maps.cntL), max(maps.cntL));


fprintf('\n===== END DIAGNOSTICS =====\n');

%% ================= SHARED AXIS LIMITS =================
lims = geomLimitsCombined(geom.threeCol.chanPos, geom.linear.chanPos, X_OFFSET_LINEAR);

%% ================= AMPLITUDE MAP =================
allAmp = [maps.amp3(:); maps.ampL(:)];
allAmp = allAmp(isfinite(allAmp));
ampClim = [prctile(allAmp,5), min(CAP_AMP_HARD_uV, prctile(allAmp,95))];

figure('Color','w','Name','Amplitude (3-column vs Linear)'); hold on
plotMapSingleAxes(gca, geom.threeCol.chanPos, min(maps.amp3,ampClim(2)), ...
    'Amplitude (\muV)', ampClim, cmap, 0);
plotMapSingleAxes(gca, geom.linear.chanPos, min(maps.ampL,ampClim(2)), ...
    'Amplitude (\muV)', ampClim, cmap, X_OFFSET_LINEAR);

finalizeAxes(gca, lims, 'Amplitude');

%% ================= SNR MAP =================
figure('Color','w','Name','Spike SNR (3-column vs Linear)'); hold on
plotMapSingleAxes(gca, geom.threeCol.chanPos, min(maps.snr3,CAP_SNR_HARD), ...
    'Spike SNR', [0 CAP_SNR_HARD], cmap, 0);
plotMapSingleAxes(gca, geom.linear.chanPos, min(maps.snrL,CAP_SNR_HARD), ...
    'Spike SNR', [0 CAP_SNR_HARD], cmap, X_OFFSET_LINEAR);

finalizeAxes(gca, lims, 'Spike SNR');

%% ================= UNITS / CHANNEL MAP =================
figure('Color','w','Name','Units per channel (3-column vs Linear)'); hold on
plotMapSingleAxes(gca, geom.threeCol.chanPos, maps.cnt3, ...
    'Units / channel', CNT_CLIM, cmap, 0);
plotMapSingleAxes(gca, geom.linear.chanPos, maps.cntL, ...
    'Units / channel', CNT_CLIM, cmap, X_OFFSET_LINEAR);

finalizeAxes(gca, lims, 'Units / channel');

%% ================= UNITS / CHANNEL MAP (MEAN ACROSS SESSIONS) =================

% Derive shared clim from data (robust, matches original intent)
allCnt = [maps.cnt3(:); maps.cntL(:)];
allCnt = allCnt(isfinite(allCnt));

cntClim = [0 max(1, prctile(allCnt, 95))];

figure('Color','w','Name','Mean units per channel per session (3-column vs Linear)');
hold on

plotMapSingleAxes(gca, geom.threeCol.chanPos, maps.cnt3, ...
    'Units / channel / session', cntClim, cmap, 0);

plotMapSingleAxes(gca, geom.linear.chanPos, maps.cntL, ...
    'Units / channel / session', cntClim, cmap, X_OFFSET_LINEAR);

finalizeAxes(gca, lims, 'Mean units per channel per session');


fprintf('\nAll figures regenerated successfully.\n');

end

%% ================= HELPER FUNCTIONS =================

function plotMapSingleAxes(ax, chanPos, values, cbarLabel, clim, cmap, xOffset)

axes(ax); hold on

x = double(chanPos(:,1)) + xOffset;
y = double(chanPos(:,2));
v = double(values(:));
v(~isfinite(v)) = clim(1);

scatter(x, y, 40, v, 'filled', ...
    'MarkerEdgeColor',[0.2 0.2 0.2]);

colormap(ax, cmap);
caxis(ax, clim);

cb = colorbar;
cb.Label.String = cbarLabel;

end

function finalizeAxes(ax, lims, ttl)

set(ax,'YDir','reverse');
axis equal
xlim(lims(1:2));
ylim(lims(3:4));

xlabel('x (\mum)');
ylabel('y (\mum)');
title(ttl);
box on

end

function lims = geomLimitsCombined(chanPos3, chanPosL, xOffsetL)

x3 = chanPos3(:,1);
y3 = chanPos3(:,2);

xL = chanPosL(:,1) + xOffsetL;
yL = chanPosL(:,2);

xAll = [x3; xL];
yAll = [y3; yL];

padX = 0.05 * range(xAll);
padY = 0.05 * range(yAll);

lims = [
    min(xAll)-padX, max(xAll)+padX, ...
    min(yAll)-padY, max(yAll)+padY
];

end
