function p = set_trainer(p,state)
%set(p,state)
%
%  PLDAPS trial function for set game training
%
%  NOTE TO SELF:  I am writing this for speedier execution rather than
%  parsimonious code.

%  Call default trial function for state dependent steps
pldapsDefaultTrialFunction(p,state);

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
        
        %  Set subject specific parameters / actions
        
        set_trainer.(p.trial.session.subject)(p)
        
        %  Prepare symbols
        %set_trainer.make_symbols(p);        
        p.trial.stimulus.flow_control.current_symbol = 1;
        p.trial.stimulus.flow_control.num_symbols = 3;
        
        %  Initialize trial state
        
        p.trial.stimulus.flow_control.trial_state = 'engage';
        
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
        p.trial.joystick.snapshot = joystick.get_joystick_status([p.trial.stimulus.flow_control.joystick_released_threshold p.trial.stimulus.flow_control.joystick_engaged_threshold],p.trial.stimulus.flow_control.joystick_orientation);
        
    case p.trial.pldaps.trialStates.framePrepareDrawing
        %  Frame PrepareDrawing is where you can prepare all drawing and
        %  task state control.
        
        %  Determine joystick status
        p.trial.stimulus.flow_control.joystick_released = ~p.trial.joystick.snapshot.status(1);
        p.trial.stimulus.flow_control.joystick_engaged = ~~p.trial.joystick.snapshot.status(2);
        
        %  Determine eye status
        p.trial.stimulus.flow_control.fixating = true;
        
        %  Display joystick status to screen
        joystick.joystick_display(p,p.trial.joystick.snapshot);
        
        %
        %  Control trial events based on trial state
        %
        
        switch p.trial.stimulus.flow_control.trial_state
            
            case 'engage'
                
                %%%%%%%%%%%%%%%%%%%%
                %  STATE:  engage  %
                %%%%%%%%%%%%%%%%%%%%
                                
                if(isnan(p.trial.stimulus.states.engage.timing.start_time))
                    
                    %  This is our first pass through on this trial.
                    
                    p.trial.stimulus.states.engage.timing.start_time = GetSecs;
                    p.trial.stimulus.states.engage.timing.cue_start_time = GetSecs;
                    fprintf('ENGAGE cue for trial %d.\n',p.trial.pldaps.iTrial);
                    
                    p.trial.stimulus.flow_control.engage_wait_for_release = ~p.trial.stimulus.flow_control.joystick_released;
                    
                    if(p.trial.stimulus.flow_control.engage_wait_for_release)
                        fprintf('\t%s must release joystick before re-engaging.\n',p.trial.session.subject);
                    end
                    
                    %  Show engage cue
                    
                    ShowEngageCue;
                    
                    %  Show him the fixation cue
                    
                    ShowFixationCue;
                    
                elseif(~isnan(p.trial.stimulus.states.engage.timing.engage_time))
                    
                    %  Since the engage timer started, I know that the
                    %  monkey had the joystick engaged and was fixating
                    %  last pass through.  If this is still the case then
                    %  show him the fixation cue and continue with the
                    %  delay timer until it ends.
                    %
                    %  If he has released the joystick, then show engage
                    %  cue and restart the engage state.
                    %
                    %  If he has broken fixation but holds joystick, show
                    %  fixation cue and restart the engage state.
                    
                    if(p.trial.stimulus.flow_control.joystick_engaged && p.trial.stimulus.flow_control.fixating)
                        
                        ShowFixationCue;
                        
                        if(p.trial.stimulus.states.engage.timing.engage_time <= GetSecs - p.trial.stimulus.states.engage.timing.post_engage_delay)
                            p.trial.stimulus.states.engage.timing.engage_time = NaN;
                            p.trial.stimulus.states.engage.timing.start_time = NaN;
                            p.trial.stimulus.states.engage.timing.cue_start_time = NaN;
                            p.trial.stimulus.flow_control.trial_state = 'symbols';
                            fprintf('\t%s has successfully remained engaged to end of delay period.\n',p.trial.session.subject);
                        end
                        
                    else
                        fprintf('\t%s disengaged during delay; restart engage state.\n',p.trial.session.subject);
                        if(~p.trial.stimulus.flow_control.joystick_engaged)
                            ShowEngageCue;
                        end
                        
                        ShowFixationCue;
                        
                        p.trial.stimulus.states.engage.timing.engage_time = NaN;
                        p.trial.stimulus.states.engage.timing.start_time = NaN;
                        p.trial.stimulus.states.engage.timing.cue_start_time = NaN;
                    end
                else
                    
                    %  Since the engage timer has not yet started, I know
                    %  that the monkey had not both engaged the joystick
                    %  and fixated on the last pass through.  First check
                    %  and see if he has engaged since our last cycle.
                    
                    if(~p.trial.stimulus.flow_control.engage_wait_for_release && p.trial.stimulus.flow_control.joystick_engaged && p.trial.stimulus.flow_control.fixating)
                        fprintf('\t%s engaged after %0.3f sec.\n',p.trial.session.subject,GetSecs-p.trial.stimulus.states.engage.timing.start_time);
                        fprintf('\tBegin %0.3f sec delay.\n',p.trial.stimulus.states.engage.timing.post_engage_delay);
                        p.trial.stimulus.states.engage.timing.engage_time = GetSecs;
                        ShowFixationCue;
                    else
                        
                        %  If we are waiting for the monkey to release the
                        %  joystick check here if he has.
                        
                        if(p.trial.stimulus.flow_control.engage_wait_for_release && p.trial.stimulus.flow_control.joystick_released)
                            p.trial.stimulus.flow_control.engage_wait_for_release = false;
                            fprintf('\t%s released joystick at %0.3f sec.\n',p.trial.session.subject,GetSecs-p.trial.stimulus.states.engage.timing.start_time);
                        end
                        
                        %  The monkey hasn't yet both engaged the joystick
                        %  and fixated.  What we do next depends on where
                        %  we are with respect to the cue display timer and
                        %  whether or not he has engaged the joystick or
                        %  fixated.
                        
                        if(p.trial.stimulus.states.engage.timing.cue_start_time > GetSecs - p.trial.stimulus.states.engage.timing.cue_display_time)
                            
                            if(p.trial.stimulus.flow_control.engage_wait_for_release || ~p.trial.stimulus.flow_control.joystick_engaged)
                                ShowEngageCue;
                            end
                            ShowFixationCue;
                            
                        else
                            if(p.trial.stimulus.states.engage.timing.cue_start_time <= GetSecs - p.trial.stimulus.states.engage.timing.cue_period)
                                p.trial.stimulus.states.engage.timing.cue_start_time = GetSecs;
                            end
                            if(p.trial.stimulus.flow_control.fixating)
                                ShowFixationCue;
                            end
                        end
                    end
                end
                
            case 'symbols'
                
                %%%%%%%%%%%%%%%%%%%%%
                %  STATE:  symbols  %
                %%%%%%%%%%%%%%%%%%%%%
                
                %  If monkey still has joystick engaged and continues to
                %  fixate and there are additional symbols to present,
                %  continue presenting symbols.
                
                if(p.trial.stimulus.flow_control.joystick_engaged && p.trial.stimulus.flow_control.fixating)
                    
                    if(isnan(p.trial.stimulus.states.symbols.timing.start_time))
                        p.trial.stimulus.states.symbols.timing.start_time = GetSecs;
                        fprintf('SYMBOL %d OF %d FOR TRIAL %d.\n',p.trial.stimulus.flow_control.current_symbol,p.trial.stimulus.flow_control.num_symbols,p.trial.pldaps.iTrial);
                        
                        %  Show the symbol and fixation square
                        
                        ShowSymbol;
                        ShowFixationCue;
                        
                        %  If this is the last symbol then also show the
                        %  release cue
                        
                        ShowReleaseCue;
                        
                    elseif(p.trial.stimulus.states.symbols.timing.start_time <= GetSecs - p.trial.stimulus.states.symbols.timing.total)
                        
                        %  We've reached the end of the total time and the
                        %  monkey is still engaged.  If this is the end of
                        %  the symbol sequence then he has missed his
                        %  opportunity to identify the set.  Otherwise
                        %  increment the symbol counter and continue to
                        %  next symbol.
                        
                        p.trial.stimulus.states.symbols.timing.start_time = NaN;
                        
                        if(p.trial.stimulus.flow_control.current_symbol == p.trial.stimulus.flow_control.num_symbols)
                            
                            %  Monkey didn't release in time.
                            
                            p.trial.stimulus.trial_result = 'miss';
                            p.trial.stimulus.flow_control.trial_state = 'timeout';
                            p.trial.stimulus.states.timeout.duration = 0.5;
                            fprintf('\t%s missed the set.  Go to short timeout.\n',p.trial.session.subject);
                        else
                            
                            p.trial.stimulus.flow_control.current_symbol = p.trial.stimulus.flow_control.current_symbol + 1;
                            
                            ShowSymbol;
                            ShowFixationCue;
                            
                            
                            %  If this is the last symbol then also show the
                            %  release cue
                            
                            ShowReleaseCue;
                            
                        end
                        
                    elseif(p.trial.stimulus.states.symbols.timing.start_time <= GetSecs - p.trial.stimulus.states.symbols.timing.display_time)
                        
                        %  We've reached the end of the display time for
                        %  the symbol, so show only the fixation cue.
                        
                        ShowFixationCue;
                        
                        %  If this is the last symbol in the list we also
                        %  need to show the release cue.
                        
                        ShowReleaseCue;
                        
                    else
                        
                        %  Display time has not yet elapsed so show symbol
                        %  and fixation cue.
                        
                        ShowSymbol;
                        ShowFixationCue;
                        
                        %  If this is the last symbol in the list we also
                        %  need to show the release cue.
                        
                        ShowReleaseCue;
                        
                    end
                    
                elseif(p.trial.stimulus.flow_control.fixating)
                    
                    %  Monkey has released the joystick but remains
                    %  fixating.  If he has seen enough symbols then this
                    %  will be a response.  Otherwise it is an early
                    %  release.
                    
                    %  If this is an early release or an error then we will
                    %  need to give him a timeout of an appropriate
                    %  duration.
                    
                    
                    if(p.trial.stimulus.flow_control.current_symbol < p.trial.stimulus.flow_control.min_symbols)
                        
                        %  Monkey has released early.  We will proceed
                        %  directly to a timeout equal to the remaining
                        %  time he would have spent in the trial (in
                        %  this case including the feedback delay).
                        %  The fixation cue stops for the timeout
                        %  period.
                        
                        p.trial.stimulus.states.symbols.timing.start_time = NaN;
                        p.trial.stimulus.states.timeout.duration = p.trial.stimulus.states.timeout.timing.max_duration - (GetSecs - p.trial.stimulus.states.symbols.timing.start_time) - p.trial.stimulus.states.symbols.timing.total*(p.trial.stimulus.flow_control.current_symbol-1) + p.trial.stimulus.states.feedback_delay.timing.delay;
                        pds.audio.play(p,'breakfix');
                        p.trial.stimulus.trial_result = 'early_release';
                        p.trial.stimulus.flow_control.trial_state = 'timeout';
                        fprintf('\t%s released joystick too early; go to timeout.\n',p.trial.session.subject);
                        
                    elseif(p.trial.stimulus.flow_control.current_symbol==p.trial.stimulus.flow_control.num_symbols)
                        
                        %  Monkey has released the joystick and
                        %  correctly identified that it is a set.  Go
                        %  to feedback delay.  Continue to show the
                        %  fixation cue.
                        
                        p.trial.stimulus.states.symbols.timing.start_time = NaN;
                        p.trial.stimulus.trial_result = 'correct';
                        p.trial.stimulus.flow_control.trial_state = 'feedback_delay';
                        fprintf('\t%s released joystick correctly; go to feedback delay.\n',p.trial.session.subject);
                        
                        ShowFixationCue;
                        
                        %  Since this was the last symbol in the list we
                        %  also need to show the release cue.
                        
                        ShowReleaseCue;
                        
                    else
                        
                        %  Monkey has released the joystick but
                        %  incorrectly identified the set.  Go to
                        %  feedback delay but make sure the appropriate
                        %  timeout has been calculated because he will
                        %  proceed to the timeout after the feedback
                        %  delay.  Continue to show the fixation cue.
                        
                        p.trial.stimulus.states.symbols.timing.start_time = NaN;
                        p.trial.stimulus.states.timeout.timing.duration = p.trial.stimulus.states.timeout.timing.max_duration - (GetSecs - p.trial.stimulus.states.symbols.timing.start_time) - p.trial.stimulus.states.symbols.timing.total*(p.trial.stimulus.flow_control.current_symbol-1);
                        p.trial.stimulus.trial_result = 'false_alarm';
                        p.trial.stimulus.flow_control.trial_state = 'feedback_delay';
                        fprintf('\t%s gave a false alarm; go to feedback delay.\n',p.trial.session.subject);
                        
                        ShowFixationCue;
                    end
                    
                else
                    
                    %  The monkey broke fixation.
                    
                    p.trial.stimulus.states.symbols.timing.start_time = NaN;
                    
                    p.trial.stimulus.states.timeout.duration = p.trial.stimulus.states.timeout.max_duration - (GetSecs - p.trial.stimulus.states.symbols.timing.start_time) - p.trial.stimulus.states.symbols.timing.total*(p.trial.stimulus.flow_control.current_symbol-1);
                    pds.audio.play(p,'breakfix');
                    p.trial.stimulus.flow_control.trial_state = 'timeout';
                    p.trial.stimulus.trial_result = 'broke_fix';
                    fprintf('\t%s broke fixation; go to timeout.\n',p.trial.session.subject);
                end
                
            case 'timeout'
                
                %%%%%%%%%%%%%%%%%%%%%
                %  STATE:  timeout  %
                %%%%%%%%%%%%%%%%%%%%%
                
                %  In this state we are going to burn a timeout period.
                %  After that is over, end trial.
                
                if(isnan(p.trial.stimulus.states.timeout.timing.start_time))
                    fprintf('TIMEOUT FOR %0.3f SEC.\n',p.trial.stimulus.states.timeout.timing.duration);
                    p.trial.stimulus.states.timeout.timing.start_time = GetSecs;
                elseif(p.trial.stimulus.states.timeout.timing.start_time <= GetSecs - p.trial.stimulus.states.timeout.timing.duration)
                    fprintf('\tTimeout elapsed.\nEND TRIAL %d.\n',p.trial.pldaps.iTrial);
                    p.trial.stimulus.states.timeout.timing.start_time = NaN;
                    p.trial.flagNextTrial = true;
                end
                
            case 'feedback_delay'
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %  STATE:  feedback_delay  %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                
                %  During the entire duration of the feedback delay, monkey
                %  must fixate and have the joystick released.
                if(~p.trial.stimulus.flow_control.joystick_engaged && p.trial.stimulus.flow_control.fixating)
                    
                    %  Continue to show the fixation cue for the duration of
                    %  the delay.  Then provide feedback and end trial.
                    
                    if(isnan(p.trial.stimulus.states.feedback_delay.timing.start_time))
                        
                        fprintf('FEEDBACK DELAY FOR %0.3f SEC.\n',p.trial.stimulus.states.feedback_delay.timing.delay);
                        p.trial.stimulus.states.feedback_delay.timing.start_time = GetSecs;
                        
                        ShowFixationCue;
                        
                        %  Only show the release cue if this had been the last symbol
                        
                        if(p.trial.stimulus.flow_control.current_symbol == p.trial.stimulus.flow_control.num_symbols)
                            ShowReleaseCue;
                        end
                        
                    elseif(p.trial.stimulus.states.feedback_delay.timing.start_time <= GetSecs - p.trial.stimulus.states.feedback_delay.timing.delay)
                        
                        p.trial.stimulus.states.feedback_delay.timing.start_time = NaN;
                        
                        fprintf('\tFeedback delay complete.\n');
                        
                        switch p.trial.stimulus.trial_result
                            case 'correct'
                                
                                pds.behavior.reward.give(p,p.trial.stimulus.reward_amount);
                                pds.audio.play(p,'reward');
                                fprintf('\t%s received reward for %0.3f sec.\n',p.trial.session.subject,p.trial.stimulus.reward_amount);
                                p.trial.stimulus.timing.feedback_start_time = NaN;
                                fprintf('END TRIAL %d.\n',p.trial.pldaps.iTrial);
                                p.trial.flagNextTrial = true;
                                
                            case 'false_alarm'
                                
                                pds.audio.play(p,'incorrect');
                                fprintf('\t%s gets a timeout penalty for incorrect response.\n',p.trial.session.subject);
                                p.trial.stimulus.flow_control.trial_state = 'timeout';
                                
                        end
                        
                    else
                        
                        %  Still in feedback delay.  Show fixation cue.
                        
                        ShowFixationCue;
                        
                        %  If this has been the last symbol in the list we also
                        %  need to show the release cue.
                        
                        if(p.trial.stimulus.flow_control.current_symbol == p.trial.stimulus.flow_control.num_symbols)
                            ShowReleaseCue;
                        end
                        
                    end
                    
                else
                    
                    %  Monkey either re-engaged joystick or broke fixation,
                    %  both of which cost him the reward and will get him a
                    %  broke fixation tone with timeout.
                    if(~p.trial.stimulus.flow_control.fixating)
                        fprintf('\t%s broke fixation during response delay.  Go to timeout.\n',p.trial.session.subject);
                    else
                        fprintf('\t%s re-engaged joystick during resposne delay.  Go to timeout.\n',p.trial.session.subject);
                    end
                    pds.audio.play(p,'breakfix');
                    p.trial.stimulus.states.timeout.duration = 0.5;
                    p.trial.stimulus.flow_control.trial_state = 'timeout';
                end
                
        end
