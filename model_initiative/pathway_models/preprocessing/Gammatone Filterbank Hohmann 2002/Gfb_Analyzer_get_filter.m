function [filter, analyzer] = ...
      Gfb_Analyzer_get_filter(analyzer, channelnumber)
% [filter, analyzer] = Gfb_Analyzer_get_filter(analyzer, channelnumber)
%
% This is a private method to portably access the filter of a channel
% of the analyzer. It should only be called by other methods of
% Gfb_Analyzer.
%
% copyright: Universitaet Oldenburg
% author   : tp
% date     : Jan 2002

% filename : Gfb_Analyzer_get_filter.m


if (exist('OCTAVE_VERSION'))
  % octave does not provide structure arrays
  eval(['filter = analyzer.filters.filter', num2str(channelnumber), ';']);
else
  filter = analyzer.filters(1, channelnumber);
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
