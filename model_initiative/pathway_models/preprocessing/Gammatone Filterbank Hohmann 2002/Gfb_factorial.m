function ftl = Gfb_factorial(n)
% Gfb_factorial(n)
%
% computes the factorial of the non-negative integer argument. This function
% exists for compatibility with octave, which lacks a "factorial" function
%
% copyright: Universitaet Oldenburg
% author   : tp
% date     : Jan 2002

% filename : Gfb_factorial.m


if (exist('OCTAVE_VERSION'))
  % octave does not have a factorial function
  ftl = prod(1:n);
else
  ftl = factorial(n);
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
