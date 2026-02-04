function ks_template_browser
% =========================================================================
%   KILOSORT TEMPLATE / ISI / AUTOCORR BROWSER (NO RAW .DAT)
%   • Loads only Kilosort outputs (KS2.5 / KS4)
%   • Displays template waveform (best channel)
%   • Displays ISI histogram
%   • Displays autocorrelogram (±50 ms)
%   • Clusters sorted by spike count (descending)
%   • Prev / Next navigation + dropdown + arrow keys
%   • Save current cluster or save all
% =========================================================================

clc; close all;

%% ============================================================
%   SELECT KS FOLDER (default directory)
%% ============================================================
ks_dir = uigetdir('F:\KS-out\ks4', 'Select Kilosort Output Folder');
if ks_dir == 0
    disp('Cancelled.');
    return;
end

%% ============================================================
%   LOAD KILOSORT FILES
%% ============================================================
fprintf("\nLoading Kilosort data from: %s\n", ks_dir);

st = readNPY(fullfile(ks_dir,'spike_times.npy'));        % spike sample indices
sc = readNPY(fullfile(ks_dir,'spike_clusters.npy'));     % cluster IDs
templates = readNPY(fullfile(ks_dir,'templates.npy'));   % [nUnits x T x nChan]

% Load FS + template length
ops = load_params_from_ks(ks_dir, size(templates,2));
Fs  = ops.fs;

% Convert spike times to seconds
t_sec = double(st) / Fs;

clusters   = unique(sc);
nClusters  = numel(clusters);

fprintf("Found %d clusters.\nSorting by spike count...\n", nClusters);

%% ============================================================
%   SORT CLUSTERS BY SPIKE COUNT (DESCENDING)
%% ============================================================
spikeCounts = arrayfun(@(c) sum(sc == c), clusters);
[spikeCounts, sortIdx] = sort(spikeCounts, 'descend');
clusters = clusters(sortIdx);

% Precompute per-cluster spike times in sorted order
ClusterSpikes = cell(nClusters,1);
for i = 1:nClusters
    cid = clusters(i);
    ClusterSpikes{i} = t_sec(sc == cid);
end

% Compute best channel for sorted clusters
best_channels = compute_best_channels(templates);
best_channels = best_channels(sorted_index_mapping(sortIdx));

%% ============================================================
%   GUI SETUP
%% ============================================================
fig = figure('Name','KS Template Browser (Sorted by Spike Count)',...
             'NumberTitle','off',...
             'Position',[200 100 1500 850],...
             'Color','w');

axWF  = axes('Parent',fig,'Position',[0.07 0.58 0.40 0.40]); % waveform
axISI = axes('Parent',fig,'Position',[0.55 0.58 0.40 0.40]); % ISI
axACG = axes('Parent',fig,'Position',[0.30 0.10 0.40 0.35]); % ACG

uicontrol(fig,'Style','pushbutton','String','◀ Prev','FontSize',12,...
    'Position',[50 20 110 45],'Callback',@prev_cluster);

uicontrol(fig,'Style','pushbutton','String','Next ▶','FontSize',12,...
    'Position',[170 20 110 45],'Callback',@next_cluster);

uicontrol(fig,'Style','text','String','Cluster','FontSize',11,...
    'BackgroundColor','w','Position',[310 55 100 20]);

popup = uicontrol(fig,'Style','popupmenu',...
    'String', cellstr( string(clusters) ),...
    'FontSize',11,...
    'Position',[305 25 120 30],...
    'Callback',@select_cluster);

uicontrol(fig,'Style','pushbutton','String','Save Current','FontSize',11,...
    'Position',[470 20 140 45],...
    'Callback', @save_current);

uicontrol(fig,'Style','pushbutton','String','Save All','FontSize',11,...
    'Position',[620 20 140 45],...
    'Callback', @save_all);

infoBox = uicontrol(fig,'Style','text','String','',...
    'FontSize',12,'BackgroundColor','w',...
    'Position',[780 5 500 70],...
    'HorizontalAlignment','left');

set(fig,'KeyPressFcn', @key_nav);

current_idx = 1;

update_display();


