# Figure Reproduction Scripts

This folder contains MATLAB scripts to reproduce each figure (1–5) and supplementary figures from the manuscript.

## Structure

Each figure has a dedicated subfolder:
- `fig1/`: scripts and data for Figure 1
- `fig2/`: scripts and data for Figure 2
- ... and so on

## Running Figure Scripts

Each figure folder contains:
- `run_figureX.m`: main script that loads data, performs analysis, and generates figure panels
- `README.md`: description of inputs, outputs, and usage instructions
- helper functions and data references as needed

### Example

```matlab
cd matlab/figures/fig1
addpath(genpath(fullfile('../../')))  % add repo to path
run('run_figure1.m')
```

Or via MATLAB batch:
```bash
matlab -batch "cd matlab/figures/fig1; addpath(genpath(fullfile('../../'))); run('run_figure1.m')"
```

## Data Requirements

Each figure script depends on raw or preprocessed `.mat` files located in `data/raw/figX/` or processed data in `data/`. See individual figure `README.md` files for specific data files required.

## Questions?

See the main repository `README.md` for general setup instructions. Contact the authors for figure-specific questions.
