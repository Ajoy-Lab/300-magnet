        
        function coeffs = curvefit(x, y, curveType)
            
            %curveType:
            %1 - Gaussian
            %2 - normalized Gaussian
            %3 - Lorentzian
            %4 - normalized Lorentzian
            %5 - exponential
            %6 - decaying sine
            
            switch curveType
                case 1
                    coeffs = nlinfit(x,y, @modelGaussian, [median(x), 1, median(y)]);
                case 2
                    coeffs = nlinfit(x,y, @modelNormGaussian, [median(x), 1]);
                case 3
                    coeffs = nlinfit(x, y, @modelLorentzian, [median(x), 1, median(y)]);
                case 4
                    coeffs = nlinfit(x, y, @modelNormLorentzian, [median(x), 1]);
                case 5
                    coeffs = nlinfit(x, y, @modelExponential, [1 1]);
                case 6
                    coeffs = nlinfit(x, y, @modelDecayingSine, [1 1 0 1]);
                case 7
                    coeffs = nlinfit(x, y, @modelTwoGaussian, [median(x), 1, median(y), median(x), 1, median(y)]);
                case 8
                    coeffs = nlinfit(x, y, @modelTwoLorentzian, [median(x), 1, median(y), median(x), 1, median(y)]);
                otherwise
                    disp('Not valid curveType');
                    
            end
            
        end