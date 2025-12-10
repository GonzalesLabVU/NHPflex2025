# Utility Functions

This folder contains utility and helper functions used throughout the MATLAB codebase.

## Contents

Typical utility functions include:
- File I/O helpers (loading/saving data, organizing by date, etc.)
- Plotting utilities and figure formatting
- Random seed and reproducibility helpers
- Color palettes and visualization standards
- Data validation and cleaning routines

## Usage

Utility functions are added to the MATLAB path automatically when you run:
```matlab
addpath(genpath(fullfile(pwd, 'matlab')))
```

Then call them directly:
```matlab
set_plot_style();  % apply consistent plotting style
data_clean = validate_neural_data(raw_data);
```

## Common Utilities

- `set_plot_style()`: applies consistent figure formatting and colors
- `set_random_seed()`: ensures reproducible random number generation
- `load_neuron_data()`: standardized loader for neuron `.mat` files
- `save_figure()`: saves figures in multiple formats with consistent settings

## Adding New Utilities

When adding utility functions:
- Keep them focused and general-purpose
- Document clearly with examples
- Avoid dependencies on large external packages where possible
- Test across different use cases

## Questions?

Contact the authors for questions about utilities or suggestions for new helpers.
