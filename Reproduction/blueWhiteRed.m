function cmap = blueWhiteRed(n)
if nargin < 1
    n = 256;
end
half = floor(n / 2);
blue = [linspace(0.10,1,half)' linspace(0.25,1,half)' ones(half,1)];
red = [ones(n-half,1) linspace(1,0.20,n-half)' linspace(1,0.15,n-half)'];
cmap = [blue; red];
end
