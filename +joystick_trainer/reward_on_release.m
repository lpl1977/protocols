function p = reward_on_release(p,state)
%reward_on_release(p,state)
%
%  PLDAPS trial function for joystick training
%
%  Reward when joystick released, give visual feedback

%  Call default trial function for state dependent steps
pldapsDefaultTrialFunction(p,state);

%  Trial state summary:
%
%  1.  STATE_BAITED This state starts after the previous unbaited state.
%  If the monkey engages the joystick during this time state will
%  transition to engage.  Otherwise transition back to unbaited state.

STATE_BAITED = 1000;

%  2.  STATE_ENGAGED This state starts when the monkey engages the joystick
%  during the baited state. Monkey may receive little rewards as long as
%  joystick is engaged and it remains baited (this is the time during which
%  other stimuli would be presented).

STATE_ENGAGED = 1010;

%  3.  STATE_UNBAITED This state precedes the baited period.  Monkey should
%  have joystick disengaged for this entire time.  If he re-engages then
%  go to timeout.

STATE_UNBAITED = 1020;

%  4.  STATE_RELEASE This state starts after the engaged period and
%  includes an instruction to release the joystick; if he does so prior to
%  the grace he may receive a reward.

STATE_RELEASE = 1030;

%  5.  STATE_TIMEOUT Enter this state if monkey engages joystick during
%  unbaited time.

STATE_TIMEOUT = 1040;

%  6.  STATE_REWARD Enter this state if monkey correctly releases the
%  joystick.

STATE_REWARD = 1050;

%  Joystick state summary:
%
%  1.  JOYSTICK_RELEASED Joystick is currently not exceeding the rest
%  threshold.

JOYSTICK_RELEASED = 0;

%  2.  JOYSTICK_ENGAGED Joystick is currently exceeding the engage
%  threshold.

JOYSTICK_ENGAGED = 1;

%  3.  JOYSTICK_EQUIVOCAL Joystick is past release threshold and not
%  exceeding engage threshold. This is here to prevent the monkey from
%  holding the joystick at threshold and allowing it to trigger off noise.

JOYSTICK_EQUIVOCAL = 2;

