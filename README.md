# Solar PV MPPT Simulink

MATLAB/Simulink implementation of a Solar PV system with MPPT (Maximum Power Point Tracking), featuring a boost converter, dynamic irradiance and temperature profiles, and a comparison of two MPPT algorithms.

## Overview

This project models a PV array feeding a DC load through a boost converter, controlled by an MPPT algorithm that continuously adjusts the converter's duty cycle to extract maximum available power as environmental conditions change. Two MPPT strategies are implemented and compared:

- **Perturb & Observe (P&O)**
- **Incremental Conductance (IncCond)**

## Key Features

- Boost converter with closed-loop PI control
- Dynamic irradiance and temperature profiles (via Repeating Sequence blocks) to simulate realistic changing weather conditions rather than fixed static inputs
- Two MPPT algorithms implemented for direct performance comparison
- Post-processing script (`analyze_results.m`) to evaluate tracking efficiency and response behavior
- Debugged and retuned control loop — corrected a summing junction sign convention error and an inverted PWM comparator relational operator, then retuned PI gains (P: 0.7 → 0.01, I: 10 → 0.1) for stable, accurate tracking

## Repository Structure

```
Solar-PV-MPPT-Simulink/
├── PV_MPPT_PandO_Final.slx      # Simulink model — Perturb & Observe MPPT
├── PV_MPPT_InCond_Final.slx     # Simulink model — Incremental Conductance MPPT
├── analyze_results.m            # Post-processing / results analysis script
├── mppt_incond.m                # Incremental Conductance MPPT algorithm function
├── ic_results.mat               # Saved simulation results (IncCond)
├── MPPT Comparison1.pdf         # Findings report comparing both algorithms
├── V_PV.png / V_PV.1.png        # PV voltage response plots
├── PI_Result.png / PI_Result.1.png  # PI controller performance plots
└── README.md
```

## Methodology

1. **Boost Converter Design** — Sized and modeled a DC-DC boost converter in Simulink to step up the PV array's output voltage to the load/bus requirement
2. **Control Loop Debugging** — Identified and fixed a sign convention error in the summing junction and an inverted relational operator in the PWM comparator, both of which were preventing the control loop from converging correctly
3. **PI Tuning** — Retuned the PI controller gains for stable duty-cycle control under varying conditions
4. **Dynamic Environmental Profiles** — Replaced static irradiance/temperature inputs with Repeating Sequence blocks to simulate realistic, time-varying weather conditions
5. **MPPT Algorithm Comparison** — Implemented Incremental Conductance as a second MPPT strategy alongside Perturb & Observe, to compare tracking speed and steady-state accuracy
6. **Results Analysis** — Used `analyze_results.m` to post-process simulation outputs and evaluate each algorithm's performance

## Results

See `MPPT Comparison1.pdf` for the full findings report comparing tracking efficiency, response time, and steady-state oscillation between the P&O and Incremental Conductance algorithms under dynamic irradiance and temperature conditions.

## Tools

MATLAB / Simulink
