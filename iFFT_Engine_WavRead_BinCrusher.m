%hold off;
clear; 

% Read in audio file
filename = 'trumpet.wav';
[inputWav,Fs] = audioread(filename);
%sound(inputWav,Fs);

% Total length of input waveform
numSamples = length(inputWav);

% Array of frequency bins for FFT plot
freqBins = Fs*(1:(numSamples/2+1))/numSamples;

% Size of frame
frameSize = 512;

% Generate Hann window
window = hann(frameSize).';

% Frame overlap amount
overlap = 0.5;

% Create waveform slices
numSlices = ceil(numSamples / (frameSize * overlap));

% Step size
stepSize = frameSize * overlap;

% Make array of input slices
for i = 1:(numSlices - 1)
    inputOffset = stepSize * (i - 1);
    x( i, 1:frameSize) = window(1:frameSize) .* inputWav((inputOffset + 1):(inputOffset + frameSize));
end

% Zero pad last slice
numZeros = frameSize - mod(numSamples, stepSize);
zeroPad = zeros(1, numZeros);
inputOffset = stepSize * (numSlices - 1);
lastSlice(1:(frameSize - numZeros)) = inputWav((inputOffset + 1):numSamples);
lastSlice((frameSize - numZeros + 1):frameSize) = zeroPad;
x( numSlices, 1:frameSize) = window(1:frameSize) .* inputWav((inputOffset + 1):(inputOffset + frameSize));

% Compute array of FFTs
for i = 1:numSlices
    X( i, 1:frameSize) = fft(x(i, 1:frameSize));
end

% Manipulate data
% Bins to chrush
binCrush = 50;
crushWidth = 40;
negfOffset = -1;

if(1)
    for i = 1:numSlices
        for j = 0:crushWidth
            X(i, binCrush + j) = 0;
            X(i, binCrush - j) = 0;
            X(i, (length(X) - binCrush + negfOffset - j)) = 0;
            X(i, (length(X) - binCrush + negfOffset + j)) = 0;
        end
    end 
end

% Take iFFT
for i = 1:(numSlices - 1)
    xx( i, 1:frameSize) = ifft(X(i, 1:frameSize));
end

if (1)
    for i = 1:(numSlices - 1)
        for j = 1:frameSize
            y(i, j) = real(xx(i, j));
        end
    end
else
    y = xx;
end


% First stepSize doesn't have an add
z(1:stepSize) = y(1, 1:stepSize);

% Overlap add
for i = 2:(numSlices - 1)
    outputIndex = stepSize * (i - 1);
    z((outputIndex + 1):(outputIndex + stepSize)) = ...
        y((i - 1), (stepSize + 1):(stepSize + stepSize)) ...
        + y(i, 1:stepSize);
end

% Last StepSize doesn't have an add
outputIndex = stepSize * numSlices;
z( (outputIndex + 1):(outputIndex + stepSize)) = ...
    y((numSlices - 1), (stepSize + 1):(stepSize + stepSize));

%plot(z);

%Z = fft(z);
%zMag = abs(Z/numSamples);
%zMagOneSided = zMag(1:numSamples/2+1);
%plot(freqBins, zMagOneSided);

sound(z,Fs);