%
%  Switch frame states
%
switch state
    
    case p.trial.pldaps.trialStates.trialSetup
        %  Trial Setup, for example starting up Datapixx ADC and allocating
        %  memory
        
        %  This is where we would perform any steps that needed to be done
        %  before a trial is started, for example preparing stimuli
        %  parameters
        
        %  Confirm joystick is attached; if not, then stop trial and pause
        %  protocol
        if(~isstruct(joystick.get_joystick_status(0,0)))
            disp('Warning:  joystick disconnected.  Plug it in, I will wait...');
            p.trial.pldaps.pause.type = 1;
            p.trial.pldaps.quit = 1;
        end
        
        %  Set subject specific parameters
        
        joystick_trainer.(p.trial.session.subject)(p)
        
        %
        %  Initialize trial state
        %
        p.trial.stimulus.trial_state = STATE_UNBAITED;
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        %  Clean Up and Save, post trial management
        
        %  Check if we have completed conditions; if so, we're finished.
        if(p.trial.pldaps.iTrial==length(p.conditions))
            p.trial.pldaps.quit=2;
        end
        
    case p.trial.pldaps.trialStates.frameDraw
        %  Got nothing here on my end
        
    case p.trial.pldaps.trialStates.frameUpdate
        %  Frame Update is called once after the last frame is done (or
        %  even before).  Get current eyepostion, curser position,
        %  keypresses, joystick position, etc.
        
        %  Grab a snapshot of the joystick data
        p.trial.joystick.snapshot = joystick.get_joystick_status([p.trial.joystick.released_threshold p.trial.joystick.engaged_threshold -3*p.trial.joystick.released_threshold],p.trial.joystick.orientation);
        
        %  DO NOT PROCEED IF JOYSTICK IS DISCONNECTED
        if(~isstruct(p.trial.joystick.snapshot))
            disp('Warning:  joystick disconnected.  Plug it in, I will wait...');
            while(~isstruct(p.trial.joystick.snapshot))
                p.trial.joystick.snapshot = joystick.get_joystick_status([p.trial.joystick.released_threshold p.trial.joystick.engaged_threshold -3*p.trial.joystick.released_threshold],p.trial.joystick.orientation);
            end
        end
        
    case p.trial.pldaps.trialStates.framePrepareDrawing
        %  Frame PrepareDrawing is where you can prepare all drawing and
        %  task state control.

        %  Determine joystick status
        if(p.trial.joystick.snapshot.status(1)==0 && p.trial.joystick.snapshot.status(3)==0)
            p.trial.joystick.state=JOYSTICK_RELEASED;
        elseif(p.trial.joystick.snapshot.status(2)==1)
            p.trial.joystick.state=JOYSTICK_ENGAGED;
        else
            p.trial.joystick.state=JOYSTICK_EQUIVOCAL;
        end
                
        %  Display joystick status to screen
        joystick.joystick_display(p,p.trial.joystick.snapshot);
        
        %
        %  Control trial events based on trial state
        %
        
        switch p.trial.stimulus.trial_state
            
            case STATE_BAITED
                
                %
                %  STATE_BAITED
                %
                
                %  We only reached this state because the unbaited time
                %  elapsed.
                
                %  Show the cue to indicate that we are in baited state
                ShowBaitedCue(p);
                
                %  Start timer
                %
                %  Once monkey engages joystick during baited time switch
                %  to engaged state.
                if(isnan(p.trial.stimulus.timing.baited_start_time))
                    p.trial.stimulus.timing.baited_start_time = GetSecs;
                    p.trial.stimulus.timing.baited_wait_for_release = p.trial.joystick.state~=JOYSTICK_RELEASED;
                    if(p.trial.stimulus.timing.baited_wait_for_release)
                        fprintf('Start baited state; must wait for monkey to release joystick.\n');
                    else
                        fprintf('Start baited state; must wait for monkey to engage joystick.\n');
                    end
                elseif(~p.trial.stimulus.timing.baited_wait_for_release && p.trial.joystick.state==JOYSTICK_ENGAGED)
                    fprintf('Monkey triggered engage state after %0.3f sec.\n',GetSecs-p.trial.stimulus.timing.baited_start_time);
                    p.trial.stimulus.timing.baited_start_time = NaN;
                    p.trial.stimulus.trial_state = STATE_ENGAGED;
                elseif(p.trial.stimulus.timing.baited_wait_for_release)
                    p.trial.stimulus.timing.baited_wait_for_release = p.trial.joystick.state~=JOYSTICK_RELEASED;
                end
                
            case STATE_ENGAGED
                
                %
                %  STATE_ENGAGED
                %
                
                %  Show the cue to continue holding the joystick
                ShowEngagedCue(p);
                
                %  Start timer
                if(isnan(p.trial.stimulus.timing.engaged_start_time))
                    p.trial.stimulus.timing.engaged_start_time = GetSecs;
                    fprintf('Start engaged state of %0.3f sec duration.\n',p.trial.stimulus.timing.engaged_time);
                elseif(p.trial.stimulus.timing.engaged_start_time >= GetSecs-p.trial.stimulus.timing.engaged_time)
                    %  We are still within the engage time
                    
                    if(p.trial.joystick.state==JOYSTICK_RELEASED)
                        %  Monkey has released the joystick prematurely.
                        held_time = GetSecs-p.trial.stimulus.timing.engaged_start_time;
                        fprintf('Monkey released joystick early (%0.3f sec).\n',held_time);
                        pds.audio.play(p,'breakfix');
                        
                        %  Set time out time
                        if(~isnan(p.trial.stimulus.timing.timeout))
                            p.trial.stimulus.timing.timeout = 0.5;
                            p.trial.stimulus.timing.engaged_reward_time = NaN;
                            p.trial.stimulus.timing.engaged_start_time = NaN;
                            p.trial.stimulus.trial_state = STATE_TIMEOUT;
                        else
                            fprintf('End trial %d.\n',p.trial.pldaps.iTrial);
                            p.trial.flagNextTrial = true;
                        end
                    end
                else
                    %  engage time has elapsed.
                    fprintf('Monkey held joystick to end of engaged time.\n');
                    p.trial.stimulus.timing.engaged_start_time = NaN;
                    p.trial.stimulus.trial_state = STATE_RELEASE;
                end
                
            case STATE_RELEASE
                
                %
                %  STATE_RELEASE
                %
                
                %  Show release cue
                ShowReleaseCue(p);
                
                if(isnan(p.trial.stimulus.timing.release_start_time))
                    p.trial.stimulus.timing.release_start_time = GetSecs;
                    fprintf('Monkey should release joystick within %0.3f sec to get a release reward.\n',p.trial.stimulus.timing.grace_to_release);
                elseif(p.trial.stimulus.timing.release_start_time >= GetSecs - p.trial.stimulus.timing.grace_to_release)
                    %  Still in grace period to release
                    if(p.trial.joystick.state==JOYSTICK_RELEASED)
                        fprintf('Monkey released joystick with reaction time %0.3f sec.\n',GetSecs-p.trial.stimulus.timing.release_start_time);
                        p.trial.stimulus.release_start_time = NaN;
                        p.trial.stimulus.trial_state = STATE_REWARD;
                    end
                else
                    %  Monkey did not release in time.
                    fprintf('Monkey did not release joystick in time.  End trial.\n');
                    pds.audio.play(p,'incorrect');
                    p.trial.stimulus.timing.timeout = 0.5;
                    p.trial.stimulus.release_start_time = NaN;
                    p.trial.stimulus.trial_state = STATE_TIMEOUT;
                end
                
            case STATE_TIMEOUT
                
                %
                %  STATE_TIMEOUT
                %
                
                %  Burn a timeout period.
                
                if(isnan(p.trial.stimulus.timing.timeout_start_time))
                    fprintf('Start timeout period of %0.3f sec\n',p.trial.stimulus.timing.timeout);
                    p.trial.stimulus.timing.timeout_start_time = GetSecs;
                elseif(p.trial.stimulus.timing.timeout_start_time <= GetSecs - p.trial.stimulus.timing.timeout)
                    fprintf('Timeout elapsed.  End trial %d.\n',p.trial.pldaps.iTrial);
                    p.trial.stimulus.timing.timeout_start_time = NaN;
                    p.trial.flagNextTrial = true;
                end
                
                
            case STATE_UNBAITED
                
                %
                %  STATE_UNBAITED
                %
                
                %  Blank screen for unbaited state
                
                if(isnan(p.trial.stimulus.timing.unbaited_start_time))
                    fprintf('Start unbaited state of %0.3f sec for trial %d.\n',p.trial.stimulus.timing.unbaited_time,p.trial.pldaps.iTrial);
                    p.trial.stimulus.timing.unbaited_start_time = GetSecs;
                elseif(p.trial.stimulus.timing.unbaited_start_time <= GetSecs - p.trial.stimulus.timing.unbaited_time)
                    fprintf('Unbaited state complete.\n');
                    p.trial.stimulus.timing.unbaited_start_time = NaN;
                    p.trial.stimulus.trial_state = STATE_BAITED;
                end
                
            case STATE_REWARD
                
                %
                %  STATE_REWARD
                %                
                
                %  Continue showing release cue
                ShowReleaseCue(p);
                                
                if(isnan(p.trial.stimulus.timing.feedback_start_time))
                    p.trial.stimulus.timing.feedback_start_time = GetSecs;
                    fprintf('Start feedback delay of %0.3f sec.\n',p.trial.stimulus.timing.feedback_delay);
                elseif(p.trial.stimulus.timing.feedback_start_time > GetSecs-p.trial.stimulus.timing.feedback_delay)
                    if(p.trial.joystick.state~=JOYSTICK_RELEASED)
                        fprintf('Monkey engaged joystick during feedback delay.\n');
                        pds.audio.play(p,'breakfix');
                        p.trial.stimulus.timing.feedback_start_time = NaN;
                        p.trial.stimulus.timing.timeout = 0.5;
                        p.trial.stimulus.trial_state = STATE_TIMEOUT;
                    end
                else
                    pds.behavior.reward.give(p,p.trial.stimulus.release_reward_amount);
                    pds.audio.play(p,'reward');
                    fprintf('Monkey received reward for %0.3f sec.\n',p.trial.stimulus.release_reward_amount);
                    p.trial.stimulus.timing.feedback_start_time = NaN;
                    fprintf('End trial %d.\n',p.trial.pldaps.iTrial);
                    p.trial.flagNextTrial = true;
                end
        end
