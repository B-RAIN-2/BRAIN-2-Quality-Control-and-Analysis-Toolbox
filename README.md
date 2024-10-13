
# BRAIN^2 Quality Control and Analysis Toolbox

## Overview

This repository contains a custom MATLAB-based toolbox developed for quality control, visualization, and analysis of electrophysiological data, including Electrocorticography (ECoG) and Deep Brain Stimulation (DBS) recordings. The toolbox provides an integrated approach for preprocessing, quality control, visualization, and spectral analysis, ensuring data integrity and reliability. The toolbox uses the FieldTrip toolbox for preprocessing and enables both time-domain and frequency-domain inspections to validate data quality before proceeding with in-depth analysis.

**Disclaimer:** This is an example code to demonstrate dataset visualization. The preprocessing, analysis, and pipeline configuration used here **do not represent the formal recommendations of the Pouratian lab**.

## Features

- **Raw Data Visualization**: Plots raw ECoG and DBS data across all channels with customizable filtering.
- **Signal Quality Control**: Implements high-pass filtering to remove slow drifts, normalization to compare amplitudes across channels, and outlier removal to enhance signal clarity.
- **Frequency Analysis**: Provides power spectrum analysis using the multi-taper method, with options to customize the segment length, overlap, and frequency band of interest.
- **Customizable Settings**: Users can configure trial types, channel selection, filter properties, and visualization preferences.

## Requirements

- **MATLAB**: Version R2020b or newer is recommended for best compatibility.
- **FieldTrip Toolbox**: The latest stable version. Ensure that the toolbox is added to your MATLAB path before using the tool.

## Installation

1. Clone this repository to your local machine:
   ```sh
   git clone https://github.com/yourusername/BRAIN2-AnalysisToolbox.git
   ```
2. Add the FieldTrip toolbox to your MATLAB path:
   ```matlab
   addpath('/path/to/fieldtrip'); % Replace with your local FieldTrip path
   ft_defaults;
   ```

## Usage

1. **Update File Paths**:

   - Modify the `dataFolder` variable in `BRAIN2_QC_Analysis.m` to point to your data location.

2. **Run the Script**:

   - Execute `BRAIN2_QC_Analysis.m` in MATLAB to visualize and analyze the electrophysiological data.
   - The script supports both ECoG and DBS data, providing raw data plots as well as PSD analysis for signal quality assessment.

3. **Configuration**:

   - Customize the preprocessing and frequency analysis parameters as needed, such as `segLen` (segment length), `fpass` (frequency range), and `normalization` type to tailor the analysis to your specific dataset.

## Example Outputs

- **Raw Data Visualization**: The tool provides a stacked view of all channels, highlighting potential artifacts and enabling quality assessment.
- **Frequency Spectrum Analysis**: The PSD plots help evaluate the spectral properties of the data, enabling detailed frequency-domain inspection of signal quality.

Refer to **Figure 7** in our B(RAIN)^2 publication for example output visualizations generated using this toolbox.

## Dataset Compatibility

- This tool has been tested with BRAIN^2 datasets to ensure compatibility with our standards.
- Each dataset should be validated with a BIDS validator before using this tool to ensure compliance with structural and functional requirements.

## License

This toolbox is part of the BRAIN^2 project and follows the guidelines provided by the Pouratian Lab at UT Southwestern. Access to and use of the BRAIN^2 database should comply with its specific terms of use.

For more information on the BRAIN^2 database, please visit the BRAIN^2 Database at: https://dabi.loni.usc.edu/brain2

## Contributing

We welcome contributions from the community. If you'd like to contribute, please open an issue or submit a pull request with your proposed changes. For significant changes, please discuss them first to ensure they align with the project's goals.

- This tool uses the FieldTrip Toolbox (Oostenveld et al., 2011). For more information, visit [FieldTrip's official website](https://www.fieldtriptoolbox.org).

## Acknowledgments

Developed by Koorosh Mirpour, Senior Scientist at the Pouratian Lab, UT Southwestern, as part of the BRAIN^2 project.

## Citation
If you use this toolbox, please cite our publication:
To be announced
