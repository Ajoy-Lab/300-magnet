function [status] = bbconfigureiq(handle, center, ref, downsample, bandwidth)
% 

    status = -1;

    if not(libisloaded('bb_api'))
        return;
    end

    status = calllib('bb_api', 'bbConfigureCenterSpan', handle, center, 1.0e3);
    if (~strcmp(status, 'bbNoError'))
        fprintf('bbConfigCenterSpan error: %s\n', bbgeterrorstring(status));
        fprintf('Device unsuccessfully configured\n');
        return
    end

    status = calllib('bb_api', 'bbConfigureLevel', handle, ref, -1);
    if (~strcmp(status, 'bbNoError'))
        fprintf('bbConfigureLevel error: %s\n', bbgeterrorstring(status));
        fprintf('Device unsuccessfully configured\n');
        return
    end

    status = calllib('bb_api', 'bbConfigureIQ', handle, downsample, bandwidth);
    if (~strcmp(status, 'bbNoError'))
        fprintf('bbConfigureIQ error: %s\n', bbgeterrorstring(status));
        fprintf('Device unsuccessfully configured\n');
        return
    end

    % Configure the device for IQ streaming
    % If status is bbNoError, the device will be actively
    %  making IQ measurements.
    % Query IQ data with bbgetiq()
    status = calllib('bb_api', 'bbInitiate', handle, 4, 0);
    if (~strcmp(status, 'bbNoError'))
        fprintf('bbConfigureLevel error: %s\n', bbgeterrorstring(status));
        fprintf('Device unsuccessfully configured\n');
        return
    end
    
end

