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

% Set low frequency detection cutoff
lowDetectionCutoff = 60;    % Hz
fundamentalArrayBins = FundDetBins(FFTSliceArray, lowDetectionCutoff, Fs);   

% Set harmonic tilt
harmoniCrushScalar = 1.5;
harmoniCrushRatio = 1;
harmoniCrushWidth = 1;
numHarmonics = 6;

% HarmoniCrush
for i = 1:numSlices
    crushRatio = harmoniCrushScalar;
    for harmonicNum = 2:numHarmonics
        % Do for all harmonics in frequency spectrum    
        % Crush harmonic bins
        crushBin = fundamentalArrayBins(i) * harmonicNum;
        FFTSliceArray(i, crushBin) = ...
            FFTSliceArray(i, crushBin) * crushRatio;
        
        for j = 0:harmoniCrushWidth
            FFTSliceArray(i, (crushBin + j)) = ...
                FFTSliceArray(i, (crushBin + j)) * crushRatio;
            FFTSliceArray(i, (crushBin - j)) = ...
                FFTSliceArray(i, (crushBin - j)) * crushRatio;
        end
        
        % Crush negative frequency bin
        negCrushBin = frameSize - crushBin + 2;
        FFTSliceArray(i, (negCrushBin)) = ...
            FFTSliceArray(i, (negCrushBin)) * crushRatio;
        
        for j = 0:harmoniCrushWidth
            FFTSliceArray(i, (negCrushBin + j)) = FFTSliceArray(i, (negCrushBin + j)) * crushRatio;
            FFTSliceArray(i, (negCrushBin - j)) = FFTSliceArray(i, (negCrushBin - j)) * crushRatio;
        end
        
        % Update chrushRatio
        crushRatio = crushRatio * harmoniCrushRatio;
        
        % Select next harmonic
        harmonicNum = harmonicNum + 1;
        crushBin = fundamentalArrayBins(i) * harmonicNum;
    end
end 

%% Take iFFT and overlap add
makeOutputReal = true;
outputSig = iFFTOverlapAdd(FFTSliceArray, makeOutputReal);

sound(outputSig,Fs);
