function stats_vsaSentencePaperFigs(figs2stat)
%STATS_VSASENTENCEPAPERFIGS Statistics for each figure in the vsaSentence paper. 

% 0 = (Not a figure) Participant demographics
% 1 = (Not a figure) Experiment: Tokens per sentence vowel
% 2 = Fig 2: AVS (and VSA and AAVS)
% 3 = Fig 3: Vowel-specific analyses
% 4 = Fig 4: Clear speech
% 5 = Fig 5: Intelligibility
% 6 = (Not a figure) Predictors of adaptation
% 7 = (Tables S1, S2, S3, S4) Perturbation awareness + strategy use

if nargin < 1 || isempty(figs2stat), figs2stat = 1; end

dataPath = get_exptLoadPath('vsaSentence');

%% Fig 0: Participant demographics

[bStat,~] = ismember(0,figs2stat);
if bStat

    load(fullfile(dataPath, 'speakerData.mat'), 'speakerData');   
    S = speakerData;
    min(S.age)
    max(S.age)
    sum(S.male)

    load(fullfile(dataPath, 'listenerData.mat'), 'listenerData');
    L = listenerData;
    L(L.FirstSession==1,:) = [];
    L(strcmp(L.SNR, '-28dBSNR'),:) = [];
    L(strcmp(L.SNR, '-10dBSNR'),:) = []; % should leave n=164
    mean(L.Age)
    std(L.Age)
    groupcounts(L, "Sex")
    groupcounts(L, "EthnicitySimplified")
    groupcounts(L, "StudentStatus")
    groupcounts(L, "EmploymentStatus")

end


%% Fig 1: Experiment: Tokens per sentence vowel

[bStat,~] = ismember(1,figs2stat);
if bStat
    
    load(fullfile(dataPath, 'sentenceVow_41.mat'), 'sentenceVow');
    nVow = groupcounts(sentenceVow, ["subj", "cond", "phase", "vow"]);
    nVow.subj  = nominal(nVow.subj);
    nVow.cond  = nominal(nVow.cond);
    nVow.phase = nominal(nVow.phase);
    nVow.vow   = nominal(nVow.vow);
    lme = fitlme(nVow, 'GroupCount ~ 1 + cond*phase*vow + (1|subj)')
    anova(lme, 'DFMethod', 'Satterthwaite')

end


%% Fig 2: Vowel-space measures

