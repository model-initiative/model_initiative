function analyzer = Gfb_Analyzer_set_filter(analyzer, channelnumber, filter)
% analyzer = Gfb_Analyzer_set_filter(analyzer, channelnumber, filter)
%
% This is a private method to portably assign a filter to a channel
% of the analyzer.  It should only be called by other methods of
% Gfb_Analyzer.
%
% copyright: Universitaet Oldenburg
% author   : tp
% date     : Jan 2002

% filename : Gfb_Analyzer_set_filter.m


if (exist('OCTAVE_VERSION'))
  % octave does not provide structure arrays
  analyzer.filters.type     = 'structure_array';
  eval(['analyzer.filters.filter', num2str(channelnumber), '=filter;']);
else
  analyzer.filters(1, channelnumber) = filter;
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
