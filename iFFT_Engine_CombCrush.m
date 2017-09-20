%hold off;
clear;

%% Set CombCrusher parameters
% Set combWidth for binCrushing
combWidth = 3;

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

% CombCrusher
for i = 1:numSlices
    for combNum = 1:floor(frameSize / combWidth)
        crushBin = combNum * combWidth;
        FFTSliceArray(i, crushBin) = 0;
        negCrushBin = frameSize - crushBin + 2;
        FFTSliceArray(i, negCrushBin) = 0;
    end
end

% iFFT overlap add
makeOutputReal = false;
outputSig = iFFTOverlapAdd(FFTSliceArray, makeOutputReal);

sound(outputSig,Fs);