# 3D Design Files

This folder contains STL and STEP design files for the microdrive adapter used to mount flexible neural probes to standard electrophysiology rigs.

## Microdrive Adapter

The 3D-printed adapter is designed to integrate flexible probes with the [Narishige MO-97A hydraulic micromanipulator](https://narishige.co.jp/en/products/micromanipulators/mo97a/). This adapter enables precise positioning and stabilization of the flexible probes during recording sessions in non-human primate experiments.

## 3D Printing Specifications

### Printer
- **Printer Model:** Formlabs Form 3 (or Form 3B)
- **Printing Technology:** Stereolithography (SLA) resin printing

### Material
- **Resin Type:** Clear Resin (Formlabs Clear Resin)
- **Key Properties:**
  - Transparent for optical visibility of probe insertion and positioning
  - High dimensional accuracy and surface smoothness
  - Excellent for mechanical components requiring precision tolerances

### Tolerance and Print Settings
- **Smallest Tolerance:** ±0.025 mm (25 μm) — achievable with Formlabs printers using highest-precision settings
- **Recommended Print Settings:**
  - Layer height: 25 μm (finest resolution)
  - Print orientation: optimized to minimize supports and maximize tolerance accuracy
  - Support density: medium to high for component stability

For the most current and detailed specifications on Formlabs Clear Resin tolerances and recommended print parameters, refer to the [official Formlabs Form 3 specifications](https://formlabs.com/products/form-3/).

## File Structure

### STL Files
- `microdrive_adapter_main.stl` — main adapter body that interfaces with the MO-97A micromanipulator
- `microdrive_adapter_probe_holder.stl` — probe holding fixture with precise alignment features
- `microdrive_adapter_assembly.stl` — (optional) full assembly for visualization

### STEP Files
- `microdrive_adapter.step` — editable CAD file (compatible with SolidWorks, FreeCAD, Fusion 360, etc.) for custom modifications

## Assembly and Usage

1. **Print:** Send STL files to a Formlabs Form 3 with the settings above. Post-processing includes isopropyl alcohol rinse and UV curing as per Formlabs standard protocol.
2. **Assembly:** Attach the adapter to the MO-97A micromanipulator arm using the provided mounting interfaces (threaded inserts or custom clamps).
3. **Probe Mounting:** Insert the flexible probe into the probe holder, ensuring alignment with the micromanipulator tip.
4. **Positioning:** Use the MO-97A hydraulic drive for smooth, fine-grained depth control during recordings.

## References

- **Narishige MO-97A Micromanipulator:** https://narishige.co.jp/en/products/micromanipulators/mo97a/
- **Formlabs Form 3 Specifications:** https://formlabs.com/products/form-3/

## Notes

- If you modify the designs, ensure that tolerance-critical features (probe holder dimensions, micromanipulator interface) are maintained to preserve mechanical fit and alignment.
- Test-fit components before use in experiments to verify proper assembly and probe alignment.
- Contact the authors for questions about design specifications or fabrication recommendations.
