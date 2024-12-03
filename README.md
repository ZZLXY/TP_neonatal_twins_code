# TP_neonatal_twins_code

The folders listed above include codes for analyses described in the manuscript titled “**The Innate Neural Representation Network Mechanisms of Semantic Knowledge: Converging Evidence from Neonatal and Adult Twin Studies**”. Additionally, we have provided brain images of adult and neonatal temporal pole (TP) parcellations, as well as the neural network masks used in the Regions of Interest (ROI) analyses.

**Installation Guide:**

To use the scripts, add the required toolboxes to the appropriate environment paths based on the programming language. In Matlab, use the ‘addpath’ function, and in R, use the ‘install.packages()’ function. These steps are straightforward and should not take much time.

The custom codes were tested on a 64-bit Windows 11 PC (Intel Core i5-10400F, 16GB RAM). Data analyses were performed using Matlab 2021a and RStudio 2022.07.2+576.

**Codes:**
1)	**A_transform_ROI_to_dhcp_space/maskregistration_MIN152_to_extdhcp40wk.sh**: This shell script transforms ROIs from adult MNI152 space to neonatal space. Before running this script, ensure that the ANTs toolbox (version 2.3.4.dev203-g952e7; http://stnava.github.io/ANTs/) is installed. The ROIs used in this study are located in the Network_ROIs folder.
2)	**B_calculate_FC/Calculate_FC_ROI_to_ROI.m**: This Matlab script calculates the functional connectivity (FC) between pairs of ROIs. 
3)	**B_calculate_FC/Calculate_FC_Seed_to_Voxel.m**: This Matlab script calculates the FC between a seed ROI and whole-brain voxels.
4)	**C_Parcellation/Two_step_clustering_approach.m**: This Matlab script employs a two-step clustering approach to parcellate TP into multiple subdivisions. The resulting TP parcellations are stored in the TP_parcellationss folder.
5)	**D_twin_studies/ACEmodeling.R**: This R script evaluates the genetic and environmental effects on specific FC patterns. It requires the R package 'umx' (version 4.15.1; https://cran.r-project.org/web/packages/umx/index.html), which must be installed prior to use.
6)	**E_SVR_analysis/parallel_of_prediction_cv.m**: This Matlab script performs support vector regression analyses followed by a permutation test. It requires the Matlab toolbox LIBSVM 3.22 (https://www.csie.ntu.edu.tw/~cjlin/libsvm/), which must be installed beforehand.

**Data:**

Images from the HCP (adults, including both unrelated and twin participants) and dHCP (neonates) datasets are available at https://www.humanconnectome.org and https://www.developingconnectome.org, respectively. In accordance with the privacy policies of both datasets, the preprocessed images of human adults and neonates, including their IDs, can only be shared upon request with qualified investigators who agree to the Restricted Data Use Terms associated with these projects.
