#!/usr/bin/env bash
# Script to clone required external MATLAB toolboxes into `external/`.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
EXTERNAL_DIR="$ROOT_DIR/external"

echo "Creating external directory: $EXTERNAL_DIR"
mkdir -p "$EXTERNAL_DIR"

clone_if_missing() {
  local repo_url="$1"
  local target_dir="$2"
  if [ -d "$target_dir/.git" ] || [ -d "$target_dir" ]; then
    echo "Already exists: $target_dir — skipping clone"
  else
    echo "Cloning $repo_url -> $target_dir"
    git clone "$repo_url" "$target_dir"
  fi
}

echo "Cloning matlabnpy (NumPy read/write for MATLAB)"
clone_if_missing "https://github.com/kwikteam/matlabnpy.git" "$EXTERNAL_DIR/matlabnpy"

echo "Cloning Open Ephys analysis toolbox"
clone_if_missing "https://github.com/open-ephys/analysis-tools.git" "$EXTERNAL_DIR/open-ephys-analysis"

echo "Done. To add these toolboxes to MATLAB path, run from MATLAB:"
echo "  addpath(genpath(fullfile(pwd,'external','matlabnpy')));"
echo "  addpath(genpath(fullfile(pwd,'external','open-ephys-analysis')));"
echo "Or run the included MATLAB helper:"
echo "  run('matlab/add_external_paths.m')"

echo "Alternatively, run this script from the repo root with:"
echo "  bash scripts/setup_external_toolboxes.sh"

exit 0
