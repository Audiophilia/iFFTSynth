%hold off;

Fs = 48000;
f = 1000;

% Total length of input waveform
numSamples = 4096;

% Array of frequency bins for FFT plot
freqBins = Fs*(1:(numSamples/2+1))/numSamples;

% Size of frame
frameSize = 512;

% Generate Hann window
window = hann(frameSize).';

% Frame overlap amount
overlap = 0.5;

% Generate sin wave
%inputSin = sin(2*pi*f/Fs*[1:numSamples])+0.5*sin(4*pi*f/Fs*[1:numSamples]);
inputSin = sin(2*pi*f/Fs*[1:numSamples]);

% Create waveform slices
numSlices = numSamples / (frameSize * overlap) - 1;

% Step size
stepSize = frameSize * overlap;

% Make array of input slices
for i = 1:numSlices
    inputOffset = stepSize * (i - 1);
    x( i, 1:frameSize) = window(1:frameSize) .* inputSin((inputOffset + 1):(inputOffset + frameSize));
end

% Compute array of FFTs
for i = 1:numSlices
    X( i, 1:frameSize) = fft(x(i, 1:frameSize));
end

% Take iFFT
for i = 1:numSlices
    y( i, 1:frameSize) = ifft(X(i, 1:frameSize));
end

% First stepSize doesn't have an add
z(1:stepSize) = y(1, 1:stepSize);

% Overlap add
for i = 2:numSlices
    outputIndex = stepSize * (i - 1);
    z((outputIndex + 1):(outputIndex + stepSize)) = ...
        y((i - 1), (stepSize + 1):(stepSize + stepSize)) ...
        + y(i, 1:stepSize);
end

% Last StepSize doesn't have an add
outputIndex = stepSize * numSlices;
z( (outputIndex + 1):(outputIndex + stepSize)) = ...
    y(numSlices, (stepSize + 1):(stepSize + stepSize));

%plot(z);

Z = fft(z);
zMag = abs(Z/numSamples);
zMagOneSided = zMag(1:numSamples/2+1);
plot(freqBins, zMagOneSided);

sound(z,Fs);