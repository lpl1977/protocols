function p = setup_v04(p)
%  PLDAPS SETUP FILE
%  PACKAGE:  only_zuul
%  TRIAL FUNCTION:  trial_function

%
%  This version of the setup file has SET and notset trials in addition to
%  mask trials.
%

%  Set trial master function
p.trial.pldaps.trialFunction = 'only_zuul.trial_function';

%  Get default colors and put the default bit names in
p = defaultColors(p);
p = defaultBitNames(p);

% dot sizes for drawing
p.trial.stimulus.eyeW = 8;      % eye indicator width in pixels (for console display)
p.trial.stimulus.cursorW = 8;   % cursor width in pixels (for console display)

%  Put additional colors into the human and monkey CLUT
p.trial.display.humanCLUT(16,:) = [0 0 1];
p.trial.display.monkeyCLUT(16,:) = p.trial.display.bgColor;

p.trial.display.humanCLUT(17:25,:) = ...
     [    0    0.4470    0.7410     %  Blue
    0.8500    0.3250    0.0980      %  Orange
    0.9290    0.6940    0.1250      %  Yellow
    0.4940    0.1840    0.5560      %  Purple
    0.4660    0.6740    0.1880      %  Green
    0.3010    0.7450    0.9330      %  Cyan
    0.6350    0.0780    0.1840      %  Scarlet
    p.trial.display.bgColor        %  Gray
    1.000     0         0];         %  Red   
p.trial.display.monkeyCLUT(17:25,:) = p.trial.display.humanCLUT(17:25,:);

%  For the sake of convenience define some references to the colors
p.trial.display.clut.hWhite = 5*[1 1 1]';
p.trial.display.clut.bWhite = 7*[1 1 1]';
p.trial.display.clut.hCyan = 8*[1 1 1]';
p.trial.display.clut.bBlack = 9*[1 1 1]';
p.trial.display.clut.hGreen = 12*[1 1 1]';
p.trial.display.clut.hRed = 13*[1 1 1]';
p.trial.display.clut.hBlack =14*[1 1 1]';
p.trial.display.clut.hBlue = 15*[1 1 1]';

p.trial.display.clut.bBlue = 16*[1 1 1]';
p.trial.display.clut.bOrange = 17*[1 1 1]';
p.trial.display.clut.bYellow = 18*[1 1 1]';
p.trial.display.clut.bPurple = 19*[1 1 1]';
p.trial.display.clut.bGreen = 20*[1 1 1]';
p.trial.display.clut.bCyan = 21*[1 1 1]';
p.trial.display.clut.bScarlet = 22*[1 1 1]';
p.trial.display.clut.bGray = 23*[1 1 1]';

p.trial.display.clut.bRed = 24*[1 1 1]';

p.trial.sound.useForReward = 0;
p.trial.control_flags.use_eyepos = false;


%
%  JOYSTICK
%

%  Load the joystick calibration file
switch p.trial.session.subject
    case 'Meatball'
        p.trial.joystick.default.beta = getfield(load('/home/astaroth/Documents/MATLAB/settings/JoystickSettings_Meatball.mat','beta'),'beta');        
    otherwise
        p.trial.joystick.default.beta = getfield(load('/home/astaroth/Documents/MATLAB/settings/JoystickSettings.mat','beta'),'beta');
end

%  Thresholds between zones
%  Zone 1--joystick released [-Inf 2]
%  Zone 2--release buffer [2 4]
%  Zone 3--joystick engaged [4 8]
%  Zone 4--press buffer [8 12]
%  Zone 5--joystick pressed [12 Inf]

p.trial.joystick.default.threshold = [2 8 14.5 15];
p.trial.joystick.joystick_warning = p.trial.joystick.default;
p.trial.joystick.joystick_warning.threshold = [2 10 14 15];
p.trial.joystick.engage = p.trial.joystick.joystick_warning;

%
%  TIMING
%

