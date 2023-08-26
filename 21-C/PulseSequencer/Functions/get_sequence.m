function [result_vars, result_pb_cmds, result_shaped_pulses] = get_sequence(sequence_filename)
% function reads in variables and code from sequence file

r = parsexml(sequence_filename);

result_pb_cmds = {};
result_vars = {};
result_shaped_pulses = {};

% get the position of the variables and the sequence tags
for k = 1:length(r.Children)
    if strcmp(lower(r.Children(k).Name), 'variables')
        pos_var = k;
    end
    if strcmp(lower(r.Children(k).Name), 'instructions')
        pos_pb = k;
    end
    if strcmp(lower(r.Children(k).Name), 'shaped_pulses')
        pos_shaped_pulses = k;
    end
end

% parse through the variables of the sequence
all_vars = r.Children(pos_var).Children(1).Data;
for k = 1:length(all_vars)
    
    parsed_var = strread(all_vars{k}, '%s', 'delimiter', sprintf('='));
    
    result_vars{end+1}.name = strtrim(parsed_var{1});
    
    m = regexp(parsed_var{2}, '(.+)\((.+)\)', 'tokens');
    
    if isempty(m)
        display(['Sequence parsing error in variables at codeline: ' all_vars{k}]);
        display('Stopping parser ...');
        break;
    end
    
    result_vars{end}.variable_type = m{1}{1};
    hlp = strread(m{1}{2}, '%s', 'delimiter', sprintf(','));
    
    result_vars{end}.default_value = str2num(hlp{1});
    
    if strcmp(result_vars{end}.variable_type,'float') || strcmp(result_vars{end}.variable_type,'AWGparam') ||strcmp(result_vars{end}.variable_type,'ProtectedPar') 
        result_vars{end}.lower_limit = str2num(hlp{2});
        result_vars{end}.upper_limit = str2num(hlp{3});
    end
    
end

% parse through the commands of the sequence
all_pb_cmds = r.Children(pos_pb).Children(1).Data;
for k = 1:length(all_pb_cmds)
    result_pb_cmds{end+1}.command = all_pb_cmds{k};
end

% parse through the shaped pulses to be loaded
all_shaped_pulses = r.Children(pos_shaped_pulses).Children(1).Data;
for k = 1:length(all_shaped_pulses)
    result_shaped_pulses{end+1}.command = all_shaped_pulses{k};
end
