function [sig, nz, out] = SigLevel(Out, SNR)
% extended March 2013 to output all relevant values

sig = Out - 10*log10(1+10.^(-SNR./10));
nz = Out - 10*log10(1+10.^(SNR./10));
out = 10*log10(10.^(sig./10)+10.^(nz./10));

