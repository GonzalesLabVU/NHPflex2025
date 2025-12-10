# PCB Design Files

This folder contains PCB schematics, layout files, and Gerber exports for the electronics supporting the neural probes.

## Contents

- **Schematics**: Circuit diagrams (`.sch`, `.kicad_sch`, or PDF) for signal conditioning, amplification, and digital interfaces.
- **Layout files**: PCB design files in KiCad, Eagle, Altium, or other EDA formats (`.kicad_pcb`, `.brd`, etc.).
- **Gerbers**: Fabrication-ready Gerber files (`.gbr`, `.gbl`, `.gts`, etc.) for PCB ordering from manufacturers.
- **Documentation**: Bill of materials (BOM), assembly notes, and layer descriptions.

## PCB Overview

The PCB provides signal conditioning and data acquisition for flexible neural probes. It includes pre-amplification, filtering, and analog-to-digital conversion stages necessary for high-quality ephys recordings.

## Fabrication and Assembly

For PCB fabrication and assembly instructions, see the `fabrication/README.md`. Gerber files can be uploaded directly to PCB manufacturers (OSHPark, PCBWay, JLC PCB, etc.).

## Design and Modifications

If modifying the PCB design:
- Ensure signal integrity and noise performance are maintained.
- Verify component availability before finalizing designs.
- Test prototypes before committing to large production runs.

## Questions?

Contact the authors for detailed circuit explanations, component sourcing, or design consultation.
