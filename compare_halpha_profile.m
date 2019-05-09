% function fom=compare_halpha_profile(wv_obs,fl_obs,wv,fl,mode)
%
% Compare an observed Halpha profile (wv_obs,fl_obs) (assumed continuum normalized)
% to the model profile (wv,fl). The model profile is spline interpolated onto
% the the observed wavelength scale for the ecomparison. Return a figure-of-merit 
% (smaller better) for the comparision. The fom is returned in percent, i.e. the
% raw fom is multiplied by 100.
%
% wv_obs	observed wavelength scale
% fl_obs	observed fluxes
% wv		model wavelength scale
% fl		model fluxes
% mode		-1 sum of square differences
%		 0 sum of absolute differences
%		 1 sum of square relative differences
%		 2 sum of absolute relative differences, wgt=1
%		 3 sum of absolute relative differences, "core" wgt=|F/Fc-1|
%
% fom		Returned Figure-of_Merit x100
%
% Currently no wavelength offset is implemented. This needs to be done for
% application to real data.
%
function fom=compare_halpha_profile(wv_obs,fl_obs,wv,fl,mode)

%
% Interpolate model line on the observed wavelength scale.
%
fl1=interp1(wv,fl,wv_obs,'spline');

switch mode
case -1
      fom=sum((fl_obs-fl1).^2);
case 0
      fom=sum(abs(fl_obs-fl1));
case 1
      fom=sum(((fl_obs-fl1).^2)./fl_obs);
case 2
      fom=sum(abs(fl_obs-fl1)./fl_obs);
case 3
      fc=0.5*(fl1(1)+fl1(end));
      wgt=abs(fl1./fc-1);
      fom=sum(wgt.*abs(fl_obs-fl1)./fl_obs);
      fom=fom/sum(wgt);
otherwise
      disp('ERROR(figure_of_merit): unknown method')
      fom=[];
end

%
% This will return [] if fom is null.
%
fom=fom*(100/length(wv_obs));

