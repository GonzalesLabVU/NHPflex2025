# Probe and PCB Fabrication

This folder contains links, step-by-step instructions, and vendor information for fabricating the flexible neural probes and associated electronics.

## Overview

Fabrication involves two main components:
1. **Neural probes**: custom flexible electrodes (typically fabricated via microfabrication or specialized vendors)
2. **PCBs**: supporting electronics for signal conditioning and acquisition

## Fabrication Process and Vendors

See the main repository `README.md` for the link to the fabrication service and detailed process documentation.

### Key Resources

- **Probe fabrication vendor/service**: [Fabrication process & vendor link](https://www.fabublox.com/process-editor/899ce03e-38a6-4836-bd59-ae51e0551a5e)
- **PCB fabrication**: Standard PCB manufacturers (OSHPark, PCBWay, JLC PCB, etc.) — see `pcb/README.md` for Gerber files.
- **3D-printed adapter**: Formlabs Form 3 with clear resin — see `3d/README.md` for specifications.

## Step-by-Step Instructions

1. **Design finalization**: Review probe and PCB designs in `probes/` and `pcb/` folders.
2. **Probe fabrication**: Submit probe CAD and masks to the designated vendor. Typical turnaround is 4–8 weeks depending on fabrication complexity.
3. **PCB fabrication**: Upload Gerber files from `pcb/` to a PCB manufacturer and select manufacturing parameters (layer stackup, trace width, etc.).
4. **PCB assembly**: Either self-assemble (hand soldering for prototypes) or use a PCB assembly service (PCBA) for component placement and soldering.
5. **3D adapter printing**: Submit STL files from `3d/` to a Formlabs Form 3 printer.
6. **Integration and testing**: Assemble probes, PCBs, and 3D adapter; perform electrical and mechanical testing before use in experiments.

## Timeline and Cost Estimates

(Add specific timelines and cost estimates based on your experience or vendor quotes)

## Troubleshooting and Support

- Contact the probe fabrication vendor for technical issues with probe design or fabrication.
- For PCB issues, consult the PCB manufacturer or reach out to the electronics design team.
- For 3D printing questions, refer to Formlabs documentation or contact Formlabs support.

## Questions?

Contact the authors for additional fabrication details, vendor recommendations, or troubleshooting guidance.
