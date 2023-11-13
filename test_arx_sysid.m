% Test ARX model identification - Example from documentation
% This code is based on the example at
% https://www.mathworks.com/help/ident/ref/arx.html

clear all
rng(0)

% Specify a polynomial model sys0 with the ARX structure.
A = [1  -1.5  0.7];
B = [0 1 0.5];
sys0 = idpoly(A,B);

% Generate a measured input signal u that contains random 
% binary noise and an error signal e
N = 300;
u = iddata([],idinput(N,'rbs'));
u.InputName = 'u';
e = iddata([],randn(N,1));
e.InputName = 'e';
y = sim(sys0,[u e]);
y.OutputName = 'y';

% Combine y and u into a single iddata object z.
z = [y,u];

t = z.Ts.*(z.Tstart:N)';

% Save data
data_est = table( ...
    t, u.InputData, e.InputData, y.OutputData, ...
    'VariableNames', {'t', 'u', 'e', 'y'} ...
);
writetable(data_est, "test_arx_sysid_data.csv")

% Estimate a new ARX model using z and the same 
% polynomial orders and input delay as the 
% original model.
sys = arx(z,[2 2 1]);

% Display results
present(sys)
disp("getpvec(sys):")
fprintf("[%s]\n", strjoin(compose("%.6f ", getpvec(sys))))

assert(isequal( ...
    round(getpvec(sys), 6), ...
    [-1.523848  0.713374  0.999994  0.474829 ]' ...
))

% Simulate model to produce a prediction
e0 = iddata([],zeros(N, 1));
y_pred = sim(sys,[u e0]);
y_pred.OutputName = 'y_pred';

% Calculate root-mean-squared error
rmse = sqrt(mean((y.OutputData - y_pred.OutputData).^2));
fprintf("Root-mean-squared-error: %.3f\n", rmse)

figure(1); clf
subplot(211)
plot(u)
legend()

subplot(212)
plot(y); hold on
plot(y_pred)
grid on
legend()

% OUTPUT:
%
% sys =                                                                         
% Discrete-time ARX model: A(z)y(t) = B(z)u(t) + e(t)                           
%   A(z) = 1 - 1.524 (+/- 0.02767) z^-1 + 0.7134 (+/- 0.02717) z^-2             
%                                                                               
%   B(z) = 1 (+/- 0.05831) z^-1 + 0.4748 (+/- 0.06362) z^-2                     
%                                                                               
% Sample time: 1 seconds                                                        
%                                                                               
% Parameterization:                                                             
%    Polynomial orders:   na=2   nb=2   nk=1                                    
%    Number of free coefficients: 4                                             
%    Use "polydata", "getpvec", "getcov" for parameters and their uncertainties.
%                                                                               
% Status:                                                                       
% Estimated using ARX on time domain data "z".                                  
% Fit to estimation data: 81.36% (prediction focus)                             
% FPE: 1.025, MSE: 0.9846                                                       
% More information in model's "Report" property.                                
% getpvec(sys):
% [-1.523848  0.713374  0.999994  0.474829 ]   
