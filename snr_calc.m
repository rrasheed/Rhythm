function new_data = snr_calc(signal,noise)
%% SNR is signal-to-noise ratio calculator
% new_data = snr_calc(signal,noise,time) takes the filtered foreground image
% signal and risidual noise noise to claulculate the avergage signal  value
% and the standard deviation of the noise. Then the new signal will be
% divided by the SD of the noise to create the SNR. 
%
% INPUTS:
% signal = filtered signal after removing background image
%
% noise = Residual noise that is left after the signal is subtracted from
%         the forground
%
%
% OUTPUTS:
% new_data = this is the calculted snr data that we will use to create the
%            mask over the image
%
% METHOD 1: Calculate Signal to Noise ratio by dividing the average
%    amplitude of the signal by the standard deviation of the noise. 
%
% METHOD 2: Compute the Signal to Noise ratio RMS value. RMS stands for
%    root mean squared. To get SNR RMS, divide Signal RMS by Noise RMS
%
%
% REFERENCES:
% Fast VG, Kleber AG: Microscopic conduction in cultured strands of
%    neonatal ral heart cells measured with voltage-sensitive dyes. 
%    Circ Res 1993:73:914-925
%
%
% RELEASE VERSION 1.0.1
%
% Author: Rayhaan Rasheed (rrasheed@gwmail.gwu.edu)

%% Method 1
[a,b,c] = size(signal);
for x = 1:a
    for y = 1:b
        sumsig = sum(signal(x,y,:));
    end
end
avgsig = sumsig./c;
stdnoise = std(noise,[],3);
snr = avgsig./stdnoise;
new_data = snr;
%% Method 2
% % sigrms = rms(signal,3);
% % noirms = rms(noise,3);
% % snrrms = sigrms./noirms;
% % new_data = snrrms;
