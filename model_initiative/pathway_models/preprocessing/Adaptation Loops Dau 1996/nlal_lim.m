% nlal - Non-linear adaptation loops -
%        The input is divided by the output of a RC-lowpass-filter.
%        The input range is restricted to [0.00001 ... 1].
%        Impulse response invariant digital design.
%
% Usage: out = nlal(in,Fs)
%
% in         = input column vector
% fs         = sampling rate
%
% out        = output column vector
%
% See also help nlalmex.m, nlalmex.c
%
% References
%
% Dau, T. , Püschel, D. and Kohlrausch, A. (1996): "A quantitative model of the
%     `effective' signal processing in the auditory system: (I). Model structure", 
%     J. Acoust. Soc. Am. 99, p. 3615-3622.
%
% Püschel, D. (1988): "Prinzipien der zeitlichan Analyse beim Hören," Doctoral Thesis, 
%     Universität Göttingen 
%

% Copyright (c) 1999 - 2004 Stephan Ewert. All rights reserved.
% $Revision: 1.00.2 beta$  $Date: 29-04-2004 16:14 $

% BM type is 1 = Gammatone, 2 = DRNL, Added by Morten 24.05.2006

function out = nlal_lim(in,Fs,limit);
% min = 2e-4;   	  %lowest signal level - initial transient solution, MSc
min = 1e-5;   	  %lowest signal level - initial transient solution, MSc

len=length(in);   %signal length
out=in;

tau1=0.005;			%first loop time-constant in sec
tau2=0.050;
tau3=0.129;
tau4=0.253;
tau5=0.500;			%last

%taul=0.02;			%overall lowpass

%--------------------------------------------------------------
% first adaption loop
b01=1/(tau1*Fs);		%b0 from RC-lowpass recursion relation y(n)=b0*x(n)+a1*y(n-1)
a11=exp(-b01);			%a1 coefficient of the upper IIR-filter
b01=1-a11;
tmp21=sqrt(min);		%from steady-state relation
%---------------------------------------------------------------
% second adaption loop
b02=1/(tau2*Fs);		%b0 from RC-lowpass recursion relation y(n)=b0*x(n)+a1*y(n-1)
a12=exp(-b02);			%a1 coefficient of the upper IIR-filter
b02=1-a12;
tmp22=min^(1/4);		%from steady-state relation
%---------------------------------------------------------------
% third adaption loop
b03=1/(tau3*Fs);		%b0 from RC-lowpass recursion relation y(n)=b0*x(n)+a1*y(n-1)
a13=exp(-b03);			%a1 coefficient of the upper IIR-filter
b03=1-a13;
tmp23=min^(1/8);		%from steady-state relation
%---------------------------------------------------------------
% forth adaption loop
b04=1/(tau4*Fs);		%b0 from RC-lowpass recursion relation y(n)=b0*x(n)+a1*y(n-1)
a14=exp(-b04);			%a1 coefficient of the upper IIR-filter
b04=1-a14;
tmp24=min^(1/16);		%from steady-state relation
%---------------------------------------------------------------
% fifth adaption loop
b05=1/(tau5*Fs);		%b0 from RC-lowpass recursion relation y(n)=b0*x(n)+a1*y(n-1)
a15=exp(-b05);			%a1 coefficient of the upper IIR-filter
b05=1-a15;
tmp25=min^(1/32);		%from steady-state relation
%---------------------------------------------------------------
% overall lowpass-filter
%b0l=1/(taul*Fs);		%b0 from RC-lowpass recursion relation y(n)=b0*x(n)+a1*y(n-1)
%a1l=exp(-b0l);			%a1 coefficient of the upper IIR-filter
%b0l=1-a1l;
%tmp_l=0;			%from steady-state relation


corr = min^(1/32);		% to get a range from 0 to 100 model units

mult = 100/(1-corr); 
%  mult = 100/(1.2*(1-corr)); % after expansion,DRNL, we need to compensate for
% "m" is added or altered by morten 26. jun 2006
if limit <=1 % m, no limitation

    for i=1:len
          tmp1=in(i);
       if tmp1 < min
          tmp1=min;
       end
       %---------------------------------------------------------------
       tmp1=tmp1/tmp21;
       tmp21 = a11*tmp21 + b01*tmp1;

       %---------------------------------------------------------------
       tmp1=tmp1/tmp22;
       tmp22 = a12*tmp22 + b02*tmp1;

       %---------------------------------------------------------------
       tmp1=tmp1/tmp23;
       tmp23 = a13*tmp23 + b03*tmp1;

       %---------------------------------------------------------------
       tmp1=tmp1/tmp24;
       tmp24 = a14*tmp24 + b04*tmp1;

        %---------------------------------------------------------------
       tmp1=tmp1/tmp25;
       tmp25 = a15*tmp25 + b05*tmp1;

        %--- Scale to model units ----------------------------------

       tmp1=(tmp1-corr)*mult;

        % --- LP --------

    %   if (lp)
    %	tmp1 = a1l*tmp_l + b0l*tmp1;
    %	tmp_l = tmp1;
    %	   
    %   end

       out(i) = tmp1;

    end
else    % m, now limit
    min1 = tmp21; min2 = tmp22; min3 = tmp23;
    min4 = tmp24; min5 = tmp25;
    for i=1:len
          tmp1=in(i);
       if tmp1 < min
          tmp1=min;
       end
       %---------------------------------------------------------------
       tmp1=tmp1/tmp21;
        maxvalue = (1 - min1^2) * limit - 1;	% m, max. possible output value
        factor = maxvalue * 2; 			% m, factor in formula to speed it up 
        expfac = -2/maxvalue; 			% m, exponential factor in output limiting function
        offset = maxvalue - 1;          % m,
        if ( tmp1 > 1 )                 % m,
            tmp1 = factor/(1+exp(expfac*(tmp1-1)))-offset;  % m,
        end                             % m,
       tmp21 = a11*tmp21 + b01*tmp1;

       %---------------------------------------------------------------
       tmp1=tmp1/tmp22;
        maxvalue = (1 - min2^2) * limit - 1;	% m, max. possible output value
        factor = maxvalue * 2; 			% m, factor in formula to speed it up 
        expfac = -2/maxvalue; 			% m, exponential factor in output limiting function
        offset = maxvalue - 1;          % m,
        if ( tmp1 > 1 )                 % m,
            tmp1 = factor/(1+exp(expfac*(tmp1-1)))-offset;  % m,
        end                             % m,
       tmp22 = a12*tmp22 + b02*tmp1;

       %---------------------------------------------------------------
       tmp1=tmp1/tmp23;
        maxvalue = (1 - min3^2) * limit - 1;	% m, max. possible output value
        factor = maxvalue * 2; 			% m, factor in formula to speed it up 
        expfac = -2/maxvalue; 			% m, exponential factor in output limiting function
        offset = maxvalue - 1;          % m,
        if ( tmp1 > 1 )                 % m,
            tmp1 = factor/(1+exp(expfac*(tmp1-1)))-offset;  % m,
        end    
       tmp23 = a13*tmp23 + b03*tmp1;

       %---------------------------------------------------------------
       tmp1=tmp1/tmp24;
        maxvalue = (1 - min4^2) * limit - 1;	% m, max. possible output value
        factor = maxvalue * 2; 			% m, factor in formula to speed it up 
        expfac = -2/maxvalue; 			% m, exponential factor in output limiting function
        offset = maxvalue - 1;          % m,
        if ( tmp1 > 1 )                 % m,
            tmp1 = factor/(1+exp(expfac*(tmp1-1)))-offset;  % m,
        end    
       tmp24 = a14*tmp24 + b04*tmp1;

        %---------------------------------------------------------------
       tmp1=tmp1/tmp25;
        maxvalue = (1 - min5^2) * limit - 1;	% m, max. possible output value
        factor = maxvalue * 2; 			% m, factor in formula to speed it up 
        expfac = -2/maxvalue; 			% m, exponential factor in output limiting function
        offset = maxvalue - 1;          % m,
        if ( tmp1 > 1 )                 % m,
            tmp1 = factor/(1+exp(expfac*(tmp1-1)))-offset;  % m,
        end    
       tmp25 = a15*tmp25 + b05*tmp1;

        %--- Scale to model units ----------------------------------

       tmp1=(tmp1-corr)*mult;

        % --- LP --------

    %   if (lp)
    %	tmp1 = a1l*tmp_l + b0l*tmp1;
    %	tmp_l = tmp1;
    %	   
    %   end

       out(i) = tmp1;

    end
end

% eof