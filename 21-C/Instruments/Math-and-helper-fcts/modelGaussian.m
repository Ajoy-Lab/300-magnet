        %modelGaussian(coeffs, x) function
        %------------
        %model Gaussian function, describes a family of (non-normalized) Gaussians:
        %f(x) = K*exp(-(x-mu)^2/(2*sigma^2))
        %coeffs = [mu sigma K]
        %
        %used for nonlinear regression to curve-fit data


        function y = modelGaussian(coeffs, x)

        mu = coeffs(1);
        sigma = coeffs(2);
        K = coeffs(3);

        y = K*exp(-(x-mu).*(x-mu)/(2*sigma^2));

        end