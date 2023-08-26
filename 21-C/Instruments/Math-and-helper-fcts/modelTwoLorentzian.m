%modelTwoLorentzian(coeffs, x) function
%------------
%model Lorentzian function, describes a family of (non-normalized) distributions with two Lorentzian peaks:
%f(x) = K1/(1+((x-x1)/gamma1)^2) + K2/(1+((x-x2)/gamma2)^2)
%coeffs = [x2 gamma2 K2]
%
%used for nonlinear regression to curve-fit data


function y = modelTwoLorentzian(coeffs, x)

x1 = coeffs(1);
gamma1 = coeffs(2);
K1 = coeffs(3);
x2 = coeffs(4);
gamma2 = coeffs(5);
K2 = coeffs(6);

y = K1./(1+((x-x1)/gamma1).^2) + K2./(1+((x-x1)/gamma1).^2);

end

