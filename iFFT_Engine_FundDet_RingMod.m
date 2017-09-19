%hold off;
clear; 

% Use modRateDivider for frequency ratio
UseModRateDivider = 0;
modRateDivider = 1.01;

% Use modRateDetune for fixed frequency shift
modRateDetune = 30;

% Size of fft frame
frameSize = 1024;

% Read in audio file
if(1)
    filename = 'trumpet.wav';
    [inputWav,Fs] = audioread(filename);
    %sound(inputWav,Fs);
    inputSig = inputWav.';
else
    % Total length of input waveform
    Fs = 48000;
    f = 400;
    sampleSize = 20480;
    %inputSin = sin(2*pi*f/Fs*[1:40960]);
    inputSin = sin(2*pi*f/Fs*[1:sampleSize]) + sin(4*pi*f/Fs*[1:sampleSize]);
    inputSin((sampleSize + 1):(2*sampleSize)) = sin(4*pi*f/Fs*[(sampleSize + 1):(2*sampleSize)]) ...
        + sin(8*pi*f/Fs*[(sampleSize + 1):(2*sampleSize)]);

    % Set input source
    inputSig = inputSin;
end

numSamples = length(inputSig);

% Frequency manipulation RingMod

% Array of frequency bins for FFT plot
freqBins = Fs*(1:(numSamples/2+1))/numSamples;

% Generate Hann window
window = hann(frameSize).';
%window = ones(frameSize);
% Frame overlap amount
overlap = 0.5;

% Create waveform slices
numSlices = ceil(numSamples / (frameSize * overlap));

% Step size
stepSize = frameSize * overlap;

% Make array of input slices
for i = 1:(numSlices - 1)
    inputOffset = stepSize * (i - 1);
    x( i, 1:frameSize) = window(1:frameSize) ...
        .* inputSig((inputOffset + 1):(inputOffset + frameSize));
end

% Zero pad last slice if necessary
numZeros = frameSize - mod(numSamples, stepSize);
inputOffset = stepSize * (numSlices - 1);
if (numZeros ~= frameSize)
    % Uneven amount of frames, zero pad the last one up to frameSize
    zeroPad = zeros(1, numZeros);
    lastSlice(1:(frameSize - numZeros)) = inputSig((inputOffset + 1):numSamples);
    lastSlice((frameSize - numZeros + 1):frameSize) = zeroPad;
    x( numSlices, 1:frameSize) = window .* lastSlice;
    % Now we've got one more slice
    numSlices = numSlices + 1;
end

% Compute array of FFTs
for i = 1:(numSlices - 1)
    X( i, 1:frameSize) = fft(x(i, 1:frameSize));
    powerX(i, 1:frameSize) = sqrt(...
        real(X(i, 1:frameSize)) .* real(X(i, 1:frameSize)) ...
        + imag(X(i, 1:frameSize)) .* imag(X(i, 1:frameSize)));
end

% Array of frequency bins for FFT plot
freqBins = Fs*(1:(frameSize/2+1))/frameSize;

%{
for i = 1:(numSlices - 1)
    if(i >= 14)
       plot(freqBins, powerX(i)); 
    end
end
%}

% Low frequency detection frequency cutoff (Hz)
lowDetectionCutoff = 60;

% Determine low frequency cutoff bin
for i = 1:(frameSize/2)
    if (lowDetectionCutoff < freqBins(i)) 
        break
    end
end
lowDetectionBin = i;

% Compute array of fundamentals
for i = 1:(numSlices - 1)
    for l = 2:(frameSize /2)
        fundProb(i, l) = sum(powerX(i, 1:(frameSize/2)) ...
            .* powerX(i, (l + 1):(frameSize/2 + l))); 
    end
    [prob, fundBin] = max(fundProb(i, 1:(frameSize/2)));
    if ( fundBin <= lowDetectionBin)
        % if detect too low, repeat the last fundamental
        if (i == 1) 
            fundamental(i) = 0;
            fundPhase(i) = 0;
        else
            fundamental(i) = fundamental(i - 1);
            fundPhase(i) = angle(i - 1);
        end
    else  
        %Determine precise fundamental frequency by weight of neighboring
        %bins
        fundBin = fundBin + 1;
        FundMag = abs(X(i, fundBin));
        FundMagUp = abs(X(i, fundBin + 1));
        FundMagDown = abs(X(i, fundBin - 1));
        BinSize = freqBins(fundBin) - freqBins(fundBin -1);
        
        p   = 0.5 * ( FundMagDown - FundMagUp ) / ...
            ( 2 * FundMag - FundMagDown - FundMagUp );
        bin = fundBin - 1 - p;
        exactFreq      = BinSize * bin;
        exactAmplitude = FundMag - 0.25 + ( FundMagDown - FundMagUp ) * p;
        
        fundamental(i) = exactFreq;
        
        %fundPhase(i) = angle(X(i, fundBin));
        fundPhase(i) = 0;
    end
end

%plot(fundamental);

% Time domain RingMod
lastPhase = 0;

if (UseModRateDivider)
    for i = 1:(numSlices - 1)
        modFreq = fundamental(i) / modRateDivider;
        modSig(((i - 1) * stepSize + 1):(i * stepSize)) = ...
            sin(2*pi*modFreq/Fs*[1:stepSize] + lastPhase);
        lastPhase = 2*pi*modFreq/Fs*(stepSize+1) + lastPhase;
    end
else
    for i = 1:(numSlices - 1)
        modFreq = fundamental(i) - modRateDetune;
        modSig(((i - 1) * stepSize + 1):(i * stepSize)) = ...
            sin(2*pi*modFreq/Fs*[1:stepSize] + lastPhase);
        lastPhase = 2*pi*modFreq/Fs*(stepSize+1) + lastPhase;
    end
end

% repeat fundamental for last slice
modFreq = fundamental(i);
modSig(((numSlices - 1) * stepSize + 1):(numSlices * stepSize)) = ...
    sin(2*pi*angle(i)+2*pi*modFreq/Fs*[1:stepSize] + lastPhase);
    
%plot(modSig, 'o');
stereo = ndims(inputSig);

if (stereo > 1)
    % Stereo processing
    outputSig(1, 1:numSamples) = modSig(1:numSamples) .* inputSig(1, 1:numSamples);
    outputSig(2, 1:numSamples) = modSig(1:numSamples) .* inputSig(2, 1:numSamples);
else
    % Mono
    outputSig(1:numSamples) = modSig(1:numSamples) .* inputSig(1:numSamples);
end

plot(outputSig.');
hold on;
plot(modSig);
hold off;

%X = fft(outputSig(1:(numSamples/2)));
%Xplot = abs(X(1:(length(X)/2 + 1)));

% Array of frequency bins for FFT plot
%freqBins = Fs*(1:(numSamples/2+1))/numSamples;

%plot(freqBins, Xplot);

sound(outputSig,Fs);