p.trial.task.timing.engage.start_time = NaN;
p.trial.task.timing.engage.cue_start_time = NaN;
p.trial.task.timing.engage.cue_display_time = 0.25;
p.trial.task.timing.engage.cue_extinguish_time = 0.25;

p.trial.task.timing.delay.start_time = NaN;

p.trial.task.timing.symbol.start_time = NaN;

p.trial.task.timing.joystick_warning.start_time = NaN;
p.trial.task.timing.joystick_warning.duration = 10;

p.trial.task.timing.eye_warning.start_time = NaN;
p.trial.task.timing.eye_warning.duration = 10;
p.trial.task.timing.eye_warning.cue_start_time = NaN;
p.trial.task.timing.eye_warning.cue_display_time = 0.25;
p.trial.task.timing.eye_warning.cue_extinguish_time = 0.25;

p.trial.task.timing.reward.start_time = NaN;

p.trial.task.timing.response_cue.start_time = NaN;
p.trial.task.timing.response_cue.start_frame = NaN;
p.trial.task.timing.response_cue.grace = 20;
p.trial.task.timing.response_cue.buffer_entry_time = NaN;
p.trial.task.timing.response_cue.buffer_maximum_time = 10/120;

p.trial.task.timing.timeout.start_time = NaN;
p.trial.task.timing.timeout.duration = 2;

p.trial.task.timing.error_penalty.start_time = NaN;
p.trial.task.timing.error_penalty.duration = 0.5;

p.trial.task.timing.reward_delay.start_time = NaN;
p.trial.task.timing.reward_delay.eligible_start_time = NaN;

p.trial.task.timing.error_delay.start_time = NaN;
p.trial.task.timing.error_delay.eligible_start_time = NaN;

p.trial.task.timing.buffer.start_time = NaN;
p.trial.task.timing.buffer.maximum_time = 10/120;

%
%  FEATURES
%

%  Fixation cue
p.trial.task.features.fixation.width = 12;
p.trial.task.features.fixation.linewidth = 3;
p.trial.task.features.fixation.color = p.trial.display.clut.bWhite;

%  Engage
p.trial.task.features.engage = p.trial.task.features.fixation;
p.trial.task.features.engage.color = p.trial.display.clut.bYellow;

%  Warning cue
p.trial.task.features.warning = p.trial.task.features.fixation;
p.trial.task.features.joystick_warning.color = p.trial.display.clut.bRed;

%  Response cue
p.trial.task.features.response_cue.diameter = 100;
p.trial.task.features.response_cue.linewidth = 10;

%  Noise annulus
p.trial.task.features.annulus.outer_diameter = 150;
p.trial.task.features.annulus.inner_diameter = 60;
p.trial.task.features.annulus.noise_sigma = 0.2149;


%  Symbols / Symbol Masks
%p.trial.task.features.symbol.colors = [16 18 19 20 21 22];
%p.trial.task.features.symbol.color_names = {'B','O','Y','P','G','C','S'}
%  Purple and yellow only:
p.trial.task.features.symbol.color_names = {'Y','P'};
p.trial.task.features.symbol.colors = [19 20];
p.trial.task.features.symbol.background = 23;
p.trial.task.features.symbol.outer_diameter = 200;
p.trial.task.features.symbol.inner_diameter = p.trial.task.features.symbol.outer_diameter/sqrt(2);
p.trial.task.features.symbol.radius = 200;

diameter = p.trial.task.features.symbol.outer_diameter;
baseRect = [0 0 diameter diameter];
centeredRect = CenterRectOnPointd(baseRect, p.trial.display.ctr(1), p.trial.display.ctr(2));
radius = p.trial.task.features.symbol.radius;
dx = radius*cos(pi/6);
dy = radius*sin(pi/6);
p.trial.task.features.symbol.positions = [centeredRect + [-dx -dy -dx -dy]; centeredRect + [dx -dy dx -dy]; centeredRect + [0 radius 0 radius]];

