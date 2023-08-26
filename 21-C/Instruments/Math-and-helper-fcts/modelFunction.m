   
        function y = modelFunction(coeffs, x, curveType)
            
            %curveType:
            %1 - Gaussian
            %2 - normalized Gaussian
            %3 - Lorentzian
            %4 - normalized Lorentzian
            %5 - exponential
            %6 - decaying sine
            %7 - two Gaussian peaks
            %8 - two Lorentzian peaks
            
            switch curveType
                case 1
                    y = modelGaussian(coeffs, x);
                case 2
                    y = modelNormGaussian(coeffs, x);
                case 3
                    y = modelLorentzian(coeffs, x);
                case 4
                    y = modelNormLorentzian(coeffs, x);
                case 5
                    y = modelExponential(coeffs, x);
                case 6
                    y = modelDecayingSine(coeffs, x);
                case 7
                    y = modelTwoGaussian(coeffs, x);
                case 8
                    y = modelTwoLorentzian(coeffs, x);
                otherwise
                    disp('Not valid curveType');
                    
            end
            
            
        end