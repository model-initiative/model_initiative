function [multichanneldata2, output_powervector, output_maxvector] = monauraltransduction_BT(multichanneldata, transduction, samplefreq, infoflag);
%Author Leslie R Bernstein
%Additional comments JH Lestang
%This file is intended to be used an an optional appendix to the binaural cross-correlogram toolbox written by Michael Akeroyd.  
% function [multichanneldata2, output_powervector, output_maxvector] = mmonauraltransduction(multichannelinput, transduction, samplefreq, infoflag);
% 
% Includes Stern/Shear front end
%
%----------------------------------------------------------------
% Applies a model of neural transduction to the multichannel output of a gammatone filterbank.
% The input must be in the same matrix format as made by mgammatonefilterbank
%-----------------------------------------------------------------
%
% Input parameters:
%   multichanneldata  = First output of mgammatonefilterbank
%   transduction      = Type of neural transduction applied to the output of the gammatone filters. Can be one of:
%                       'linear'       = dont do anything
%                       'none'         = dont do anything (same as 'linear'
%                       'null'         = dont do anything (same as 'linear'
%                       'hw'           = halfwave rectification
%                       'log'          = halfwave rectification + log compression (all inputs < 1.0 become 0.0 in the output)
%                       'power'        = halfwave rectification + power-law (^0.4) compression of waveform
%                       'bt1996'       = halfwave rectification + square-law + lowpass filter
%                       'envelope'     = halfwave rectification + power-law (^0.2 then ^2) compression of envelope then lowpass filter
%                       'envelope_lp   = halfwave rectification + power-law (^0.2 then ^2) compression of envelope plus 2nd order low-pass filter at 150 Hz
%                       'envelope_lp1   = see code
%                       'shear_hif'
%                       'shear_lof'
%                       'v=3'          = halfwave rectification + power-law (^3) expansion of waveform
%                       'meddishigh'   = Meddis et al (1990) haircell, high-spontaneous rate
%                       'meddismedium' = Meddis et al (1990) haircell, medium-spontaneous rate
%  samplefreq         = sampling frequency (Hz)
%  infoflag           = 1 = report some information while running
%                     = 0 = dont report anything
%
% Output:
%   multichanneldata2  = transduced input, same matrix format as first output of mgammatonefilterbank
%   output_powervector = power in each channel (linear units not dB) (measured *after* transduction)
%   output_maxvector   = maximum value in each channel (linear units not dB) (measured *after* transduction)
% 
% Example:
%    to apply log compression to the output of a gammatone filterbank, from 47.4 to 1694 Hz, using
%    1 filter per ERB, to the left-channel waveform of a 'wave' signal, type:
% >> [multichanneloutput, cfs, n, lf, hf, q, bw] = mgammatonefilterbank(47.4, 1690, 1, wave1.leftwaveform, wave1.samplefreq, 1);
% >> [multichanneloutput2, powervector, maxvector] = mmonauraltransduction(multichanneloutput, 'log', wave1.samplefreq, 1);
% there are 19 channels in this example:
% >> whos
%  multichanneloutput2      19x48000      7296000  double array
%  powervector              19x1              152  double array
%  maxvector                19x1              152  double array
%
%
% If you are wanting to process a 'wave' signal then use 'mgennap' instead
%
%
% Citations:
% 'v=3' 
%   Shear GD (1987) "Modeling the dependence of auditory lateralization on frequency and bandwidth", (Masters thesis, Department of 
%   Electrical and Computer Engineering, Carnegie-Mellon University, Pittsburgh)
%   Stern RM and Shear GD (1996). "Lateralization and detection of low-frequency binaural stimuli: Effects of distribution of 
%   internal delay", J. Acoust. Soc. Am., 100, 2278-2288
%
% 'bt1996' 
%   Bernstein LR and Trahiotis C (1996)"The normalized correlation: Accounting for binaural detection across center frequency,"
%   J. Acoust. Soc. Am., 100, 3774-3784.
%
% 'envelope'
%   Bernstein LR and Trahiotis C (1996)"The normalized correlation: Accounting for binaural detection across center frequency,"
%   J. Acoust. Soc. Am., 100, 3774-3784.
%   Bernstein LR, van de Par S, and Trahiotis C (1999) "The normalized correlation: Accounting for NoSpi thresholds 
%   obtained with Gaussian and 'low-noise' masking noise," J. Acoust. Soc. Am., 106, 870-876.
%
% Meddis haircell :
%   Meddis R (1986). "Simulation of mechanical to neural transduction in the auditory receptor," J. Acoust. Soc. Am. 79, 702-711.
%   Meddis R (1988). "Simulation of auditory-neural transduction: Further studies," J. Acoust. Soc. Am. 83, 1056-1063.
%   Meddis R Hewitt M and Shackleton TM (1990). "Implementation details of a computational model of the inner-haircell/
%    auditory-nerve synapse," J. Acoust. Soc. Am. 87, 1813-1816.
%
%
% Thanks to Klaus Hartung for speeding the code up (and especially the Meddis hair cell)
% Thanks to Les Bernstein for supplying the envelope-compression code
%
%
%----------------------------------------------------------------
% Original version 
% MAA Winter 2001 (20i01)
%
% Updates: 
%
% MAA Summer 2001 (20vii01)
% De-compacted the code in the final 'measure power' bit as I was running
% into memory problems there; myabe it was complaining about lack of swap space.
% Also clear the intermediate variables
%
% MAA Winter 2002 (18iii02)
% The 'measure power' bit was measuing RMS amplitude not power (oops)
% Now mended to actually measure power
%
% MAA Spring 2002 (10iv02)
% Added the 'bt1996' option 
%
% LRB Summer 2002 (18vii02)
% (1) Added 'envelope_lp' transduction ala Bernsteina and Trahiotis (2002)
% (2) Renamed filter variable to filternum to avoid conflict with Matlab filter function
%
% MAA Summer 2002 (25viii02)
% Cosmetic changes only
%
% DMC Spring 2004 (5iv04)
% New copyright added
%----------------------------------------------------------------

%-----------------------------------------------------------
% 
% "Binaural auditory processing toolbox for MATLAB Software"
% 
% **  Licence Agreement **
% 
% The "Binaural auditory processing toolbox for MATLAB" software
% was developed by Michael Akeroyd for supporting research at 
% MRC IHR. It is based on earlier work at the University of 
% Connecticut (funded by the NIH) and the University of Sussex 
% (funded by the MRC).  It is made available to the academic
% community in the hope that it may prove useful.  
% 
% Definitions:
% TOOLBOX means the "Binaural auditory processing toolbox for 
%   MATLAB" software package and any associated documentation,
%   whether electronic or printed.
% USER means any person or organisation that uses the TOOLBOX.
% ACADEMIC means not-for-profit.
% 
% By using the TOOLBOX, the USER hereby agrees to the following conditions:
% 
% Grant:
% The TOOLBOX is copyrighted by MRC from 2001 to 2004, and
% protected by European Copyright Law.  All rights are reserved worldwide.
% MRC grants USER the royalty free right under MRC Copyright and
% MRC intellectual property rights to use TOOLBOX for ACADEMIC
% purposes only.  If USER wishes to use TOOLBOX for commercial
% for-profit purposes then USER will contact MRC for a commercial licence. 
%         
% Contact address:
%   Dr Michael A Akeroyd,
%   MRC Institute of Hearing Research,
%   Glasgow Royal Infirmary,
%   (Queen Elizabeth Building),
%   16 Alexandra Parade,
%   Glasgow, G31 2ER, United Kingdom
% 
%   maa@ihr.gla.ac.uk
%   http://www.ihr.gla.ac.uk  http://www.ihr.mrc.ac.uk
% 
% USER will not pass the TOOLBOX to any other party unless it is
% accompanied by this Licence Agreement.
% 
% Disclaimer:
% MRC makes no representation or warranty with respect to TOOLBOX
% and specifically disclaims any implied warranties of merchantability
% and fitness for a particular purpose or that use of TOOLBOX
% will not infringe any third party rights.
% 
% MRC reserves the right to revise TOOLBOX and to make changes
% therein from time to time without obligation to notify any person
% or organisation of such revision or changes.
% 
% While MRC will make every effort to ensure the accuracy of TOOLBOX,
% neither MRC nor its employees or agents may be held responsible
% for errors, omissions or other inaccuracies or any consequences
% thereof.  The MRC will not be liable in any way for any losses
% howsoever caused by the use of TOOLBOX, such losses to include
% but not be limited to loss of profit, business interruption, 
% loss of business information, or other pecuniary loss, including
% but not limited to special incidental consequential or other damages.
% 
%-----------------------------------------------------------



switch transduction
   
case {'linear' 'null' 'none'}
   % dont do anything
   if infoflag >= 1
      fprintf('''%s'' = not doing anything ... \n', transduction);
   end;
   multichanneldata2 = multichanneldata;
   clear multichanneldata;
      
      
case 'hw'
   % halfwave rectify 
   if infoflag >= 1
      fprintf('''%s'' = halfwave rectification only ... \n', transduction);
   end;
   multichanneldata2 = mhalfwaverectify(multichanneldata);
   clear multichanneldata;
   
   
case 'log'
   % halfwave rectify then log compression
   if (infoflag >= 1)
      fprintf('''%s'' = halfwave rectification then 20*log10 compression \n', transduction);
      fprintf('(assuming all values <1 become 0.0) ... \n');
   end;
   multichanneldata = mhalfwaverectify(multichanneldata);
   multichanneldata2 = multichanneldata;
   temp1 = find(multichanneldata2 < 1);
   multichanneldata2(temp1) = ones(size(temp1));
   multichanneldata2 = 20*log10(multichanneldata2);
   clear multichanneldata;
   

   
case 'power'
   % halfwave rectify then powerlaw compression of waveform
   compress1 = 0.4;
   if infoflag >= 1
      fprintf('''%s'' = halfwave rectification then power-law compression (to %.1f) ... \n', transduction, compress1);
   end;
   multichanneldata = mhalfwaverectify(multichanneldata);
   multichanneldata2 = multichanneldata .^ compress1;
   clear multichanneldata;
   
   
case 'v=3'
   % halfwave rectify then powerlaw expansion of waveform
   % Included as Shear (1987) used it.
   compress1 = 3;
   if infoflag >= 1
      fprintf('''%s'' = halfwave rectification then power-law expansion (to %.1f) ... \n', transduction, compress1);
   end;
   multichanneldata = mhalfwaverectify(multichanneldata);
   multichanneldata2 = multichanneldata .^ compress1;
   clear multichanneldata;
   
   
case 'bt1996'
   % halfwave rectify then square-law then lowpass filter...
   %
   % As used by Bernstein and Trahiotis (1996) JASA v100 3774-3784
   % Lowpass filter is 4th-order Weiss/Rose with 425-Hz cutoff 
   %
   % This code taken from the following 'envelope' code
   if (infoflag >= 1)
      fprintf('''%s'' = Bernstein/Trahiotis (1996): halfwave rectification then square-law then lowpass filtering ... \n', transduction);
   end;
   % define lowpass filter
   cutoff = 425; %Hz
   order = 4;
   if (infoflag >= 1)
     fprintf('(lowpass filter: %.0f-Hz cutoff %d-order)\n', cutoff, order);
   end;
   lpf = linspace(0, samplefreq/2, 10000);
   f0 = cutoff * (1./ (2.^(1/order)-1).^0.5);
   lpmag = 1./ (1+(lpf./f0).^2) .^ (order/2);
   lpf=lpf ./ (samplefreq/2);
   f=[lpf];
   m=[lpmag];
   lowpassfiltercoefficients = fir2(256, f, m, hamming(257));
   % do each channel .... 
   if (infoflag >= 1)
      fprintf('doing frequency channel # ');
   end;
   nfilters = size(multichanneldata, 1);
   for filternum=1:nfilters,
      if (infoflag >= 1)
         fprintf(' %.0f', filternum);
         if mod(filternum,20) ==0
            fprintf('\n');
         end;
      end;
      % get waveform for this channel and halfwave rectify it
      rectifiedwaveform = multichanneldata(filternum,:);
      findoutput = find(rectifiedwaveform<0);
      rectifiedwaveform(findoutput) = zeros(size(findoutput));
      % square 
      rectifiedwaveform = rectifiedwaveform .^ 2;
      % overlap-add FIR filter using the fft
      multichanneldata2(filternum,:) = fftfilt(lowpassfiltercoefficients, rectifiedwaveform);
   end;
   clear multichanneldata;
   
   if (infoflag >= 1)
      fprintf('\n');
   end;


case 'envelope'
   % halfwave rectify then full envelope compression ...
   %
   % The envelope compression itself is from Bernsten, van de Par
   % and Trahiotis (1996, especially the Appendix). The
   % lowpass filtering is from Berstein and Trahiotis (1996,
   % especially eq 2 on page 3781). 
   %
   % envelope compression using Weiss/Rose lowpass filter
   compress1 = 0.23;
   compress2 = 2.0;
   if (infoflag >= 1)
      fprintf('''%s'' = envelope compression (to %.2f) then halfwave rectification (to %.2f) ... \n', transduction, compress1, compress2);
   end;
   % define lowpass filter
   cutoff = 425; %Hz
   order = 4;
   if (infoflag >= 1)
     fprintf('(including %.0f-Hz cutoff %d-order lowpass filter)\n', cutoff, order);
   end;
   lpf = linspace(0, samplefreq/2, 10000);
   f0 = cutoff * (1./ (2.^(1/order)-1).^0.5);
   lpmag = 1./ (1+(lpf./f0).^2) .^ (order/2);
   lpf=lpf ./ (samplefreq/2);
   f=[lpf];
   m=[lpmag];
   lowpassfiltercoefficients = fir2(256, f, m, hamming(257));
   % compress each filter! 
   if (infoflag >= 1)
      fprintf('doing frequency channel # ');
   end;
   nfilters = size(multichanneldata, 1);
   for filternum=1:nfilters,
      if (infoflag >= 1)
         fprintf(' %.0f', filternum);
         if mod(filternum,20) ==0
            fprintf('\n');
         end;
      end;
      % get envelope
      envelope = abs(hilbert(multichanneldata(filternum,:)));
      % compress the envelope to a power of compression1, while maintaining
      % the fine structure. 
      compressedenvelope = (envelope.^(compress1 - 1)).*multichanneldata(filternum,:);
      % rectify that compressed envelope 
      rectifiedenvelope = compressedenvelope;
      findoutput = find(compressedenvelope<0);
      rectifiedenvelope(findoutput) = zeros(size(findoutput));
      % raise to power of compress2
      rectifiedenvelope = rectifiedenvelope.^compress2;
      % overlap-add FIR filter using the fft
      multichanneldata2(filternum,:) = fftfilt(lowpassfiltercoefficients, rectifiedenvelope);
   end;
   clear multichanneldata;
   
   if (infoflag >= 1)
      fprintf('\n');
   end;

   
   
case 'envelope_lp'
   % halfwave rectify then full envelope compression ...
   %
   % The envelope compression itself is from Bernsten, van de Par
   % and Trahiotis (1996, especially the Appendix). The
   % lowpass filtering is from Bernstein and Trahiotis (1996,
   % especially eq 2 on page 3781). 
   %
   % envelope compression using Weiss/Rose lowpass filter
   % low-pass filter follows envelope processing (for use only with high-frequency signals, see Bernstein and Trahiotis (2002)
   compress1 = 0.23;
   compress2 = 2.0;
  
   if (infoflag >= 1)
      fprintf('''%s'' = envelope compression (to %.2f) then halfwave rectification (to %.2f) ... \n', transduction, compress1, compress2);
   end;
   % define Weiss/Rose synchrony lowpass filter
   cutoff = 425; %Hz
   order = 4;
   if (infoflag >= 1)
     fprintf('(including %.0f-Hz cutoff %d-order lowpass filter)\n', cutoff, order);
   end;
   lpf = linspace(0, samplefreq/2, 10000);
   f0 = cutoff * (1./ (2.^(1/order)-1).^0.5);
   lpmag = 1./ (1+(lpf./f0).^2) .^ (order/2);
   lpf=lpf ./ (samplefreq/2);
   f=[lpf];
   m=[lpmag];
   lowpassfiltercoefficients = fir2(256, f, m, hamming(257));
   %define 150-Hz low-pass envelope filter
   buttercut=150; %Hz
   butterord=2.0;
   if (infoflag >= 1)
     fprintf('(including %.0f-Hz cutoff %d-order lowpass filter)\n', buttercut, butterord);
   end;
   [B,A]=butter(butterord,(150/(samplefreq/2)));
   
   % compress each filter! 
   if (infoflag >= 1)
      fprintf('doing frequency channel # ');
   end;
   nfilters = size(multichanneldata, 1);
   for filternum=1:nfilters,
      if (infoflag >= 1)
         fprintf(' %.0f', filternum);
         if mod(filternum,20) ==0
            fprintf('\n');
         end;
      end;
      % get envelope
      envelope = abs(hilbert(multichanneldata(filternum,:)));
      % compress the envelope to a power of compression1, while maintaining
      % the fine structure. 
      compressedenvelope = (envelope.^(compress1 - 1)).*multichanneldata(filternum,:);
      % rectify that compressed envelope 
      rectifiedenvelope = compressedenvelope;
      findoutput = find(compressedenvelope<0);
      rectifiedenvelope(findoutput) = zeros(size(findoutput));
      % raise to power of compress2
      rectifiedenvelope = rectifiedenvelope.^compress2;
      % overlap-add FIR filter using the fft
      synchfiltered = fftfilt(lowpassfiltercoefficients, rectifiedenvelope);
      multichanneldata2(filternum,:)=filter(B,A,synchfiltered);
   end;
   clear multichanneldata;
   
   if (infoflag >= 1)
      fprintf('\n');
   end;

case 'shear_hif'
  rectv = 3.0;
  
   if (infoflag >= 1)
      fprintf('''%s'' = envelope compression (to %.2f) then halfwave rectification (to %.2f) ... \n', transduction, compress1, compress2);
   end;
   % define Stern/Shear synchrony lowpass filter
   if (infoflag >= 1)
     fprintf('(including %.0f-Hz cutoff %d-order lowpass filter)\n', cutoff, order);
   end;
    lpf = linspace(0, samplefreq/2, 10000);
    lpmag=ones(size(lpf));
    indx=(lpf>1200)&(lpf<=5600); %Note the use of local indexing rather than find
    lpmag(indx)=(1-(lpf(indx)/5600))./(1-(1.2/5.6));
    indx1= lpf>5600;
    lpmag(indx1)=0;
    %plot(lpf,lpmag)
    lpf=lpf ./ (samplefreq/2);
    f=[lpf];
    m=[lpmag];
    lowpassfiltercoefficients = fir2(256, f, m, hamming(257));
    %define 150-Hz low-pass envelope filter
    buttercut=150; %Hz
    butterord=1.0;
   if (infoflag >= 1)
     fprintf('(including %.0f-Hz cutoff %d-order lowpass filter)\n', buttercut, butterord);
   end;
   [B,A]=butter(butterord,(buttercut/(samplefreq/2)));
   %[B,A]=cheby1(butterord,1,(buttercut/(samplefreq/2)));
   if (infoflag >= 1)
      fprintf('doing frequency channel # ');
   end;
   nfilters = size(multichanneldata, 1);
   for filternum=1:nfilters,
      if (infoflag >= 1)
         fprintf(' %.0f', filternum);
         if mod(filternum,20) ==0
            fprintf('\n');
         end;
      end;
      % get waveform for this channel and halfwave rectify it
      rectifiedwaveform = multichanneldata(filternum,:);
      findoutput = find(rectifiedwaveform<0);
      rectifiedwaveform(findoutput) = zeros(size(findoutput));
      % Raise to power 
      rectifiedwaveform = rectifiedwaveform .^ rectv;
      % overlap-add FIR filter using the fft
      %multichanneldata2(filternum,:) = fftfilt(lowpassfiltercoefficients, rectifiedwaveform);
      multichanneldata2(filternum,:) =filter(B,A,(fftfilt(lowpassfiltercoefficients, rectifiedwaveform)));
   end;
   clear multichanneldata;
   
   if (infoflag >= 1)
      fprintf('\n');
   end; 
   
case 'shear_hif_slope'
  rectv = 3.0;
  
   if (infoflag >= 1)
      fprintf('''%s'' = envelope compression (to %.2f) then halfwave rectification (to %.2f) ... \n', transduction, compress1, compress2);
   end;
   % define Stern/Shear synchrony lowpass filter
   if (infoflag >= 1)
     fprintf('(including %.0f-Hz cutoff %d-order lowpass filter)\n', cutoff, order);
   end;
    lpf = linspace(0, samplefreq/2, 10000);
    lpmag=ones(size(lpf));
    indx=(lpf>1200)&(lpf<=5600); %Note the use of local indexing rather than find
    lpmag(indx)=(1-(lpf(indx)/5600))./(1-(1.2/5.6));
    indx1= lpf>5600;
    lpmag(indx1)=0;
    %plot(lpf,lpmag)
    lpf=lpf ./ (samplefreq/2);
    f=[lpf];
    m=[lpmag];
    lowpassfiltercoefficients = fir2(256, f, m, hamming(257));
    %define 150-Hz low-pass envelope filter
    buttercut=150; %Hz
    butterord=1.0;
   if (infoflag >= 1)
     fprintf('(including %.0f-Hz cutoff %d-order lowpass filter)\n', buttercut, butterord);
   end;
   [B,A]=butter(butterord,(buttercut/(samplefreq/2)));
   %[B,A]=cheby1(butterord,1,(buttercut/(samplefreq/2)));
   if (infoflag >= 1)
      fprintf('doing frequency channel # ');
   end;
   nfilters = size(multichanneldata, 1);
   for filternum=1:nfilters,
      if (infoflag >= 1)
         fprintf(' %.0f', filternum);
         if mod(filternum,20) ==0
            fprintf('\n');
         end;
      end;
      % get waveform for this channel and halfwave rectify it
     rectifiedwaveform = multichanneldata(filternum,:);
     rectifiedwaveform = [0 diff(abs(hilbert(rectifiedwaveform)))]; %slope
     rectifiedwaveform = max(0,rectifiedwaveform); % rising slope
      % Raise to power 
     rectifiedwaveform = rectifiedwaveform .^ rectv;
      % overlap-add FIR filter using the fft
      %multichanneldata2(filternum,:) = fftfilt(lowpassfiltercoefficients, rectifiedwaveform);
      
      multichanneldata2(filternum,:) =filter(B,A,(fftfilt(lowpassfiltercoefficients, rectifiedwaveform)));
   end;
   clear multichanneldata;
   
   if (infoflag >= 1)
      fprintf('\n');
   end;       

case 'shear_lof'
  rectv = 3.0;
  
   if (infoflag >= 1)
      fprintf('''%s'' = envelope compression (to %.2f) then halfwave rectification (to %.2f) ... \n', transduction, compress1, compress2);
   end;
   % define Stern/Shear synchrony lowpass filter
   if (infoflag >= 1)
     fprintf('(including %.0f-Hz cutoff %d-order lowpass filter)\n', cutoff, order);
   end;
    lpf = linspace(0, samplefreq/2, 10000);
    lpmag=ones(size(lpf));
    indx=(lpf>1200)&(lpf<=5600); %Note the use of local indexing rather than find
    lpmag(indx)=(1-(lpf(indx)/5600))./(1-(1.2/5.6));
    indx1= lpf>5600;
    lpmag(indx1)=0;
    %plot(lpf,lpmag)
    lpf=lpf ./ (samplefreq/2);
    f=[lpf];
    m=[lpmag];
    lowpassfiltercoefficients = fir2(256, f, m, hamming(257));

   
   if (infoflag >= 1)
      fprintf('doing frequency channel # ');
   end;
   nfilters = size(multichanneldata, 1);
   for filternum=1:nfilters,
      if (infoflag >= 1)
         fprintf(' %.0f', filternum);
         if mod(filternum,20) ==0
            fprintf('\n');
         end;
      end;
      % get waveform for this channel and halfwave rectify it
      rectifiedwaveform = multichanneldata(filternum,:);
      findoutput = find(rectifiedwaveform<0);
      rectifiedwaveform(findoutput) = zeros(size(findoutput));
      % Raise to power 
      rectifiedwaveform = rectifiedwaveform .^ rectv;
      % overlap-add FIR filter using the fft
      multichanneldata2(filternum,:) =fftfilt(lowpassfiltercoefficients, rectifiedwaveform);
   end;
   clear multichanneldata;
   
   if (infoflag >= 1)
      fprintf('\n');
   end;       
    
case 'envelope_lp1'
   % halfwave rectify then full envelope compression ...
   %
   % The envelope compression itself is from Bernsten, van de Par
   % and Trahiotis (1996, especially the Appendix). The
   % lowpass filtering is from Bernstein and Trahiotis (1996,
   % especially eq 2 on page 3781). 
   %
   % envelope compression using Weiss/Rose lowpass filter
   % low-pass filter follows envelope processing (for use only with high-frequency signals, see Bernstein and Trahiotis (2002)
   compress1 = 0.23;
   compress2 = 2.0;
  
   if (infoflag >= 1)
      fprintf('''%s'' = envelope compression (to %.2f) then halfwave rectification (to %.2f) ... \n', transduction, compress1, compress2);
   end;
   % define Weiss/Rose synchrony lowpass filter
   cutoff = 425; %Hz
   order = 4;
   if (infoflag >= 1)
     fprintf('(including %.0f-Hz cutoff %d-order lowpass filter)\n', cutoff, order);
   end;
   lpf = linspace(0, samplefreq/2, 10000);
   f0 = cutoff * (1./ (2.^(1/order)-1).^0.5);
   lpmag = 1./ (1+(lpf./f0).^2) .^ (order/2);
   lpf=lpf ./ (samplefreq/2);
   f=[lpf];
   m=[lpmag];
   lowpassfiltercoefficients = fir2(256, f, m, hamming(257));
   %define xxx-Hz low-pass envelope filter
   buttercut=150; %Hz
   butterord=1.0;
   if (infoflag >= 1)
     fprintf('(including %.0f-Hz cutoff %d-order lowpass filter)\n', buttercut, butterord);
   end;
   [B,A]=butter(butterord,(buttercut/(samplefreq/2)));
   
   % compress each filter! 
   if (infoflag >= 1)
      fprintf('doing frequency channel # ');
   end;
   nfilters = size(multichanneldata, 1);
   for filternum=1:nfilters,
      if (infoflag >= 1)
         fprintf(' %.0f', filternum);
         if mod(filternum,20) ==0
            fprintf('\n');
         end;
      end;
      % get envelope
      envelope = abs(hilbert(multichanneldata(filternum,:)));
      % compress the envelope to a power of compression1, while maintaining
      % the fine structure. 
      compressedenvelope = (envelope.^(compress1 - 1)).*multichanneldata(filternum,:);
      % rectify that compressed envelope 
      rectifiedenvelope = compressedenvelope;
      findoutput = find(compressedenvelope<0);
      rectifiedenvelope(findoutput) = zeros(size(findoutput));
      % raise to power of compress2
      rectifiedenvelope = rectifiedenvelope.^compress2;
      % overlap-add FIR filter using the fft
      synchfiltered = fftfilt(lowpassfiltercoefficients, rectifiedenvelope);
      multichanneldata2(filternum,:)=filter(B,A,synchfiltered);
   end;
   clear multichanneldata;
   
   if (infoflag >= 1)
      fprintf('\n');
   end;   
   
case 'meddishigh'
   % Meddis et al (1990) haircell, high spontaneous rate ...
   if (infoflag >= 1)
      fprintf('''%s''= applying Meddis et al (1990) hair cell (high-spontaneous rate) ... \n', transduction);
   end;
   % Uses Klaus Hartung's implentation of the Meddis haircell so does
   % the whole filterbank in one go.
   % Note that the haircell adds a small silence at the beginning 
   % and end
   % See mmeddishaircell.m for more information.
   multichanneldata2 = mmeddishaircell(multichanneldata, 'high', samplefreq, infoflag);
   clear multichanneldata;
   
   
   
case 'meddismedium'
   % Meddis et al (1990) haircell, medium spontaneous rate ...
   if (infoflag >= 1)
      fprintf('''%s'' = applying Meddis et al (1990) hair cell (medium-spontaneous rate) ... \n', transduction);
   end;
   % Uses Klaus Hartung's implentation of the Meddis haircell so does
   % the whole filterbank in one go.
   % Note that the haircell adds a small silence at the beginning 
   % and end
   % See mmeddishaircell.m for more information.
   multichanneldata2 = mmeddishaircell(multichanneldata, 'medium', samplefreq, infoflag);
   clear multichanneldata;


otherwise
   % unknown compression value
   fprintf('%s: error! unknown compression type ''%s''\n', mfilename, transduction);
   fprintf('valid options are: \n');
   fprintf('  ''linear''       = dont do anything\n');
   fprintf('  ''null''         = dont do anything (same as ''linear'')\n');
   fprintf('  ''none''         = dont do anything (same as ''linear'')\n');
   fprintf('  ''hw''           = halfwave rectification\n');
   fprintf('  ''log''          = halfwave rectification + log compression\n');
   fprintf('  ''power''        = halfwave rectification + power-law (^0.4) compression of waveform\n');
   fprintf('  ''bt1996''       = halfwave rectification + square-law + lowpass filter\n');
   fprintf('  ''envelope''     = halfwave rectification + power-law (^0.2 then ^2) compression of envelope then lowpass filter\n');
   fprintf('  ''envelope_lp''  = halfwave rectification + power-law (^0.2 then ^2) compression of envelope plus 2nd order low-pass filter at 150 Hz\n');
   fprintf('  ''envelope_lp1''  = halfwave rectification + power-law (^0.23 then ^2) compression of envelope plus 1st order low-pass filter at 150 Hz\n');
   fprintf('  ''v=3''          = halfwave rectification + power-law (^3) expansion of waveform\n');
   fprintf('  ''meddishigh''   = Meddis et al (1990) haircell, high-spontaneous rate\n');
   fprintf('  ''meddismedium'' = Meddis et al (1990) haircell, medium-spontaneous rate\n');
   fprintf('\n');
   return;
end;   
   
   
% multichanneldata2 is one output
   
% measures power and maximum values in each channel
%% MAA Summer 2001:
%% old, compactcode
% output_powervector = (sqrt(mean(power(multichanneldata2, 2)')))';
% output_maxvector = (max(multichanneldata2'))';

% MAA Winter 2002 (18iii02)
% bug! the code originally returned the rms amplitude, not the power ...
% old:
%   tempvector = power(multichanneldata2, 2)';
%   output_powervector = (sqrt(mean(tempvector)))';
% new:
tempvector = power(multichanneldata2, 2)';
output_powervector = (mean(tempvector))';


output_maxvector = (max(multichanneldata2'))';




% the end!
%------------------------------