[bStat,~] = ismember(2,figs2stat);
if bStat

    %%%%%%%%%%
    % SENTENCE
    %%%%%%%%%%
    
    % ----- AVS Norm Within Session -----
    fprintf('\n*** Sentence, AVS Norm Within Session ***\n');
    
    load(fullfile(dataPath, 'avs_vsa_41.mat'), 'AVS_VSA');
    sen = AVS_VSA(strcmp(AVS_VSA.phase, 'hold6') | strcmp(AVS_VSA.phase, 'washout') | strcmp(AVS_VSA.phase, 'retention'),:); % select phases of interest
    
    [p,t,stats] = anovan(sen.avsNormWithinSession, {sen.cond sen.phase sen.adaptFirst sen.subj}, ...
                        'model', 'full', 'random', 4, 'nested', [0 0 0 0; 0 0 0 0; 0 0 0 0; 0 0 1 0], 'varnames', {'cond','phase','adaptFirst','subj'}); %#ok<*ASGLU> 

    clear p t stats;
    [~,p(1),~,stats(1)] = ttest(sen.avsNormWithinSession(ismember(sen.cond,'adapt') & ismember(sen.phase,'hold6')), 1);
    [~,p(2),~,stats(2)] = ttest(sen.avsNormWithinSession(ismember(sen.cond,'adapt') & ismember(sen.phase,'washout')), 1);   
    [~,p(3),~,stats(3)] = ttest(sen.avsNormWithinSession(ismember(sen.cond,'adapt') & ismember(sen.phase,'retention')), 1);
    [~,p(4),~,stats(4)] = ttest(sen.avsNormWithinSession(ismember(sen.cond,'null')  & ismember(sen.phase,'hold6')), 1);
    [~,p(5),~,stats(5)] = ttest(sen.avsNormWithinSession(ismember(sen.cond,'null')  & ismember(sen.phase,'washout')), 1);
    [~,p(6),~,stats(6)] = ttest(sen.avsNormWithinSession(ismember(sen.cond,'null')  & ismember(sen.phase,'retention')), 1);
    threshold = 0.05 ./ (length(p):-1:1) % Holm-Bonferroni
    [pSort,pInd] = sort(p) % each sorted p must be less than its corresponding threshold
    
    meanEffectSize(sen.avsNormWithinSession(ismember(sen.cond,'adapt') & ismember(sen.phase,'hold6')), Mean=1, Effect="cohen")
    meanEffectSize(sen.avsNormWithinSession(ismember(sen.cond,'adapt') & ismember(sen.phase,'washout')),  Mean=1, Effect="cohen")
    meanEffectSize(sen.avsNormWithinSession(ismember(sen.cond,'adapt') & ismember(sen.phase,'retention')),  Mean=1, Effect="cohen")
    meanEffectSize(sen.avsNormWithinSession(ismember(sen.cond,'null')  & ismember(sen.phase,'hold6')),  Mean=1, Effect="cohen")
    meanEffectSize(sen.avsNormWithinSession(ismember(sen.cond,'null')  & ismember(sen.phase,'washout')),  Mean=1, Effect="cohen")
    meanEffectSize(sen.avsNormWithinSession(ismember(sen.cond,'null')  & ismember(sen.phase,'retention')),  Mean=1, Effect="cohen")
    
    groupsummary(sen, {'cond'}, {'mean','std'}, {'avsNormWithinSession'})

    % ----- AVS Norm First Session -----
    fprintf('\n*** Sentence, AVS Norm First Session ***\n');
    
    [p,t,stats] = anovan(sen.avsNormFirstSession, {sen.cond sen.phase sen.adaptFirst sen.subj}, ...
                        'model', 'full', 'random', 4, 'nested', [0 0 0 0; 0 0 0 0; 0 0 0 0; 0 0 1 0], 'varnames', {'cond','phase','adaptFirst','subj'});
    
    groupsummary(sen, {'cond','adaptFirst'}, {'mean','std'}, {'avsNormFirstSession'})
    
    sen_adaptation = sen(strcmp(sen.phase, 'hold6'),:); % split b/c of session type x phase interaction
    sen_washout    = sen(strcmp(sen.phase, 'washout'),:);
    sen_retention  = sen(strcmp(sen.phase, 'retention'),:);
    
    [p,t,stats] = anovan(sen_adaptation.avsNormFirstSession, {sen_adaptation.cond sen_adaptation.adaptFirst sen_adaptation.subj}, ...
                        'model', 'full', 'random', 3, 'nested', [0 0 0; 0 0 0; 0 1 0], 'varnames', {'cond','adaptFirst','subj'});

    groupsummary(sen_adaptation, {'cond'}, {'mean','std'}, {'avsNormFirstSession'})

    [p,t,stats] = anovan(sen_washout.avsNormFirstSession, {sen_washout.cond sen_washout.adaptFirst sen_washout.subj}, ...
                        'model', 'full', 'random', 3, 'nested', [0 0 0; 0 0 0; 0 1 0], 'varnames', {'cond','adaptFirst','subj'});

    groupsummary(sen_washout, {'cond'}, {'mean','std'}, {'avsNormFirstSession'})
    
    [p,t,stats] = anovan(sen_retention.avsNormFirstSession, {sen_retention.cond sen_retention.adaptFirst sen_retention.subj}, ...
                        'model', 'full', 'random', 3, 'nested', [0 0 0; 0 0 0; 0 1 0], 'varnames', {'cond','adaptFirst','subj'});

    groupsummary(sen_retention, {'cond'}, {'mean','std'}, {'avsNormFirstSession'})
    
    % ----- VSA Norm Within Session -----
    fprintf('\n*** Sentence, VSA Norm Within Session ***\n');
    
    [p,t,stats] = anovan(sen.vsa4NormWithinSession, {sen.cond sen.phase sen.adaptFirst sen.subj}, ...
                        'model', 'full', 'random', 4, 'nested', [0 0 0 0; 0 0 0 0; 0 0 0 0; 0 0 1 0], 'varnames', {'cond','phase','adaptFirst','subj'});
    
    % ----- VSA Norm First Session -----
    fprintf('\n*** Sentence, VSA Norm First Session ***\n');
    
    [p,t,stats] = anovan(sen.vsa4NormFirstSession, {sen.cond sen.phase sen.adaptFirst sen.subj}, ...
                        'model', 'full', 'random', 4, 'nested', [0 0 0 0; 0 0 0 0; 0 0 0 0; 0 0 1 0], 'varnames', {'cond','phase','adaptFirst','subj'});

    % ----- AAVS Norm Within Session -----
    fprintf('\n*** Sentence, AAVS Norm Within Session ***\n');
    
    load(fullfile(dataPath, 'aavs_41.mat'), 'AAVS');
    sen = AAVS(strcmp(AAVS.phase, 'hold6') | strcmp(AAVS.phase, 'washout') | strcmp(AAVS.phase, 'retention'),:);
    [p,t,stats] = anovan(sen.aavsNormWithinSession, {sen.cond sen.phase sen.adaptFirst sen.subj}, ...
                        'model', 'full', 'random', 4, 'nested', [0 0 0 0; 0 0 0 0; 0 0 0 0; 0 0 1 0], 'varnames', {'cond','phase','adaptFirst','subj'});
    
    sen_adaptFirst  = sen((strcmp(sen.cond, 'adapt') & (sen.adaptFirst==1)),:); % split b/c of session type x session order interaction
    sen_adaptSecond = sen((strcmp(sen.cond, 'adapt') & (sen.adaptFirst==0)),:);
    sen_nullFirst   = sen((strcmp(sen.cond, 'null') & (sen.adaptFirst==0)),:);
    sen_nullSecond  = sen((strcmp(sen.cond, 'null') & (sen.adaptFirst==1)),:);
    sen_first       = [sen_adaptFirst; sen_nullFirst];
    sen_second      = [sen_adaptSecond; sen_nullSecond];
    
    [p,t,stats] = anovan(sen_first.aavsNormWithinSession, {sen_first.cond sen_first.phase}, 'model', 'full', 'varnames', {'cond','phase'}); % can't include subj
    
    [p,t,stats] = anovan(sen_second.aavsNormWithinSession, {sen_second.cond sen_second.phase}, 'model', 'full', 'varnames', {'cond','phase'}); % can't include subj
    
    groupsummary(sen_second, {'cond'}, {'mean','std'}, {'aavsNormWithinSession'})
    
    % t-tests for difference from 1
    clear p t stats;
    [~,p(1),~,stats(1)] = ttest(sen_second.aavsNormWithinSession(ismember(sen_second.cond,'adapt') & ismember(sen_second.phase,'hold6')), 1);
    [~,p(2),~,stats(2)] = ttest(sen_second.aavsNormWithinSession(ismember(sen_second.cond,'adapt') & ismember(sen_second.phase,'washout')), 1);   
    [~,p(3),~,stats(3)] = ttest(sen_second.aavsNormWithinSession(ismember(sen_second.cond,'adapt') & ismember(sen_second.phase,'retention')), 1);
    [~,p(4),~,stats(4)] = ttest(sen_second.aavsNormWithinSession(ismember(sen_second.cond,'null')  & ismember(sen_second.phase,'hold6')), 1);
    [~,p(5),~,stats(5)] = ttest(sen_second.aavsNormWithinSession(ismember(sen_second.cond,'null')  & ismember(sen_second.phase,'washout')), 1);
    [~,p(6),~,stats(6)] = ttest(sen_second.aavsNormWithinSession(ismember(sen_second.cond,'null')  & ismember(sen_second.phase,'retention')), 1);
    threshold = 0.05 ./ (length(p):-1:1) % Holm-Bonferroni
    [pSort,pInd] = sort(p) % each sorted p must be less than its corresponding threshold

    meanEffectSize(sen.aavsNormWithinSession(ismember(sen.cond,'adapt') & ismember(sen.phase,'hold6')), Mean=1, Effect="cohen")
    
    groupsummary(sen_second, {'cond','phase'}, {'mean','std'}, {'aavsNormWithinSession'})
        
    % ----- AAVS Norm First Session -----
    fprintf('\n*** Sentence, AAVS Norm First Session ***\n');
    
    [p,t,stats] = anovan(sen.aavsNormFirstSession, {sen.cond sen.phase sen.adaptFirst sen.subj}, ...
                        'model', 'full', 'random', 4, 'nested', [0 0 0 0; 0 0 0 0; 0 0 0 0; 0 0 1 0], 'varnames', {'cond','phase','adaptFirst','subj'});    
    
    %%%%%%%%%%
    % TRANSFER
    %%%%%%%%%%
    
    % ----- AVS Transfer Norm Within Session -----
    fprintf('\n*** Transfer, AVS Norm Within Session ***\n');
    
    tra = AVS_VSA(strcmp(AVS_VSA.phase, 'transfer3'),:); % select phase of interest
    [p,t,stats] = anovan(tra.avsNormWithinSession, {tra.cond tra.adaptFirst tra.subj}, ...
                        'model', 'full', 'random', 3, 'nested', [0 0 0; 0 0 0; 0 1 0], 'varnames', {'cond','adaptFirst','subj'});
    
    clear p t stats;
    [~,p(1),~,stats(1)] = ttest(tra.avsNormWithinSession(ismember(tra.cond,'adapt')), 1)
    [~,p(2),~,stats(2)] = ttest(tra.avsNormWithinSession(ismember(tra.cond,'null')), 1)
    threshold = 0.05 ./ (length(p):-1:1) % Holm-Bonferroni
    [pSort,pInd] = sort(p) % each sorted p must be less than its corresponding threshold

    meanEffectSize(tra.avsNormWithinSession(ismember(tra.cond,'adapt')), Mean=1, Effect="cohen")
    meanEffectSize(tra.avsNormWithinSession(ismember(tra.cond,'null')), Mean=1, Effect="cohen")
    
    groupsummary(tra, {'cond'}, {'mean','std'}, {'avsNormWithinSession'})
    
    % ----- VSA Transfer Norm Within Session -----
    fprintf('\n*** Transfer, VSA Norm Within Session ***\n');

    [p,t,stats] = anovan(tra.vsa4NormWithinSession, {tra.cond tra.adaptFirst tra.subj}, ...
                        'model', 'full', 'random', 3, 'nested', [0 0 0; 0 0 0; 0 1 0], 'varnames', {'cond','adaptFirst','subj'});
    
    groupsummary(tra, {'cond'}, {'mean','std'}, {'vsa4NormWithinSession'})
    
    % ----- AVS Transfer Norm First Session -----
    fprintf('\n*** Transfer, AVS Norm First Session ***\n');
    
    [p,t,stats] = anovan(tra.avsNormFirstSession, {tra.cond tra.adaptFirst tra.subj}, ...
                        'model', 'full', 'random', 3, 'nested', [0 0 0; 0 0 0; 0 1 0], 'varnames', {'cond','adaptFirst','subj'});
    
    groupsummary(tra, {'cond'}, {'mean','std'}, {'avsNormFirstSession'})
    
    % ----- VSA Transfer Norm First Session -----
    fprintf('\n*** Transfer, VSA Norm First Session ***\n');
    
    [p,t,stats] = anovan(tra.vsa4NormFirstSession, {tra.cond tra.adaptFirst tra.subj}, ...
                        'model', 'full', 'random', 3, 'nested', [0 0 0; 0 0 0; 0 1 0], 'varnames', {'cond','adaptFirst','subj'});
    
    groupsummary(tra, {'cond'}, {'mean','std'}, {'vsa4NormFirstSession'})

end


%% Fig 3: Vowel-specific analyses

