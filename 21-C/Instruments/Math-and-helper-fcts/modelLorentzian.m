        %modelLorentzian(coeffs, x) function
        %------------
        %model Lorentzian function, describes a family of (non-normalized) Lorentzian:
        %f(x) = K/(1+((x-x_0)/gamma)^2)
        %coeffs = [x0 gamma K]
        %
        %used for nonlinear regression to curve-fit data


        function y = modelLorentzian(coeffs, x)

        x0 = coeffs(1);
        gamma = coeffs(2);
        K = coeffs(3);


        y = K./(1+((x-x0)/gamma).^2);

        end
