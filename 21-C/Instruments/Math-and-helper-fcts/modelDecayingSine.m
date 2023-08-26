  
        %modelDecayingSine(coeffs, x) function
        %------------
        %model decaying sine function, describes a family of decaying sine functions
        %f(x) = K*exp(-alpha*x)*sin(beta*x + phi)
        %coeffs = [alpha beta phi K]
        %
        %used for nonlinear regression to curve-fit data
        
        
        function y = modelDecayingSine(coeffs, x)
            
            alpha = coeffs(1);
            beta = coeffs(2);
            phi = coeffs(3);
            K = coeffs(4);
            
            y = K*exp(-alpha*x).*sin(beta*x + phi);
            
        end