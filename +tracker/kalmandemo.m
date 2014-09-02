x = 1;
len = 100;
z = x + 0.1 * randn(1, len);

stateTransitionModel = 1;
measurementModel = 1;
obj = vision.KalmanFilter(stateTransitionModel,measurementModel,'StateCovariance', 1,'ProcessNoise', 1e-5,'MeasurementNoise', 1e-2);

z_corr = zeros(1, len);
for idx = 1: len
  predict(obj);
  z_corr(idx) = correct(obj, z(idx));
end

figure(1), plot(x * ones(1, len), 'g-'); hold on;
plot(1:len, z, 'b+', 1:len, z_corr, 'r-');
legend('Original signal', 'Noisy signal', 'Filtered signal');

for idx = 1:20
  predict(obj);
  z_corr(idx) = correct(obj, z(idx));
end