end
end

%  FUNCTIONS TO DO SOME FRAME DRAWING

function ShowBaitedCue(p)
%  ShowBaitedCue
%
%  This function should draw a blinking rectangle as the cue to engage the
%  joystick.
%
%  In PLDAPS the pointer to the stimulus window is p.trial.display.ptr

width = p.trial.stimulus.features.baited.cue_width;
baseRect = [0 0 width width];
centeredRect = CenterRectOnPointd(baseRect, p.trial.display.ctr(1), p.trial.display.ctr(2));

display_time = p.trial.stimulus.features.baited.cue_period*p.trial.stimulus.features.baited.cue_duty_cycle;
cue_period = p.trial.stimulus.features.baited.cue_period;
if(isnan(p.trial.stimulus.timing.baited_cue_start_time))
    p.trial.stimulus.timing.baited_cue_start_time = GetSecs;
    Screen('FrameRect',p.trial.display.ptr,p.trial.stimulus.features.baited.cue_color,centeredRect,p.trial.stimulus.features.baited.cue_linewidth);
else
    if(p.trial.stimulus.timing.baited_cue_start_time > GetSecs-display_time)
        Screen('FrameRect',p.trial.display.ptr,p.trial.stimulus.features.baited.cue_color,centeredRect,p.trial.stimulus.features.baited.cue_linewidth);
    elseif(p.trial.stimulus.timing.baited_cue_start_time <= GetSecs-cue_period)
        p.trial.stimulus.timing.baited_cue_start_time = NaN;
    end
