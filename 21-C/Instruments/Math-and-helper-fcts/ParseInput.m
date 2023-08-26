function [out] = ParseInput(s)
             
                         % parsing standard input as 3.3, 0.3, 5p, 0.5p, -0.5e-3 mu, 0.5e3, ...
                         a = regexp(s, '^\s*([-+]?)(\d+|\d*\.\d+|\d+\.\d*)([eE][+-]?\d+)?\s*(p|n|mu|u|m|k|M|G)?$',  'tokens');

                         % example
                         % a = regexp(' -5.e+2  mu', '^\s*([-+]?)(\d+|\d*\.\d+|\d+\.\d*)([eE][+-]?\d+)?\s*(p|n|mu|u|m|k|M|G)?$',  'tokens'); 
                         % a{:} =  '-'    '5.'    'e+2'    'mu'
                                
             if ~isempty(a)
                 
                                 temp = eval([a{1}{1}, a{1}{2}, a{1}{3}]);

                 switch a{1}{4}
                     case 'p'
                         temp = temp*1e-12;
                     case 'n'
                         temp = temp*1e-9;
                     case 'u'
                         temp = temp*1e-6;
                     case 'mu'
                         temp = temp*1e-6;
                     case 'm'
                         temp = temp*1e-3;
                     case 'k'
                         temp = temp*1e+3;
                     case 'M'
                         temp = temp*1e+6;
                     case 'G'
                         temp = temp*1e+9;
                end
                        else                                        
                                        uiwait(warndlg({'Format not recognized.Aborted.'}));
                                        out = NaN;
                                        return;
             end
                        out = temp;
