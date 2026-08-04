function drawBoxWithBounds(ax,x0,y,color,boxWidth,lo,hi)
y = y(isfinite(y));
q = quantile(y,[0.25 0.50 0.75]);
half = boxWidth / 2;
patch(ax,[x0-half x0+half x0+half x0-half],[q(1) q(1) q(3) q(3)], ...
    color,'FaceAlpha',0.28,'EdgeColor','k','LineWidth',1.15);
plot(ax,[x0-half x0+half],[q(2) q(2)],'k-','LineWidth',1.3);
plot(ax,[x0 x0],[lo q(1)],'k-','LineWidth',1.0);
plot(ax,[x0 x0],[q(3) hi],'k-','LineWidth',1.0);
plot(ax,[x0-0.11 x0+0.11],[lo lo],'k-','LineWidth',1.0);
plot(ax,[x0-0.11 x0+0.11],[hi hi],'k-','LineWidth',1.0);
end
