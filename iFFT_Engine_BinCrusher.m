%hold off;
clear;

%% Set Bincrusher parameters
% Bins to crush, Center +/- Width
binCrush = 6;           % Center bin
crushWidth = 4;         % Crush width (must be less than binCrush - 2)
negFreqOffset = 20;     % Center bin offset on negative frequency side

%% Setup FFT parameters
% Size of frame
frameSize = 512;

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

% Create FFTSliceArray
FFTSliceArray = BuildFFTSliceArray(inputSig, window, stepSize);

%% Manipulate data

% BinCrusher
for i = 1:numSlices
    for j = 0:crushWidth
        FFTSliceArray(i, binCrush + j) = 0;
        FFTSliceArray(i, binCrush - j) = 0;
        negCrushBin = length(FFTSliceArray) - binCrush + 2 + negFreqOffset;
        FFTSliceArray(i, (negCrushBin - j)) = 0;
        FFTSliceArray(i, (negCrushBin + j)) = 0;
    end
end 

% iFFT overlap add
makeOutputReal = true;
outputSig = iFFTOverlapAdd(FFTSliceArray, makeOutputReal);

sound(outputSig,Fs);