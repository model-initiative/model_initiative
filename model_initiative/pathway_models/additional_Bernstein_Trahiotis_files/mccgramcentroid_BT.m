function [output_centroid] = mccgramcentroid_BT(correlogram, infoflag)
%Author Leslie R Bernstein
%Additional comments JH Lestang
%This file is intended to be used an an optional appendix to the binaural cross-correlogram toolbox written by Michael Akeroyd.  

% function [output_centroid] = 
% mccgramcentroid(correlogram, infoflag)
% 
%--------------------------------------------------------------------
% Calculates the centroid of the across-frequency average of
% a correlogram.
%--------------------------------------------------------------------
%
% Input parameters:
%    correlogram  = 'correlogram' structure as defined in mccgramcreate.m
%    infoflag     = 1 report centroid to screen
%                 = 0 don report anything
%
% Output parameters:
%    output_centroid = centroid of across-frequency average of 
%                      correlogram (microseconds)
%
% Example :
% to measure the centroid of a previously made correlogram cc1, 
% type:
% >> centroid = mccgramcentroid(cc1, 1);
%
%
% Thanks to Klaus Hartung for speeding the code up
%
% version 1.0 (Jan 20th 2001)
% MAA Winter 2001 
%----------------------------------------------------------------

% ******************************************************************
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
   
   
% average across-frequency 
if infoflag >= 1
   fprintf('averaging across frequency ... \n');
end;
%LRB-- Take the sum over over rows.  This allows centroid operation to work
%even if only one filter
integratedccfunction = sum(correlogram.data,1);   

% measure centroid
if infoflag >= 1
   fprintf('calculating centroid as sum(t * correlogram(t,f)) / sum(correlogram(t,f))\n');
   fprintf('(sums are over delay t and frequency f)\n');
end;


numerator =   sum(correlogram.delayaxis .* integratedccfunction);
denominator = sum(integratedccfunction);


centroid = numerator/denominator;

if infoflag >= 1
   fprintf('\n');
   fprintf('centroid = %.3f usecs\n', centroid);
   fprintf('\n');
end;

% return values
output_centroid = centroid;


% the end!
%----------------------------------------------------------
