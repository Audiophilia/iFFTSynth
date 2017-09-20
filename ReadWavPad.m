% Reads the wavefile 'fileName' and zero pads the data for an even number
% of iFFT engine steps

% Returns the padded wav data signal, sample rate, 
% and number of samples after zero padding

function [outputSig, Fs, numSamples, numSlices] = ...
    ReadWavPad (fileName, stepSize, playInputSound)
    
% Read in wav file
[inputWav, Fs] = audioread(fileName);

% Store number of samples
numSamples = length(inputWav);

% Play sound if desired
if (playInputSound) 
    sound(inputWav, Fs);
end

% Zero pad the input wave to fit even number of slices
numZeros = stepSize - mod(numSamples, stepSize);
zeroPad = zeros(1, numZeros);

isStereo = ndims(inputWav);

if (isStereo > 2)
    % Stereo processing
    outputSig(1, 1:numSamples) = inputWav(1, 1:(numSamples));
    outputSig(1, (numSamples + 1):(numSamples + numZeros)) = zeroPad;
    outputSig(2, 1:numSamples) = inputWav(2, 1:(numSamples));
    outputSig(2, (numSamples + 1):(numSamples + numZeros)) = zeroPad;
else
    % Mono
    outputSig(1:numSamples) = inputWav(1:(numSamples));
    outputSig((numSamples + 1):(numSamples + numZeros)) = zeroPad;
end

% Return number of samples
numSamples = numSamples + numZeros;

% Return number of waveform slices
numSlices = numSamples/stepSize - 1;

end

