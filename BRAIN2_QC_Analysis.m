% This code calculates and visualizes the power spectrum of electrocorticography (ECoG) and deep brain stimulation (DBS) channels during functional neurosurgery.
% It utilizes the FieldTrip toolbox for preprocessing and analysis. If you don't have FieldTrip installed, download it and add the folder to the MATLAB path.

% Channel Naming Convention:
% - ECOG1-x or ECOG2-x: The first number denotes the strip (1 for the first, 2 for the second), and the second number indicates the contact on the strip.

% Disclaimer:
% This is an example code to demonstrate dataset visualization. The preprocessing, analysis, and pipeline configuration used here do not represent the formal recommendations of the Pouratian lab.

% Adding FieldTrip Toolbox:
% Add FieldTrip to the MATLAB path if it has not been added already.
% Example:
% addpath('/path/to/fieldtrip');  % Replace with the actual path to your FieldTrip installation.
% ft_defaults;  % Initialize FieldTrip defaults.

%% Set Parameters
clc; clear; close all  % Clear command window, workspace, and close all figures.

% Define the folder containing the dataset.
dataFolder = '/path/to/your/data/folder';  % Update to your data location.

% Retrieve the list of subjects from the data folder.
files = dir([dataFolder 'sub-*']);
subjList = {files.name};  % Extract subject identifiers.

% Display the list of subjects identified.
for ifile = 1:length(files)
    fprintf('  - %d - %s \n', ifile, files(ifile).name);
end

%% Subject and Channel Settings
subj = 1;  % Select the subject by index for processing. Change this value to select a different subject.

chnlToPlt = {'RDBS1'};  % Channel to use for power spectrum calculation. Update based on your analysis requirements.

% Set preprocessing parameters.
lineNoiseCut = [59 61];  % Frequency range to remove line noise (commonly at 60 Hz in the US).
smWin = 10;  % Smoothing window size to facilitate data visualization.
segLen = 4;  % Segment length (in seconds) for power analysis.
segOver = 0.5;  % Segment overlap (in seconds) to improve data stability.

fpass = [1 100];  % Frequency range of interest (in Hz).
fstep = 1;  % Frequency resolution (in Hz).

trialType = {'rest'};  % Types of trials to include in the analysis. Add other types if available (e.g., 'posture').
meanCentering = 'non';  % Method for mean centering ('mean', 'median', or 'non').
normalization = 'non';  % Normalization method ('mean', 'median', 'z-score', or 'non').

% Update the subject list for current data folder.
files = dir([dataFolder 'sub-*']);
subjList = {files.name};

%% FieldTrip Configuration for Data Visualization
cfg = [];

% Specify the data file.
dataFile = dir([dataFolder subjList{subj} '/ses-intraop/ieeg/*.eeg']);

dataAddress = [dataFolder subjList{subj} '/ses-intraop/ieeg/' dataFile.name];
cfg.dataset = dataAddress;

% Load event data.
eventFile = [dataFolder subjList{subj} '/ses-intraop/ieeg/' subjList{subj} '_ses-intraop_task-RestMove_run-1_events.tsv'];

%% Data Preprocessing and Visualization of Raw Data
cfg = [];
cfg.dataset = dataAddress;
cfg.reref = 'no';  % No re-referencing.
cfg.refmethod = 'bipolar';
cfg.refchannel = 'all';
cfg.hpfilter = 'yes';  % Enable high-pass filter to remove slow drifts.
cfg.lpfilter = 'no';  % Low-pass filter is disabled.
cfg.hpfreq = 6;  % High-pass filter frequency set to 6 Hz.
cfg.lpfreq = 100;
cfg.demean = 'no';
cfg.detrend = 'no';

% Preprocess the data.
data_all = ft_preprocessing(cfg);

% Plot the raw data.
plt_data = data_all.trial{1}(:, 1:10:end);  % Downsample the data for faster visualization.

% Normalize the data for visualization.
plt_data = (plt_data - median(plt_data, 2, 'omitmissing')) ./ mad(plt_data, [], 2);

% Remove outliers for visualization purposes.
plt_data(abs(plt_data) > 10 * mad(plt_data, [], 2)) = nan;

subplot(1, 5, [1 2 3])
% Zooming and stacking traces for visualization.
pltTrace = plt_data + [1:size(plt_data)]' * 10;
plot(data_all.time{1}(1:10:end), pltTrace)
yticks = mean(pltTrace, 2, 'omitmissing');
yticks(isnan(yticks)) = [];
set(gca, 'YTick', yticks, 'YTickLabel', data_all.label)
xlabel('Time (s)');
ylabel('Normalized Amplitude (z-score)');
title('Raw ECoG/DBS Data');

