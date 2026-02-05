%% ================================================================
% plot_delay_tuning_compass.m
% QUIVER-BASED POLAR COMPASS
% Direction-colored arrows (45° bins)
% Fully labeled (0° = East)
% ================================================================
clear; clc; close all;

%% -------- PATHS --------
dataDir   = 'F:\Single Neuron Files\ZZZ -Final Dataset 12_8_2025\Archive';
statsFile = fullfile(dataDir, 'neuron_stats_metaOnly.mat');

if ~exist(statsFile, 'file')
    error('Cannot find stats file: %s', statsFile);
end

S = load(statsFile);
T = S.T;

fprintf("Loaded %d neurons (non-flat only)\n", height(T));

%% -------- OUTPUT FOLDER --------
polarDir = fullfile(dataDir, 'Polar Plots');
if ~exist(polarDir,'dir')
    mkdir(polarDir);
end

%% ================================================================
% SELECT DELAY + MIXED NEURONS
%% ================================================================
isDelay = strcmpi(T.neuronType,"delay");
isMixed = strcmpi(T.neuronType,"mixed");
Tsel = T(isDelay | isMixed,:);
fprintf("Delay + Mixed neurons: %d\n", height(Tsel));

%% ================================================================
% ANGLES
%% ================================================================
if any(~isnan(Tsel.prefAngleDeg))
    theta_deg = Tsel.prefAngleDeg;
else
    theta_deg = (Tsel.prefLoc - 1) * 45;
end
theta = deg2rad(theta_deg);

%% ================================================================
% HEMISPHERE FLIP (ROS ONLY)
%% ================================================================
isOLI = contains(Tsel.fileName,'OLI','IgnoreCase',true);
isROS = contains(Tsel.fileName,'ROS','IgnoreCase',true);

theta(isROS) = theta(isROS) + pi;
theta = mod(theta, 2*pi);

%% ================================================================
% MAGNITUDE = FR_delay - FR_baseline (RECTIFIED + NORMALIZED)
%% ================================================================
mag = Tsel.FR_delay - Tsel.FR_baseline;
mag(mag < 0) = 0;
mag = mag ./ max(mag + eps);

%% ================================================================
% DIRECTION-BASED COLORS (45° BINS)
%% ================================================================
colors8 = [ ...
    230  63  63;   % 0°   E
    231 188  63;   % 45°  NE
    146 231  63;   % 90°  N
     67 231 108;   % 135° NW
     63 231 231;   % 180° W
     63 104 231;   % 225° SW
    149  67 231;   % 270° S
    231  63 188];  % 315° SE
colors8 = colors8 / 255;

dirBin = floor(mod(theta + deg2rad(22.5),2*pi)/deg2rad(45)) + 1;
arrowColors = colors8(dirBin,:);

%% ================================================================
% REGION MASKS
%% ================================================================
isPFC = strcmpi(Tsel.area,'PFC');
isPPC = strcmpi(Tsel.area,'PPC');

isRightHem_PFC = isOLI & isPFC;
isLeftHem_PFC  = isROS & isPFC;
isLeftHem_PPC  = isROS & isPPC;

%% ================================================================
% OUTLIER REMOVAL
%% ================================================================
outlierMask = strcmpi(Tsel.fileName,'OLI157_1_004.mat');
isRightHem_PFC = isRightHem_PFC & ~outlierMask;
isLeftHem_PFC  = isLeftHem_PFC  & ~outlierMask;

%% ================================================================
% MAKE PLOTS
%% ================================================================
makeCompassPlot(isRightHem_PFC, theta, mag, arrowColors, ...
    'OLI PFC (Right Hemisphere — NOT Flipped)', ...
    fullfile(polarDir,'OLI_PFC.png'));

makeCompassPlot(isLeftHem_PFC, theta, mag, arrowColors, ...
    'ROS PFC (Left Hemisphere — Flipped)', ...
    fullfile(polarDir,'ROS_PFC.png'));

makeCompassPlot(isLeftHem_PPC, theta, mag, arrowColors, ...
    'ROS PPC (Left Hemisphere — Flipped)', ...
    fullfile(polarDir,'ROS_PPC.png'));

fprintf("\nDONE.\n");

%% ================================================================
%% ================================================================
function makeCompassPlot(mask, theta, mag, arrowColors, titleTxt, outFile)

    theta = theta(mask);
    mag   = mag(mask);
    arrowColors = arrowColors(mask,:);
    N = numel(theta);

    if N == 0, return; end

    meanTheta = atan2(sum(mag.*sin(theta)), sum(mag.*cos(theta)));

    jitter = deg2rad(30) * (2*rand(size(theta)) - 1);
    theta_j = theta + jitter;


    newMean = atan2(sum(mag.*sin(theta_j)), sum(mag.*cos(theta_j)));
    theta_draw = theta_j + (meanTheta - newMean);

    %% --- Cartesian ---
    x = mag .* cos(theta_draw);
    y = mag .* sin(theta_draw);

    %% --- Population vector ---
    meanX = mean(mag .* cos(theta));
    meanY = mean(mag .* sin(theta));

    %% --- Figure ---
    fig = figure('Color','w','Position',[300 200 750 750]);
    hold on; axis equal;

    %% --- Neuron arrows ---
    for i = 1:N
        quiver(0,0,x(i),y(i),0, ...
            'Color',arrowColors(i,:), ...
            'LineWidth',4, ...
            'MaxHeadSize',0.35);
    end

    %% --- Population arrow ---
    quiver(0,0,meanX,meanY,0, ...
        'Color','k','LineWidth',8,'MaxHeadSize',0.6);


    %% --- Resultant direction (degrees, 0° = East) ---
    resultantTheta = atan2(meanY, meanX);           % radians
    resultantDeg   = mod(rad2deg(resultantTheta),360);

    fprintf('Resultant direction: %.1f° (0° = East, CCW), n = %d\n', ...
    resultantDeg, N);


    %% ============================================================
    % POLAR GRID + LABELS
    %% ============================================================
    lim = max(mag)*1.15;
    th = linspace(0,2*pi,400);

    for r = 0.1:0.1:0.5
        plot(r*cos(th), r*sin(th), 'Color',[0.85 0.85 0.85]);
    end

    for ang = 0:45:315
        plot([0 lim*cosd(ang)], [0 lim*sind(ang)], 'Color',[0.85 0.85 0.85]);
    end

    plot(lim*cos(th), lim*sin(th), 'k', 'LineWidth',1.5);

    xlim([-lim lim]); ylim([-lim lim]); axis off
end