%  Trial duration information
p.trial.pldaps.maxTrialLength = 5*60;
p.trial.pldaps.maxFrames = p.trial.pldaps.maxTrialLength*p.trial.display.frate;

%
%  Constants
%
p.trial.task.constants.minTrialTime = 60;
p.trial.task.constants.TrialsPerBlock = [];
p.trial.task.constants.maxBlocks = [];
p.trial.task.constants.maxTrials = [];

%  Subject specific timing parameters / actions
feval(str2func(strcat('only_zuul.',p.trial.session.subject)),p);

%
%  CONDITIONS MATRIX
%

%  Subject specific parameters
ntotal = p.trial.task.features.ntotal;
maskratio = p.trial.task.features.maskratio;
log10C = p.trial.task.features.log10C;

%  Luminances
bgColor =  p.trial.display.bgColor(1);
lum = bgColor(1) - (1-bgColor(1))*power(10,log10C);
nlum = length(lum);

%  Generate the sequences (only two colors for now)
[set,notset] = sequence.generator(p.trial.task.features.symbol.color_names);

%  The number of repetitions will be the number of sequences in the notset
%  category; that way, there is an example of each notset for each signal
%  strength.
nset = size(set,1);
nnotset = size(notset,1);

%  Organize trials into blocks.  There are, at a minimum, nlum*nnotset trials
%  from the notset category and nlum*nnotset trials from the set category in
%  the block.  Based on the maskratio there will be
%  2*nlum*nnotset*maskratio mask trials per block (nlum*nnotset*maskratio
%  release trials and nlum*nnotset*maskratio press trials).  Total number
%  of trials is then 2*nlum*nnotset + 2*nlum*nnotset*maskratio or
%  2*nlum*nnotset*(1+maskratio)

if(maskratio >= 1)
    NumSetTrials = 2*nlum*nnotset;
    NumMaskTrials = maskratio*nlum*nnotset; %  The number of release or press trials
else
    NumSetTrials = 2*nlum*nnotset/maskratio;
    NumMaskTrials = nlum*nnotset;
end

p.trial.task.constants.TrialsPerBlock = 2*(NumSetTrials+NumMaskTrials);
nblocks = floor(ntotal/p.trial.task.constants.TrialsPerBlock);
p.trial.task.constants.maxBlocks = nblocks;
p.trial.task.constants.maxTrials = p.trial.task.constants.maxBlocks*p.trial.task.constants.TrialsPerBlock;

%  Trial specifiers to be shuffled:
%  Column order:
%  1--luminance
%  2--log10C
%  3--luminance index into matrix for performance display purposes
%  4--choice (1==press, 0==release)
%  5--trial class (0==mask, 1==set, 2==notset)
%  6--index into sequence identifier

A = zeros(p.trial.task.constants.TrialsPerBlock,6);

%  Mask trials

%  Press trials
A(1:NumMaskTrials,1) = bgColor;
A(1:NumMaskTrials,2) = -Inf;
A(1:NumMaskTrials,3) = nlum+1;
A(1:NumMaskTrials,4) = 1;