%% ============================================================
%   UPDATE DISPLAY
%% ============================================================
    function update_display()

        cid    = clusters(current_idx);
        spikes = ClusterSpikes{current_idx};

        %% ---------- TEMPLATE WAVEFORM ----------
        axes(axWF); cla(axWF); hold(axWF,'on');

        tpl = squeeze(templates(cid+1,:,:));     % [T x nChan]

        best_ch = best_channels(current_idx) + 1; % 1-based
        wf = tpl(:, best_ch);

        t = (0:length(wf)-1) / Fs * 1000;

        % Plot all channels faintly
        for ch = 1:size(tpl,2)
            plot(axWF, t, tpl(:,ch), 'Color',[0.7 0.7 0.7 0.3]);
        end

        % highlight best channel
        plot(axWF, t, wf, 'LineWidth',3, 'Color',[0 0.3 0.9]);

        xlabel(axWF,'Time (ms)');
        ylabel(axWF,'Amplitude');
        title(axWF, sprintf('Template — Cluster %d (Rank %d / %d)', ...
            cid, current_idx, nClusters));

        %% ---------- ISI ----------
        axes(axISI); cla(axISI);
        if numel(spikes) > 2
            isi = diff(spikes) * 1000;
            histogram(axISI, isi, 0:1:100, ...
                'FaceColor',[0.5 0.5 1], 'EdgeColor','none');
            xlabel(axISI,'ISI (ms)');
            ylabel(axISI,'Count');
            title(axISI,'ISI Distribution');
        else
            text(0.5,0.5,'Not enough spikes','HorizontalAlignment','center');
        end

        %% ---------- AUTOCORR ----------
        axes(axACG); cla(axACG);
        [centers, ac] = fast_acg(spikes);

        if ~isempty(ac)
            bar(axACG, centers, ac, 1, 'k', 'EdgeColor','none');
            xlim(axACG, [-0.05 0.05]);
        else
            text(0.5,0.5,'Not enough spikes','HorizontalAlignment','center');
        end

        xlabel(axACG,'Lag (s)');
        ylabel(axACG,'Count');
        title(axACG,'Autocorrelogram');

        %% ---------- INFO ----------
        infoBox.String = sprintf( ...
            'Cluster ID: %d\nRank: %d / %d (sorted by spike count)\nSpikes: %d', ...
            cid, current_idx, nClusters, numel(spikes) );

        popup.Value = current_idx;
    end

%% ============================================================
%   AUTOCORRELOGRAM
%% ============================================================
function [centers, ac] = fast_acg(st)
    if numel(st) < 2
        centers = [];
        ac = [];
        return;
    end
    bin    = 0.001;
    maxLag = 0.05;

    bins   = round(st / bin);
    counts = histcounts(bins, min(bins)-1:max(bins)+1);

    xc  = conv(counts, fliplr(counts));
    mid = ceil(numel(xc)/2);
    hl  = round(maxLag/bin);

    ac      = xc(mid-hl : mid+hl);
    centers = linspace(-maxLag, maxLag, numel(ac));
    ac      = ac - mean(ac);
end

%% ============================================================
%   KS PARAM LOADER
%% ============================================================
function ops = load_params_from_ks(ks_dir, tpl_len)
    ops.fs = 30000;
    ops.nt = tpl_len;

    params = fullfile(ks_dir,'params.py');
    if exist(params,'file')
        txt = fileread(params);
        ops.fs = extract_val(txt,'sample_rate',ops.fs);
        ops.nt = extract_val(txt,'n_samples_template',ops.nt);
    end
end

function v = extract_val(txt,patt,def)
    r = regexp(txt,[patt '\s*=\s*([\d\.]+)'],'tokens');
    if isempty(r)
        v = def;
    else
        v = str2double(r{1}{1});
    end
end

%% ============================================================
%   BEST CHANNEL SELECTION
%% ============================================================
function best_ch = compute_best_channels(templates)
    amp = squeeze(max(templates,[],2) - min(templates,[],2));
    [~, best_ch] = max(amp, [], 2);
    best_ch = best_ch - 1; % KS style 0-based
end

%% ============================================================
%   REORDER BEST CHANNELS TO MATCH SORTED CLUSTER ORDER
%% ============================================================
function reordered = sorted_index_mapping(sortIdx)
    reordered = sortIdx;  % identity mapping here since templates are aligned
end

%% ============================================================
%   NAVIGATION
%% ============================================================
    function prev_cluster(~,~)
        if current_idx > 1
            current_idx = current_idx - 1;
            update_display();
        end
    end

    function next_cluster(~,~)
        if current_idx < nClusters
            current_idx = current_idx + 1;
            update_display();
        end
    end

    function select_cluster(src,~)
        current_idx = src.Value;
        update_display();
    end

    function key_nav(~,evt)
        switch evt.Key
            case {'leftarrow','uparrow'}
                prev_cluster();
            case {'rightarrow','downarrow','space'}
                next_cluster();
        end
    end

%% ============================================================
%   SAVE FUNCTIONS
%% ============================================================
    function save_current(~,~)
        cid = clusters(current_idx);
        outDir = fullfile(ks_dir,'KS_TemplatePlots');
        if ~exist(outDir,'dir'), mkdir(outDir); end
        fname = fullfile(outDir,sprintf('cluster_%03d.png',cid));
        exportgraphics(fig,fname,'Resolution',200);
        fprintf('Saved %s\n',fname);
    end

    function save_all(~,~)
        outDir = fullfile(ks_dir,'KS_TemplatePlots_All');
        if ~exist(outDir,'dir'), mkdir(outDir); end

        h = waitbar(0,'Saving all clusters...');
        for i = 1:nClusters
            current_idx = i;
            update_display();
            cid = clusters(i);
            fname = fullfile(outDir, sprintf('cluster_%03d.png',cid));
            exportgraphics(fig,fname,'Resolution',200);
            waitbar(i/nClusters,h);
        end
        close(h);

        fprintf("Saved all %d templates.\n", nClusters);
    end

end
