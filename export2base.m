%------------ export2base.m -------------------
function export2base(varargin)
%export2base: Export variables to base workspace.
 
% Douglas M. Schwarz
 
% Get names of variables in caller's workspace
w = evalin('caller','who');
 
% Remove 'ans' if it is present.
w = setdiff(w,'ans');
 
% Keep only variables listed in input arguments that actually exist in
% caller's workspace.
if ~isempty(varargin)
    w = intersect(w,varargin);
end
 
% Loop through variables and put them in base workspace.
for i = 1:length(w)
    assignin('base',w{i},evalin('caller',w{i}))
end
