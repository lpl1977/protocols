function p = joystick_trainer_setup(p)
%joystick_setup a PLDAPS experiment setup file for initial joystick
%testing and training.

%  Create the initial trial structure
p = pdsDefaultTrialStructure(p);

%  Setup default trial values in p.trial
p = joystick_trainer.joystick_defaultTrialVariables(p);

%  Set trial master function, this gets called each trial
%p.defaultParameters.pldaps.trialFunction = 'joystick_trainer.joystick_trainer_trial_function';

p.defaultParameters.pldaps.trialFunction = 'joystick_trainer.reward_on_release';

%  Let's try and make the color purple
p.defaultParameters.display.humanCLUT(15+1,:) = [147 112 219]/255;
p.defaultParameters.display.monkeyCLUT(15+1,:) = [147 112 219]/255;


%  Try and set this (not sure yet what it's for):
p.trial.display.clut.fixationColor = p.trial.display.clut.bg;

%
%  State control
%

%  Trial
p.trial.stimulus.trial_state = NaN;

%  Joystick
p.trial.stimulus.joystick.state = NaN;

%  Error type
p.trial.stimulus.error_code = NaN;

%
%  Features of stimulus
%
p.trial.stimulus.features.baited.cue_width = 200;
p.trial.stimulus.features.baited.cue_duty_cycle = 0.5;
p.trial.stimulus.features.baited.cue_period = 1;
p.trial.stimulus.features.baited.cue_linewidth = 16;
p.trial.stimulus.features.baited.cue_color = [1 1 1];

p.trial.stimulus.features.engaged = p.trial.stimulus.features.baited;

p.trial.stimulus.features.unbaited = p.trial.stimulus.features.baited;
p.trial.stimulus.features.unbaited.cue_color = [0 0 0];
%p.trial.stimulus.features.unbaited.cue_width = 400;

p.trial.stimulus.features.reward = p.trial.stimulus.features.baited;
p.trial.stimulus.features.reward.cue_color = [0 0 0];

p.trial.stimulus.features.released = p.trial.stimulus.features.unbaited;


%
%  Reward sounds
%
p.trial.behavior.fail_to_release.sound.file = 'breakfix';
p.trial.behavior.early_release.sound.file = 'incorrect';
p.trial.behavior.fail_to_engage.sound.file = 'incorrect';
p.trial.behavior.reward.sound.file = 'reward';

%  Trial duration information
p.trial.pldaps.maxTrialLength = 1000;
p.trial.pldaps.maxFrames = p.trial.pldaps.maxTrialLength*p.trial.display.frate;

p.trial.stimulus.error_code = 0;

p.trial.stimulus.exit_flag = 0;

%  Set up condition array
%  Only one condition--push the joystick
c = cell(1);
c{1}.Nr=1;
p.conditions=repmat(c,1,1000);

%  Maximum number of trials
p.trial.pldaps.finish = 1000;
