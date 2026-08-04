function drawBox(ax,x0,y,color,boxWidth)
y = y(isfinite(y));
q = quantile(y,[0.25 0.50 0.75]);
iqrVal = q(3) - q(1);
loVals = y(y >= q(1) - 1.5 * iqrVal);
hiVals = y(y <= q(3) + 1.5 * iqrVal);

if isempty(loVals)
    lo = min(y);
else
    lo = min(loVals);
end

if isempty(hiVals)
    hi = max(y);
else
    hi = max(hiVals);
end

half = boxWidth / 2;
patch(ax,[x0-half x0+half x0+half x0-half],[q(1) q(1) q(3) q(3)], ...
    color,'FaceAlpha',0.25,'EdgeColor','k','LineWidth',1.1);
plot(ax,[x0-half x0+half],[q(2) q(2)],'k-','LineWidth',1.2);
plot(ax,[x0 x0],[lo q(1)],'k-','LineWidth',1.0);
plot(ax,[x0 x0],[q(3) hi],'k-','LineWidth',1.0);
plot(ax,[x0-0.11 x0+0.11],[lo lo],'k-','LineWidth',1.0);
plot(ax,[x0-0.11 x0+0.11],[hi hi],'k-','LineWidth',1.0);
end
