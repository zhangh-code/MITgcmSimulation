# Circulation Simulation
![3D plot](./pics/MIT3Dskip.gif) 

![3D plot](./pics/MIT3Dskip_deseasoned.gif) 

Introduction

This study establishes a high-resolution numerical simulation for the Pacific Ocean and its adjacent marginal seas, 
including the South China Sea and the Indonesian seas, using the Massachusetts Institute of Technology general circulation model (MITgcm). 


The model domain covers a extensive region from 100°E to 120°W and 20°S to 30°N, encompassing the Pacific Ocean, the South China Sea, and the Indonesian seas. This area is critical for studying inter-basin interactions, such as the Indonesian Throughflow, and multi-scale dynamic processes like mesoscale eddies and air-sea interactions. The model configuration employs a horizontal resolution of 1/12° × 1/12°, which is eddy-permitting and suitable for capturing mesoscale features. The vertical direction is discretized into 35 layers. The bathymetry is derived from the GEBCO_24 dataset (30-arc-second resolution). The initial conditions and lateral boundary conditions are provided by the GLORYS12V1 reanalysis product, while the atmospheric forcing is supplied by the ERA5 reanalysis dataset.

The code configuration involves key parameter files such as SIZE.h(defining array dimensions), CPP_OPTIONS.h(setting model capabilities via CPP flags), data.pkgs(enabling specific packages), and data(core model parameters). Package-specific options are detailed in files like GMREDI_OPTIONS.h(eddy parameterization), KPP_OPTIONS.h(boundary layer mixing), and EXF_OPTIONS.h(surface forcing). The input directory contains necessary forcing data, boundary conditions, and configuration scripts (e.g., data.obcsfor open boundaries, data.exffor surface fluxes). Diagnostic outputs, including temperature and salinity fields visualized in MIT3D_temp_skip.gifand MIT3D_salt_skip.gif, are configured via data.diagnostics.

This simulation aims to provide a reliable tool for investigating ocean circulation dynamics, water mass transformations, and climate-scale variability in this complex and critically important region.
