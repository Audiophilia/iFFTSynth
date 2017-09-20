%hold off;
clear;

% ringModFreq = fundDetectFreq / ringModFreq - modRateDetune
modRateDivider = 2; % Divide ratio fundDetectFreq / ringModFreq
modRateDetune = 100;  % ringMod frequency detune amount
    
%% Setup FFT parameters
% Size of frame
frameSize = 2048;

% Generate Hann window
window = hann(frameSize).';

% Frame overlap amount
overlap = 0.5;

% Step size
stepSize = frameSize * overlap;

%% Read in wav file
fileName = 'trumpet.wav';
playInputSound = false;

[inputSig, Fs, numSamples, numSlices] = ...
    ReadWavPad(fileName, stepSize, playInputSound);

% Array of frequency bins for FFT plot
freqBins = Fs/frameSize * (1:(frameSize/2+1));

% Make array of input slices
for i = 1:numSlices
    inputOffset = stepSize * (i - 1);
    inputSliceArray( i, 1:frameSize) = window(1:frameSize) ...
        .* inputSig((inputOffset + 1):(inputOffset + frameSize));
end

% Compute array of FFT slices
for i = 1:numSlices
    FFTSliceArray( i, 1:frameSize) = fft(inputSliceArray(i, 1:frameSize));
end

%% Fundamental detection

% Calculate low frequency detection frequency cutoff bin
lowDetectionCutoff = 60;    % Hz

fundamentalArray = FundDet(FFTSliceArray, lowDetectionCutoff, Fs);                      

%% Time domain ring modulator
         
outputSig = RingMod(inputSig, Fs, fundamentalArray, ...
                    modRateDivider, modRateDetune);
                       
%plot(outputSig);

%Z = fft(outputSig);
%zMag = abs(Z/numSamples);
%zMagOneSided = zMag(1:numSamples/2+1);
%plot(freqBins, zMagOneSided);

sound(outputSig,Fs);