end


    function ShowFixationCue
        %  ShowFixationCue
        %
        %  This function draws a fixation sqaure but only if we are using
        %  eye position.
        if(p.trial.control_flags.use_eyepos)
            win = p.trial.display.overlayptr;
            
            width = p.trial.stimulus.features.fixation.width;
            baseRect = [0 0 width width];
            centeredRect = CenterRectOnPointd(baseRect, p.trial.display.ctr(1), p.trial.display.ctr(2));
            color = p.trial.stimulus.features.fixation.color;
            linewidth = p.trial.stimulus.features.fixation.linewidth;
            
            Screen('FrameRect',win,color,centeredRect,linewidth);
        end
    end

    function ShowEngageCue
        %  ShowEngageCue
        %
        %  This function draws a cue to engage the joystick.
        
        win = p.trial.display.overlayptr;
        
        width = p.trial.stimulus.states.engage.features.width;
        baseRect = [0 0 width width];
        centeredRect = CenterRectOnPointd(baseRect, p.trial.display.ctr(1), p.trial.display.ctr(2));
        color = p.trial.stimulus.states.engage.features.color;
        linewidth = p.trial.stimulus.states.engage.features.linewidth;
        
        Screen('FrameRect',win,color,centeredRect,linewidth);
    end

    function ShowSymbol
        %  Show Symbol
        %
        %  This function will draw the requested symbol to screen
        
        win = p.trial.display.overlayptr;

        foo = 'diamond';
        
        linewidth = 16;
        
        width = 140;
        outerRect = [0 0 width width];
        innerRect = [linewidth/2 linewidth/2 width-linewidth/2 width-linewidth/2];
        outerRect = CenterRectOnPointd(outerRect, p.trial.display.ctr(1), p.trial.display.ctr(2));
        innerRect = CenterRectOnPointd(innerRect, p.trial.display.ctr(1), p.trial.display.ctr(2));
        
        outerPoly = [0 width/2 ; width/2 0 ; width width/2 ; width/2 width];
        innerPoly = [linewidth/2 width/2 ; width/2 linewidth/2 ; width-linewidth/2 width/2 ; width/2 (width-linewidth)/2];
        
        outerPoly = [outerPoly(:,1) + p.trial.display.ctr(1)-width/2 outerPoly(:,2) + p.trial.display.ctr(2)-width/2];
        innerPoly = [innerPoly(:,1) + p.trial.display.ctr(1)-width/2 innerPoly(:,2) + p.trial.display.ctr(2)-width/2];
        
        color = p.trial.display.clut.P;
        
        
        
        switch foo
            case 'circle'                
                Screen('FillOval',win,color,outerRect);
                Screen('FillOval',win,p.trial.display.clut.bg,innerRect);
            case 'square'
                Screen('FillRect',win,color,outerRect);
                Screen('FillRect',win,p.trial.display.clut.bg,innerRect);
            case 'diamond'
                Screen('FillPoly',win,color,outerPoly,1);
                Screen('FillPoly',win,p.trial.display.clut.bg,innerPoly,1);
            case 'up_triangle'
            case 'down_triangle'
            case 'cross'
            case 'X'
        end
                
    end

    function ShowReleaseCue
        %  ShowReleaseCue
        %
        %  This function should draw a black rectangle as the cue that the
        %  joystick is released.
        %
        %  I want a square drawn as a cue indicating release of joystick.
        %  It will be black and centered in the middle of the screen, where
        %  there is not currently a fixation point but at some point in the
        %  future there will be.  I don't need it smoothed.
        
        
        if(p.trial.stimulus.flow_control.current_symbol == p.trial.stimulus.flow_control.num_symbols)
            width = p.trial.stimulus.states.release.features.width;
            baseRect = [0 0 width width];
            centeredRect = CenterRectOnPointd(baseRect, p.trial.display.ctr(1), p.trial.display.ctr(2));
            Screen('FrameRect',p.trial.display.overlayptr,p.trial.stimulus.states.release.features.color,centeredRect,p.trial.stimulus.states.release.features.linewidth);
        end
    end
end