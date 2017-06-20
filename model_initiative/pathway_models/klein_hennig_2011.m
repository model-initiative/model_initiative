% attempt to reimplement Bernstein and Trahiotis 2002 model
% added the ability to include adaptation loops as in Dau et al. 1997
% from Martin Klein-Hennig Diplom thesis and JASA 2011 paper

% small edits by Mathias Dietz 2017 to allow artificial observer:
% internal noise is added after peripheral processing

function rho = klein_hennig_2011(in,fs,adapt_loops,internal_noise_ratio)

in = in / rms(rms(in));

in_l=in(:,1);
in_r=in(:,2);

% gammatone filter
analyzer = Gfb_Analyzer_new(fs, 4000,4000,4000,1);
in_l = Gfb_Analyzer_process(analyzer, in_l);
in_r = Gfb_Analyzer_process(analyzer, in_r);

% half-wave rectification
% -----------------------------------------------
in_l=max(real(in_l),0);
in_r=max(real(in_r),0);

% cochlear compression + square law (0.23 x 2)
% -----------------------------------------------
in_l=in_l.^0.46;
in_r=in_r.^0.46;

% hair-cell lowpass
% -----------------------------------------------
in_l=lp_filter(4,425,fs,in_l);
in_r=lp_filter(4,425,fs,in_r);

% envelope lowpass
% -----------------------------------------------
in_l=lp_filter(1,150,fs,in_l);
in_r=lp_filter(1,150,fs,in_r);

% non-linear adaptation loops with limitation
% -------------------------------------------
if exist('adapt_loops','var')
    if adapt_loops == 1
        in_l = nlal_lim_var(in_l, fs, 10,0.005,0,0,0,0);
        in_r = nlal_lim_var(in_r, fs, 10,0.005,0,0,0,0);
    elseif adapt_loops == 5
        in_l = nlal_lim_var(in_l, fs, 10,0.005,0.05,0.129,0.253,0.5);
        in_r = nlal_lim_var(in_r, fs, 10,0.005,0.05,0.129,0.253,0.5);
    end
end

in_l = in_l / rms(in_l);
in_r = in_r / rms(in_r);

in_l = in_l + randn(size(in_l))*internal_noise_ratio;
in_r = in_r + randn(size(in_r))*internal_noise_ratio;

rho = corrcoef(in_l,in_r);
if size(rho,1)>1 % should be always true in Matlab and always false in Octave
    rho = rho(2,1);
end