%  Release trials
A(1+NumMaskTrials:2*NumMaskTrials,1) = repmat(lum(:),NumMaskTrials/nlum,1);
A(1+NumMaskTrials:2*NumMaskTrials,2) = repmat(log10C(:),NumMaskTrials/nlum,1);
A(1+NumMaskTrials:2*NumMaskTrials,3) = repmat((1:nlum)',NumMaskTrials/nlum,1);

%  notset trials (press)
A(1+2*NumMaskTrials:2*NumMaskTrials+NumSetTrials,1) = bgColor;
A(1+2*NumMaskTrials:2*NumMaskTrials+NumSetTrials,2) = -Inf;
A(1+2*NumMaskTrials:2*NumMaskTrials+NumSetTrials,3) = 1;
A(1+2*NumMaskTrials:2*NumMaskTrials+NumSetTrials,4) = 1;
A(1+2*NumMaskTrials:2*NumMaskTrials+NumSetTrials,5) = 2;
A(1+2*NumMaskTrials:2*NumMaskTrials+NumSetTrials,6) = repmat((1:nnotset)',NumSetTrials/nnotset,1);

%  Set trials (release)
A(1+2*NumMaskTrials+NumSetTrials:2*(NumMaskTrials+NumSetTrials),1) = repmat(lum(:),NumSetTrials/nlum,1);
A(1+2*NumMaskTrials+NumSetTrials:2*(NumMaskTrials+NumSetTrials),2) = repmat(log10C(:),NumSetTrials/nlum,1);
A(1+2*NumMaskTrials+NumSetTrials:2*(NumMaskTrials+NumSetTrials),3) = repmat((1:nlum)',NumSetTrials/nlum,1);
A(1+2*NumMaskTrials+NumSetTrials:2*(NumMaskTrials+NumSetTrials),4) = 0;
A(1+2*NumMaskTrials+NumSetTrials:2*(NumMaskTrials+NumSetTrials),5) = 1;
sequence_index = repmat(1:nset,nlum,1);
sequence_index = sequence_index(:);
A(1+2*NumMaskTrials+NumSetTrials:2*(NumMaskTrials+NumSetTrials),6) = repmat(sequence_index,NumSetTrials/(nset*nlum),1);

A = repmat(A,nblocks,1);

%  Trial specifiers not to be shuffled:
%  1--within block trial number
%  2--block number

B = zeros(p.trial.task.constants.TrialsPerBlock,2);

B(1:2*(NumMaskTrials+NumSetTrials),1) = (1:2*(NumMaskTrials+NumSetTrials))';
B = repmat(B,nblocks,1);
blocknum = repmat(1:nblocks,2*(NumMaskTrials+NumSetTrials),1);
B(:,2) = blocknum(:);

%  Now go through and shuffle the trials within the blocks.

for i=1:nblocks
    indx = B(:,2)==i;
    A(indx,:) = Shuffle(A(indx,:),2);
end

%  Features of the trials
%
%  luminance -- for stimulus preparation
%  log10C -- for display
%  lum_indx -- for record keeping
%  trial_type -- press or release
%  sequence_type -- mask versus the sequence type
%  symbol_code -- array of strings describing symbols
%  symbol_features -- array of structures describing symbols

ntrials = size(A,1);
c = cell(1,ntrials);
for i=1:ntrials
    c{i}.luminance = A(i,1);
    c{i}.log10C = A(i,2);
    c{i}.lum_indx = A(i,3);
    if(A(i,4))
        c{i}.trial_type = 'press';
    else
        c{i}.trial_type = 'release';
    end
    if(A(i,5)==0)
        c{i}.sequence_type = 'mask';
    elseif(A(i,5)==1)
        c{i}.sequence_type = 'set';
        c{i}.sequence_code = strcat(set{A(i,6),1},'.',set{A(i,6),2},'.',set{A(i,6),3});
        for j=1:3
            c{i}.symbol_features(j).color = p.trial.task.features.symbol.colors(strcmp(set{A(i,6),j},p.trial.task.features.symbol.color_names));
            c{i}.symbol_features(j).name = set{A(i,6),j};
        end
    else
        c{i}.sequence_type = 'notset';
        c{i}.sequence_code = strcat(notset{A(i,6),1},'.',notset{A(i,6),2},'.',notset{A(i,6),3});
        for j=1:3
            c{i}.symbol_features(j).color = p.trial.task.features.symbol.colors(strcmp(notset{A(i,6),j},p.trial.task.features.symbol.color_names));
            c{i}.symbol_features(j).name = notset{A(i,6),j};
        end
    end
    
    c{i}.trial_number = B(i,1);
    c{i}.block_number = B(i,2);
end
p.conditions = c;

%  Maximum number of trials
p.trial.pldaps.finish = Inf;
