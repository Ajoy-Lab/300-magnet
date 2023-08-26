
%modelNormLorentzian(coeffs, x) function
%------------
%model normalized Lorentzian function, describes a family of normalized Lorentzian distributions:
%f(x) = 1/(pi*gamma*(1+((x-x_0)/gamma)^2))
%coeffs = [x0 gamma]
%
%used for nonlinear regression to curve-fit data


function y = modelNormLorentzian(coeffs, x)

x0 = coeffs(1);
gamma = coeffs(2);

y = (1/(pi*gamma))./(1+((x-x0)/gamma).^2);

end