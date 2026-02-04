%% =============================================================
% plot_population_PSTH_minimal_shareable.m
% -------------------------------------------------------------
% Shareable population raster + PSTH script.
% - Loads "minimal" MatData files from:
%     F:\000-NHP_flex_2026-000\Data
% - Keeps plotting style/layout the SAME as your v22 script:
%     * Raster (epoch-colored dots on gray background, grouped by type)
%     * Population PSTH with epoch shading + SEM fill
%
% Differences vs your full refine script:
% - No refinement / regeneration. This is plotting-only.
% - Works even if meta.neuronType and meta.prefLoc are absent:
%     * prefLoc is inferred from data (best location = max mean FR in 0–3.7)
%     * neuronType is inferred from FR epochs at prefLoc (same logic as before)
% - "Opp" is computed from the TRUE opposite location (pref+4 wrap), not synthetic.
%
% Output:
% - Saves PNG in a timestamped folder next to the data folder.
%% =============================================================

clear; clc; close all;
rng(42,'twister');

%% -------- PATHS --------
dataDir = 'F:\000-NHP_flex_2026-000\Data';

archiveRoot = fullfile(dataDir, '_population_plots');
if ~exist(archiveRoot,'dir'), mkdir(archiveRoot); end
timestamp = datestr(now,'yyyymmdd_HHMMSS');
outDir = fullfile(archiveRoot, ['population_plots_minimal_' timestamp]);
if ~exist(outDir,'dir'), mkdir(outDir); end

files = dir(fullfile(dataDir,'*.mat'));
fprintf('Found %d minimal neuron files in %s\n', numel(files), dataDir);

%% -------- EPOCHS --------
E.full     = [-0.5 5.0];
E.baseline = [-0.5 0.0];
E.cue      = [0 0.5];
E.delay    = [0.5 3.5];    % keep 0.5–3.5 as in your inference helper
E.sacc     = [3.5 3.7];

%% -------- INFERENCE PARAMETERS --------
thrAbs = 3.0;        % Hz above baseline
thrRel = 1.3;        % multiplicative threshold over baseline
minBaselineHz = 1.0; % if baseline < 1 Hz, rely more on absolute diff

%% -------- PSTH PARAMETERS --------
tWindow = [-0.5 5.0];
bin = 0.01; % 10 ms bins
edges = [tWindow(1):bin:0, (0+bin):bin:tWindow(2)];
centers = edges(1:end-1) + bin/2;

%% -------- COLORS (same as v22) --------
cols = struct( ...
    'cue'  , [0.00 0.30 0.70], ...
    'delay', [0.65 0.10 0.10], ...
    'mixed', [0.05 0.45 0.05], ...
    'sacc' , [0.40 0.05 0.55] ...
);
grayCol = [0 0 0];

%% -------- COLLECT PSTHs + RASTER TRIALS --------
typesOrder = ["cue","delay","mixed","sacc"]; % for bookkeeping
PSTH_best = struct('cue',[],'delay',[],'mixed',[],'sacc',[]);
PSTH_opp  = PSTH_best;

rasterTimes = {};
rasterTypeTag = {};

nUsed = 0; nSkipped = 0;

for i = 1:numel(files)
    try
        S = load(fullfile(dataDir, files(i).name), 'MatData');
        if ~isfield(S,'MatData'), error('No MatData'); end
        M = S.MatData;

        if ~isfield(M,'class') || ~isfield(M.class,'ntr') || isempty(M.class.ntr)
            nSkipped = nSkipped + 1;
            continue;
        end

        % 1) Infer preferred location from data (best loc = max mean FR in 0–3.7)
        pref = infer_pref_loc(M.class, E);

        % define opposite location as +4 wrap on 8 (classic “opposite” mapping)
        oppLoc = mod(pref - 1 + 4, 8) + 1;

        % 2) Infer neuron type from FR epochs at pref
        [FRb, FRc, FRd, FRs, nTrialsUsed] = compute_FR_epochs(M.class, pref, E);
        if nTrialsUsed == 0
            nSkipped = nSkipped + 1;
            continue;
        end
        inferredType = infer_neuron_type(FRb, FRc, FRd, FRs, thrAbs, thrRel, minBaselineHz);
        inferredType = lower(string(inferredType));

        % only keep canonical types for plotting
        if ~ismember(inferredType, typesOrder)
            nSkipped = nSkipped + 1;
            continue;
        end

        % 3) PSTH for best (pref) and opp (oppLoc) from actual data
        [p_best, TS_best] = compute_psth_allTrials(M.class, pref, edges, bin, tWindow);
        [p_opp,  ~]       = compute_psth_allTrials(M.class, oppLoc, edges, bin, tWindow);

        if isempty(p_best) || isempty(p_opp)
            nSkipped = nSkipped + 1;
            continue;
        end

        PSTH_best.(inferredType)(end+1,:) = p_best;
        PSTH_opp.(inferredType)(end+1,:)  = p_opp;

        % pick a representative trial for raster (max FR in full window)
        if ~isempty(TS_best)
            trialFRs = cellfun(@(x) numel(x)/diff(E.full), TS_best);
            [~,repIdx] = max(trialFRs);
            rasterTimes{end+1} = TS_best{repIdx};
        else
            rasterTimes{end+1} = [];
        end
        rasterTypeTag{end+1} = char(inferredType);

        nUsed = nUsed + 1;

    catch ME
        warning('Skip %s: %s', files(i).name, ME.message);
        nSkipped = nSkipped + 1;
    end
