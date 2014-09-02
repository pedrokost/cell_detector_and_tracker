function [X_k, Kalman_Params] = KalmanFilter(X, Z, Kalman_Params, action_flag)
% Simple implementation of a Kalman filter 
% Usage:
% ======
%   [X_k, KALMAN_PARAMS] = KALMANFILTER(X, Z, KALMAN_PARAMS, ACTION_FLAG)
%   X_k and X - state vector
%   Z - measurement vector
%   KALMAN_PARAMS - structure with Kalman Filter parameters
%       process_noise_var2 (Q)
%       measurement_noise_var2 (R) 
%       estimate_error_var2 (P)
%       kalman_gain (K)
%       velocity (constant - u = [ux uy uz])
%       deta_T (usually 1)
%   ACTION_FLAG - defines user request
%       'initialize' - to initialize Kalman_Params
%       'predict'   - to perform the Kalman prediction step
%       'update'    - to perform the Kalman update/correction step
%
%  Assumptions:
%  ============
%  1. prediction equation
%  x' = A * x + B * u + w
%  where, x' = a-priori state estimate (prediction)
%  We assume, A = [I3 delta_T*I3; 0*I3 I3], B = 0, w ~ N(0, Q)
%  where, I3 is a 3x3 identity matrix
%  
%  2. measurement equation
%  z' = H * x' + v
%  where, z' = measurement 
%  We assume, H = 1 
%  We assume, v ~ N(0, R)
%
%  Author  - Kedar Patwardhan
%  Date    - 10/07/2008
%
%  @TODO:
%   generalize filter implementation for user-specified values of B, H
%==========================================================================

if(nargin ~= 4),
    error('Insufficient input arguments. Please see documentation for help.');
end
if(nargout ~= 2),
    error('Insufficient output arguments. Please see documentation for help.');
end

initialization_step = false;
prediction_step = false;
update_step = false;

switch action_flag,
    case 'initialize',  initialization_step = true;
    case 'predict',     prediction_step = true;
    case 'update',      update_step = true;
    otherwise,  error('Invalid action-flag.');
end


X_k = X;
Z_k = X;
A = Kalman_Params.A; 
H = 1;
B = 0;

% initialization step
if(initialization_step),
    disp('...KalmanFilter: initialization step...');
    Q = Kalman_Params.process_noise_var2;
    R = Kalman_Params.measurement_noise_var2;
    P = Kalman_Params.estimate_error_var2;
    K = P*H / (H*P*H' + R);
    for tune_itrs = 1:10,
        P = A*P*A' + Q;
        K = P*H' / (H*P*H' + R);
        % @TODO - check for invalid values
    end
    Kalman_Params.estimate_error_var2 = P;
    Kalman_Params.kalman_gain = K;
    
% prediction step
elseif(prediction_step),
   disp('...KalmanFilter: prediction step...');
    X_k = A*X;
    Q = Kalman_Params.process_noise_var2;
    P = Kalman_Params.estimate_error_var2;
    Kalman_Params.estimate_error_var2 = A*P*A' + Q;    
% update step
elseif(update_step),
   disp('...KalmanFilter: update step...');
    R = Kalman_Params.measurement_noise_var2;
    P = Kalman_Params.estimate_error_var2;
    K = P*H' / (H*P*H' + R);
    Kalman_Params.kalman_gain = K;
    X_k = X + Kalman_Params.kalman_gain*(Z - H*X);
    Kalman_Params.estimate_error_var2 = (diag(ones(size(X))) - K*H)*P;
end
        