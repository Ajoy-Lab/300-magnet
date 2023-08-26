function [result_seq, result_var_values, result_var_bools, result_var_coerced] = make_pulse_sequence(handles)

code = handles.Sequence_code;
vars = handles.Seq_vars;
data_floats = handles.Data_float;
data_bools = handles.Data_bool;

result_var_values = {};
result_var_bools = {};
result_var_coerced.value = false;
result_var_coerced.name = '';

% define variables
for k = 1:length(vars)
    
    var_found = false;
    for hlp = 1:size(data_floats,1)
        % check name
        if strcmp(vars{k}.name, data_floats{hlp,1})
            
            if (data_floats{hlp,2}<=vars{k}.upper_limit) && (data_floats{hlp,2}>=vars{k}.lower_limit)
                % set variables as given by user
                eval([vars{k}.name ' = ' num2str(data_floats{hlp,2}) ';']);
            else
                result_var_coerced.value = true;
                result_var_coerced.name = vars{k}.name;
                %Set Scan is not accepted (ie Start button is not enabled)
                eval([vars{k}.name ' = ' num2str(max(min(data_floats{hlp,2}, vars{k}.upper_limit), vars{k}.lower_limit)) ';']);
            end
            var_found = true;
            
            % save name and actual value
            result_var_values{end+1}.name = vars{k}.name; % save name
            eval(['result_var_values{end}.value = ' vars{k}.name ';']); % save value of that variable
            
        end
    end
    for hlp = 1:size(data_bools,1)
        % check name
        if strcmp(vars{k}.name, data_bools{hlp,2})
            % set variables as given by user
            eval([vars{k}.name ' = ' num2str(data_bools{hlp,1}) ';']);
            var_found = true;
            
            %save name and actual value
            result_var_bools{end+1}.name = vars{k}.name; %save name
            eval(['result_var_bools{end}.value = ' vars{k}.name ';']); % save value of that variable
            
        end
    end
    
    if var_found == false
        eval([vars{k}.name ' = ' num2str(vars{k}.default_value) ';']);
        warndlg(['Warning: User variable not found. Setting ' vars{k}.name ' to default value.']);
    end
    
end

% loop over scanning interval and produce sequences
complete_code_str = [];
for k = 1:length(code)
    complete_code_str = sprintf('%s\n%s', complete_code_str, code{k}.command);
end

PSeq = initialize_pulse_sequence(handles);

% user code
eval(complete_code_str);

% resulting sequence
result_seq = PSeq;
