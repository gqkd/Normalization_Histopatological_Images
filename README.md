# NHIs Algorithm for Histopathological Image Normalization

## Overview

The NHIs (Normalized Histopathological Images) algorithm is a tool for normalizing histopathological images based on a target reference image. This algorithm calculates the normalized version (IsNorm) of a source image (I) concerning a target image (Itarget) while quantifying the relative squared error (rse) as a measure of the normalization quality. NHIs is based on the research presented in the paper [Structure-Preserving Color Normalization and Sparse Stain Separation for Histological Images](https://pubmed.ncbi.nlm.nih.gov/27164577/) by Abhishek Vahadane.

## Getting Started

### Clone the Repository

To get started with NHIs, clone this repository to your local machine using the following command:

```bash
git clone https://github.com/your-username/your-repo.git
```

Navigate to the Project Directory
Navigate to the project directory:

```bash
cd NHIs-Algorithm
```

## Prepare Source and Target Images

To use the NHIs algorithm, follow these steps:

1. **Place your source image (I)** in the project folder. Ensure that it is in a directory where you have also manually selected points for rSE calculation.

2. Additionally, the **target image (Itarget)** should be located in the same directory.

## Run the Algorithm

To run the NHIs algorithm, execute the "MAIN_algoritmoNHIS.m" script.

The algorithm will **automatically execute the following steps**:

- Image segmentation
- Optimization of beta values
- Optimization of alpha values (which, in turn, calls the rSE optimization)
- rSE calculation

The algorithm will **display the following outputs**:

- **Figure 1**: Original source image, target image, normalized source image (IsNorm), and the calculated rSE.
- **Figure 2**: Manually selected points for rSE calculation on the original source image and the normalized source image.

## Algorithm Workflow

The NHIs algorithm follows these key steps:

1. **Segmentation**: The target image (Itarget) is segmented to isolate structures related to diaminobenzidine (brown) and hematoxylin (blue).

2. **Stain Color Appearance Extraction (Ct)**: Ct is computed, representing the stain color appearance in the RGB space for diaminobenzidine and hematoxylin based on percentiles of color values in segmented regions.

3. **Optical Density Calculation (Vt)**: The optical density of the target image is determined using the inverse Lambert-Beer law.

4. **Stain Density Map (Ht)**: Stain density maps are calculated by inverting the relationship between optical density (Vt) and stain color appearance (Wt).

5. **Normalization of Source Image**:
   - The source image (I) undergoes segmentation.
   - Stain color appearance (Cs) for the source image is optimized using the selected points.
   - Optical density (Vs) of the source image is computed.
   - Stain density map (Hs) for the source image is generated.

6. **Robust Maximum Calculation (HsRM and HtRM)**: Robust maximum values are computed for stain density maps obtained from the source and target images.

7. **Normalization of Stain Density Map (HsNorm)**: The stain density map of the source image (Hs) is normalized based on the robust maximum values.

8. **Image Restoration**: The source image (I) is normalized in the optical density space.

9. **rSE Calculation**: The relative squared error (rse) between the normalized source image (IsNorm) and the target image (Itarget) is calculated.

## Notes

- The algorithm takes approximately 120 seconds to normalize a single image, and the processing time increases during use.

- Ensure that the source image, target image, and manually selected points are in the same folder for proper execution.