[bStat,~] = ismember(3,figs2stat);
if bStat

    %%%%%%%%%%
    % SENTENCE
    %%%%%%%%%%
    fprintf('\n*** Sentence ***\n');

    load(fullfile(dataPath, 'sentenceVow_41.mat'), 'sentenceVow');
    sV = groupsummary(sentenceVow, ["subj","cond","phase","vow","speaker","adaptFirst"], "mean");
    
    sen = sV(strcmp(sV.phase, 'hold6'),:); % select phases of interest

    [p,t,stats] = anovan(sen.mean_centdistdiff, {sen.cond sen.adaptFirst sen.vow sen.subj}, ...
                        'model', 'full', 'random', 4, 'nested', [0 0 0 0; 0 0 0 0; 0 0 0 0; 0 1 0 0], 'varnames', {'cond','adaptFirst','vow','subj'});
            
    clear p t stats; % first test adapt vs. control (subjects stay in order for paired test)
    [~,p(1),~,stats(1)]   = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'AA')), sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'AA')));
    [~,p(2),~,stats(2)]   = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'AE')), sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'AE')));
    [~,p(3),~,stats(3)]   = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'AH')), sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'AH')));
    [~,p(4),~,stats(4)]   = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'AO')), sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'AO')));
    [~,p(5),~,stats(5)]   = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'AW')), sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'AW')));
    [~,p(6),~,stats(6)]   = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'AY')), sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'AY')));
    [~,p(7),~,stats(7)]   = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'EH')), sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'EH')));
    [~,p(8),~,stats(8)]   = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'ER')), sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'ER')));
    [~,p(9),~,stats(9)]   = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'EY')), sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'EY')));
    [~,p(10),~,stats(10)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'IH')), sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'IH')));
    [~,p(11),~,stats(11)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'IY')), sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'IY')));
    [~,p(12),~,stats(12)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'OW')), sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'OW')));
    [~,p(13),~,stats(13)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'UH')), sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'UH')));
    [~,p(14),~,stats(14)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'UW')), sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'UW')));
    threshold = 0.05 ./ (length(p):-1:1) % Holm-Bonferroni
    [pSort,pInd] = sort(p) % each sorted p must be less than its corresponding threshold

    clear p t stats; % then test each adapt and control vs. 0
    [~,p(1),~,stats(1)]   = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'AA')), 0);
    [~,p(2),~,stats(2)]   = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'AE')), 0);   
    [~,p(3),~,stats(3)]   = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'AH')), 0);
    [~,p(4),~,stats(4)]   = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'AO')), 0);
    [~,p(5),~,stats(5)]   = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'AW')), 0);
    [~,p(6),~,stats(6)]   = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'AY')), 0);
    [~,p(7),~,stats(7)]   = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'EH')), 0);
    [~,p(8),~,stats(8)]   = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'ER')), 0);   
    [~,p(9),~,stats(9)]   = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'EY')), 0);
    [~,p(10),~,stats(10)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'IH')), 0);
    [~,p(11),~,stats(11)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'IY')), 0);
    [~,p(12),~,stats(12)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'OW')), 0);
    [~,p(13),~,stats(13)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'UH')), 0);
    [~,p(14),~,stats(14)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'UW')), 0);
    [~,p(15),~,stats(15)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'AA')), 0);
    [~,p(16),~,stats(16)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'AE')), 0);   
    [~,p(17),~,stats(17)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'AH')), 0);
    [~,p(18),~,stats(18)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'AO')), 0);
    [~,p(19),~,stats(19)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'AW')), 0);
    [~,p(20),~,stats(20)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'AY')), 0);
    [~,p(21),~,stats(21)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'EH')), 0);
    [~,p(22),~,stats(22)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'ER')), 0);   
    [~,p(23),~,stats(23)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'EY')), 0);
    [~,p(24),~,stats(24)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'IH')), 0);
    [~,p(25),~,stats(25)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'IY')), 0);
    [~,p(26),~,stats(26)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'OW')), 0);
    [~,p(27),~,stats(27)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'UH')), 0);
    [~,p(28),~,stats(28)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'UW')), 0);
    threshold = 0.05 ./ (length(p):-1:1) % Holm-Bonferroni
    [pSort,pInd] = sort(p) % each sorted p must be less than its corresponding threshold

    %%%%%%%%%%
    % TRANSFER
    %%%%%%%%%%
    fprintf('\n*** Transfer ***\n');

    load(fullfile(dataPath, 'transferVow_41.mat'), 'transferVow');
    tV = groupsummary(transferVow, ["subj","cond","phase","vow","speaker","adaptFirst"], "mean");
    
    tra = tV(strcmp(tV.phase, 'transfer3'),:); % select phases of interest

    [p,t,stats] = anovan(tra.mean_centdistdiff, {tra.cond tra.adaptFirst tra.vow tra.subj}, ...
                        'model', 'full', 'random', 4, 'nested', [0 0 0 0; 0 0 0 0; 0 0 0 0; 0 1 0 0], 'varnames', {'cond','adaptFirst','vow','subj'});
    
    clear p t stats; % first test adapt vs. control (subjects stay in order for paired test)
    [~,p(1),~,stats(1)]   = ttest(tra.mean_centdistdiff(ismember(tra.cond,'adapt') & ismember(tra.vow,'AA')), tra.mean_centdistdiff(ismember(tra.cond,'null') & ismember(tra.vow,'AA')));
    [~,p(2),~,stats(2)]   = ttest(tra.mean_centdistdiff(ismember(tra.cond,'adapt') & ismember(tra.vow,'AE')), tra.mean_centdistdiff(ismember(tra.cond,'null') & ismember(tra.vow,'AE')));
    [~,p(3),~,stats(3)]   = ttest(tra.mean_centdistdiff(ismember(tra.cond,'adapt') & ismember(tra.vow,'AH')), tra.mean_centdistdiff(ismember(tra.cond,'null') & ismember(tra.vow,'AH')));
    [~,p(4),~,stats(4)]   = ttest(tra.mean_centdistdiff(ismember(tra.cond,'adapt') & ismember(tra.vow,'EH')), tra.mean_centdistdiff(ismember(tra.cond,'null') & ismember(tra.vow,'EH')));
    [~,p(5),~,stats(5)]   = ttest(tra.mean_centdistdiff(ismember(tra.cond,'adapt') & ismember(tra.vow,'EY')), tra.mean_centdistdiff(ismember(tra.cond,'null') & ismember(tra.vow,'EY')));
    [~,p(6),~,stats(6)]   = ttest(tra.mean_centdistdiff(ismember(tra.cond,'adapt') & ismember(tra.vow,'IH')), tra.mean_centdistdiff(ismember(tra.cond,'null') & ismember(tra.vow,'IH')));
    [~,p(7),~,stats(7)]   = ttest(tra.mean_centdistdiff(ismember(tra.cond,'adapt') & ismember(tra.vow,'IY')), tra.mean_centdistdiff(ismember(tra.cond,'null') & ismember(tra.vow,'IY')));
    [~,p(8),~,stats(8)]   = ttest(tra.mean_centdistdiff(ismember(tra.cond,'adapt') & ismember(tra.vow,'OW')), tra.mean_centdistdiff(ismember(tra.cond,'null') & ismember(tra.vow,'OW')));
    [~,p(9),~,stats(9)]   = ttest(tra.mean_centdistdiff(ismember(tra.cond,'adapt') & ismember(tra.vow,'UH')), tra.mean_centdistdiff(ismember(tra.cond,'null') & ismember(tra.vow,'UH')));
    [~,p(10),~,stats(10)] = ttest(tra.mean_centdistdiff(ismember(tra.cond,'adapt') & ismember(tra.vow,'UW')), tra.mean_centdistdiff(ismember(tra.cond,'null') & ismember(tra.vow,'UW')));
    threshold = 0.05 ./ (length(p):-1:1) % Holm-Bonferroni
    [pSort,pInd] = sort(p) % each sorted p must be less than its corresponding threshold

    clear p t stats; % then test each adapt and control vs. 0
    [~,p(1),~,stats(1)]   = ttest(tra.mean_centdistdiff(ismember(tra.cond,'adapt') & ismember(tra.vow,'AA')), 0);
    [~,p(2),~,stats(2)]   = ttest(tra.mean_centdistdiff(ismember(tra.cond,'adapt') & ismember(tra.vow,'AE')), 0);
    [~,p(3),~,stats(3)]   = ttest(tra.mean_centdistdiff(ismember(tra.cond,'adapt') & ismember(tra.vow,'AH')), 0);
    [~,p(4),~,stats(4)]   = ttest(tra.mean_centdistdiff(ismember(tra.cond,'adapt') & ismember(tra.vow,'EH')), 0);
    [~,p(5),~,stats(5)]   = ttest(tra.mean_centdistdiff(ismember(tra.cond,'adapt') & ismember(tra.vow,'EY')), 0);
    [~,p(6),~,stats(6)]   = ttest(tra.mean_centdistdiff(ismember(tra.cond,'adapt') & ismember(tra.vow,'IH')), 0);
    [~,p(7),~,stats(7)]   = ttest(tra.mean_centdistdiff(ismember(tra.cond,'adapt') & ismember(tra.vow,'IY')), 0);
    [~,p(8),~,stats(8)]   = ttest(tra.mean_centdistdiff(ismember(tra.cond,'adapt') & ismember(tra.vow,'OW')), 0);
    [~,p(9),~,stats(9)]   = ttest(tra.mean_centdistdiff(ismember(tra.cond,'adapt') & ismember(tra.vow,'UH')), 0);
    [~,p(10),~,stats(10)] = ttest(tra.mean_centdistdiff(ismember(tra.cond,'adapt') & ismember(tra.vow,'UW')), 0);
    [~,p(11),~,stats(11)] = ttest(tra.mean_centdistdiff(ismember(tra.cond,'null') & ismember(tra.vow,'AA')), 0);
    [~,p(12),~,stats(12)] = ttest(tra.mean_centdistdiff(ismember(tra.cond,'null') & ismember(tra.vow,'AE')), 0);
    [~,p(13),~,stats(13)] = ttest(tra.mean_centdistdiff(ismember(tra.cond,'null') & ismember(tra.vow,'AH')), 0);
    [~,p(14),~,stats(14)] = ttest(tra.mean_centdistdiff(ismember(tra.cond,'null') & ismember(tra.vow,'EH')), 0);
    [~,p(15),~,stats(15)] = ttest(tra.mean_centdistdiff(ismember(tra.cond,'null') & ismember(tra.vow,'EY')), 0);
    [~,p(16),~,stats(16)] = ttest(tra.mean_centdistdiff(ismember(tra.cond,'null') & ismember(tra.vow,'IH')), 0);
    [~,p(17),~,stats(17)] = ttest(tra.mean_centdistdiff(ismember(tra.cond,'null') & ismember(tra.vow,'IY')), 0);
    [~,p(18),~,stats(18)] = ttest(tra.mean_centdistdiff(ismember(tra.cond,'null') & ismember(tra.vow,'OW')), 0);
    [~,p(19),~,stats(19)] = ttest(tra.mean_centdistdiff(ismember(tra.cond,'null') & ismember(tra.vow,'UH')), 0);
    [~,p(20),~,stats(20)] = ttest(tra.mean_centdistdiff(ismember(tra.cond,'null') & ismember(tra.vow,'UW')), 0);
    threshold = 0.05 ./ (length(p):-1:1) % Holm-Bonferroni
    [pSort,pInd] = sort(p) % each sorted p must be less than its corresponding threshold

    % ----------------------------------------------------------------------------
    % ----- Subjectwise perturbation magnitude predicts vowelwise adaptation -----
    % ----------------------------------------------------------------------------
    fprintf('\n*** Subjectwise perturbation magnitude predicts vowelwise adaptation ***\n');

    load(fullfile(dataPath, 'sentenceVow_41.mat'), 'sentenceVow');
    sV = groupsummary(sentenceVow, ["subj","cond","phase","vow","speaker","adaptFirst"], "mean");
    sen = sV(strcmp(sV.cond, 'adapt'),:); % adapt only
    sen = sen(strcmp(sen.phase, 'hold6'),:); % select phases of interest
    sen.mean_pertsize = sen.mean_centdist/2;
    sen.vow = nominal(sen.vow);
    sen.subj = nominal(sen.subj);

    lme = fitlme(sen, 'mean_centdistdiff ~ mean_pertsize + (1+mean_pertsize|subj) + (1+mean_pertsize|vow)')  %#ok<*NOPRT> 
    anova(lme, 'DFMethod', 'Satterthwaite')

    tblnew = table(); % new data for prediction
    tblnew.mean_pertsize = linspace(0,250,100)';
    tblnew.subj = repmat(70,100,1);
    tblnew.vow = repmat(70,100,1);
    tblnew.vow = nominal(tblnew.vow);
    tblnew.subj = nominal(tblnew.subj);
    [ypred, yCI, DF] = predict(lme, tblnew, 'Conditional', true, 'DFMethod', 'Satterthwaite');

