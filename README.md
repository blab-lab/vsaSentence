Read the paper
------
"Increased vowel contrast and intelligibility in connected speech induced by sensorimotor adaptation" was authored by Sara D. Beach, Sophie A. Johnson, Benjamin Parrell, and Caroline A. Niziolek. A preprint is available here: [placeholder]

Run the experiment
------
Users will also need the code in the free-speech repository (https://github.com/carrien/free-speech). To ensure compatibility, use a version from ~August 2024.

Analyze the data
------
Data analysis was performed in MATLAB 2022a. 

The main function is `stats_vsaSentencePaperFigs.m`, which is organized by the corresponding paper figure. 

You will need to update the path on line XX in order to load the following data:

`speakerData.mat`

`listenerData.mat`

`avs_vsa_41.mat`

`aavs.mat`

`sentenceVow_41.mat`

`transferVow_41.mat`

`segmentDuration_sentence_41.mat`

You will also need code in the free-speech repository (https://github.com/carrien/free-speech). To ensure compatibility, use a version from ~August 2024.

Generate the figures
------
Figures were generated using MATLAB 2022a. The main function is `plot_vsaSentencePaperFigs.m`.

You will need to update the path on line XX in order to load the following data:
- `expt.mat`
- `dataVals_sentences.mat`
- `avs_vsa_41.mat`
- `aavs.mat`
- `sentenceVow_41.mat`

⋅⋅⋅⋅* `transferVow_41.mat`

⋅⋅⋅⋅* `segmentDuration_sentence_41.mat`

⋅⋅⋅⋅* `speakerData.mat`
