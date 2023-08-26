
        
        %modelNormGaussian(coeffs, x) function
        %------------
        %model normalized Gaussian function, describes a family of normalized Gaussians:
        %f(x) = (1/(sqrt(2*pi*sigma^2))*exp(-(x-mu)^2/(2*sigma^2))
        %coeffs = [mu sigma]
        %
        %used for nonlinear regression to curve-fit data
        
        
        function y = modelNormGaussian(coeffs, x)
            
            mu = coeffs(1);
            sigma = coeffs(2);
            
            y = (1/sqrt(2*pi*sigma^2))*exp(-(x-mu).*(x-mu)/(2*sigma^2));
            
        end