end


%% Fig 4: Clear speech

[bStat,~] = ismember(4,figs2stat);
if bStat

    analyses = {'durations', 'intensityMax', 'f0Max', 'f0Range'};
    norms = {'normWithinSession', 'normFirstSession'};

    for a = 1:length(analyses)

        for n = 1:length(norms)

            d = gen_data2plot_suppData(dataPath, analyses{a}, norms{n});

            nSubj_adaptFirst = size(d.adaptFirst,1);
            subs_adaptFirst = 1:nSubj_adaptFirst;
            subs_adaptFirst = subs_adaptFirst';
        
            sen_a1 = table(repmat({'adapt'},nSubj_adaptFirst,1), ...
                repmat(subs_adaptFirst,1,1), ...
                ones(nSubj_adaptFirst,1), ...
                d.adaptFirst(:,11), ...
                'VariableNames', {'cond','subj','adaptFirst','value'});
        
            sen_c2 = table(repmat({'control'},nSubj_adaptFirst,1), ...
                    repmat(subs_adaptFirst,1,1), ...
                    ones(nSubj_adaptFirst,1), ...
                    d.controlSecond(:,11), ...
                    'VariableNames', {'cond','subj','adaptFirst','value'});
            
            tra_a1 = table(repmat({'adapt'},nSubj_adaptFirst,1), ...
                    repmat(subs_adaptFirst,1,1), ...
                    ones(nSubj_adaptFirst,1), ...
                    d.adaptFirst(:,12), ...
                    'VariableNames', {'cond','subj','adaptFirst','value'});
            
            tra_c2 = table(repmat({'control'},nSubj_adaptFirst,1), ...
                    repmat(subs_adaptFirst,1,1), ...
                    ones(nSubj_adaptFirst,1), ...
                    d.controlSecond(:,12), ...
                    'VariableNames', {'cond','subj','adaptFirst','value'});
        
            nSubj_controlFirst = size(d.controlFirst,1);
            subs_controlFirst = (nSubj_adaptFirst+1):(nSubj_adaptFirst+nSubj_controlFirst);
            subs_controlFirst = subs_controlFirst';
            
            sen_c1 = table(repmat({'control'},nSubj_controlFirst,1), ...
                    repmat(subs_controlFirst,1,1), ...
                    zeros(nSubj_controlFirst,1), ...
                    d.controlFirst(:,11), ...
                    'VariableNames', {'cond','subj','adaptFirst','value'});
            
            sen_a2 = table(repmat({'adapt'},nSubj_controlFirst,1), ...
                    repmat(subs_controlFirst,1,1), ...
                    zeros(nSubj_controlFirst,1), ...
                    d.adaptSecond(:,11), ...
                    'VariableNames', {'cond','subj','adaptFirst','value'});
            
            tra_c1 = table(repmat({'control'},nSubj_controlFirst,1), ...
                    repmat(subs_controlFirst,1,1), ...
                    zeros(nSubj_controlFirst,1), ...
                    d.controlFirst(:,12), ...
                    'VariableNames', {'cond','subj','adaptFirst','value'});
            
            tra_a2 = table(repmat({'adapt'},nSubj_controlFirst,1), ...
                    repmat(subs_controlFirst,1,1), ...
                    zeros(nSubj_controlFirst,1), ...
                    d.adaptSecond(:,12), ...
                    'VariableNames', {'cond','subj','adaptFirst','value'});
            
            sen = [sen_a1; sen_c2; sen_c1; sen_a2];
            tra = [tra_a1; tra_c2; tra_c1; tra_a2];

            fprintf('\n*** %s %s, %s ***\n', 'sentence', analyses{a}, norms{n});

            disp(groupsummary(sen, {'cond', 'adaptFirst'}, {'mean','std'}, {'value'}));       
            [p,t,stats] = anovan(sen.value, {sen.cond sen.adaptFirst sen.subj}, ...
                    'model', 'full', 'random', 3, 'nested', [0 0 0; 0 0 0; 0 1 0], 'varnames', {'cond','adaptFirst','subj'});            
            clear p t stats;

            fprintf('overall mean = %4f, std = %4f \n', mean(sen.value), std(sen.value));
            [~,p,~,stats] = ttest(sen.value, 0);
            es = meanEffectSize(sen.value, Mean=0, Effect="cohen");
            fprintf('t = %4f, df = %4f, p = %4f, d = %4f \n', stats.tstat, stats.df, p, es.Effect(1));                                 
            
            if strcmp(analyses{a}, 'durations') && strcmp(norms{n}, 'normFirstSession')
                fprintf('\n* post-hoc analysis for cond x adaptFirst interaction *\n');
                clear p t stats;
                [~,p(1),~,stats(1)] = ttest(sen_a1.value, sen_c2.value);
                [~,p(2),~,stats(2)] = ttest(sen_c1.value, sen_a2.value);
                [~,p(3),~,stats(3)] = ttest2(sen_a1.value, sen_a2.value);
                [~,p(4),~,stats(4)] = ttest2(sen_c1.value, sen_c2.value);
                [~,p(5),~,stats(5)] = ttest2(sen_a1.value, sen_c1.value);
                [~,p(6),~,stats(6)] = ttest2(sen_a2.value, sen_c2.value);
                threshold = 0.05 ./ (length(p):-1:1) % Holm-Bonferroni
                [pSort,pInd] = sort(p) % each sorted p must be less than its corresponding threshold
            end

            fprintf('\n*** %s %s, %s ***\n', 'transfer', analyses{a}, norms{n});

            clear p t stats;
            fprintf('overall mean = %4f, std = %4f \n', mean(tra.value), std(tra.value));
            [~,p,~,stats] = ttest(tra.value, 0);
            es = meanEffectSize(tra.value, Mean=0, Effect="cohen");
            fprintf('t = %4f, df = %4f, p = %4f, d = %4f \n', stats.tstat, stats.df, p, es.Effect(1));
    
        end
    end

    % ----- Stop-Consonant Durations -----
    fprintf('\n*** Sentence durations, Norm Within Session, Stop-consonant segments only ***\n');
    clear sen p t stats es;
    load(fullfile(dataPath, 'segmentDuration_sentence_41.mat'), 'sen');
    stops = {'B','D','G','P','T','K'};
    s = sen(ismember(sen.vow,stops),:);
    [~,p,~,stats] = ttest(s.durNormWithinSession, 0);
    es = meanEffectSize(s.durNormWithinSession, Mean=0, Effect="cohen");
    fprintf('t = %4f, df = %4f, p = %4f, d = %4f \n', stats.tstat, stats.df, p, es.Effect(1));                                 