end

fprintf('Used %d neurons; skipped %d\n', nUsed, nSkipped);

%% -------- POPULATION MEAN (same structure as v22) --------
ALL_best = []; ALL_opp = [];
for t = typesOrder
    ALL_best = [ALL_best; PSTH_best.(t)];
    ALL_opp  = [ALL_opp ; PSTH_opp.(t)];
end

if isempty(ALL_best)
    error('No neurons available for plotting after filtering.');
end

m_best_all = mean(ALL_best, 1, 'omitnan');
s_best_all = std(ALL_best, [], 1, 'omitnan') / sqrt(size(ALL_best,1));
m_opp_all  = mean(ALL_opp , 1, 'omitnan');
s_opp_all  = std(ALL_opp , [], 1, 'omitnan') / sqrt(size(ALL_opp,1));

% Match Opp baseline to Best (keep your exact trick)
maskBL = (centers < 0) | (centers > 3.6);
muB = mean(m_best_all(maskBL), 'omitnan');
sdB = std(m_best_all(maskBL), [], 'omitnan');
muO = mean(m_opp_all(maskBL), 'omitnan');
sdO = std(m_opp_all(maskBL), [], 'omitnan');

if sdO > 0
    m_opp_all = (m_opp_all - muO) * (0.6 * sdB / sdO) + muB;
    s_opp_all = s_opp_all * (0.6 * sdB / sdO);
else
    m_opp_all = m_opp_all - muO + muB;
end

%% -------- FIGURE (same layout + styling) --------
fig = figure('Color','w','Position',[100 100 1200 850]);
tl = tiledlayout(5,1,'TileSpacing','tight','Padding','compact');

%% RASTER (unchanged styling)
rasterOrder = ["mixed","sacc","delay","cue"];
plotLabels  = struct('cue',"CUE",'delay',"DELAY",'sacc',"SACCADE",'mixed',"MULTIPLE");

ax1 = nexttile(tl,[3 1]); hold(ax1,'on');
row = 0; idxOrder = []; blockEdges = struct(); run = 0;

for t = rasterOrder
    idx = find(strcmpi(rasterTypeTag, char(t)));
    n = numel(idx);
    blockEdges.(char(t)) = [run+1, run+n];
    run = run + n;
    idxOrder = [idxOrder idx];
end

for t = rasterOrder
    seg = blockEdges.(char(t));
    if seg(1) <= seg(2)
        patch(ax1, [tWindow(1) tWindow(2) tWindow(2) tWindow(1)], ...
                     [seg(1)-0.5 seg(1)-0.5 seg(2)+0.5 seg(2)+0.5], ...
                     cols.(char(t)), 'FaceAlpha',0.15, 'EdgeColor','none');
        text(ax1, tWindow(1)-0.25, mean(seg), plotLabels.(char(t)), ...
             'FontWeight','bold','HorizontalAlignment','right', ...
             'Color', cols.(char(t)));
    end
end

for k = idxOrder
    row = row + 1;
    st = rasterTimes{k};
    st = st(st>=tWindow(1) & st<=tWindow(2));
    ttag = lower(string(rasterTypeTag{k}));

    plot(ax1, st, row*ones(size(st)), '.', 'MarkerSize',3.0, 'Color', grayCol);

    switch ttag
        case 'cue',   mask = (st>=E.cue(1)   & st<=E.cue(2));
        case 'delay', mask = (st>=E.delay(1) & st<=E.delay(2));
        case 'sacc',  mask = (st>=E.sacc(1)  & st<=E.sacc(2));
        case 'mixed', mask = (st>=E.cue(1)   & st<=E.sacc(2));
        otherwise,    mask = false(size(st));
    end

    plot(ax1, st(mask), row*ones(sum(mask),1), '.', 'MarkerSize',3.9, 'Color', cols.(char(ttag)));
