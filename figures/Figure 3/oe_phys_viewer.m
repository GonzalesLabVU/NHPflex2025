function oe_phys_viewer
%% =============================================================
%   STEP 1 — SELECT RECORDINGS ONE BY ONE
% =============================================================
defaultStructPath = 'F:\Gonzales Lab Recordings\Wilson Hall NHP';

oebinList = {};
while true
    [f,p] = uigetfile(fullfile(defaultStructPath,'*.oebin'), ...
                      'Select a structure.oebin (Cancel to finish)');
    if isequal(f,0), break; end
    oebinList{end+1} = fullfile(p,f);
end

if isempty(oebinList)
    disp('No recordings selected.');
    return;
end

nRecs = numel(oebinList);

%% =============================================================
%   STEP 2 — LOAD EACH RECORDING (ULTRA FAST)
% =============================================================
Recordings = cell(nRecs,1);

for r = 1:nRecs
    fprintf('\n=== Loading Recording %d/%d ===\n', r, nRecs);

    oebinFile = oebinList{r};
    oePath = fileparts(oebinFile);

    D = load_open_ephys_binary(oebinFile,'continuous',1,'mmap');
    Fs  = D.Header.sample_rate;
    nChan = D.Header.num_channels;

    CF = fullfile(oePath,'continuous',D.Header.folder_name);
    rawMap = D.Data.Data.mapped;
    nSamples = size(rawMap,2);

    % Window selection
    answ = inputdlg({['Start time for recording ' num2str(r) ' (s):'], ...
                     ['Duration (s):']}, ...
                     sprintf('Recording %d Window',r),1,{'0','3'});
    t0  = str2double(answ{1});
    dur = str2double(answ{2});

    startIdx = max(1, round(t0*Fs));
    endIdx   = min(nSamples, round((t0+dur)*Fs));

    fprintf('Extracting %d → %d samples via mmap...\n', startIdx, endIdx);

    % FAST SLICE ONLY WINDOW
    raw = single(rawMap(:, startIdx:endIdx));

    % FAST FILTER (no filtfilt)
    [b,a] = butter(3,[300 6000]/(Fs/2),'bandpass');
    filt = filter(b,a,raw')';

    Recordings{r}.Fs   = Fs;
    Recordings{r}.raw  = raw;
    Recordings{r}.filt = filt;
    Recordings{r}.t_ms = (0:size(filt,2)-1)./Fs * 1000;
    Recordings{r}.nChan = nChan;
    Recordings{r}.startIdx = startIdx;
    Recordings{r}.endIdx   = endIdx;
end

%% =============================================================
%   STEP 3 — SELECT MULTIPLE KS FOLDERS ONE BY ONE
% =============================================================
ksDefault = 'F:\KS-out\ks4';

KSfolders = {};
while true
    ksDir = uigetdir(ksDefault,'Select Kilosort folder (Cancel to finish)');
    if ksDir==0, break; end
    KSfolders{end+1} = ksDir;
end

if isempty(KSfolders)
    disp('No KS selected.');
    return;
end

%% =============================================================
%   STEP 4 — LOAD ALL KS UNITS
% =============================================================
AllUnits = [];
uCount = 1;

fprintf('\n=== Loading KS units ===\n');

for k = 1:numel(KSfolders)
    ksPath = KSfolders{k};
    fprintf('\nLoading %s\n', ksPath);

    st = readNPY(fullfile(ksPath,'spike_times.npy'));  % 0-based
    sc = readNPY(fullfile(ksPath,'spike_clusters.npy'));
    T  = readNPY(fullfile(ksPath,'templates.npy'));

    cluList = unique(sc);

    for c = 1:numel(cluList)
        clu = cluList(c);
        inds = double(st(sc==clu)) + 1;

        AllUnits(uCount).cluster_id = clu;
        AllUnits(uCount).inds       = inds;
        AllUnits(uCount).count      = numel(inds);
        AllUnits(uCount).template   = squeeze(T(clu+1,:,:));
        AllUnits(uCount).ks_folder  = ksPath;

        uCount = uCount + 1;
    end
end

% Convert spike times → sec
Fs_global = Recordings{1}.Fs;
for i = 1:numel(AllUnits)
    AllUnits(i).t_sec = AllUnits(i).inds ./ Fs_global;
end

%% =============================================================
%   STEP 5 — FAST PHY-STYLE AUTOCORR
% =============================================================
    function [centers, ac] = fastACG(st)
        if numel(st) < 2
            centers = []; ac = []; return;
        end

        maxLag = 0.05;  % ±50 ms
        bin = 0.001;

        spikeBins = round(st/bin);
        bounds = (min(spikeBins)-1):(max(spikeBins)+1);
        histVec = histcounts(spikeBins,bounds);

        xc = conv(histVec, fliplr(histVec));
        mid = ceil(numel(xc)/2);
        halfBins = round(maxLag/bin);

        ac = xc(mid-halfBins : mid+halfBins);
        centers = linspace(-maxLag, maxLag, numel(ac));

        ac = ac - mean(ac);
    end

%% =============================================================
%   STEP 6 — PANEL f FIGURE FOR RECORDING 1
% =============================================================
Rec = Recordings{1};
trace = double(Rec.filt(10,:));  % example channel

% noise
noiseMAD = median(abs(trace - median(trace))) / 0.6745;
noiseSD  = noiseMAD;

thr4 = -4 * noiseSD;
thr6 = -6 * noiseSD;

spikeIx = find(trace < thr4);

figure('Name','Panel f','Position',[200 200 1600 500])
hold on;
plot(Rec.t_ms, trace, 'k');
yline(thr4,'r--','LineWidth',1.5);
yline(thr6,'b--','LineWidth',1.5);
plot(Rec.t_ms(spikeIx), trace(spikeIx), 'g.', 'MarkerSize', 8);
xlabel('Time (ms)'); ylabel('Amplitude (µV)');
title('Filtered Neural Signal');

% inset
inset = axes('Position',[0.18 0.15 0.20 0.28]); hold(inset,'on'); box(inset,'on');
colors = lines(3);
SNRs = zeros(3,1);

for u = 1:min(3,numel(AllUnits))
    wfAll = AllUnits(u).template;
    [~,peak] = max(max(abs(wfAll),[],1));
    wf = wfAll(:,peak);

    % snr
    SNRs(u) = (max(wf)-min(wf)) / noiseSD;

    plot(inset, wf, 'Color', colors(u,:), 'LineWidth', 2);
end

xlabel(inset,'Samples'); ylabel(inset,'µV');
text(inset, 0.05,0.05, sprintf('SNR_{Max} = %.2f ± %.2f', mean(SNRs), std(SNRs)), ...
     'Units','normalized');

%% =============================================================
%   STEP 7 — PANEL d/e STYLE PER-UNIT FIGURES
% =============================================================
maxChToShow = 8;
maxWavesPerChan = 300;
grayColor = [0.8 0.8 0.8];

for i = 1:numel(AllUnits)
    st_global = AllUnits(i).inds;
    st_win = st_global - Rec.startIdx + 1;

    halfWin = round(0.001 * Fs_global);
    valid = st_win > halfWin & st_win < (size(Rec.filt,2) - halfWin);
    st_val = st_win(valid);

    wfAll = AllUnits(i).template;
    p2p = max(wfAll)-min(wfAll);
    [~,idxSort] = sort(p2p,'descend');
    topCh = idxSort(1:min(maxChToShow, numel(idxSort)));

    figure('Name',sprintf('Unit %d',AllUnits(i).cluster_id), ...
           'Position',[100 100 1500 500]);

    % ========== PANEL d (Left): Multi-channel waveform ==========
    subplot(1,3,1); hold on;
    chanSpacing = 5 * max(p2p(topCh));
    tRel = ((-halfWin:halfWin)/Fs_global)*1000;

    for chIdx = 1:numel(topCh)
        ch = topCh(chIdx);
        offset = chanSpacing*(chIdx-1);

        if ~isempty(st_val)
            nS = numel(st_val);
            nTake = min(maxWavesPerChan, nS);
            useIdx = st_val(round(linspace(1,nS,nTake)));

            W = zeros(numel(tRel), nTake,'single');
            for k = 1:nTake
                center = useIdx(k);
                W(:,k) = Rec.filt(ch,center-halfWin:center+halfWin);
            end

            for k = 1:nTake
                plot(tRel, double(W(:,k)) + offset, ...
                     'Color', grayColor, 'LineWidth',0.3);
            end

            meanW = mean(double(W),2);
        else
            meanW = wfAll(:,ch);
            if numel(meanW) ~= numel(tRel)
                meanW = interp1(1:numel(meanW), meanW, ...
                    linspace(1,numel(meanW),numel(tRel)),'linear','extrap');
            end
        end

        plot(tRel, meanW + offset, 'LineWidth',2);
        text(tRel(end)+0.2, offset, sprintf('Ch %d',ch));
    end
    xlabel('Time (ms)'); ylabel('Channels'); title('Unit Waveforms'); set(gca,'YTick',[]);

    % ========== PANEL e (Middle): ISI histogram ==========
    subplot(1,3,2); hold on;
    st_times = AllUnits(i).t_sec;
    if numel(st_times)>1
        isis = diff(st_times)*1000;
        h = histogram(isis,0:1:100);
        h.EdgeColor='none'; h.FaceAlpha=0.7;
    else
        text(.3,.5,'Not enough spikes'); 
    end
    xlabel('ISI (ms)'); ylabel('Count');
    title(sprintf('n = %d',AllUnits(i).count));

    % ========== PANEL e (Right): ACG ==========
    subplot(1,3,3); hold on;
    [centers, ac] = fastACG(st_times);
    if isempty(ac)
        text(.3,.5,'No ACG');
    else
        bar(centers, ac, 1,'k','EdgeColor','none');
        xlim([-0.05 0.05]);
    end
    xlabel('Lag (s)'); ylabel('Counts'); title('Autocorr');
end

end
