# Drift Data

This folder contains quantified drift measurements from all sessions across flexible and rigid probes.

## Drift Calculation Methodology

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


## References

- Steinmetz, N. A., et al. (2019). Neuropixels 2.0: A miniaturized high-density probe for scalable neural recordings. *Science*, 372(6539), eabf4588.
- Pachitariu, M., et al. (2016). Fast and accurate spike sorting of high-channel count probes with Kilosort. *Advances in Neural Information Processing Systems*, 29, 4455-4463.
