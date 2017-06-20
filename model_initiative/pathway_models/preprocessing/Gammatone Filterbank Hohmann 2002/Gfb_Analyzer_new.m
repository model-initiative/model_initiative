function analyzer = Gfb_Analyzer_new(sampling_frequency_hz,         ...
                                     lower_cutoff_frequency_hz,     ...
                                     specified_center_frequency_hz, ...
                                     upper_cutoff_frequency_hz,     ...
                                     filters_per_ERBaud)
% analyzer = Gfb_Analyzer_new(sampling_frequency_hz,         ...
%                             lower_cutoff_frequency_hz,     ...
%                             specified_center_frequency_hz, ...
%                             upper_cutoff_frequency_hz,     ...
%                             filters_per_ERBaud)
%
% Gfb_Analyzer_new constructs a new Gfb_Analyzer object.  The analyzer
% implements the analysis part of a gammatone filterbank as described
% in [Hohmann 2002].
% It consists of several 4th order all-pole gammatone filters; each
% one with a bandwidth of 1 ERBaud.  The center frequencies of the in-
% dividual filters are computed as described in section 3 of [Hohmann
% 2002].
%
% PARAMETERS: (all frequencies in Hz)
% sampling_frequency_hz      The sampling frequency of the signals on which
%                            the analyzer will operate
% lower_cutoff_frequency_hz  The lowest possible center frequency of a
%                            contained gammatone filter
% specified_center_frequency_hz       ( == "base frequency")
%                            One of the gammatone filters of the analyzer
%                            will have this center frequency.  Must be >=
%                            lower_cutoff_frequency_hz
% upper_cutoff_frequency_hz  The highest possible center frequency of a
%                            contained gammatone filter.  Must be >=
%                            specified_center_frequency_hz
% filters_per_ERBaud         The density of gammatone filters on the ERB
%                            scale.
%
% analyzer                   The constructed Gfb_Analyzer object
%
% copyright: Universitaet Oldenburg
% author   : tp
% date     : Jan 2002

% filename : Gfb_Analyzer_new.m


% The order of the gammatone filter is derived from the global constant
% GFB_PREFERED_GAMMA_ORDER defined in "Gfb_set_constants.m".  Usually,
% this is equal to 4.
global GFB_PREFERED_GAMMA_ORDER;
Gfb_set_constants;

% To avoid storing information in global variables, we use Matlab
% structures:
analyzer.type                          = 'Gfb_Analyzer';
analyzer.sampling_frequency_hz         = sampling_frequency_hz;
analyzer.lower_cutoff_frequency_hz     = lower_cutoff_frequency_hz;
analyzer.specified_center_frequency_hz = specified_center_frequency_hz;
analyzer.upper_cutoff_frequency_hz     = upper_cutoff_frequency_hz;
analyzer.filters_per_ERBaud            = filters_per_ERBaud;
analyzer.fast                          = 0;

% Calculate the values of the parameter frequencies on the ERBscale:
lower_cutoff_frequency_erb     = ...
    Gfb_hz2erbscale(lower_cutoff_frequency_hz);
specified_center_frequency_erb = ...
    Gfb_hz2erbscale(specified_center_frequency_hz);
upper_cutoff_frequency_erb     = ...
    Gfb_hz2erbscale(upper_cutoff_frequency_hz);


% The center frequencies of the individual filters are equally
% distributed on the ERBscale.  Distance between adjacent filters'
% center frequencies is 1/filters_per_ERBaud.
% First, we compute how many filters are to be placed at center
% frequencies below the base frequency:
erbs_below_base_frequency = ...
    specified_center_frequency_erb - lower_cutoff_frequency_erb;
num_of_filters_below_base_freq = ...
    floor(erbs_below_base_frequency * filters_per_ERBaud);

% Knowing this number of filters with center frequencies below the
% base frequency, we can easily compute the center frequency of the
% gammatone filter with the lowest center frequency:
start_frequency_erb = ...
    specified_center_frequency_erb - ...
    num_of_filters_below_base_freq / filters_per_ERBaud;

% Now we create a vector of the equally distributed ERBscale center
% frequency values:
center_frequencies_erb = ...
    [start_frequency_erb:(1/filters_per_ERBaud):upper_cutoff_frequency_erb];

%
analyzer.center_frequencies_hz = Gfb_erbscale2hz(center_frequencies_erb);

% This loop actually creates the gammatone filters:
for channel = [1:length(analyzer.center_frequencies_hz)]
  center_frequency_hz = analyzer.center_frequencies_hz(channel);

  % Construct gammatone filter with one ERBaud bandwidth:
  gammafilter = ...
      Gfb_Filter_new(sampling_frequency_hz, center_frequency_hz, ...
                     GFB_PREFERED_GAMMA_ORDER);

  analyzer = Gfb_Analyzer_set_filter(analyzer, channel, gammafilter);
end


%%-----------------------------------------------------------------------------
%%
%%   Copyright (C) 2002   AG Medizinische Physik,
%%                        Universitaet Oldenburg, Germany
%%                        http://www.physik.uni-oldenburg.de/docs/medi
%%
%%   Permission to use, copy, and distribute this software/file and its
%%   documentation for any purpose without permission by UNIVERSITAET OLDENBURG
%%   is not granted.
%%   
%%   Permission to use this software for academic purposes is generally
%%   granted.
%%
%%   Permission to modify the software is granted, but not the right to
%%   distribute the modified code.
%%
%%   This software is provided "as is" without expressed or implied warranty.
%%
%%   Author: Tobias Peters (tobias@medi.physik.uni-oldenburg.de)
%%
%%-----------------------------------------------------------------------------
