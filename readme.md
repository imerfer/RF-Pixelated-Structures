# RFPS-AI: Automated Generation and Electromagnetic Simulation of Pixelated RF Structures

This repository contains the MATLAB scripts used to generate, simulate, and process the **RFPS-AI dataset**, comprising 70,000 randomly generated pixelated radio-frequency (RF) structures and their corresponding electromagnetic responses.

The code automates the generation of binary geometries, the creation of simulation layouts, electromagnetic analysis using Keysight ADS Momentum, and the extraction of complex scattering parameters.

The resulting dataset is intended to support electromagnetic modeling, microwave component design, optimization, and machine learning applications.

**Dataset:** [RFPS-AI on Zenodo — DOI pending]  
**Associated publication:** [DOI pending]

## 1. Repository Contents

The main MATLAB scripts are:

| File | Description |
|---|---|
| `variables.m` | Defines the geometric parameters, simulation settings, frequency sweep, and ADS environment configuration. |
| `ael_creator.m` | Generates random binary pixelated structures and creates the AEL instructions required to construct their layouts in ADS. |
| `EM_simulation_bat.m` | Automates electromagnetic simulations, extracts scattering parameters, and organizes the resulting data into MATLAB files. |

Additional ADS workspace files or simulation templates may be required to execute the complete workflow.

## 2. Dataset Generation Workflow

The dataset generation process consists of four main stages:

1. **Random geometry generation:** Binary pixelated structures are generated in MATLAB.
2. **Layout creation:** The geometries are translated into ADS layouts using Application Extension Language (AEL).
3. **Electromagnetic simulation:** Each structure is simulated using Keysight ADS Momentum.
4. **Data extraction:** The real and imaginary components of the scattering parameters are extracted and stored together with the corresponding geometric configurations.

## 3. Geometry Configuration

Each structure contains a 16 × 16 binary pixelated design region, where:

- `1` represents the presence of metal.
- `0` represents the absence of metal.

Each pixel has a 50% probability of containing metal in the corrected geometry generator.

An additional border accommodates four external ports, producing an 18 × 18 binary representation containing 324 elements.

A 25% overlap between adjacent metallic pixels is applied to improve electrical connectivity, particularly for diagonal connections.

### Geometric and Material Parameters

| Parameter | Value |
|---|---|
| Pixelated region | 16 × 16 |
| Complete binary representation | 18 × 18 |
| Nominal pixel width | 950 µm |
| Metallic pixel probability | 50% |
| Metallic pixel overlap | 25% |
| Number of ports | 4 |
| Substrate | FR-4 |
| Relative permittivity | 4.6 |
| Substrate thickness | 1.6 mm |

## 4. Electromagnetic Simulation

The electromagnetic simulations were performed using **Keysight ADS 2023 Update 2**, employing the Momentum electromagnetic solver.

The simulation configuration is summarized below:

| Parameter | Value |
|---|---|
| EM solver | ADS Momentum |
| Frequency range | 0.1–3 GHz |
| Frequency points | 100 |
| Network configuration | Four-port |
| Output | Complex scattering parameters |
| MATLAB version | R2023b |

For each geometry, the simulation produces a frequency-dependent 4 × 4 scattering matrix.

The real and imaginary components are stored separately, allowing the complex coefficients to be reconstructed as:

\[
S_{ij}(f)=\operatorname{Re}(S_{ij}(f))+j\operatorname{Im}(S_{ij}(f))
\]

## 5. Requirements

The original workflow was developed using:

- MATLAB R2023b.
- Keysight ADS 2023 Update 2.
- ADS Momentum electromagnetic solver.
- A valid ADS license.
- Windows environment for the original batch-based simulation workflow.

**Note:** Keysight ADS is commercial software and is not distributed with this repository.

## 6. Usage

### Step 1 — Configure the environment

Open `variables.m` and update the local ADS installation paths, workspace directories, and simulation settings.

The original scripts contain environment-specific configurations that must be adapted before execution.

### Step 2 — Generate the geometries

Create a workspace called as lib_name changing _lib to _wrk (Example, if lib_name  = 'AEL_layout_lib', the workspace is AEL_layout_wkr); in ADS and configure the substrate.

Execute the geometry generation script in MATLAB:

```matlab
ael_creator
```

This script generates the random pixelated structures and creates the AEL instructions required to reproduce their layouts in ADS.

### Step 3 — Perform electromagnetic simulations

After configuring the ADS environment (load .ael files) and the required simulation files, execute:

```matlab
EM_simulation_bat
```

The script automates the simulation workflow and extracts the electromagnetic responses.

Execution requires the corresponding ADS project configuration and simulation resources.

## 7. Output Data Format

The generated MATLAB files contain the binary geometry representations and their corresponding scattering parameters.

The principal variables are:

| Variable | Description |
|---|---|
| `inputs` | Flattened binary geometry representation |
| `freq` | Frequency vector in GHz |
| `S11_real`, `S11_imag` | Real and imaginary components of S11 |
| `S21_real`, `S21_imag` | Real and imaginary components of S21 |
| `S22_real`, `S22_imag` | Real and imaginary components of S22 |
| `Sij_real`, `Sij_imag` | Corresponding components of the remaining four-port S-parameters |

The extraction script stores all 16 complex coefficients of the four-port scattering matrix.

## 8. Dataset Availability

The complete RFPS-AI dataset contains **70,000 simulated geometries**, organized into seven MATLAB files with 10,000 structures each.

The dataset is distributed separately through Zenodo:

10.5281/zenodo.24322721

This GitHub repository provides the source code associated with dataset generation and processing.

## 9. Reproducibility

The provided scripts document the computational workflow used to generate the dataset.

Reproducing the complete simulation process requires a compatible ADS Momentum installation, the necessary simulation setup, and appropriate software licensing.

The electromagnetic results are simulation-based and should not be interpreted as experimentally measured responses.

## 10. License

The MATLAB source code is intended to be distributed under the **MIT License**, subject to confirmation that all included code can be redistributed.

The associated RFPS-AI dataset is distributed separately under **Creative Commons Attribution 4.0 International (CC BY 4.0)**.

Third-party software and proprietary ADS components remain subject to their respective licenses.

## 11. Citation

If you use RFPS-AI in your research, please cite the dataset and its associated scientific publication.

Dataset DOI: 10.5281/zenodo.24322721

Publication DOI: pending publication

## 12. Contact

For questions, suggestions, or issues related to the code, please use the GitHub Issues section of this repository.