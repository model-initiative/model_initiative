function [output_correlogram, output_delayweight] = mccgramdelayweight_hitest_BT(correlogram, ptswitch, forcefrequency, infoflag);
%Author Leslie R Bernstein
%This file is intended to be used as an optional appendix to the binaural cross-correlogram toolbox written by Michael Akeroyd.

% function [output_correlogram, output_delayweight] = 
% mccgramdelayweight(correlogram, ptswitch, infoflag);

%LRB-- bastardized version to monkey with Stern/Shear weights

%
%------------------------------------------------------------------
% Applies a delay-weighting (=p(tau)) function to a correlogram
%------------------------------------------------------------------
%
% Input parameters:
%    correlogram = 'correlogram' structure as defined in mccgramcreate.m
%    ptswitch    = delay weighting function to use: can be
%                   'colburn'    = Colburn (1977)
%                   'shear'      = Shear (1987, Stern and Shear, 1996);
%                   'shackleton' = Shackleton et al (1992)
%    infoflag    = 1: report some information while running only
%                = 0  dont report anything
%
% Output parameters:
%    output_correlogram = the input correlogram weighted by p(tau)
%    output_delayweight = the delay-weighting function in a correlogram structure
%
%
% Example:
% to apply Colburn's weighting to a previously-made correlogram cc1, 
% and store the weighted correlogram in cc2 and the weighting-
% function itself in ccw, type:
% >> [cc2 ccw] = mccgramdelayweight(cc1, 'colburn', 1);
%
%
% Citations:
% Colburn HS (1977). "Theory of binaural interaction based on 
%   auditory-nerve data. II. Detection of tones in noise," 
%   J. Acoust. Soc. Am., 61, 525-533.
% Shackleton TM, Meddis R and Hewitt MJ (1992). "Across frequency 
%   integration in a model of lateralization", J. Acoust. Soc. Am., 
%   91, 227602279.
% Shear GD (1987). "Modeling the dependence of auditory 
%   lateralization on frequency and bandwidth", (Masters thesis, 
%   Department of Electrical and Computer Engineering, 
%   Carnegie-Mellon University, Pittsburgh)
% Stern RM and Shear GD (1996). "Lateralization and detection of 
%   low-frequency binaural stimuli: Effects of distribution of 
%   internal delay", J. Acoust. Soc. Am., 100, 2278-2288
%
%
% version 1.0 (Jan 20th 2001)
% MAA Winter 2001 
%----------------------------------------------------------------

%!**********************************
%! 
%! mac version 9vii01
%!
%!***********************************


%******************************************************************
% This MATLAB software was developed by Michael A Akeroyd for 
% supporting research at the University of Connecticut
% and the University of Sussex.  It is made available
% in the hope that it may prove useful. 
% 
% Any for-profit use or redistribution is prohibited. No warranty
% is expressed or implied. All rights reserved.
% 
%    Contact address:
%      Dr Michael A Akeroyd,
%      Laboratory of Experimental Psychology, 
%      University of Sussex, 
%      Falmer, 
%      Brighton, BN1 9QG, 
%      United Kingdom.
%    email:   maa@biols.susx.ac.uk 
%    webpage: http://www.biols.susx.ac.uk/Home/Michael_Akeroyd/
%  
% ******************************************************************
   
 
% define and clear delay-weighting function
% (create by copying then changing input)
delayweight = correlogram;
delayweight.title = 'delay-weighting function';
delayweight.data = zeros(delayweight.nfilters, delayweight.ndelays); 

switch ptswitch
   
