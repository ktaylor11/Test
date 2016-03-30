function checkTime = tea_timer(duration,titleStr)
%% TEA_TIMER Timer for brewing tea
% 
% DESCRIPTION
%   This function is a timer for brewing tea. It pops up a flashing message box
%   and plays an intermittent tone for 5 seconds.
% 
% USAGE
% 	checkTime = tea_timer(duration,titleStr)
% 
% INPUTS (Default values given within <> symbols)
% 	duration (scalar): Duration to wait before display popup message
%	titleStr (string): Optional string to display in the message box
% 
% OUTPUTS
% 	checkTime (anonymous function): Function that allows you to check how much
%		time is left in the timer. Call it like this: checkTime()

% Author(s): Robert M. Patterson (03/17/2015)

% COPYRIGHT NOTICE
% 	© 2015 The Johns Hopkins University / Applied Physics Laboratory
% 	All Rights Reserved.
%********1*********2*********3*********4*********5*********6*********7*********8

% Check inputs
if nargin<1 || isempty(duration)
	duration = 4*60*60;
end;
if nargin<2 || isempty(titleStr)
	titleStr = '';
end;

tHandle = timer('StartDelay',duration,'TasksToExecute',1,'ExecutionMode','singleShot','TimerFcn',@(x,y) flash_figure,'StopFcn',@(x,y) kill_timer);
tStart = clock;
start(tHandle);
tic;	% In case user wants to use 'toc'
checkTime = @check_time;

% Make sound
fs = 8000;
F = 440*2;
t = [.1,.9];
s1 = sin(2*pi*F*(0:round(fs*t(1)-1)).'/fs);
n = zeros(round(t(2)*fs),1);
t = 1;
s2 = sin(2*pi*F*(0:round(fs*t-1)).'/fs);
x = [repmat([s1;n],[4,1]); s2];

	function flash_figure
		h = msgbox('Brewing is finished. Enjoy your tea!',titleStr);
		flash_obj(h,.5,5);
		soundsc(x);
	end

	function kill_timer
		delete(tHandle);
	end

	function check_time
		tNow = clock;
		timeSpent = etime(tNow,tStart);
		fprintf('Time left until tea enjoyment: %s\n',time2str(duration-timeSpent));
	end
end
