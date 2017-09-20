%% FundDet

% This function detects the fundamental frequency in each element of
% inputFFTArray with a high pass detection threshold at lowDetectionCutoff

function fundamentalArray = FundDet(inputFFTArray, lowDetectionCutoff, Fs)

% Determine numSlices, frameSize from inputFFTArray
[numSlices, frameSize] = size(inputFFTArray);

% Array of frequency bins for FFT plot
freqBins = Fs/frameSize * (1:(frameSize/2+1));

% Determine low frequency cutoff bin
for i = 1:length(freqBins)
    if (lowDetectionCutoff < freqBins(i)) 
        break
    end
end
lowDetectionCutoffBin = i;

% Compute array of FFT power spectrum slices
for i = 1:numSlices
    powerSliceArray(i, 1:frameSize) = sqrt(...
        real(inputFFTArray(i, 1:frameSize)) .* real(inputFFTArray(i, 1:frameSize)) ...
        + imag(inputFFTArray(i, 1:frameSize)) .* imag(inputFFTArray(i, 1:frameSize)));
end

% Compute array of fundamentals
for i = 1:numSlices
    for l = 2:(frameSize /2)
        fundProb(i, l) = sum(powerSliceArray(i, 1:(frameSize/2)) ...
            .* powerSliceArray(i, (l + 1):(frameSize/2 + l))); 
    end
    [prob, fundBin] = max(fundProb(i, 1:(frameSize/2)));
    if ( fundBin <= lowDetectionCutoffBin)
        % if detect too low, repeat the last fundamental
        if (i == 1) 
            fundamentalArray(i) = 0;
            %fundPhaseArray(i) = 0;
        else
            fundamentalArray(i) = fundamentalArray(i - 1);
            %fundPhaseArray(i) = fundPhaseArray(i - 1);
        end
    else  
        %Determine precise fundamental frequency by weight of neighboring
        %bins
        fundBin = fundBin + 1;
        FundMag = abs(inputFFTArray(i, fundBin));
        FundMagUp = abs(inputFFTArray(i, fundBin + 1));
        FundMagDown = abs(inputFFTArray(i, fundBin - 1));
        BinSize = freqBins(fundBin) - freqBins(fundBin -1);
        
        p   = 0.5 * ( FundMagDown - FundMagUp ) / ...
            ( 2 * FundMag - FundMagDown - FundMagUp );
        bin = fundBin - 1 - p;
        exactFreq      = BinSize * bin;
        exactAmplitude = FundMag - 0.25 + ( FundMagDown - FundMagUp ) * p;
        
        fundamentalArray(i) = exactFreq;
        
        %fundPhaseArray(i) = angle(X(i, fundBin));
    end
    
end

%plot(fundamentalArray);
    
end