% Mark trial events on the plot.
cfg = [];
cfg.dataset = dataAddress;
cfg.trialfun = 'ft_trialfun_general';  % Default trial function.
cfg.trialdef.eventtype = trialType;

cfg = ft_definetrial(cfg);
tln = [cfg.event.timestamp];
dln = [cfg.event.duration];
for iln = 1:size(tln, 2)
    line([tln(iln) tln(iln)], ylim, 'LineStyle', '--', 'Color', 'k')
end
xlim([tln(1) - 5 tln(end) + 5])

%% Frequency Analysis and Power Spectrum Visualization
for itr = 1:length(trialType)
    % Set up trial-specific configuration.
    cfg = [];
    cfg.dataset = dataAddress;
    cfg.trialfun = 'ft_trialfun_general';  % Default trial function.
    cfg.trialdef.eventtype = trialType{itr};
    
    cfg = ft_definetrial(cfg);

    % Preprocess the data for the specified trial.
    data = ft_preprocessing(cfg);

    % Low-pass filter configuration.
    cfg = [];
    cfg.channel = 'all';
    cfg.reref = 'no';
    cfg.refmethod = 'bipolar';
    cfg.refchannel = 'all';
    cfg.hpfilter = 'no';  % High-pass filter is disabled.
    cfg.lpfilter = 'yes'; % Enable low-pass filter to remove high-frequency noise.
    cfg.lpfreq = 200;
    cfg.demean = 'no';
    cfg.detrend = 'no';

    % Apply preprocessing with the filter settings.
    data_reref = ft_preprocessing(cfg, data);
    
    % Select the desired channel for power analysis.
    cfg = [];
    ind1 = find(contains(data_reref.label, chnlToPlt{1}));
    chanConf = data_reref.label(ind1(1));
    cfg.channel = chanConf;
    data_selected = ft_selectdata(cfg, data_reref);

    % Apply normalization if specified.
    switch normalization
        case 'meanFac'
            for inor = 1:length(data_selected.trial)
                data_selected.trial{inor} = (data_selected.trial{inor} - mean(data_selected.trial{inor}, 2, 'omitmissing')) ./ mean(data_selected.trial{inor}, 2);
            end
        case 'z-score'
            for inor = 1:length(data_selected.trial)
                data_selected.trial{inor} = (data_selected.trial{inor} - mean(data_selected.trial{inor}, 2, 'omitmissing')) ./ std(data_selected.trial{inor}, [], 2, 'omitmissing');
            end
        case 'non'
    end

    % Segment data for frequency analysis.
    cfg = [];
    cfg.length = segLen;
    cfg.overlap = segOver;
    cfg.keeptrials = 'yes';
    cfg.keeptapers = 'yes';

    data_segmented = ft_redefinetrial(cfg, data_selected);
    
    % Configure the frequency analysis parameters.
    cfg_mt = [];
    cfg_mt.method = 'mtmfft';  % Use multi-taper method for frequency analysis.
    cfg_mt.taper = 'hanning';
    cfg_mt.output = 'pow';  % Output power spectrum.
    cfg_mt.foilim = [fpass(1) fpass(2)];  % Frequency range (1 Hz to 100 Hz).
    cfg.foi = fpass(1):fstep:fpass(2);

    % Perform frequency analysis.
    freq = ft_freqanalysis(cfg_mt, data_segmented);

    % Convert power values to dB/Hz and smooth data for visualization.
    power_dBHz = 10 * log10(freq.powspctrm);
    smData = smoothdata(power_dBHz', 'gaussian', smWin);

    % Remove line noise (around 60 Hz).
    indNoise = freq.freq > 55 & freq.freq < 65;
    smData(indNoise) = nan;

    subplot(1, 5, [4 5])
    % Mean centering if needed.
    switch meanCentering
        case 'mean'
            smData = smData - mean(smData, 'omitmissing');
        case 'median'
            smData = smData - mean(smData, 'omitmissing');
        case 'hiFrqMed'
            indfrqbase = freq.freq > 65;
            smData = smData - mean(smData(indfrqbase), 'omitmissing');
        case 'non'
    end
    
    % Plot the power spectrum.
    plt(itr) = plot(freq.freq, smData);
    hold on
    plt(itr).DisplayName = upper(trialType{itr});
    plt(itr).Parent.XScale = 'log';
    plt(itr).Parent.XTick = round(logspace(log10(fpass(1)), log10(fpass(2)), 10));
    plt(itr).Parent.FontSize = 13;
    plt(itr).LineWidth = 2.2;
end

% Finalize plot formatting.
legend(plt)
xlim([fpass(1) + 1 fpass(2)])
xlabel('Frequency (Hz)');
ylabel('Power (dB)');
title(['Single Subject: ' subjList{subj}], ['Channel: ', channel_label]);
grid on
shg