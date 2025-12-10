# Neuron Data Files

This folder contains `.mat` files, one file per sorted unit (neuron). Each file includes two main MATLAB structs: `matdata` and `metadata`.

## File Naming
Files are named by unit identifier: `unit_XXXX.mat` (replace `XXXX` with the unit number or identifier).

## Data Structure

### `matdata` struct
Contains spiking activity and associated behavioral data organized by trial and cue location.

**Fields:**
- `cue_location_1`, `cue_location_2`, ... (or similar labels for each cue condition):
  - Each field is an array of trial data.
  - **Subfields (per trial):**
    - `spike_times`: spike times (in seconds) for this neuron during this trial.
    - `trial_number`: trial index.
    - `behavioral_data`: struct containing behavioral variables for this trial (e.g., reaction time, success/failure, eye position, etc.).
    - Additional fields as needed (e.g., `stimulus_onset`, `response_time`, `reward_received`).

**Example usage (MATLAB):**
```matlab
load('unit_0001.mat');  % loads matdata and metadata

% Access spiking data for cue location 1, trial 5
spike_times = matdata.cue_location_1(5).spike_times;
behavior = matdata.cue_location_1(5).behavioral_data;
```

### `metadata` struct
Contains neuron-level information useful for analysis and filtering.

**Fields:**
- `brain_area`: brain region/area where this neuron was recorded (e.g., 'PFC', 'ACC', 'M1').
- `depth`: recording depth in micrometers (μm) relative to cortical surface or other reference.
- `recording_date`: date/session identifier for this unit.
- `animal_id`: identifier of the animal from which this neuron was recorded.
- `probe_id`: probe/electrode identifier on which this unit was recorded.
- `spike_width`: action potential width (in milliseconds) — useful for distinguishing putative pyramidal vs. interneurons.
- `firing_rate`: mean firing rate (spikes/second) during the recording session.
- `isolation_quality`: measure of spike-sorting quality (e.g., 'good', 'ok', 'multiunit'; or a numerical score).
- Additional fields as needed (e.g., `waveform_mean`, `refractory_period_violation_rate`, `modulation_index`).

**Example usage (MATLAB):**
```matlab
load('unit_0001.mat');

fprintf('Unit recorded in %s at depth %d μm\n', metadata.brain_area, metadata.depth);
fprintf('Isolation quality: %s\n', metadata.isolation_quality);
```

## Loading and Processing All Units

To iterate over all neuron files in this folder:

```matlab
files = dir('*.mat');
for i = 1:length(files)
    load(files(i).name);
    
    % Access matdata and metadata for this unit
    % ... your analysis code ...
    
    clear matdata metadata;  % clear before next iteration
end
```

## Notes
- Spike times are typically in absolute time (seconds from trial start or session start); check individual file documentation or headers.
- Behavioral data fields may vary by experimental protocol; refer to the corresponding experiment documentation.
- If you have questions about specific fields or want to add metadata, contact the authors.