end
end

function ShowEngagedCue(p)
%  ShowEngagedCue
%
%  This function should draw a white rectangle as the cue to continue
%  engaging the joystick.
%
%  In PLDAPS the pointer to the stimulus window is p.trial.display.ptr
%
%  I want a square drawn as a cue to engage the joystick.  It will be white
%  and centered in the middle of the screen, where there is not currently a
%  fixation point but at some point in the future there will be.  I don't
%  need it smoothed.

width = p.trial.stimulus.features.engaged.cue_width;
baseRect = [0 0 width width];
centeredRect = CenterRectOnPointd(baseRect, p.trial.display.ctr(1), p.trial.display.ctr(2));

Screen('FrameRect',p.trial.display.ptr,p.trial.stimulus.features.engaged.cue_color,centeredRect,p.trial.stimulus.features.engaged.cue_linewidth);
end

function ShowReleaseCue(p)
%  ShowReleaseCue
%
%  This function should draw a black rectangle as the cue that the joystick
%  is released.
%
%  I want a square drawn as a cue indicating release of joystick.  It will
%  be black and centered in the middle of the screen, where there is not
%  currently a fixation point but at some point in the future there will
%  be.  I don't need it smoothed.


width = p.trial.stimulus.features.release.cue_width;
baseRect = [0 0 width width];
centeredRect = CenterRectOnPointd(baseRect, p.trial.display.ctr(1), p.trial.display.ctr(2));

Screen('FrameRect',p.trial.display.ptr,p.trial.stimulus.features.release.cue_color,centeredRect,p.trial.stimulus.features.release.cue_linewidth);
end