function [expt] = run_vsaSentence_audapter(expt,conds2run)
% Experiment engine for vsaSentence.

if nargin < 1, expt = []; end

if isfield(expt,'dataPath')
    outputdir = expt.dataPath;
else
    warning('Setting output directory to current directory: %s\n',pwd);
    outputdir = pwd;
end

% assign folder for saving trial data
% create output directory if it doesn't exist
trialdirname = 'temp_trials';
trialdir = fullfile(outputdir,trialdirname);
if ~exist(trialdir,'dir')
    mkdir(outputdir,trialdirname)
end

%set RMS threshold for deciding if a trial is good or not
rmsThresh = 0.04;

%% set up stimuli
% set experiment-specific fields (or pass them in as 'expt')
% set missing expt fields to defaults

expt = set_exptDefaults(expt);

if nargin < 2 || isempty(conds2run), conds2run = expt.conds; end

% define trials to run based on conditions
trials2run = [];
for c = 1:length(conds2run)
    condname = conds2run{c};
    trials2run = [trials2run expt.inds.conds.(condname)];
end

transferCond = ['transfer1'; 'transfer2'; 'transfer3'];
if strcmp(condname,transferCond(1,:))||strcmp(condname,transferCond(2,:))||strcmp(condname,transferCond(3,:))
    stimtxtsize = 200;
else stimtxtsize = 45;
end
%% set up audapter
audioInterfaceName = 'Focusrite USB'; %SMNG default for Windows 10
Audapter('deviceName', audioInterfaceName);
Audapter('ost', '', 0);     % nullify online status tracking/
Audapter('pcf', '', 0);     % pert config files (use pert field instead)

% set audapter params
p = getAudapterDefaultParams(expt.gender); % get default params
% overwrite selected params with experiment-specific values:
p = add2struct(p,expt.audapterParams);
p.bShift = 1;
p.bRatioShift = 0;
p.bMelShift = 1;
p.bShift2D = 1; %flag for 2D experiment

% set noise
w = get_noiseSource(p);
Audapter('setParam', 'datapb', w, 1);
p.fb = 3;          % set feedback mode to 3: speech + noise
p.fb3Gain = 0.02;   % gain for noise waveform
p.fb2Gain = 0.16; % 77

%% initialize Audapter
AudapterIO('init', p);
Audapter(3,'pertf1',p.pertF1);
Audapter(3,'pertf2',p.pertF2);
Audapter(3,'pertAmp2D',p.pertAmp2D);
Audapter(3,'pertPhi2D',p.pertPhi2D);

%% run experiment
% setup figures
h_fig = setup_exptFigs;
get_figinds_audapter; % names figs: stim = 1, ctrl = 2, dup = 3;
h_sub = get_subfigs_audapter(h_fig(ctrl),1);

% give instructions and wait for keypress
if strcmp(condname,transferCond(1,:))||strcmp(condname,transferCond(2,:))||strcmp(condname,transferCond(3,:))
    h_ready = draw_exptText(h_fig,.5,.5,expt.instruct.wordTxt,expt.instruct.txtparams);
else
    h_ready = draw_exptText(h_fig,.5,.5,expt.instruct.sentenceTxt,expt.instruct.txtparams);
end
pause
delete_exptText(h_fig,h_ready)

% run trials
pause(1)
if expt.isRestart
    trials2run = trials2run(trials2run >= expt.startTrial);
