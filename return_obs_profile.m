% function [wv_obs,fl_obs]=return_obs_profile(fname,wv_shift,varargin);
%
% Take an observed Halpha profile from Chris and put it in a format
% that can be used by match_halpha_profile.m.
%
% Required Input:
%
% fname		(string) filename with observed profile.
%		Column 1 = wavelength
%		Column 2 = Relative Flux
%
% wv_shift	Shift to wavelength scale to be it into the star's
%		rest frame. Must be in Angstroms. Shift is *added*
%		to the wavelength scale.
%
% Varargin:
%
% WVunit	[1] Multiplicative constant to place wavelength scale in 
%		Angstroms, i.e. set to 10 if input in nm, 1 if in Ang.
%
% Vmax		[1000] Half-width of profile 'box' in km/s, i.e. default
%		gives the profile withing +/- 1000 km/s of line centre.
%
% Wv0		[6562.8] Line centre wavelength in Angstroms.
%
% Verbose	[1] screen output.
%
% DoPlot	[1] plot the extracted profile.
% 
%
% Example use: [wv_obs,fl_obs]=return_obs_profile('Halpha22718.txt',0.140,...
%                                        'WvUnit',10,'Verbose',1,'DoPlot',1);
%
% ASigut June 7, 2018.
%
function [wv_obs,fl_obs]=return_obs_profile(fname,wv_shift,varargin);

CKMS=physconst('ckms');

wvunit=1;
vmax=1000.0;
wv0=6562.8;
verbose=0;
doplot=0;

for i=1:2:length(varargin)

    switch lower(varargin{i})

    case 'verbose',
                   verbose=varargin{i+1};
    case 'doplot',
                   doplot=varargin{i+1};
    case 'wvunit',
                   wvunit=varargin{i+1};
    case 'vmax',
                   vmax=varargin{i+1};
    case 'wv0',
                   wv0=varargin{i+1};
    otherwise,
       disp(' ')
       disp(sprintf('WARNING: unknown varargin %s',varargin{i}))
       disp(' ')

    end
end

a=load(fname);

wv=a(:,1);
fl=a(:,2);

wv=wvunit.*wv;
wv=wv+wv_shift;

wv_min=wv0-(vmax/CKMS)*wv0;
wv_max=wv0+(vmax/CKMS)*wv0;

ind=find(wv>wv_min & wv<wv_max);

wv_obs=wv(ind);
fl_obs=fl(ind);

if verbose > 0
   disp(' ')
   disp(sprintf('wvunit = %6.2f',wvunit))
   disp(sprintf('wv0 = %10.3f wv_min = %10.3f wv_max=%10.3f',wv0,wv_min,wv_max))
   disp(sprintf('Npts = %5i',length(ind)))
   disp(' ')
end

if doplot > 0
   fh=figure;
   plot(wv_obs,fl_obs,'b-')
   hold('on')
   plot(wv_obs,fl_obs,'bo')
   hold('off')
   myfig_labels(fh,'Wavelength (Angstroms)','Relative Flux',14);
   title(fname,'FontWeight','Bold','FontSize',14)
end
   
