%hold off;
clear;

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
% Put your functions here



%% Take iFFT and overlap add

outputSig = iFFTOverlapAdd(FFTSliceArray);

sound(outputSig,Fs);