end
for itrial = 1:length(trials2run)  % for each trial
    bGoodTrial = 0;
    while ~bGoodTrial
        % pause if 'p' is pressed
        if get_pause_state(h_fig,'p')
            pause_trial(h_fig);
        end

        % set trial index
        trial_index = trials2run(itrial);

        % plot trial number in experimenter view
        cla(h_sub(1))
        ctrltxt = sprintf('trial: %d/%d, cond: %s',trial_index,expt.ntrials,expt.listConds{trial_index});
        ctrltxt = regexprep(ctrltxt, '_', '\\_'); % fixes formatting if cond has underscore
        h_trialn = text(h_sub(1),0,0.5,ctrltxt,'Color','black', 'FontSize',30, 'HorizontalAlignment','center');

        % set text
        if (strcmp(condname,transferCond(1,:))||strcmp(condname,transferCond(2,:))||strcmp(condname,transferCond(3,:)))&& isfield(expt,'listTransfer')
            txt2display = expt.listTransfer{trial_index};
        else
            txt2display = expt.listWords{trial_index};
        end
        color2display = expt.colorvals{expt.allColors(trial_index)};

        % set new perturbation
        p.pertAmp2D = expt.shiftScaleFact(trial_index) * expt.audapterParams.pertAmp2D;
        Audapter('setParam','pertAmp2D',p.pertAmp2D)
        
        %set noise
        if p.fb ~= expt.allNoise(trial_index)
            p.fb = expt.allNoise(trial_index);
            Audapter('setParam', 'fb', p.fb)
            % initialize Audapter
            AudapterIO('init',p);
        end
        

        % run trial in Audapter
        Audapter('reset'); %reset Audapter
        fprintf('starting trial %d\n',trial_index)
        Audapter('start'); %start trial

        fprintf('Audapter started for trial %d\n',trial_index)
        % display stimulus
        h_text(1) = draw_exptText(h_fig,.5,.5,txt2display, 'Color',color2display, 'FontSize',stimtxtsize, 'HorizontalAlignment','center');
        if strcmp(condname,transferCond(1,:))||strcmp(condname,transferCond(2,:))||strcmp(condname,transferCond(3,:))
            pause(expt.timing.stimdurTrns);
        else pause(expt.timing.stimdur);
        end

        % stop trial in Audapter
        Audapter('stop');
        fprintf('Audapter ended for trial %d\n',trial_index)
        % get data
        data = AudapterIO('getData');

        % plot shifted spectrogram
        subplot_expt_spectrogram(data, p, h_fig, h_sub)
        
        %check if good trial
        bGoodTrial = check_rmsThresh(data,rmsThresh,h_sub(3));
                
        % clear screen
        delete_exptText(h_fig,h_text)
        clear h_text

        if ~bGoodTrial
            h_text = draw_exptText(h_fig,.5,.2,'Please speak a little louder','FontSize',40,'HorizontalAlignment','center','Color','y');
            pause(1)
            delete_exptText(h_fig,h_text)
            clear h_text
        end
        
        % add intertrial interval + jitter
        pause(expt.timing.interstimdur + rand*expt.timing.interstimjitter);

        % save trial
        trialfile = fullfile(trialdir,sprintf('%d.mat',trial_index));
        save(trialfile,'data')

        % clean up data
        clear data
    end
    % display break text
    if itrial == length(trials2run)
        breaktext = sprintf('Thank you!\n\nPlease wait.');
        draw_exptText(h_fig,.5,.5,breaktext,expt.instruct.txtparams);
        pause(3);
    elseif any(expt.breakTrials == trial_index)
        breaktext = sprintf('Time for a break!\n%d of %d trials done.\n\nPress the space bar to continue.',itrial,length(trials2run));
        h_break = draw_exptText(h_fig,.5,.5,breaktext,expt.instruct.txtparams);
        pause
        delete_exptText(h_fig,h_break)
        pause(1)
     end
    
end

%% write experiment data and metadata
if ismember(conds2run,'retention')
    
    % collect trials into one variable
    alldata = struct;
    fprintf('Processing data\n')
    for i = 1:trials2run(end)
        load(fullfile(trialdir,sprintf('%d.mat',i)))
        names = fieldnames(data);
        for j = 1:length(names)
            alldata(i).(names{j}) = data.(names{j});
        end
    end
    
    % save data
    fprintf('Saving data... ')
    clear data
    data = alldata;
    save(fullfile(outputdir,'data.mat'), 'data')
    fprintf('saved.\n')
    
    % save expt
    fprintf('Saving expt... ')
    save(fullfile(outputdir,'expt.mat'), 'expt')
    fprintf('saved.\n')
    
    % remove temp trial directory
    fprintf('Removing temp directory... ')
    rmdir(trialdir,'s');
    fprintf('done.\n')
    
end

%% close figures
close(h_fig)