end

xline(ax1,0,'--b'); xline(ax1,0.5,'--b'); xline(ax1,3.5,'k-');
xlim(ax1,tWindow); ylim(ax1,[0 row+1]); set(ax1,'YDir','normal');
grid(ax1,'on');
xlabel(ax1,'Time (s)'); ylabel(ax1,'Neurons');
title(ax1,'Raster (epoch-colored dots with gray background)');

%% PSTH (same look)
ax2 = nexttile(tl,[2 1]); hold(ax2,'on');
yl = [0 30];

patch(ax2,[E.cue(1)  E.cue(2)  E.cue(2)  E.cue(1)],  [yl(1) yl(1) yl(2) yl(2)], cols.cue,  'FaceAlpha',0.25,'EdgeColor','none');
patch(ax2,[E.delay(1) E.delay(2) E.delay(2) E.delay(1)], [yl(1) yl(1) yl(2) yl(2)], cols.delay,'FaceAlpha',0.25,'EdgeColor','none');
patch(ax2,[E.sacc(1) E.sacc(2) E.sacc(2) E.sacc(1)], [yl(1) yl(1) yl(2) yl(2)], cols.sacc,'FaceAlpha',0.25,'EdgeColor','none');

bestFillCol = [0 0 0];
bestAlpha   = 0.25;

fill(ax2, [centers fliplr(centers)], ...
          [m_best_all - s_best_all, fliplr(m_best_all + s_best_all)], ...
          bestFillCol, 'FaceAlpha', bestAlpha, 'EdgeColor','none');

oppFillCol = [0.6 0.6 0.6];
oppAlpha   = 0.20;

fill(ax2, [centers fliplr(centers)], ...
          [m_opp_all - s_opp_all, fliplr(m_opp_all + s_opp_all)], ...
          oppFillCol, 'FaceAlpha', oppAlpha, 'EdgeColor','none');

hBest = plot(ax2, centers, m_best_all,'Color',[0 0 0],'LineWidth',2.0);
hOpp  = plot(ax2, centers, m_opp_all,'Color',[0.4 0.4 0.4],'LineWidth',2.0,'LineStyle','--');

legend(ax2, [hBest hOpp], {'Best','Opp'}, 'Location','northeast', 'Box','off');

xline(ax2,0,'--b'); xline(ax2,0.5,'--b'); xline(ax2,3.5,'k-');
xlim(ax2,tWindow); ylim(ax2,yl); grid(ax2,'on'); ylabel(ax2,'Spikes/s');
title(ax2,'Population PSTH — Best (solid) vs Opp (dashed)');

%% SAVE
saveas(fig, fullfile(outDir,'Figure_population_minimal.png'));
fprintf('\n✅ Done: figure saved to %s\n', outDir);

%% ==================== HELPERS ====================

function pref = infer_pref_loc(C, E)
% Choose preferred location as the location (1..8) with max mean FR
% over the task window [0, 3.7] across trials.
    nLoc = min(8, numel(C.ntr));
    frLoc = nan(1,nLoc);

    for L = 1:nLoc
        block = C.ntr(L);
        if isfield(block,'ntr'), trials = block.ntr; else, trials = block; end
        if isempty(trials) || ~isstruct(trials), continue; end

        frs = [];
        for tr = 1:numel(trials)
            if ~isfield(trials(tr),'TS') || isempty(trials(tr).TS), continue; end
            ts = double(trials(tr).TS(:));
            ts = ts(ts >= E.full(1) & ts <= E.full(2));
            if isempty(ts), continue; end

            win = [0 3.7];
            dur = diff(win);
            nspk = sum(ts >= win(1) & ts < win(2));
            frs(end+1,1) = nspk / dur; %#ok<AGROW>
        end
        if ~isempty(frs)
            frLoc(L) = mean(frs,'omitnan');
        end
    end

    if all(isnan(frLoc))
        pref = 1;
    else
        [~,pref] = max(frLoc);
        if isempty(pref) || isnan(pref), pref = 1; end
    end
end

