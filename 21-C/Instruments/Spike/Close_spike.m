function  Close_spike()
LibraryName = 'sa_api';
handle = uint32(0);
[close] = calllib(LibraryName, 'saCloseDevice', handle);

end