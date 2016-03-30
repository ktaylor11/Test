function t = flash_obj(h,period,duration)
%% FLASH_OBJ Flash an object at a specified period for some duration
% 
% DESCRIPTION
%   This function will flash an object for a specified period for some duration.
%   The original state of the object that is flashed will be retained. Flashing
%   works by toggling the visible state of the object.
% 
% USAGE
% 	t = flash_obj(h,period,duration)
% 
% INPUTS (Default values given within <> symbols)
% 	h (scalar): Handle of object to be flashed
% 	period (scalar): Period between on-off-on states. One period include both
%		on & off states, so the flash rate will be one-half the period.
% 	duration (scalar): Approximate amount of time to perform flashing. The state
%		of the object that is flashed always returns to its original state.
% 
% OUTPUTS
% 	t (scalar): Handle to timer object.
% 
% NOTES
%	The timer object is deleted automatically when the flashed is finished.

% Author(s): Robert M. Patterson (10/01/2014)

% COPYRIGHT NOTICE
% 	© 2014 The Johns Hopkins University / Applied Physics Laboratory
% 	All Rights Reserved.
%********1*********2*********3*********4*********5*********6*********7*********8

% Check that the handle to be flashed has a visible state
if ~isprop(h,'Visible')
	error('The object to be flashed must have a visible state.');
end;

% Compute number of tasks to execute. Must always be even so that state returns
% to original state.
tasksToExecute = round(duration/period)*2;

% Construct a timer
t = timer;
set(t,'TimerFcn',@(x,y) toggle_obj,'StartDelay',0,'ExecutionMode','fixedRate','Period',period/2,'TasksToExecute',tasksToExecute,'StopFcn',@(x,y) stop_fcn);
toggleState = get(h,'Visible');
start(t);

	%% Nested function: toggle_obj
	% ======================================================================
	function toggle_obj
		switch toggleState
			case 'on'
				toggleState = 'off';
			case 'off'
				toggleState = 'on';
			otherwise
				error('Invalid toggle state.');
		end;
		set(h,'Visible',toggleState);
	end

	%% Nested function: stop_fcn
	% ======================================================================
	function stop_fcn
		delete(t);
	end

end
