function reproduce_Fig5()
clear; clc;
setupFigureDefaults();

TRep = loadSourceSheet("Fig5B_S9_S10_psth_cell_type");
TPop = loadSourceSheet("Fig5D_PSTH_population");

bestColor = [0.86 0.30 0.24];
oppColor = [0.22 0.47 0.72];
shadeBest = [0.96 0.72 0.68];
shadeOpp = [0.70 0.82 0.94];
cueOn = 0.0;
cueOff = 0.5;
delayEnd = 3.5;
saccadeEnd = 3.7;

timeRep = double(TRep.time_s);
cells = [
    struct('id',"ROS198_1_006",'type',"DELAY",'best',"ROS198_1_006_DELAY_best_psth_hz",'opp',"ROS198_1_006_DELAY_opp_psth_hz")
    struct('id',"ROS198_1_024",'type',"MIX",'best',"ROS198_1_024_MIX_best_psth_hz",'opp',"ROS198_1_024_MIX_opp_psth_hz")
    struct('id',"ROS201_1_039",'type',"SACC",'best',"ROS201_1_039_SACC_best_psth_hz",'opp',"ROS201_1_039_SACC_opp_psth_hz")
    struct('id',"OLI158_1_005",'type',"CUE",'best',"OLI158_1_005_CUE_best_psth_hz",'opp',"OLI158_1_005_CUE_opp_psth_hz")
    ];

figB = figure('Color','w','Units','inches','Position',[1 1 9.2 6.6]);
tl = tiledlayout(figB,2,2,'TileSpacing','compact','Padding','compact');
for i = 1:numel(cells)
    ax = nexttile(tl,i);
    hold(ax,'on');
    best = double(TRep.(cells(i).best));
    opp = double(TRep.(cells(i).opp));
    shadeTaskEpochs(ax,cueOn,cueOff,delayEnd,saccadeEnd);
    plot(ax,timeRep,best,'Color',bestColor,'LineWidth',1.8);
    plot(ax,timeRep,opp,'Color',oppColor,'LineWidth',1.8);
    xline(ax,cueOn,'k-','LineWidth',0.8);
    xline(ax,cueOff,'k-','LineWidth',0.8);
    xline(ax,delayEnd,'k-','LineWidth',0.8);
    xline(ax,saccadeEnd,'k-','LineWidth',0.8);
    xlim(ax,[min(timeRep) max(timeRep)]);
    ylim(ax,[0 1.12 * max([best; opp],[],'omitnan')]);
    xlabel(ax,'Time from cue onset (s)');
    ylabel(ax,'Firing rate (Hz)');
    title(ax,sprintf('%s (%s)',cells(i).id,cells(i).type),'Interpreter','none');
    grid(ax,'on');
    styleAxes(ax);
    if i == 1
        legend(ax,{'Best direction','Opposite direction'},'Location','northwest','Box','off');
    end
end
annotation(figB,'textbox',[0.005 0.94 0.04 0.04],'String','B','LineStyle','none', ...
    'FontSize',14,'FontWeight','bold','HorizontalAlignment','left','VerticalAlignment','top');
exportFigure(figB,'Fig5B_representative_cell_PSTHs');

timePop = double(TPop.Time_s);
bestMean = double(TPop.Best_mean_Hz);
bestLo = double(TPop.Best_minus_SEM_Hz);
bestHi = double(TPop.Best_plus_SEM_Hz);
oppMean = double(TPop.Opp_mean_Hz);
oppLo = double(TPop.Opp_minus_SEM_Hz);
oppHi = double(TPop.Opp_plus_SEM_Hz);

figD = figure('Color','w','Units','inches','Position',[1 1 6.2 4.8]);
axD = axes('Position',[0.14 0.16 0.80 0.76]);
hold(axD,'on');
shadeTaskEpochs(axD,cueOn,cueOff,delayEnd,saccadeEnd);
fill(axD,[timePop; flipud(timePop)],[bestLo; flipud(bestHi)],shadeBest,'EdgeColor','none','FaceAlpha',0.45);
fill(axD,[timePop; flipud(timePop)],[oppLo; flipud(oppHi)],shadeOpp,'EdgeColor','none','FaceAlpha',0.45);
plot(axD,timePop,bestMean,'Color',bestColor,'LineWidth',2.0);
plot(axD,timePop,oppMean,'Color',oppColor,'LineWidth',2.0);
xline(axD,cueOn,'k-','LineWidth',0.8);
xline(axD,cueOff,'k-','LineWidth',0.8);
xline(axD,delayEnd,'k-','LineWidth',0.8);
xline(axD,saccadeEnd,'k-','LineWidth',0.8);
xlabel(axD,'Time from cue onset (s)');
ylabel(axD,'Population firing rate (Hz)');
xlim(axD,[min(timePop) max(timePop)]);
ylim(axD,[0 1.08 * max(bestHi,[],'omitnan')]);
grid(axD,'on');
styleAxes(axD);
legend(axD,{'Best direction SEM','Opposite direction SEM','Best direction','Opposite direction'}, ...
    'Location','northwest','Box','off');
text(axD,-0.15,1.05,'D','Units','normalized','FontSize',14,'FontWeight','bold');
exportFigure(figD,'Fig5D_population_PSTH');
end

function shadeTaskEpochs(ax,cueOn,cueOff,delayEnd,saccadeEnd)
yl = [0 1];
patch(ax,[cueOn cueOff cueOff cueOn],[yl(1) yl(1) yl(2) yl(2)],[0.92 0.92 0.92], ...
    'EdgeColor','none','FaceAlpha',0.35,'HandleVisibility','off');
patch(ax,[cueOff delayEnd delayEnd cueOff],[yl(1) yl(1) yl(2) yl(2)],[0.97 0.97 0.97], ...
    'EdgeColor','none','FaceAlpha',0.25,'HandleVisibility','off');
patch(ax,[delayEnd saccadeEnd saccadeEnd delayEnd],[yl(1) yl(1) yl(2) yl(2)],[0.88 0.88 0.88], ...
    'EdgeColor','none','FaceAlpha',0.35,'HandleVisibility','off');
uistack(findobj(ax,'Type','line'),'top');
end
