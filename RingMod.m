
function outputSig = RingMod(inputSig, Fs, fundamentalArray, ...
                                    modRateDivider, modRateDetune)

[x, numSlices] = size(fundamentalArray);
numSamples = length(inputSig);
stepSize = numSamples / (numSlices + 1);

% Time domain RingMod
lastPhase = 0;

for i = 1:numSlices
    modFreq = fundamentalArray(i) / modRateDivider - modRateDetune;
    modSig(((i - 1) * stepSize + 1):(i * stepSize)) = ...
        sin(2*pi*modFreq/Fs*[1:stepSize] + lastPhase);
    lastPhase = 2*pi*modFreq/Fs*(stepSize + 1) + lastPhase;
end

% repeat fundamental for last slice
modFreq = fundamentalArray(i);
modSig((numSlices * stepSize + 1):((numSlices + 1) * stepSize)) = ...
    sin(2*pi*angle(i)+2*pi*modFreq/Fs*[1:stepSize] + lastPhase);
    
%plot(modSig, 'o');
isStereo = ndims(inputSig);

if (isStereo > 2)
    % Stereo processing
    outputSig(1, 1:numSamples) = modSig(1:numSamples) .* inputSig(1, 1:numSamples);
    outputSig(2, 1:numSamples) = modSig(1:numSamples) .* inputSig(2, 1:numSamples);
else
    % Mono
    outputSig(1:numSamples) = modSig(1:numSamples) .* inputSig(1:numSamples);
end

%plot(outputSig.');
%hold on;
%plot(modSig);
%hold off;
end