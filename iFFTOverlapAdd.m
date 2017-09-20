%% iFFTOverlapAdd

function outputSig = iFFTOverlapAdd(FFTSliceArray, makeOutputReal)

if ~exist('makeOutputReal', 'var')
    % Set outputABS default
    makeOutputReal = false;
end

% Determine numSlices, frameSize from inputFFTArray
[numSlices, frameSize] = size(FFTSliceArray);
stepSize = frameSize / 2;

% iFFT array of FFT slices
for i = 1:numSlices
    iFFTSlices( i, 1:frameSize) = ifft(FFTSliceArray(i, 1:frameSize));
end

% Overlap add
% First stepSize doesn't have an add
outputSig(1:stepSize) = iFFTSlices(1, 1:stepSize);

% Overlap add
for i = 2:numSlices
    outputIndex = stepSize * (i - 1);
    outputSig((outputIndex + 1):(outputIndex + stepSize)) = ...
        iFFTSlices((i - 1), (stepSize + 1):(stepSize + stepSize)) ...
        + iFFTSlices(i, 1:stepSize);
end

% Last StepSize doesn't have an add
outputIndex = stepSize * numSlices;
outputSig( (outputIndex + 1):(outputIndex + stepSize)) = ...
    iFFTSlices(numSlices, (stepSize + 1):(stepSize + stepSize));

% If makeOutputReal is true, take real part of outputSig only
if (makeOutputReal)
    for i = 1:length(outputSig)
        outputSig(i) = real(outputSig(i));
    end
else
    % Throw error if there is significant imaginary content in outputSig
    assert (max(abs(imag(outputSig))) < 1e-12, ...
        'Significant imaginary content in outputSig');
end

end