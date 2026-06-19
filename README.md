Read the paper
------
"Increased vowel contrast and intelligibility in connected speech induced by sensorimotor adaptation" was authored by Sara D. Beach, Sophie A. Johnson, Benjamin Parrell, and Caroline A. Niziolek. A preprint is available at <https://doi.org/10.1101/2024.08.04.606537>.

Run the experiment
------
The vsaSentence experiment was run in MATLAB. The main function is `run_vsaSentence_expt.m`.

You will also need code in the free-speech repository (<https://github.com/carrien/free-speech>). To ensure compatibility, use a version from ~2021–2023.

Access the data
------
Our data have been deposited at <https://osf.io/3fhbg>.

Analyze the data
------
Data analysis was performed in MATLAB 2022a. The main function is `stats_vsaSentencePaperFigs.m`, which is organized by the corresponding figure in the paper. Make sure to update the path on line XX.

You will also need code in the free-speech repository (<https://github.com/carrien/free-speech>). To ensure compatibility, use a version from ~August 2024.

Generate the figures
------
Figures were generated using MATLAB 2022a. The main function is `plot_vsaSentencePaperFigs.m`. Make sure to update the path on line XX.

- `expt.mat`
- `dataVals_sentences.mat`
- `avs_vsa_41.mat`
- `aavs_41.mat`
- `sentenceVow_41.mat`
- `transferVow_41.mat`
- `segmentDuration_sentence_41.mat`
- `speakerData.mat`
- `listenerData.mat`

This code relies on `textborder.m`, available at <https://www.mathworks.com/matlabcentral/fileexchange/27383-textborder-higher-contrast-text-using-a-1-pixel-thick-border/files/textborder.m>.
