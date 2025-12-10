# Processing Scripts

This folder contains preprocessing and data processing scripts for neural recordings.

## Contents

Scripts in this folder typically handle:
- Raw data loading and conversion
- Data filtering and artifact removal
- Spike-sorting wrappers or quality checks
- Drift correction and alignment
- Data organization and formatting for analysis

## Usage

Processing scripts are typically called by higher-level figure or analysis scripts. See `matlab/figures/` and `matlab/analysis/` for examples of how these are integrated into analysis pipelines.

## Adding New Scripts

When adding preprocessing steps:
- Document input/output formats clearly
- Use consistent variable naming across the codebase
- Test with sample data before use in production analyses

## Questions?

Contact the authors for questions about preprocessing steps or data pipeline details.