case'shear'
  % Shear/Stern weights
  % (from Stern and Shear 1996 p. 2282 eqs 6 and 7)
  k_h = 3000;
  lf = 0.1;
  lp = -1.1;
  flattoplimit_us = 200;
  flattoplimit_secs = flattoplimit_us/1000000;
  if infoflag >= 1
     fprintf('creating delay-weighting function: Shear/Stern, normalized so area = 1:\n');
     fprintf('Kh = %.0f sec-1  flattop = +/- %.0f usecs  lf = %.1f  lp = %.1f\n', k_h, flattoplimit_us, lf, lp);
  end;
  
  % calculate weights in advance so allowing normalization for 
  % area = 1 (ie, a proper probability-density function)
  
  for filter=1:correlogram.nfilters;
     freq = forcefrequency;
     % define freq dependent parameter
     if freq <= 1200
        k_l = lf/freq^lp;
     else
        k_l = lf/1200^lp;
     end;
     % calculate nonnormalised first
     area = 0;
     for delay=1:correlogram.ndelays
        tau_microseconds = correlogram.delayaxis(delay);
        tau_seconds = tau_microseconds/1000000;
        if abs(tau_microseconds) <= flattoplimit_us
           % assume that the top part of eq 6 might be wrong: 
           % instead, go for a flat top so that the weight is 
           % that at +/- 200 microsecs
           part1 = exp(-2*pi*k_l*abs(flattoplimit_secs));
           part2 = exp(-2*pi*k_h*abs(flattoplimit_secs));
           delayweight.data(filter, delay) = 1.0 * (part1 - part2)/abs(flattoplimit_secs);
       else
           part1 = exp(-2*pi*k_l*abs(tau_seconds));
           part2 = exp(-2*pi*k_h*abs(tau_seconds));
           delayweight.data(filter, delay) = 1.0 * (part1 - part2)/abs(tau_seconds);
        end;
        area = area + delayweight.data(filter, delay);
     end;
     
     % calculate C_lf to allow normalisation of area 
     C_lf = 1/area;
     
     % normalize so area = 1 in each channel
     for delay=1:correlogram.ndelays,
        delayweight.data(filter, delay) = C_lf * delayweight.data(filter, delay);
     end;
  end;  % next filter
     
     
     
case 'colburn'
  % colburn weights
  flattoplimit_msecs = 0.15;
  tc1 = 0.6;
  tc2 = 2.3;
  tc2limit = 2.2;
  if infoflag >= 1
     fprintf('creating delay-weighting function: Colburn, normalized so area = 1\n');
     fprintf('tc1 = %.1f ms  tc2= %.1f ms  flattop = +/-%.2f ms\n', tc1, tc2, flattoplimit_msecs);
  end;
  % calculate weights in advance so allowing normalization for 
  % area = 1 (ie, a proper probability-density function)
  % This is a frequency-independent weighting function so only do 
  % once.
  area = 0;
  for delay=1:correlogram.ndelays,
     tau_microseconds = correlogram.delayaxis(delay);
     tau_absmilliseconds = abs(tau_microseconds/1000);
     if (tau_absmilliseconds <= flattoplimit_msecs)
        weight(delay) = exp(-1*0/tc1);
     elseif (tau_absmilliseconds <= tc2limit)
        weight(delay) = exp(-1*(tau_absmilliseconds - flattoplimit_msecs)/tc1);
     else
        weight(delay) = 0.033 * exp(-1*(tau_absmilliseconds - tc2limit)/tc2);
     end;
     area = area + weight(delay);
  end;
  
  % calculate C_lf to allow normalisation of area 
  C_lf = 1/area;
  
  % normalize so area = 1 in each channel
  for filter=1:correlogram.nfilters
     for delay=1:correlogram.ndelays,
        delayweight.data(filter, delay) = C_lf * weight(delay);
     end; 
  end;
  
  
case 'shackleton'
  % Gaussian function from Shackleton et al (1992)
  sd_usecs = 600;
  if infoflag >= 1
     fprintf('creating delay-weighting function: Shackleton et al, normalized so area = 1\n');
     fprintf('standard deviation = %.1f us  \n', sd_usecs);
  end;
  % calculate weights in advance so allowing normalization for 
  % area = 1 (ie, a proper probability-density function)
  % This is a frequency-independent weighting function so only do 
  % once.
  area = 0;
  for delay=1:correlogram.ndelays,
     tau_microseconds = correlogram.delayaxis(delay);
     weight(delay) = 1/sqrt((2*pi)*sd_usecs)  * exp(-1*(tau_microseconds-0)^2/(2*sd_usecs^2));
     area = area + weight(delay);
  end;
  
  % calculate C_lf to allow normalisation of area 
  C_lf = 1/area;
  
  % normalize so area = 1 in each channel
  for filter=1:correlogram.nfilters
     for delay=1:correlogram.ndelays,
        delayweight.data(filter, delay) = C_lf * weight(delay);
     end; 
  end;
  
  
otherwise   % unknown p(t) value
   fprintf('%s: error! unknown delay weight ''%s''\n\n', mfilename, ptswitch);
   return;
   
end;


% apply weight (but copy first to get index values ok)
if (infoflag >= 1)
   fprintf('applying function ... \n');
end;
correlogram2 = correlogram;
correlogram2.data = delayweight.data .* correlogram.data;

% reset names
correlogram2.delayweight = ptswitch;
delayweight.delayweight = ptswitch;
delayweight.modelname = mfilename;


% return values
output_correlogram = correlogram2;
output_delayweight = delayweight;

if infoflag >= 1
   fprintf('\n');
end;
  
  
  
% the end
%------------------------------
