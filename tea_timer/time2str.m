function timeStr = time2str(val,timeSep,useFracSec,nFracSecDigits,useDay,ignoreWarning)
%% TIME2STR Convert time (in seconds) to 'hh:mm:ss[.sss...]' string
% 
% DESCRIPTION
%   This function converts time (in seconds) to 'hh:mm:ss[.sss...]' string
% 
% USAGE
% 	timeStr = time2str(val,timeSep,useFracSec,nFracSecDigits,useDay,ignoreWarning)
% 
% INPUTS (Default values given within <> symbols)
% 	val (array): Number of seconds that needs to be converted
% 	timeSep (char): Character to use as the time separator <':'>
% 	useFracSec (boolean): Flag indicating if partial seconds (.sss) are to be 
%		used <false>
%	nFracSecDigits (scalar): Number of fractional second digits to use <2>
%	useDay (boolean): Flag indicating if day number starting at day 0
%		should be prepended to the time string.  For instance, 1'15:32:10.
%	ignoreWarning (boolean): Flag indicating if warnings for negative times
%		are to be ignored. <true>
% 
% OUTPUTS
% 	timeStr (string): If the number of elements in 'val' is one, then the
%		output is a string containing the time in the specified format.
%			(cell): The output is a cell array if the input is not a single
%		element.

% Author(s): Robert M. Patterson
% $Revision: 1.0 $  $Date: 2010/06/01 12:38:49 $

% COPYRIGHT NOTICE
% 	© 2010 The Johns Hopkins University / Applied Physics Laboratory
% 	All Rights Reserved.
%********1*********2*********3*********4*********5*********6*********7*********8

% Check inputs
if nargin<1
	error('The times (in seconds) to convert to a time string must be passed in as the first parameter');
end;
if nargin<2 || isempty(timeSep)
	timeSep = ':';
end;
if nargin<3 || isempty(useFracSec)
	useFracSec = false;
end;
if nargin<4 || isempty(nFracSecDigits)
	nFracSecDigits = 2;
end;
if nargin<5 || isempty(useDay)
	useDay = false;
end;
if nargin<6 || isempty(ignoreWarning)
	ignoreWarning = true;
end;
if ~ischar(timeSep)
	error('Syntax for ''time2str'' has been changed.  Please see the help for this function.');
end;

% Look for negative times
if any(val(:)<0) && ~ignoreWarning
	% Display warning for a negative time.  Note: The function datestr converts
	% negative numbers to 0.
	warning('MATLAB:time2str:negativeTime','A negative time was entered. This time will be converted to 0.');
end;

% Specify the format
fmt = 'HH:MM:SS';

% Perform the time to string conversion
if ~useFracSec
	secondsInDay = 24*60*60;
	val = val./secondsInDay;
	timeStr = arrayfun(@(x) datestr2(x,fmt),val,'UniformOutput',false);
else
	[timeStr,val] = arrayfun(@(x) custom_time(x,fmt,nFracSecDigits),val,'UniformOutput',false);
	val = cell2mat(val);
end;

% Append day onto front of string?
if useDay
	daySep = '''';
	dayNum = floor(val);
	timeStr = arrayfun(@(x) [num2str(dayNum(x)),daySep,timeStr{x}],reshape(1:numel(val),size(val)),'UniformOutput',false);
end;

% If there is only a single array element, convert the cell to a string
if numel(timeStr)==1
	timeStr = timeStr{1};
	if timeSep~=':'
		timeStr = strrep(timeStr,':',timeSep);
	end;
else
	if timeSep~=':'
		timeStr = cellfun(@(x) strrep(x,':',timeSep),timeStr,'UniformOutput',false);
	end;
end;


%% Sub-function: custom_time
% ======================================================================
function [str,x2] = custom_time(x,fmt,nFracSecDigits)

% Round to the number of fractional second digits
x = roundn(x,-nFracSecDigits);

% Convert to float date
secondsInDay = 24*60*60;
if nFracSecDigits<=0
	x2 = x./secondsInDay;
else
	x2 = floor(x)./secondsInDay;
end;

% Find the full string portion.
str = datestr2(x2,fmt);

% Compute the partial number of seconds
frac = mod(x,1);

% Convert partial seconds to a string and append
convertStr = sprintf('%%0.%df',nFracSecDigits);
fracStr = sprintf(convertStr,frac);
str = [str,fracStr(2:end)];


%% Sub-function: datestr2
% ======================================================================
function y = datestr2(x,fmt)

switch lower(fmt)
	case 'hh:mm:ss'
		% Note: Handle the most common case manually since 'datestr' (used 
		% to handle all other cases) has a high amount of overhead.
		secondsInDay = 24*60*60;
		x = round(x*secondsInDay);
		xMod = mod(x,secondsInDay);
		hr = floor(xMod/60/60);
		xMod = xMod-hr*60*60;
		min = floor(xMod/60);
		xMod = xMod-min*60;
		sec = xMod;
		y = sprintf('%02d:%02d:%02d',hr,min,sec);
	otherwise
		y = datestr(x,fmt);
end;