end


%% Fig 5: Intelligibility

[bStat,~] = ismember(5,figs2stat);
if bStat

    load(fullfile(dataPath, 'speakerData.mat'), 'speakerData');
    T = speakerData;

    %%%%%%%%%%
    % SENTENCE
    %%%%%%%%%%
    fprintf('Sentence');

    % select second sessions (where we have perceptual data)
    for s = 1:height(T)
        if T.adaptFirst(s) == 0                            % use adapt data
            avs_base(s)  = T.avs_adapt_baseline2(s);
            vsa4_base(s) = T.vsa4_adapt_baseline2(s);
            aavs_base(s) = T.aavs_adapt_baseline2(s);
            dur_base(s)  = T.durations_adapt_baseline2(s);
            avs_gain(s)  = T.avsNormWithinSession_adapt_hold6(s); % ivs: (avs)NormWithinSession_(session)_(phase)
            vsa4_gain(s) = T.vsa4NormWithinSession_adapt_hold6(s);
            aavs_gain(s) = T.aavsNormWithinSession_adapt_hold6(s);
            dur_gain(s)  = T.durationsNormWithinSession_adapt_hold6(s);
            wrd_base(s)  = T.sentenceAcc_adapt_MWord_baseline2(s); % dvs: (sentence)Acc_(session)_(metric)_(phase)
            vwl_base(s)  = T.sentenceAcc_adapt_MVwl_baseline2(s);
            wrd_gain(s)  = T.sentenceAcc_adapt_MWord_gain(s);
            vwl_gain(s)  = T.sentenceAcc_adapt_MVwl_gain(s);
        else                                               % use null data
            avs_base(s)  = T.avs_null_baseline2(s);
            vsa4_base(s) = T.vsa4_null_baseline2(s);
            aavs_base(s) = T.aavs_null_baseline2(s);
            dur_base(s)  = T.durations_null_baseline2(s);
            avs_gain(s)  = T.avsNormWithinSession_null_hold6(s); 
            vsa4_gain(s) = T.vsa4NormWithinSession_null_hold6(s);
            aavs_gain(s) = T.aavsNormWithinSession_null_hold6(s);
            dur_gain(s)  = T.durationsNormWithinSession_null_hold6(s);
            wrd_base(s)  = T.sentenceAcc_null_MWord_baseline2(s); 
            vwl_base(s)  = T.sentenceAcc_null_MVwl_baseline2(s);
            wrd_gain(s)  = T.sentenceAcc_null_MWord_gain(s); 
            vwl_gain(s)  = T.sentenceAcc_null_MVwl_gain(s);
        end
        age(s) = T.age(s);
        male(s) = T.male(s);
    end
    avs_base = avs_base'; vsa4_base = vsa4_base'; aavs_base = aavs_base'; dur_base = dur_base'; avs_gain = avs_gain'; vsa4_gain = vsa4_gain'; aavs_gain = aavs_gain'; 
    dur_gain = dur_gain'; age = age'; male = male'; wrd_base = wrd_base'; vwl_base = vwl_base'; wrd_gain = wrd_gain'; vwl_gain = vwl_gain';

    [r,p] = corr(avs_base, wrd_base, 'type', 'Pearson');
    fprintf('avs_base ~ wrd_base: r = %4f, p = %4f \n', r, p);

    [r,p] = corr(avs_gain, wrd_gain, 'type', 'Pearson'); 
    fprintf('avs_gain ~ wrd_gain: r = %4f, p = %4f \n', r, p);

    T_starting = [0 0 0 0 0]; % constant
    T_upper = [0 0 0 0 0; 1 0 0 0 0; 0 1 0 0 0; 0 0 1 0 0; 0 0 0 1 0; 1 1 0 0 0; 1 0 1 0 0; 1 0 0 1 0; 0 1 1 0 0; 0 1 0 1 0; 0 0 1 1 0];
    mdl = stepwiselm([age male avs_gain dur_gain], wrd_gain, T_starting, 'upper', T_upper, ...
        'VarNames', {'age','male','avs_gain','dur_gain','wrd_gain'}, 'CategoricalVar', 2, 'Verbose',2);
    anova(mdl)

    [r,p] = corr(vsa4_base, wrd_base, 'type', 'Pearson');
    fprintf('vsa4_base ~ wrd_base: r = %4f, p = %4f \n', r, p);

    [r,p] = corr(vsa4_gain, wrd_gain, 'type', 'Pearson'); 
    fprintf('vsa4_gain ~ wrd_gain: r = %4f, p = %4f \n', r, p);

    [r,p] = corr(aavs_base, wrd_base, 'type', 'Pearson');
    fprintf('aavs_base ~ wrd_base: r = %4f, p = %4f \n', r, p);

    [r,p] = corr(aavs_gain, wrd_gain, 'type', 'Pearson'); 
    fprintf('aavs_gain ~ wrd_gain: r = %4f, p = %4f \n', r, p);

    % --- Excluding n=3 who reported using pronunciation strategies ---
    fprintf('\n*** Excluding n=3 who reported using pronunciation strategies *** \n');

    T_ = T;
    T_(T_.subj==15,:) = [];
    T_(T_.subj==17,:) = [];
    T_(T_.subj==41,:) = [];
    for s = 1:height(T_)
        if T_.adaptFirst(s) == 0                           % use adapt data
            avs_gain_(s)  = T_.avsNormWithinSession_adapt_hold6(s); % ivs: (avs)NormWithinSession_(session)_(phase)
            wrd_gain_(s)  = T_.sentenceAcc_adapt_MWord_gain(s);
        else                                               % use null data
            avs_gain_(s)  = T_.avsNormWithinSession_null_hold6(s); 
            wrd_gain_(s)  = T_.sentenceAcc_null_MWord_gain(s); 
        end
    end
    avs_gain_ = avs_gain_'; wrd_gain_ = wrd_gain_';

    [r,p] = corr(avs_gain_, wrd_gain_, 'type', 'Pearson'); 
    fprintf('without strategic, avs_gain ~ wrd_gain: r = %4f, p = %4f \n', r, p);

    [~,p,~,stats] = ttest(wrd_base, (wrd_base + wrd_gain));
    es = meanEffectSize(wrd_base, (wrd_base + wrd_gain), Effect="cohen");
    fprintf('sentence: wrd_base vs. (wrd_base + wrd_gain): t = %4f, df = %4f, p = %4f, d = %4f \n', stats.tstat, stats.df, p, es.Effect(1));

    % --- select adapt-second only (show on Fig 5B) ---
    clear avs_gain wrd_gain;
    count = 1;
    for s = 1:height(T)
        if T.adaptFirst(s) == 0                            % use adapt data
            avs_gain(count) = T.avsNormWithinSession_adapt_hold6(s);
            wrd_gain(count) = T.sentenceAcc_adapt_MWord_gain(s);
            count = count + 1;
        end
    end
    avs_gain = avs_gain'; wrd_gain  = wrd_gain';

    [r,p] = corr(avs_gain, wrd_gain, 'type', 'Pearson');
    fprintf('adapt-second: avs_gain ~ wrd_gain: r = %4f, p = %4f \n', r, p);

    % --- select control-second only (just out of curiosity) ---
    clear avs_gain wrd_gain;
    count = 1;
    for s = 1:height(T)
        if T.adaptFirst(s) == 1                            % use null data
            avs_gain(count) = T.avsNormWithinSession_null_hold6(s); 
            wrd_gain(count) = T.sentenceAcc_null_MWord_gain(s); 
            count = count + 1;
        end
    end
    avs_gain = avs_gain'; wrd_gain  = wrd_gain';

    [r,p] = corr(avs_gain, wrd_gain, 'type', 'Pearson');
    fprintf('control-second: avs_gain ~ wrd_gain: r = %4f, p = %4f \n', r, p);

    %%%%%%%%%%
    % TRANSFER
    %%%%%%%%%%
    fprintf('Transfer');

    clear wrd_base wrd_gain;
    for s = 1:height(T)
        if T.adaptFirst(s) == 0                            % use adapt data
            tra_base(s) = T.avs_adapt_transfer2(s);
            tra_gain(s) = T.avsNormWithinSession_adapt_transfer3(s);
            wrd_base(s) = T.transferAcc_adapt_transfer2(s);
            wrd_gain(s) = T.transferAcc_adapt_gain(s);
        else                                               % use null data
            tra_base(s) = T.avs_null_transfer2(s);
            tra_gain(s) = T.avsNormWithinSession_null_transfer3(s);
            wrd_base(s) = T.transferAcc_null_transfer2(s); 
            wrd_gain(s) = T.transferAcc_null_gain(s); 
        end
    end
    tra_base = tra_base'; tra_gain = tra_gain'; wrd_base = wrd_base'; wrd_gain = wrd_gain';
    
    [r,p] = corr(tra_base, wrd_base, 'type', 'Pearson');
    fprintf('transfer: tra_base ~ wrd_base: r = %4f, p = %4f \n', r, p);

    [r,p] = corr(tra_gain, wrd_gain, 'type', 'Pearson');
    fprintf('transfer: tra_gain ~ wrd_gain: r = %4f, p = %4f \n', r, p);

    [~,p,~,stats] = ttest(wrd_base, (wrd_base + wrd_gain));
    es = meanEffectSize(wrd_base, (wrd_base + wrd_gain), Effect="cohen");
    fprintf('transfer: wrd_base ~ (wrd_base + wrd_gain): t = %4f, df = %4f, p = %4f, d = %4f \n', stats.tstat, stats.df, p, es.Effect(1));

