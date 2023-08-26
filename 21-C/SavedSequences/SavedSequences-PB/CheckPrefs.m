function CheckPrefs()
% this function checks the preferences that are used, e.g. it defines the folders where to save the images
% see if prefs of type 'nv' are set
NV = getpref('nv');

if isempty(NV),
    
    a = uigetdir([],'Choose Default Initialization Directory');
    setpref('nv','SavedInitializationDirectory',a);
   
    b = uigetdir([],'Choose Default Saved Image Directory');
    setpref('nv','SavedImageDirectory',b);
    
    c = uigetdir([],'Choose Default Saved Experiment Directory');
    setpref('nv','SavedExpDirectory',c);
    
    d = uigetdir([],'Choose Default Saved Sequences Directory');
    setpref('nv','SavedSequenceDirectory',d);
    
end

