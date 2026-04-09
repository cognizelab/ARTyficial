<!-- [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.19486642.svg)](https://doi.org/10.5281/zenodo.19486642) --> 

# Repository for "Latent Neural Architecture Organizing Shared Aesthetic Evaluations of Visual Artworks"
Authors: Xinyu Liang, Kaixiang Zhuang, Yun Wang, Yueting Su, Jianfeng Feng, Zhou Feng, Benjamin Becker and Deniz Vatansever

This repository contains the codes used for analyses and figures in our manuscript "Latent Neural Architecture Organizing Shared Aesthetic Evaluations of Visual Artworks".
Large data files are hosted externally ([OSF](https://osf.io/8hfae/files/osfstorage?view_only=1955d0ed099a4fc68dcdf1a7efe4b5b5)) due to size constraints.

## Abstract
Aesthetic experience shapes a wide range of behaviours, from everyday consumer choices to the appreciation of visual art. While theoretical accounts propose that such experiences emerge from interactions among core brain systems during aesthetic evaluations, the principal dimensions organizing this mental process remain unclear. Here we introduce a data-driven framework to characterize the latent neural architecture of shared aesthetic evaluations. Participants viewed traditional paintings during 7T functional MRI and subsequently rated their aesthetic appreciation of each artwork. Drawing on approaches used in online recommender systems, we constructed an aesthetic agreement matrix capturing the similarity structure of participants’ ratings and applied dimensionality-reduction techniques to identify the main axes organizing aesthetic evaluations. Two principal dimensions emerged: visual semantics and hedonic valuation, each predicted by distinct multivariate neural signatures. Category-selective regions along the ventral visual stream predicted variation in visual semantics, whereas medial prefrontal and subcortical valuation circuitry predicted variation in hedonic value. Importantly, individual differences in the neural representation of this two-dimensional latent aesthetic space, particularly within key regions of the default mode network, were systematically associated with expertise in the visual arts. Together, these findings reveal how interacting core brain systems synergistically organize shared aesthetic evaluations of visual artworks while also accounting for idiosyncratic aspects of aesthetic experience.

## Keywords
Neuroaesthetics, 7T fMRI, multivariate decoding, visual semantics, hedonic value

## Repository Structure
Here is a detailed guide to the code and files included in this repository:
- ***Main_codes/*** Core scripts for the primary analyses reported in the manuscript.
	- ***m1_AAT_Grades.m*** script processing and decompose the aesthetic agreement matrix to get latent components. 
	- ***m2_Predict_Dimension1.m*** script for neural decoding of the visual semantics component and idetification of the corresponding neural signature.
	- ***m2_Predict_Dimension2.m*** script for neural decoding of the hedonic value component and idetification of the corresponding neural signature.
	- ***m3_Predict_crossmodel.m*** script to evaluate cross-prediction perfomance using a permutation-based procedure.
	- ***m4_Model_generalization*** script to test the generalizability of both neural signatures using HCP tasks. Requires the pre-calculated file ([HCP_generalization_contrast.mat](https://osf.io/8hfae/files/wc4zf?view_only=1955d0ed099a4fc68dcdf1a7efe4b5b5)).
	- ***m5_Neurosynth_decoding_onSurface.m*** script for surface-based Neurosynth decoding for neural signatures. Requires the pre-extracted file ([data_neurosynth_topic.mat](https://osf.io/4ys29?view_only=1955d0ed099a4fc68dcdf1a7efe4b5b5)).
	- ***m6_RSA_trials.m*** script to run cortical surface-based RSA searchlight and subcortical regional RSA.
	- ***Data/*** Folder containing pre-saved metadata data files required for analysis.
	  ￼
- ***Validation_codes/*** scripts for supplementary analyses and additional validation procedures to ensure reproducibility.
	- ***Validation_matrixPCA_reliability.m*** script to conduct reliability analyses for the aesthetic agreement matrix and PCA solution.
	- ***Validation_matrixPCA_meaning.m*** script to conduct correlation analyses for aesthetic agreement matrix and PCA components.
	- ***Validation_PCA_meaning.m*** script to test the significance of PCA components.
	- ***Model_expressions_img.m*** script to estimate the model expression values for each image stimulus.
	- ***Validation_RSA/*** scripts for RSA validation analyses
		- ***get_RSAsearchlight_results.m*** function to perform cortical surface-based RSA searchlight.
		- ***run_RSAsearchlight_validation.m*** script to run validation analyses for cortical surface-based RSA searchlight.
		- ***load_RSAsearchlight_results.m*** script to load, combine and save individual resultant maps.
		- ***Validation_RSA_TFCE_correction.m*** script to conduct TFCE correction on surface-based RSA searchlight results.
		- ***Validation_distance_RSA_subcortical.m*** script to conduct regional RSA for subcortex.

- ***Utilities/*** Supporting functions used across analysis pipelines.  ￼
	- ***GenerateCV.m*** function to generate multiple cross-validation divisions.
	- ***fast_haufe.m*** function to conduct the Haufe transform on model weights.
	- ***get_permutation_P.m*** function to compute statistical significance based on permutation distributions.
	- ***parallel_analysis.m*** function to conduct parallel analysis to determine PCA component retention.
	- ***pca_structure_comparision.m*** function to estimate the RV coeffient or congruence coefficient. 
	- ***g_ls.m*** function to list filepaths. 
	- ***cluster_identification.m*** script to find clusters and report associated brain regions.
	- ***HCPtemplates/*** HCP-based group-level template files used in the analyses, including mask of medial wall and inflated cortical surfaces from the [HCP S1200 GroupAvg](https://balsa.wustl.edu/reference/pkXDZ), as well as Scale IV of the [Melbourne Subcortex Atlas](https://github.com/yetianmed/subcortex)

- ***Figure_codes/*** Jupyter notebooks and associated output data for reproducing figures and visual results presented in the manuscript.
	- ***Figure1-5.ipynb*** Notebooks for generating each main figure separately. The file ([circleimage.npy](https://osf.io/8hfae/files/njyb5?view_only=1955d0ed099a4fc68dcdf1a7efe4b5b5)) is required for visualization in Figure2.
	- ***SFigures.ipynb*** Notebook for generationg supplementary figures.
	- ***Figure_data/*** pre-saved output files used for figure generation and visualization.


## Prerequisites
- MATLAB Dependencies:
	- [CablabCore](https://github.com/canlab/CanlabCore);
	- [CoSMoMVPA](https://cosmomvpa.org/index.html);
	- [GIfTI library](https://github.com/gllmflndn/gifti);
	- [cifti-matlab](https://github.com/Washington-University/cifti-matlab).

- Python Dependencies:
	- For reproducing the figures using Jupyter notebooks, the following Python packages are required: NumPy, Pandas, Matplotlib, Seaborn, SciPy, scikit-learn, H5py, pingouin, and wordcloud.

## AI models and External Tools:
- [MUSIQ](https://research.google/blog/musiq-assessing-image-aesthetic-and-technical-quality-with-multi-scale-transformers/) model to generate aesthetic quality score. See the example [script](https://www.kaggle.com/code/neocosmliang/image-aesthetic-scoring-with-musiq-models) on Kaggle.
- [Aesthetics-Toolbox](https://link.springer.com/article/10.3758/s13428-025-02632-3) to generate low-level viusal quantitative image properties (QIPs). Available via the [cloud interface](https://aesthetics-toolbox.streamlit.app/) or the [GitHub repository](https://github.com/RBartho/Aesthetics-Toolbox).
- [CLIP](https://huggingface.co/openai/clip-vit-large-patch14) model to extract high-level semantic embeddings. Requires the following Python librarie: PyTorch, Pillow, and [OpenAI CLIP](https://github.com/openai/CLIP).
- [EmoNet](https://www.science.org/doi/10.1126/sciadv.aaw4358) model to generate emotion-related image categories. Requires the [pretrained model](https://osf.io/htfdm/) and the associated [codes](https://github.com/ecco-laboratory/EmoNet).


## Data Availability
The raw data generated in this study cannot be made publicly available due to restrictions imposed by institutional ethics approval and the informed consent obtained from study participants. Individual-specific brain maps (e.g., fMRI response estimates) are available under restricted access to qualified researchers, contingent upon approval of a data use agreement and compliance with institutional ethics guidelines. Access requests should be submitted to the corresponding author (Prof. Deniz Vatansever, deniz@fudan.edu.cn) and will be reviewed by the institutional data access committee. Requests will typically receive a response within 4 weeks. Approved data will be made available for non-commercial research purposes for a period of 5 years following approval. All group-level statistical brain maps supporting the findings of this study are publicly available at the BALSA repository (https://balsa.wustl.edu/study/view/58NkK).


