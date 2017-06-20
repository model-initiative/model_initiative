function [output, analyzer] = Gfb_Analyzer_process(analyzer, input)
% [output, analyzer] = Gfb_Filter_process(analyzer, input)
%
% The analyzer processes the input data.
%
% PARAMETERS
% analyzer A Gfb_Analyzer struct created from Gfb_Analyzer_new. The
%          analyzer will be returned (with updated filter states) as
%          the second return parameter
% input   A vector containing the input signal to process
% output  A matrix containing the analyzer's output signals.  The
%         rows correspond to the filter channels
%
% copyright: Universitaet Oldenburg
% author   : tp
% date     : Jan 2002

% filename : Gfb_Analyzer_process.m


if (analyzer.fast)
  % use a matlab/octave extension for fast computation.
  [output, analyzer] = Gfb_Analyzer_fprocess(analyzer, input);
else
  number_of_channels = length(analyzer.center_frequencies_hz);
  output = zeros(number_of_channels, length(input));
  for channel = [1:number_of_channels]
    filter = Gfb_Analyzer_get_filter(analyzer, channel);
    [output(channel,:), filter] = Gfb_Filter_process(filter, input);
    analyzer = Gfb_Analyzer_set_filter(analyzer, channel, filter);
  end
end
output = output';

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
