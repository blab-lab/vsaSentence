Read the paper
------
"Increased vowel contrast and intelligibility in connected speech induced by sensorimotor adaptation" was authored by Sara D. Beach, Sophie A. Johnson, Benjamin Parrell, and Caroline A. Niziolek. A preprint is available on bioRxiv at <https://doi.org/10.1101/2024.08.04.606537>.

Run the experiment
------
The vsaSentence experiment was run in MATLAB. The main function is `run_vsaSentence_expt.m`.

You will also need code in the free-speech repository (<https://github.com/carrien/free-speech>), the blab-lab fork of Audapter (https://github.com/blab-lab/audapter_mex), and Audapter functions (https://github.com/blab-lab/audapter_matlab). To ensure software compatibility, use a version released between 2021 and 2023, as the data were collected during that period.

Access the data
------
Our data have been deposited at <https://osf.io/3fhbg>. To reproduce our workflow (we used MATLAB 2022a), follow these steps:

Process the speakers' data
------
N=41 speakers contributed data to vsaSentence. Point to the location of the data using `get_dataPaths_vsaSentence.m`. Make sure to update the path on line 9.

You will also need code in the free-speech repository (<https://github.com/carrien/free-speech>). To ensure compatibility, use a version from ~August 2024.

Begin making a wide table (suitable for correlations) with one row per speaker using `gen_speakerData.m` (path on line 7).

The main vowel-data assembling step is:
`sentenceVow = gen_vowelSegment_dataTable(dataPaths, 0);`
`transferVow = gen_vowelSegment_dataTable(dataPaths, 1);`

Generate long tables (suitable for RM-ANOVA) of the global vowel-space measures using `gen_AVS_VSA.m` (path on line 4) and `gen_AAVS.m` (path on line 6). For reference, `gen_AVS_VSA` calls `get_AVS_VSA`, which in turn calls `calc_AVS` and `calc_VSA`; `gen_AAVS` calls `get_AAVS`, which in turn calls `calc_AAVS`.

Generate the data for the clear-speech metrics (duration, peak intensity, max f0, and f0 range) using `gen_supplementaryData.m` (path on line 11).

Generate the data for segment (vowel and consonant) duration using `gen_segmentDuration_dataTable(dataPaths, 0);` and `gen_segmentDuration_dataTable(dataPaths, 1);` (path on line 14).

Now you have generated and saved the following results files:
`sentenceVow_41.mat`
`transferVow_41.mat`
`avs_vsa_41.mat`
`aavs_41.mat`
`supplementaryData_sentence_41.mat`
`supplementaryData_transfer_41.mat`
`segmentDuration_sentence_41.mat`
`segmentDuration_transfer_41.mat`.
Add them to the existing speakerData using `add_speakerData.m` (path on line 7).

Process the listeners' data
------
Raw perceptual data were downloaded from Prolific. Calculate listeners' accuracy in transcribing sentences and identifying transfer words using `gen_sentenceAcc.m` (path on line 30) and `gen_transferAcc.m` (path on line 22), and then add it to the existing speakerData using `add_speakerData.m` (path on line 7).

Analyze the data
------
The main function is `stats_vsaSentencePaperFigs.m`, which is organized by the corresponding figure in the paper. Make sure to update the path on line 15.

Generate the figures
------
The main function is `plot_vsaSentencePaperFigs.m`. Make sure to update the paths on lines 43 and 45.

This code uses `varycolor.m`, available at <https://www.mathworks.com/matlabcentral/fileexchange/21050-varycolor>, and `textborder.m`, available at <https://www.mathworks.com/matlabcentral/fileexchange/27383-textborder>.
