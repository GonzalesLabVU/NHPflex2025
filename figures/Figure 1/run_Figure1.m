%% EIS_nature_style_matched_axes.m
%
%
% Figure layout:
%   Left column:
%       Top    – Impedance magnitude (|Z|) vs frequency (log–log)
%       Bottom – Phase vs frequency (log-x)
%   Right column:
%       Scatter of 1 kHz impedance values across electrodes
%
% Data handling:
%   - All spectra are pooled together (single material)
%   - Mean ± SEM is shown for impedance and phase
%   - Channel-to-channel variability at 1 kHz is quantified
%
% Axes constraints:
%   - Frequency range fixed to 10^1–10^4 Hz for BOTH impedance and phase
%   - Phase axis fixed to −180° to 0°
%
% Output:
%   - SVG only, 600 dpi
%

clear; clc; close all;

%% ------------------ LOAD EIS DATA ------------------
% Select folder containing Gamry .dta files
dataFolder = uigetdir(pwd,'Select folder with Gamry .dta files');
files = dir(fullfile(dataFolder,'*.dta'));
assert(~isempty(files),'No .dta files found in selected folder.');

% Containers for pooled data
Zall  = [];   % impedance magnitude
PHall = [];   % phase
freq  = [];   % frequency vector (assumed identical across files)

% Read each file and stack data
for k = 1:numel(files)
    [f, Z, PH] = readGamry_minimal(fullfile(dataFolder,files(k).name));

    % Store frequency vector from first file
    if isempty(freq)
        freq = f(:)';
    end

    Zall  = [Zall;  Z(:)'];
    PHall = [PHall; PH(:)'];
end

%% ------------------ FREQUENCY WINDOW ------------------
% Match reference figure frequency range exactly
fmin = 1e1;
fmax = 1e4;

freqMask = freq >= fmin & freq <= fmax;
freqPlot = freq(freqMask);

% Restrict all data to the selected frequency window
Zall  = Zall(:,freqMask);
PHall = PHall(:,freqMask);

%% ------------------ SUMMARY STATISTICS ------------------
% Mean and SEM across channels at each frequency
meanZ  = mean(Zall,1);
semZ   = std(Zall,[],1)

meanPH = mean(PHall,1);
semPH  = std(PHall,[],1)

% Extract impedance at ~1 kHz
[~,idx1k] = min(abs(freqPlot - 1e3));
Z1k = Zall(:,idx1k);   % Ohms

% Channel-to-channel variability metrics at 1 kHz
meanZ1k = mean(Z1k);
stdZ1k  = std(Z1k);
semZ1k  = stdZ1k / sqrt(numel(Z1k));
cvZ1k   = (stdZ1k / meanZ1k) * 100;

% Print variability statistics to command window
fprintf('\nChannel-to-channel variability at 1 kHz:\n');
fprintf('Mean |Z| : %.2f kOhm\n', meanZ1k/1e3);
fprintf('SD        : %.2f kOhm\n', stdZ1k/1e3);
fprintf('SEM       : %.2f kOhm\n', semZ1k/1e3);
fprintf('CV        : %.2f %%\n', cvZ1k);

%% ------------------ FIGURE SETUP ------------------
% Create figure canvas with fixed physical size
fig = figure('Color','w');
set(fig,'Units','inches','Position',[1 1 10 5]);

% Manually position axes to match reference layout
axMag   = axes('Position',[0.08 0.55 0.55 0.38]); hold on;
axPhase = axes('Position',[0.08 0.12 0.55 0.38]); hold on;
axScat  = axes('Position',[0.70 0.12 0.25 0.80]); hold on;

%% ------------------ IMPEDANCE PANEL ------------------
axes(axMag)

% Shaded SEM envelope
fill([freqPlot fliplr(freqPlot)], ...
     [meanZ-semZ fliplr(meanZ+semZ)], ...
     [0.95 0.85 0.55], ...
     'EdgeColor','none','FaceAlpha',0.45);

% Mean impedance trace
loglog(freqPlot, meanZ, ...
       'Color',[0.9 0.6 0.0], ...
       'LineWidth',2);

% Axis formatting
set(gca,'XScale','log','YScale','log');
xlim([fmin fmax]);
ylabel('Impedance (\Omega)');
title('Impedance');

grid on;
xline(1e3,'--k','LineWidth',1);   % 1 kHz reference
niceAxes(gca);

% Hide x tick labels (shared with phase panel)
set(gca,'XTickLabel',[]);

%% ------------------ PHASE PANEL ------------------
axes(axPhase)

% Shaded SEM envelope
fill([freqPlot fliplr(freqPlot)], ...
     [meanPH-semPH fliplr(meanPH+semPH)], ...
     [0.95 0.85 0.55], ...
     'EdgeColor','none','FaceAlpha',0.45);

% Mean phase trace
semilogx(freqPlot, meanPH, ...
          'Color',[0.9 0.6 0.0], ...
          'LineWidth',2);

% Axis formatting
set(gca,'XScale','log');
xlim([fmin fmax]);      % Explicitly match impedance panel
ylim([-180 0]);
yticks([-180 -135 -90 -45 0]);

xlabel('Frequency (Hz)');
ylabel('Phase (°)');

grid on;
xline(1e3,'--k','LineWidth',1);
niceAxes(gca);

%% ------------------ 1 kHz SCATTER PANEL ------------------
axes(axScat)

% Individual electrode values
scatter(ones(size(Z1k)), Z1k/1e3, ...
    55, [0.9 0.6 0.0], ...
    'filled', 'MarkerFaceAlpha',0.5);

% Mean ± SD
errorbar(1, meanZ1k/1e3, stdZ1k/1e3, ...
    'k','LineWidth',2,'CapSize',10);


% Axis formatting
xlim([0.6 1.4]);
set(gca,'XTick',1,'XTickLabel',{'Electrodes'});
ylabel('1 kHz Impedance (k\Omega)');

grid on;
niceAxes(gca);

%% ------------------ EXPORT ------------------
% Save as SVG only (600 dpi)
print(fig, fullfile(dataFolder,'EIS_nature_style_matched_axes.svg'), ...
      '-dsvg','-r600');

fprintf('\nFigure saved: EIS_nature_style_matched_axes.svg\n');

%% =====================================================================
% Helper functions
%% =====================================================================

function [freq, Zmod, Zphz] = readGamry_minimal(fname)
    % Minimal Gamry .dta reader for EIS magnitude and phase

    fid = fopen(fname,'r');
    txt = textscan(fid,'%s','Delimiter','\n');
    fclose(fid);
    txt = txt{1};

    idx = find(contains(txt,'CURVE'),1,'last');

    h1 = strsplit(txt{idx+1},char(9));
    h2 = strsplit(txt{idx+2},char(9));

    names = cellfun(@(a,b) matlab.lang.makeValidName([a '_' b]), ...
                    h1,h2,'UniformOutput',false);

    data = txt(idx+3:end);
    data = data(~cellfun('isempty',regexp(data,'[-+0-9]')));

    M = cell2mat(cellfun(@(x) sscanf(x,'%f')',data,'UniformOutput',false));
    T = array2table(M,'VariableNames',names);

    freq = T{:,contains(names,'Freq')};
    Zmod = T{:,contains(names,'Zmod')};
    Zphz = T{:,contains(names,'Zphz')};
end

function niceAxes(ax)
    % Standardized axis styling for publication figures
    set(ax,'Box','off','LineWidth',1.2,'FontSize',10,'TickDir','out');
end
