%modelExponential(coeffs, x) function
        %------------
        %model exponential function, describes a family of decaying exponentials:
        %f(x) = K*exp(-alpha*x)
        %coeffs = [alpha K]
        %
        %used for nonlinear regression to curve-fit data
        
        
        function y = modelExponential(coeffs, x)
            
            alpha = coeffs(1);
            K = coeffs(2);
            
            y = K*exp(-alpha*x);
            
            
        end
        