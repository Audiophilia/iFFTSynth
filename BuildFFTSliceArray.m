%% BuildFFTSliceArray

% Transforms inputSig into FFTSliceArray
function FFTSliceArray = BuildFFTSliceArray(inputSig, window, stepSize)

numSlices = length(inputSig)/stepSize - 1;
frameSize = length(window);

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

end