function run_all_figures()
scripts = {
    @reproduce_Fig1B
    @reproduce_Fig3H
    @reproduce_Fig4
    @reproduce_Fig5
    @reproduce_FigS2
    @reproduce_FigS4
    @reproduce_FigS7
    @reproduce_FigS8
    };

for i = 1:numel(scripts)
    close all;
    feval(scripts{i});
end
end
