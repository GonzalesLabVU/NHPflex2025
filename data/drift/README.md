# Drift Data

This folder contains quantified drift measurements derived from sorted spike data exported from Kilosort4 for each recording session. These drift metrics characterize the temporal displacement of the population spike depth centroid over time and have been reliably used for drift comparisons in several previous studies.

## Drift Calculation Methodology

All drift analysis was performed using custom MATLAB scripts (MathWorks, MATLAB R2022a) at a sampling rate of 30 kHz.

### Template Depth Determination

For each spike-sorting template, template depth was determined as the signal power-weighted center of mass (COM) of the template waveforms across recording channels (Pachitariu et al., 2016). For template $k$, the signal power on channel $c$ was computed as the sum of squared waveform amplitudes, and the corresponding depth was obtained as:

$$D_k = \frac{\sum_c (E_{k,c} y_c)}{\sum_c E_{k,c} t}$$

where $E_{k,c}$ is the channel's vertical position and $y_c$ is the waveform amplitude on that channel.

### Spike Depth Assignment and Binning

Each spike was assigned a depth $d_i = D_{k_i}$ according to its template identity $k_i$. Spike times were divided into consecutive temporal bins of 2 seconds. For each bin $b$ containing $N_b$ spikes, the median spike depth (bin-wise center of mass) was computed as:

$$COM_b = \text{median}\{d_i : i \in B_b\}$$

The resulting time series of depth centroids $COM(t_b)$ reflects the population's median depth as a function of time.

### Drift Rate and Displacement Metrics

**Instantaneous drift rate** (velocity) was calculated as the absolute frame-to-frame change in micrometers per second:

$$v(t_b) = \frac{|COM(t_b) - COM(t_{b-1})|}{\Delta t}$$

**Net drift displacement** was defined as the total range of motion across the session:

$$D_{\text{net}} = \max(COM) - \min(COM)$$

These metrics quantify both short-term motion $v(t_b)$ and the overall amplitude of probe-relative movement $D_{\text{net}}$.

## Data Files and Structure

### File Naming
Files are typically named by recording session or probe identifier (e.g., `session_YYYY-MM-DD_probe_A.mat` or `recording_001_drift.mat`).

### Expected Fields

Each `.mat` file contains:

- **`drift_rate`**: time series of instantaneous drift velocity (μm/s). Dimensions: [n_bins, 1] or [n_timepoints, 1].
- **`depth_centroid`** or **`COM`**: time series of population spike depth centroid (μm). Dimensions: [n_bins, 1].
- **`time_bins`**: time vector corresponding to drift rate and depth centroid (seconds). Dimensions: [n_bins, 1].
- **`net_drift`**: scalar; total net drift displacement (μm) across the session.
- **`metadata`**: struct containing:
  - `session_id`: recording session identifier.
  - `probe_id`: probe identifier.
  - `recording_duration_s`: total recording duration in seconds.
  - `bin_width_s`: temporal bin width used (typically 2 seconds).
  - `sampling_rate_khz`: sampling rate in kHz (typically 30 kHz).
  - `n_spikes_total`: total number of spikes in the session.
  - `n_templates`: number of spike-sorting templates.

### Example MATLAB Usage

```matlab
load('session_2024_01_15_probe_A.mat');

% Plot drift rate over time
figure; plot(time_bins, drift_rate);
xlabel('Time (s)'); ylabel('Drift Rate (μm/s)');
title(sprintf('Session %s, Probe %s', metadata.session_id, metadata.probe_id));

% Summarize
fprintf('Net drift displacement: %.2f μm\n', net_drift);
fprintf('Maximum drift rate: %.2f μm/s\n', max(drift_rate));
```

## Analysis and Comparisons

### Normalization for Cross-Session Comparison

Drift rate time series were normalized to 1000 bins per recording to allow comparison across sessions of different lengths and were concatenated into heatmaps for visualization.

### Statistical Analysis

**Net drift displacement distributions** were further summarized across recordings via bootstrapping (10,000 resamples of the median) to estimate distribution variability.

**Group differences** were assessed using a non-parametric permutation test (10,000 permutations) on median values, where the p-value corresponded to the proportion of permuted differences greater than or equal to the observed absolute median difference.

## References

- Steinmetz, N. A., et al. (2019). Neuropixels 2.0: A miniaturized high-density probe for scalable neural recordings. *Science*, 372(6539), eabf4588.
- Pachitariu, M., et al. (2016). Fast and accurate spike sorting of high-channel count probes with Kilosort. *Advances in Neural Information Processing Systems*, 29, 4455-4463.
- See the main repository `README.md` for additional citations.

## Questions or Issues?

If you have questions about drift calculation, file formats, or would like to request additional metrics, contact the authors.
