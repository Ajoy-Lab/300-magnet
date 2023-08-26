 function guess = goodGuess(x, y, curveType)
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
                    guess = [median(x), 1, median(y)];
                case 2
                    guess = [median(x), 1];
                case 3
                    guess = [median(x), 1, median(y)];
                case 4
                    guess = [median(x), 1];
                case 5
                    guess = [1 1];
                case 6
                    guess = [1 1 0 1];
                case 7
                    guess = [median(x), 1, median(y), median(x), 1, median(y)];
                case 8
                    guess = [median(x), 1, median(y), median(x), 1, median(y)];
                otherwise
                    disp('Not valid curveType');
                    
            end
            
            
        end