end


%% Not a Figure: Predictors of adaptation

[bStat,~] = ismember(6,figs2stat);
if bStat

    load(fullfile(dataPath, 'speakerData.mat'), 'speakerData');
    T = speakerData;

    % select first-session AVS baselines and adapt-session AVS gains
    for s = 1:height(T)
        if T.adaptFirst(s) == 1 % use adapt data
            avs_base(s)      = T.avs_adapt_baseline2(s);
            avs_gain_norm(s) = T.avsNormFirstSession_adapt_hold6(s); %#ok<*AGROW> 
            avs_gain_raw(s)  = T.avs_adapt_hold6(s) - T.avs_adapt_baseline2(s);
        else % use null data for base and adapt for hold
            avs_base(s)      = T.avs_null_baseline2(s);
            avs_gain_norm(s) = T.avsNormFirstSession_adapt_hold6(s);
            avs_gain_raw(s)  = T.avs_adapt_hold6(s) - T.avs_null_baseline2(s);
        end
        age(s)  = T.age(s);
        male(s) = T.male(s);
    end
    avs_base = avs_base'; avs_gain_norm = avs_gain_norm'; avs_gain_raw = avs_gain_raw'; age = age'; male = male';

    [r,p] = corr(age, avs_base, 'type', 'Pearson'); % S
    fprintf('age ~ avs_base: r = %4f, p = %4f \n', r, p);

    [~,p,~,stats] = ttest2(avs_base(male==1), avs_base(male==0)); % S
    es = meanEffectSize(avs_base(male==1), avs_base(male==0), Effect="cohen");
    fprintf('avs_base by male: t = %4f, df = %4f, p = %4f, d = %4f \n', stats.tstat, stats.df, p, es.Effect(1));

    [r,p] = corr(avs_base, avs_gain_norm, 'type', 'Pearson'); % S
    fprintf('avs_base ~ avs_gain_norm: r = %4f, p = %4f \n', r, p);
    [r,p] = corr(avs_base, avs_gain_raw, 'type', 'Pearson'); % S
    fprintf('avs_base ~ avs_gain_raw: r = %4f, p = %4f \n', r, p);

    [r,p] = corr(age, avs_gain_norm, 'type', 'Pearson'); % NS
    fprintf('age ~ avs_gain_norm: r = %4f, p = %4f \n', r, p);
    [r,p] = corr(age, avs_gain_raw, 'type', 'Pearson'); % NS
    fprintf('age ~ avs_gain_raw: r = %4f, p = %4f \n', r, p);

    [~,p,~,stats] = ttest2(avs_gain_norm(male==1), avs_gain_norm(male==0)); % NS
    [~,p,~,stats] = ttest2(avs_gain_raw(male==1), avs_gain_raw(male==0));   % NS

%     m0 = stepwiselm([age male], avs_base, 'constant', 'VarNames', {'age','male','avs_base'}, 'CategoricalVar', 2, 'Verbose', 2) %#ok<*NASGU,*NOPRT> 
%     anova(m0)
%     m1 = stepwiselm([age male], avs_base, 'linear', 'VarNames', {'age','male','avs_base'}, 'CategoricalVar', 2, 'Verbose', 2) %#ok<*NASGU,*NOPRT> 
%     anova(m1)
%     m2 = stepwiselm([age male], avs_base, 'interactions', 'VarNames', {'age','male','avs_base'}, 'CategoricalVar', 2, 'Verbose', 2) %#ok<*NASGU,*NOPRT> 
%     anova(m2)
%     m3 = stepwiselm([age male avs_base], avs_gain_norm, 'constant', 'VarNames', {'age','male','avs_base','avs_gain_norm'}, 'CategoricalVar', 2, 'Verbose', 2) %#ok<*NASGU,*NOPRT> 
%     anova(m3)
%     m4 = stepwiselm([age male avs_base], avs_gain_norm, 'linear', 'VarNames', {'age','male','avs_base','avs_gain_norm'}, 'CategoricalVar', 2, 'Verbose', 2) %#ok<*NASGU,*NOPRT> 
%     anova(m4)
%     m5 = stepwiselm([age male avs_base], avs_gain_norm, 'interactions', 'VarNames', {'age','male','avs_base','avs_gain_norm'}, 'CategoricalVar', 2, 'Verbose', 2) %#ok<*NASGU,*NOPRT> 
%     anova(m5)
%     m6 = stepwiselm([age male avs_base], avs_gain_raw, 'interactions', 'VarNames', {'age','male','avs_base','avs_gain_raw'}, 'CategoricalVar', 2, 'Verbose', 2)  
%     anova(m6)

    % https://math.stackexchange.com/questions/617735/multiple-regression-degrees-of-freedom-f-test#:~:text=The%20correct%20approach%20is%20to,freedom%2C%20i.e.%20n%E2%88%921.

    % 7-26-24
    T_starting = [0 0 0]; % constant
    T_upper = [0 0 0;1 0 0;0 1 0;1 1 0]; % a linear model with interactions
    mdl = stepwiselm([age male], avs_base, T_starting, 'upper', T_upper, ...
        'VarNames', {'age','male','avs_base'}, 'CategoricalVar', 2, 'Verbose',2)

    T_upper = [0 0 0 0; 1 0 0 0; 0 1 0 0; 0 0 1 0; 1 1 0 0; 1 0 1 0; 0 1 1 0; 1 1 1 0];
    mdl = stepwiselm([age male avs_base], avs_gain_norm, T_starting, 'upper', T_upper, ...
        'VarNames', {'age','male','avs_base','avs_gain_norm'}, 'CategoricalVar', 2, 'Verbose',2)
    mdl = stepwiselm([age male avs_base], avs_gain_raw, T_starting, 'upper', T_upper, ...
        'VarNames', {'age','male','avs_base','avs_gain_raw'}, 'CategoricalVar', 2, 'Verbose',2)

end


%% Tables S1, S2, S3, S4: Perturbation awareness and strategy use

