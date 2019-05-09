% function [wv,fl]=profile_interp(flux_array,flux_grid,n0,rho0,rd0,i0,varargin)
%
% Interpolate a profile corresponding to model (n0,rho0,rd0,i0) in the
% Beray line profile array flux_array(:,:,:,:,:). Returns the full, 
% continuum normalized flux profile on a wavelength scale.
%
% Linear interpolation is the default. Nearest neighbour (good for
% testing) and cubic are available via varargin.
%
% Currently only a single model (n0,rho0,rd0,i0) can be requested.
%
% Interpolation is based on the Matlab interpn function. The default
% behavior of interpn is to return that NaNs for models outside 
% the defined grid.
%
% Input:
%
% flux_array	(:,:,:,:,:) Beray flux profile library built by 
%                  create_profile_array.m.
% flux_grid	Structure array describing the parameters of the 
%                  profile grid (also made by create_profile_array.m).
% n0		index n of requested model
% rho0		base disk density (in g/cm3) of requested model
% rd0		disk radius (in units of Rstar) of the requested model
% i0		system inclination (in degrees) of the requested model
%
% Varargin:
%
% Method	[1] =0 nearest, =1 linear, =2 cubic; anything else, linear
%
% Output:
%
% wv		(:) wavelengths in Angstroms
% fl		(:) continuum normalized, flux profile flux.
%
% Requires: physconst.m
%
% ASigut February 1, 2018
%
function [wv,fl]=profile_interp(flux_array,flux_grid,n0,rho0,rd0,i0,varargin)

interp_method=1;

for i=1:2:length(varargin)
    idone=0;
    if strcmp(varargin{i},'Method') == 1
       interp_method=varargin{i+1};
       idone=1;
    end
    if idone == 0
       disp(' ')
       disp(sprintf('WARNING(deredden): unknown varargin %s',varargin{i}))
       disp(' ')
    end
end

switch interp_method
case 0
       interp_string='nearest';
case 1
       interp_string='linear';
case 2
       interp_string='cubic';
otherwise
       disp('Unknown interpolation method: reverting to linear')
       interp_string='linear'
end

nfreq=length(flux_grid.wv);

x1=flux_grid.wv';
x2=flux_grid.n';
x3=flux_grid.rho';
x4=flux_grid.rd';
x5=flux_grid.i';

[X1,X2,X3,X4,X5]=ndgrid(x1,x2,x3,x4,x5);

xq1=flux_grid.wv;
xq2=n0*ones(1,nfreq);
xq3=log10(rho0).*ones(1,nfreq);
xq4=rd0.*ones(1,nfreq);
xq5=i0.*ones(1,nfreq);

%
% Be careful! Anything more than linear interp might lead to
% resources problems...
%
fl=interpn(X1,X2,X3,X4,X5,flux_array,xq1,xq2,xq3,xq4,xq5,interp_string);

%
% Return full normalized flux profile as a function of wavelength.
% Action depends on what is stored in flux_array.
%

if isempty(strfind(flux_grid.wvtype,'velocity'))

%
% All that is required is to normalize the profile.
%
   fc=0.5*(fl(1)+fl(end));
   fl=fl./fc;
   wv=x1;

else

   fl1=fl;
%
% Must (1) convert velocity into wavelength and (2) create the
% full profile from the stored half profile.
%
   cc_kms=physconst('CKMS');
   wv0=6562.757;
   wv1=wv0.*x1./cc_kms;

   ntot=2*nfreq-1;
   fl(nfreq:ntot)=fl1;
   wv(nfreq:ntot)=wv1;

   for n=1:nfreq-1
       m=nfreq-n+1;
       fl(n)=fl1(m);
       wv(n)=-wv1(m);
   end

   wv=(wv0+wv)';

end
