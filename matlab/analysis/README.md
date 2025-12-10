# Analysis Functions

This folder contains core MATLAB functions and routines used across figures for data analysis.

## Contents

Modular analysis functions typically include:
- Spike-train analysis (firing rates, ISI, raster plots, etc.)
- Decoding and dimensionality reduction
- Statistical tests and comparisons
- Population-level analyses
- Behavioral correlation analyses

## Usage

Analysis functions are called by figure-specific scripts in `matlab/figures/`. They are designed to be reusable across multiple analyses and figures.

### Example

```matlab
addpath(genpath(fullfile(pwd, 'matlab')))  % add all matlab subfolders
result = analyze_population_activity(spike_data, metadata);
```

## Design Principles

- **Modularity**: each function should handle a single analysis task
- **Documentation**: include header comments describing inputs, outputs, and usage
- **Error handling**: validate inputs and provide informative error messages
- **Efficiency**: optimize for large datasets where applicable

## Adding New Functions

When contributing new analysis functions:
- Follow MATLAB naming conventions (snake_case or camelCase consistently)
- Include comprehensive function documentation
- Test thoroughly before integration

## Questions?

Contact the authors for questions about specific analyses or for guidance on implementing new functions.
