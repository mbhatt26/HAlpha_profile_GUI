% function [constantValue]=physconst(name)
% 
% Return numeric value in cgs units for named constant.
% An error is reported and null returned for unknown constants.
%
% Supported constants: c, ckms, h, k, g, me, amu, sig
%
% Request for an unlisted constant is treated as a fatal error.
%
% ASigut, The University of Western Ontario
% asigut@uwo.ca
%
function [constantValue]=physconst(name)

switch lower(name)

case 'c',
	constantValue=2.99792458e+10;

case 'ckms',
	constantValue=2.99792458e+5;

case 'h',
        constantValue=6.62606896e-27;

case 'k',
        constantValue=1.3806504e-16;

case 'g',
        constantValue=6.67259e-08;

case 'me',
        constantValue=9.10938215e-28;

case 'amu',
        constantValue=1.660538782e-24;

case 'sig',
        constantValue=5.670e-5;

otherwise
        constantValue=[];   
	error('Unknown physical constant: %s',lower(name))

end
