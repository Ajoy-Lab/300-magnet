%modelTwoGaussian(coeffs, x) function
%------------
%model Gaussian function, describes a family of (non-normalized) distributions with two Gaussian peaks:
%f(x) = K1*exp(-(x-mu1)^2/(2*sigma1^2)) + K2*exp(-(x-mu2)^2/(2*sigma2^2)) 
%coeffs = [mu1 sigma1 K1 mu2 sigma2 K2]
%
%used for nonlinear regression to curve-fit data


function y = modelTwoGaussian(coeffs, x)

mu1 = coeffs(1);
sigma1 = coeffs(2);
K1 = coeffs(3);

mu2 = coeffs(4);
sigma2 = coeffs(5);
K2 = coeffs(6);

y = K1*exp(-(x-mu1).*(x-mu1)/(2*sigma1^2)) + K2*exp(-(x-mu2).*(x-mu2)/(2*sigma2^2));

end
