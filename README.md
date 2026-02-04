# NHPflex2026

**Project:** Repeatable, low-drift recordings in behaving non-human primates using flexible microelectrodes.

This repository accompanies Woods et al in describing the design, fabrication, and use of flexible neural probes and associated hardware for acute recordings in non-human primates. It contains all files needed to reproduce the figures in the manuscript, design and fabrication data for probes and PCBs, 3D designs for a microdrive adapter, and the analysis code used in the study.

**Repository Contents**
- **`/data/neurons/`**: Neuron spike files.
- **`/data/drift/`**: Drift metrics used in analyses, built off of KiloSort4 drift correction.
- **`/probes/`**: Probe mask files used for layout.
- **`/pcb/`**: PCB design files and Gerbers for electronics supporting the probes.
- **`/fabrication/`**: Link and step-by-step notes for the probe fabrication process (see `README` inside folder).
- **`/3d/`**: 3D design files (STEP, STL) for the microdrive adapter and mounting parts.
- **`/figures/`**: Scripts used to generate figures from data.

### MATLAB Requirements

Scripts were developed and tested with **MATLAB R2022a**. 

**Required MathWorks Toolboxes:**
- Signal Processing Toolbox
- Statistics and Machine Learning Toolbox
- Image Processing Toolbox

**Required Community Toolboxes:**
- **`matlabnpy`** — lightweight toolbox to read/write NumPy `.npy`/`.npz` files directly from MATLAB
- **Open Ephys Analysis Toolbox** — load and preprocess Open Ephys recordings

### Setting Up External Toolboxes

**Manual clone**
```bash
mkdir -p external
git clone https://github.com/kwikteam/matlabnpy.git external/matlabnpy
git clone https://github.com/open-ephys/analysis-tools.git external/open-ephys-analysis
```

**Add to MATLAB path (from MATLAB):**
```matlab
addpath(genpath(fullfile(pwd,'external','matlabnpy')))
addpath(genpath(fullfile(pwd,'external','open-ephys-analysis')))
savepath;
```

## Probe Fabrication & PCB

- **`probes/`** directory: Mask layouts and fabrication notes for probe design.
- **`pcb/`** directory: PCB schematics, Fusion360 project files, and Gerber exports for electronics.
- **Fabrication process:** Detailed steps and vendor links are in `fabrication/README.md`. 
- **Fabrication service:** See the [probe fabrication process & vendor link](https://www.fabublox.com/process-editor/899ce03e-38a6-4836-bd59-ae51e0551a5e) for detailed instructions and availability.

## 3D Designs

- The `3d/` folder contains STEP and STL files for the microdrive adapter used to mount flexible probes.
- Adapter is designed for the [Narishige MO-97A hydraulic micromanipulator]([https://narishige.co.jp/en/products/micromanipulators/mo97a/](https://products.narishige-group.com/group1/MO-97A/chronic/english.html)).
- Fabricated using a Formlabs Form 3 with clear resin (±0.025 mm tolerance).

## Ethical Considerations

- **Animal care compliance:** All animal procedures were performed in accordance with institutional and national guidelines and approved by the Institutional Animal Care and Use Committee (IACUC).

## Reproducing Figures

- Each `matlab/figures/figX` folder containing scripts used to generate each figure.
- **Typical workflow:**
  1. Ensure MATLAB R2022a+ and required toolboxes are installed.
  2. Set up external toolboxes using the steps above.
  3. Obtain required `.mat` data files from `data/`.
  4. Run `run_figureX.m`

## License

- **Code:** Analysis code, scripts, and design files are provided under the `MIT` license (see `LICENSE`).
- **Data:** Data are offered under `Creative Commons Attribution 4.0 International (CC BY 4.0)` (see `DATA_LICENSE.md` for details and citation requirements).

## Contact & Acknowledgements

- **Lead Author:** daniel.p.woods@vanderbilt.edu

---

*Last updated: February 2026*