function [psth,allTS] = compute_psth_allTrials(C, loc, edges, bin, tWindow)
    psth = zeros(1, numel(edges)-1);
    allTS = {};
    if ~isfield(C,'ntr') || numel(C.ntr) < loc, psth=[]; return; end
    block = C.ntr(loc);
    if isfield(block,'ntr'), trials = block.ntr; else, trials = block; end
    if isempty(trials) || ~isstruct(trials), psth=[]; return; end

    spkAll = [];
    for tr = 1:numel(trials)
        if isfield(trials(tr),'TS') && ~isempty(trials(tr).TS)
            ts = double(trials(tr).TS(:));
            keep = ts(ts >= tWindow(1) & ts <= tWindow(2));
            if ~isempty(keep)
                spkAll = [spkAll; keep];
                allTS{end+1} = keep; %#ok<AGROW>
            end
        end
    end
    if isempty(spkAll), psth=[]; return; end

    counts = histcounts(spkAll, edges);
    psth = counts / max(1, numel(trials)) / bin; % spikes/s
end

function [FR_baseline, FR_cue, FR_delay, FR_sacc, nTrialsUsed] = compute_FR_epochs(C, loc, E)
    FR_baseline = NaN; FR_cue = NaN; FR_delay = NaN; FR_sacc = NaN; nTrialsUsed = 0;

    if ~isfield(C,'ntr') || numel(C.ntr) < loc, return; end
    block = C.ntr(loc);
    if isfield(block,'ntr'), trials = block.ntr; else, trials = block; end
    if isempty(trials) || ~isstruct(trials), return; end

    trials = trials(:);
    FR = struct('baseline',[],'cue',[],'delay',[],'sacc',[]);

    for tr = 1:numel(trials)
        if ~isfield(trials(tr),'TS') || isempty(trials(tr).TS), continue; end

        ts = double(trials(tr).TS(:));
        ts = ts(ts >= E.full(1) & ts <= E.full(2));
        if isempty(ts), continue; end
        nTrialsUsed = nTrialsUsed + 1;

        % baseline
        dur = diff(E.baseline);
        FR.baseline(end+1,1) = sum(ts >= E.baseline(1) & ts < E.baseline(2)) / dur; %#ok<AGROW>

        % cue
        dur = diff(E.cue);
        FR.cue(end+1,1)      = sum(ts >= E.cue(1) & ts < E.cue(2)) / dur; %#ok<AGROW>

        % delay (0.5–3.5)
        dur = diff(E.delay);
        FR.delay(end+1,1)    = sum(ts >= E.delay(1) & ts < E.delay(2)) / dur; %#ok<AGROW>

        % sacc
        dur = diff(E.sacc);
        FR.sacc(end+1,1)     = sum(ts >= E.sacc(1) & ts < E.sacc(2)) / dur; %#ok<AGROW>
    end

    if nTrialsUsed == 0, return; end
    FR_baseline = mean(FR.baseline,'omitnan');
    FR_cue      = mean(FR.cue,'omitnan');
    FR_delay    = mean(FR.delay,'omitnan');
    FR_sacc     = mean(FR.sacc,'omitnan');
end

function inferredType = infer_neuron_type(FR_baseline, FR_cue, FR_delay, FR_sacc, thrAbs, thrRel, minBaselineHz)
    if isnan(FR_baseline), FR_baseline = 0; end
    if isnan(FR_cue),      FR_cue      = 0; end
    if isnan(FR_delay),    FR_delay    = 0; end
    if isnan(FR_sacc),     FR_sacc     = 0; end

    baselineEff = max(FR_baseline, eps);

    dCue   = FR_cue   - baselineEff;
    dDelay = FR_delay - baselineEff;
    dSacc  = FR_sacc  - baselineEff;

    function sig = is_sig(FR_epoch, dEpoch)
        if FR_baseline < minBaselineHz
            sig = dEpoch > thrAbs;
        else
            sig = (dEpoch > thrAbs) && (FR_epoch > thrRel * FR_baseline);
        end
    end

    cueActive   = is_sig(FR_cue,   dCue);
    delayActive = is_sig(FR_delay, dDelay);
    saccActive  = is_sig(FR_sacc,  dSacc);

    nActive = cueActive + delayActive + saccActive;

    if nActive == 0
        inferredType = "none";
        return;
    elseif nActive >= 2
        inferredType = "mixed";
        return;
    end

    if cueActive
        inferredType = "cue";
    elseif delayActive
        inferredType = "delay";
    elseif saccActive
        inferredType = "sacc";
    else
        [~, idx] = max([dCue, dDelay, dSacc]);
        labels = ["cue","delay","sacc"];
        inferredType = labels(idx);
    end
end
