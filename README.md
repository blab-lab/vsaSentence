Read the paper
------
"Increased vowel contrast and intelligibility in connected speech induced by sensorimotor adaptation" was authored by Sara D. Beach, Sophie A. Johnson, Benjamin Parrell, and Caroline A. Niziolek. A preprint is available on bioRxiv at <https://doi.org/10.1101/2024.08.04.606537>.

Run the experiment
------
The vsaSentence experiment was run in MATLAB. The main function is `run_vsaSentence_expt.m`.

You will also need code in the free-speech repository (<https://github.com/carrien/free-speech>), the blab-lab fork of Audapter (https://github.com/blab-lab/audapter_mex), and Audapter functions (https://github.com/blab-lab/audapter_matlab). To ensure software compatibility, use a version released between 2021 and 2023, as the data were collected during that period.

Access the data
------
Our data have been deposited at <https://osf.io/3fhbg>.

Analyze the data
------
Data analysis was performed in MATLAB 2022a. The main function is `stats_vsaSentencePaperFigs.m`, which is organized by the corresponding figure in the paper. Make sure to update the path on line XX.

You will also need code in the free-speech repository (<https://github.com/carrien/free-speech>). To ensure compatibility, use a version from ~August 2024.

Generate the figures
------
Figures were generated using MATLAB 2022a. The main function is `plot_vsaSentencePaperFigs.m`. Make sure to update the paths on lines 43 and 45.

- `get_dataPaths_vsaSentence.m`
- `run_vsaSentence_audapter.m`
- `gen_data2plot.m`
- `gen_data2plot_suppData.m`
- `plot_pairedData_1axVowel.m`

This code relies on `textborder.m`, available at <https://www.mathworks.com/matlabcentral/fileexchange/27383-textborder-higher-contrast-text-using-a-1-pixel-thick-border/files/textborder.m>.