[bStat,~] = ismember(7,figs2stat);
if bStat

    fprintf('\n*** Without the n=5 aware/strategic participants ***\n');
    toExcl = [7 15 17 34 41]; % 'sp301','sp343','sp347','sp443','sp601'

    % ----- AVS Norm Within Session -----
    
    load(fullfile(dataPath, 'avs_vsa_41.mat'), 'AVS_VSA');
    sen = AVS_VSA(strcmp(AVS_VSA.phase, 'hold6') | strcmp(AVS_VSA.phase, 'washout') | strcmp(AVS_VSA.phase, 'retention'),:); % select phases of interest
    for i = 1:length(toExcl)
        sen(sen.subj==toExcl(i),:) = [];
    end
    [p,t,stats] = anovan(sen.avsNormWithinSession, {sen.cond sen.phase sen.adaptFirst sen.subj}, ...
         'model', 'full', 'random', 4, 'nested', [0 0 0 0; 0 0 0 0; 0 0 0 0; 0 0 1 0], 'varnames', {'cond','phase','adaptFirst','subj'}); %#ok<*ASGLU> 

    sen_adaptFirst  = sen((strcmp(sen.cond, 'adapt') & (sen.adaptFirst==1)),:); % split b/c of session type x session order interaction
    sen_adaptSecond = sen((strcmp(sen.cond, 'adapt') & (sen.adaptFirst==0)),:);
    sen_nullFirst   = sen((strcmp(sen.cond, 'null') & (sen.adaptFirst==0)),:);
    sen_nullSecond  = sen((strcmp(sen.cond, 'null') & (sen.adaptFirst==1)),:);
    sen_first       = [sen_adaptFirst; sen_nullFirst];
    sen_second      = [sen_adaptSecond; sen_nullSecond];
    [p,t,stats] = anovan(sen_first.avsNormWithinSession, {sen_first.cond sen_first.phase}, 'model', 'full', 'varnames', {'cond','phase'}); % can't include subj
    [p,t,stats] = anovan(sen_second.avsNormWithinSession, {sen_second.cond sen_second.phase}, 'model', 'full', 'varnames', {'cond','phase'}); % can't include subj

    % ----- AVS Norm First Session -----
    
    [p,t,stats] = anovan(sen.avsNormFirstSession, {sen.cond sen.phase sen.adaptFirst sen.subj}, ...
         'model', 'full', 'random', 4, 'nested', [0 0 0 0; 0 0 0 0; 0 0 0 0; 0 0 1 0], 'varnames', {'cond','phase','adaptFirst','subj'});

    % ----- AVS Transfer Norm Within Session -----
    
    tra = AVS_VSA(strcmp(AVS_VSA.phase, 'transfer3'),:); % select phase of interest
    for i = 1:length(toExcl)
        tra(tra.subj==toExcl(i),:) = [];
    end
    [p,t,stats] = anovan(tra.avsNormWithinSession, {tra.cond tra.adaptFirst tra.subj}, ...
          'model', 'full', 'random', 3, 'nested', [0 0 0; 0 0 0; 0 1 0], 'varnames', {'cond','adaptFirst','subj'});
    
    % ----- AVS Transfer Norm First Session -----
    
    [p,t,stats] = anovan(tra.avsNormFirstSession, {tra.cond tra.adaptFirst tra.subj}, ...
          'model', 'full', 'random', 3, 'nested', [0 0 0; 0 0 0; 0 1 0], 'varnames', {'cond','adaptFirst','subj'});

    % ----- VSA Norm Within Session -----

    [p,t,stats] = anovan(sen.vsa4NormWithinSession, {sen.cond sen.phase sen.adaptFirst sen.subj}, ...
          'model', 'full', 'random', 4, 'nested', [0 0 0 0; 0 0 0 0; 0 0 0 0; 0 0 1 0], 'varnames', {'cond','phase','adaptFirst','subj'});

    % ----- VSA Norm First Session -----

    [p,t,stats] = anovan(sen.vsa4NormFirstSession, {sen.cond sen.phase sen.adaptFirst sen.subj}, ...
          'model', 'full', 'random', 4, 'nested', [0 0 0 0; 0 0 0 0; 0 0 0 0; 0 0 1 0], 'varnames', {'cond','phase','adaptFirst','subj'});
        
    % ----- VSA Transfer Norm Within Session -----
    
    [p,t,stats] = anovan(tra.vsa4NormWithinSession, {tra.cond tra.adaptFirst tra.subj}, ...
          'model', 'full', 'random', 3, 'nested', [0 0 0; 0 0 0; 0 1 0], 'varnames', {'cond','adaptFirst','subj'});
    
    % ----- VSA Transfer Norm First Session -----
    
    [p,t,stats] = anovan(tra.vsa4NormFirstSession, {tra.cond tra.adaptFirst tra.subj}, ...
          'model', 'full', 'random', 3, 'nested', [0 0 0; 0 0 0; 0 1 0], 'varnames', {'cond','adaptFirst','subj'});

    % ----- AAVS Norm Within Session -----

    load(fullfile(dataPath, 'aavs_41.mat'), 'AAVS');
    sen = AAVS(strcmp(AAVS.phase, 'hold6') | strcmp(AAVS.phase, 'washout') | strcmp(AAVS.phase, 'retention'),:);
    for i = 1:length(toExcl)
        sen(sen.subj==toExcl(i),:) = [];
    end
    [p,t,stats] = anovan(sen.aavsNormWithinSession, {sen.cond sen.phase sen.adaptFirst sen.subj}, ...
         'model', 'full', 'random', 4, 'nested', [0 0 0 0; 0 0 0 0; 0 0 0 0; 0 0 1 0], 'varnames', {'cond','phase','adaptFirst','subj'});

    % ----- AAVS Norm First Session -----
    
    [p,t,stats] = anovan(sen.aavsNormFirstSession, {sen.cond sen.phase sen.adaptFirst sen.subj}, ...
         'model', 'full', 'random', 4, 'nested', [0 0 0 0; 0 0 0 0; 0 0 0 0; 0 0 1 0], 'varnames', {'cond','phase','adaptFirst','subj'});

    % ----- Vowel-specific Sentence -----

    load(fullfile(dataPath, 'sentenceVow_41.mat'), 'sentenceVow');
    sV = groupsummary(sentenceVow, ["subj","cond","phase","vow","speaker","adaptFirst"], "mean");   
    sen = sV(strcmp(sV.phase, 'hold6'),:); % select phases of interest
    for i = 1:length(toExcl)
        sen(sen.subj==toExcl(i),:) = [];
    end
    [p,t,stats] = anovan(sen.mean_centdistdiff, {sen.cond sen.adaptFirst sen.vow sen.subj}, ...
         'model', 'full', 'random', 4, 'nested', [0 0 0 0; 0 0 0 0; 0 0 0 0; 0 1 0 0], 'varnames', {'cond','adaptFirst','vow','subj'});

    clear p t stats; % first test adapt vs. control (subjects stay in order for paired test)
    [~,p(1),~,stats(1)]   = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'AA')), sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'AA')));
    [~,p(2),~,stats(2)]   = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'AE')), sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'AE')));
    [~,p(3),~,stats(3)]   = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'AH')), sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'AH')));
    [~,p(4),~,stats(4)]   = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'AO')), sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'AO')));
    [~,p(5),~,stats(5)]   = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'AW')), sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'AW')));
    [~,p(6),~,stats(6)]   = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'AY')), sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'AY')));
    [~,p(7),~,stats(7)]   = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'EH')), sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'EH')));
    [~,p(8),~,stats(8)]   = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'ER')), sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'ER')));
    [~,p(9),~,stats(9)]   = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'EY')), sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'EY')));
    [~,p(10),~,stats(10)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'IH')), sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'IH')));
    [~,p(11),~,stats(11)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'IY')), sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'IY')));
    [~,p(12),~,stats(12)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'OW')), sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'OW')));
    [~,p(13),~,stats(13)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'UH')), sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'UH')));
    [~,p(14),~,stats(14)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'UW')), sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'UW')));
    threshold = 0.05 ./ (length(p):-1:1) % Holm-Bonferroni
    [pSort,pInd] = sort(p) % each sorted p must be less than its corresponding threshold

    clear p t stats; % then test each adapt and control vs. 0
    [~,p(1),~,stats(1)]   = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'AA')), 0);
    [~,p(2),~,stats(2)]   = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'AE')), 0);   
    [~,p(3),~,stats(3)]   = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'AH')), 0);
    [~,p(4),~,stats(4)]   = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'AO')), 0);
    [~,p(5),~,stats(5)]   = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'AW')), 0);
    [~,p(6),~,stats(6)]   = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'AY')), 0);
    [~,p(7),~,stats(7)]   = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'EH')), 0);
    [~,p(8),~,stats(8)]   = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'ER')), 0);   
    [~,p(9),~,stats(9)]   = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'EY')), 0);
    [~,p(10),~,stats(10)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'IH')), 0);
    [~,p(11),~,stats(11)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'IY')), 0);
    [~,p(12),~,stats(12)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'OW')), 0);
    [~,p(13),~,stats(13)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'UH')), 0);
    [~,p(14),~,stats(14)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'adapt') & ismember(sen.vow,'UW')), 0);
    [~,p(15),~,stats(15)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'AA')), 0);
    [~,p(16),~,stats(16)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'AE')), 0);   
    [~,p(17),~,stats(17)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'AH')), 0);
    [~,p(18),~,stats(18)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'AO')), 0);
    [~,p(19),~,stats(19)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'AW')), 0);
    [~,p(20),~,stats(20)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'AY')), 0);
    [~,p(21),~,stats(21)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'EH')), 0);
    [~,p(22),~,stats(22)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'ER')), 0);   
    [~,p(23),~,stats(23)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'EY')), 0);
    [~,p(24),~,stats(24)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'IH')), 0);
    [~,p(25),~,stats(25)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'IY')), 0);
    [~,p(26),~,stats(26)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'OW')), 0);
    [~,p(27),~,stats(27)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'UH')), 0);
    [~,p(28),~,stats(28)] = ttest(sen.mean_centdistdiff(ismember(sen.cond,'null') & ismember(sen.vow,'UW')), 0);
    threshold = 0.05 ./ (length(p):-1:1) % Holm-Bonferroni
    [pSort,pInd] = sort(p) % each sorted p must be less than its corresponding threshold

    % ----- Vowel-specific Transfer -----

    load(fullfile(dataPath, 'transferVow_41.mat'), 'transferVow');
    tV = groupsummary(transferVow, ["subj","cond","phase","vow","speaker","adaptFirst"], "mean");
    tra = tV(strcmp(tV.phase, 'transfer3'),:); % select phases of interest
    for i = 1:length(toExcl)
        tra(tra.subj==toExcl(i),:) = [];
    end
    [p,t,stats] = anovan(tra.mean_centdistdiff, {tra.cond tra.adaptFirst tra.vow tra.subj}, ...
                        'model', 'full', 'random', 4, 'nested', [0 0 0 0; 0 0 0 0; 0 0 0 0; 0 1 0 0], 'varnames', {'cond','adaptFirst','vow','subj'});

    clear p t stats; % first test adapt vs. control (subjects stay in order for paired test)
    [~,p(1),~,stats(1)]   = ttest(tra.mean_centdistdiff(ismember(tra.cond,'adapt') & ismember(tra.vow,'AA')), tra.mean_centdistdiff(ismember(tra.cond,'null') & ismember(tra.vow,'AA')));
    [~,p(2),~,stats(2)]   = ttest(tra.mean_centdistdiff(ismember(tra.cond,'adapt') & ismember(tra.vow,'AE')), tra.mean_centdistdiff(ismember(tra.cond,'null') & ismember(tra.vow,'AE')));
    [~,p(3),~,stats(3)]   = ttest(tra.mean_centdistdiff(ismember(tra.cond,'adapt') & ismember(tra.vow,'AH')), tra.mean_centdistdiff(ismember(tra.cond,'null') & ismember(tra.vow,'AH')));
    [~,p(4),~,stats(4)]   = ttest(tra.mean_centdistdiff(ismember(tra.cond,'adapt') & ismember(tra.vow,'EH')), tra.mean_centdistdiff(ismember(tra.cond,'null') & ismember(tra.vow,'EH')));
    [~,p(5),~,stats(5)]   = ttest(tra.mean_centdistdiff(ismember(tra.cond,'adapt') & ismember(tra.vow,'EY')), tra.mean_centdistdiff(ismember(tra.cond,'null') & ismember(tra.vow,'EY')));
    [~,p(6),~,stats(6)]   = ttest(tra.mean_centdistdiff(ismember(tra.cond,'adapt') & ismember(tra.vow,'IH')), tra.mean_centdistdiff(ismember(tra.cond,'null') & ismember(tra.vow,'IH')));
    [~,p(7),~,stats(7)]   = ttest(tra.mean_centdistdiff(ismember(tra.cond,'adapt') & ismember(tra.vow,'IY')), tra.mean_centdistdiff(ismember(tra.cond,'null') & ismember(tra.vow,'IY')));
    [~,p(8),~,stats(8)]   = ttest(tra.mean_centdistdiff(ismember(tra.cond,'adapt') & ismember(tra.vow,'OW')), tra.mean_centdistdiff(ismember(tra.cond,'null') & ismember(tra.vow,'OW')));
    [~,p(9),~,stats(9)]   = ttest(tra.mean_centdistdiff(ismember(tra.cond,'adapt') & ismember(tra.vow,'UH')), tra.mean_centdistdiff(ismember(tra.cond,'null') & ismember(tra.vow,'UH')));
    [~,p(10),~,stats(10)] = ttest(tra.mean_centdistdiff(ismember(tra.cond,'adapt') & ismember(tra.vow,'UW')), tra.mean_centdistdiff(ismember(tra.cond,'null') & ismember(tra.vow,'UW')));
    threshold = 0.05 ./ (length(p):-1:1) % Holm-Bonferroni
    [pSort,pInd] = sort(p) % each sorted p must be less than its corresponding threshold

    clear p t stats; % then test each adapt and control vs. 0
    [~,p(1),~,stats(1)]   = ttest(tra.mean_centdistdiff(ismember(tra.cond,'adapt') & ismember(tra.vow,'AA')), 0);
    [~,p(2),~,stats(2)]   = ttest(tra.mean_centdistdiff(ismember(tra.cond,'adapt') & ismember(tra.vow,'AE')), 0);
    [~,p(3),~,stats(3)]   = ttest(tra.mean_centdistdiff(ismember(tra.cond,'adapt') & ismember(tra.vow,'AH')), 0);
    [~,p(4),~,stats(4)]   = ttest(tra.mean_centdistdiff(ismember(tra.cond,'adapt') & ismember(tra.vow,'EH')), 0);
    [~,p(5),~,stats(5)]   = ttest(tra.mean_centdistdiff(ismember(tra.cond,'adapt') & ismember(tra.vow,'EY')), 0);
    [~,p(6),~,stats(6)]   = ttest(tra.mean_centdistdiff(ismember(tra.cond,'adapt') & ismember(tra.vow,'IH')), 0);
    [~,p(7),~,stats(7)]   = ttest(tra.mean_centdistdiff(ismember(tra.cond,'adapt') & ismember(tra.vow,'IY')), 0);
    [~,p(8),~,stats(8)]   = ttest(tra.mean_centdistdiff(ismember(tra.cond,'adapt') & ismember(tra.vow,'OW')), 0);
    [~,p(9),~,stats(9)]   = ttest(tra.mean_centdistdiff(ismember(tra.cond,'adapt') & ismember(tra.vow,'UH')), 0);
    [~,p(10),~,stats(10)] = ttest(tra.mean_centdistdiff(ismember(tra.cond,'adapt') & ismember(tra.vow,'UW')), 0);
    [~,p(11),~,stats(11)] = ttest(tra.mean_centdistdiff(ismember(tra.cond,'null') & ismember(tra.vow,'AA')), 0);
    [~,p(12),~,stats(12)] = ttest(tra.mean_centdistdiff(ismember(tra.cond,'null') & ismember(tra.vow,'AE')), 0);
    [~,p(13),~,stats(13)] = ttest(tra.mean_centdistdiff(ismember(tra.cond,'null') & ismember(tra.vow,'AH')), 0);
    [~,p(14),~,stats(14)] = ttest(tra.mean_centdistdiff(ismember(tra.cond,'null') & ismember(tra.vow,'EH')), 0);
    [~,p(15),~,stats(15)] = ttest(tra.mean_centdistdiff(ismember(tra.cond,'null') & ismember(tra.vow,'EY')), 0);
    [~,p(16),~,stats(16)] = ttest(tra.mean_centdistdiff(ismember(tra.cond,'null') & ismember(tra.vow,'IH')), 0);
    [~,p(17),~,stats(17)] = ttest(tra.mean_centdistdiff(ismember(tra.cond,'null') & ismember(tra.vow,'IY')), 0);
    [~,p(18),~,stats(18)] = ttest(tra.mean_centdistdiff(ismember(tra.cond,'null') & ismember(tra.vow,'OW')), 0);
    [~,p(19),~,stats(19)] = ttest(tra.mean_centdistdiff(ismember(tra.cond,'null') & ismember(tra.vow,'UH')), 0);
    [~,p(20),~,stats(20)] = ttest(tra.mean_centdistdiff(ismember(tra.cond,'null') & ismember(tra.vow,'UW')), 0);
    threshold = 0.05 ./ (length(p):-1:1) % Holm-Bonferroni
    [pSort,pInd] = sort(p) % each sorted p must be less than its corresponding threshold

end


end % of function
