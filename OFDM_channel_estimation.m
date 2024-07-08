% clear;

%% OFDM parameters
numSubcarriers = 64;      % Number of subcarriers
cpLen = 16;               % Cyclic prefix length
numSymbols = 10;          % Number of OFDM symbols

%% Generate random QPSK data symbols
data = randi([0 3], numSubcarriers, numSymbols);
txSymbols = pskmod(data, 4, pi/4); % QPSK modulation

%% OFDM modulation
txOFDM = ifft(txSymbols); % IFFT to create OFDM symbols
txOFDM = [txOFDM(end-cpLen+1:end, :); txOFDM]; % Add cyclic prefix

% Reshape to a single stream
txSignal = txOFDM(:);

%% Load channel coefficients
% Use a single snapshot from h_initial and reshape it to match subcarriers
h = h_initial(:);  % Convert to a column vector

%% Apply the channel (assuming flat fading for simplicity)
rxSignal = conv(txSignal, h);
rxSignal = rxSignal(1:length(txSignal)); % Truncate to the original signal length

%% Add noise
snr = 20; % Signal-to-noise ratio in dB
rxSignal = awgn(rxSignal, snr, 'measured');

%% Reshape received signal back to OFDM symbols
rxOFDM = reshape(rxSignal, numSubcarriers + cpLen, numSymbols);

%% Remove cyclic prefix
rxOFDM = rxOFDM(cpLen+1:end, :);

%% OFDM demodulation
rxSymbols = fft(rxOFDM);

%% Channel estimation (MMSE)
% Channel estimation with MMSE requires the channel covariance matrix and noise variance
% For simplicity, we assume ideal conditions for covariance matrix
H_est_LS = rxSymbols ./ txSymbols;  % LS estimate

% Assume identity matrix for channel covariance matrix (for simplicity)
% In practice, you should use the actual channel covariance matrix
R_h = eye(numSubcarriers);

% Noise variance calculation
noiseVar = var(rxSignal - conv(txSignal, h, 'same'));

% MMSE estimation
H_est_MMSE = zeros(size(H_est_LS));
for k = 1:numSymbols
    X = diag(txSymbols(:, k));  % Diagonal matrix of transmitted symbols for the k-th symbol
    H_est_MMSE(:, k) = R_h * (R_h + noiseVar * inv(X' * X)) \ H_est_LS(:, k);
end

%% Plot the estimated channel
figure;
plot(real(H_est_LS(:)), imag(H_est_LS(:)), 'o', 'DisplayName', 'LS Estimation');
hold on;
plot(real(H_est_MMSE(:)), imag(H_est_MMSE(:)), 'x', 'DisplayName', 'MMSE Estimation');
title('Estimated Channel Coefficients');
xlabel('Re');
ylabel('Im');
legend('show');
grid on;
hold off;
