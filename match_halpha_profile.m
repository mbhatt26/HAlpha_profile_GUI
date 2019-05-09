% function [pbest,models_save]=match_halpha_profile(mode,wv_obs,fl_obs,flux_array,flux_grid,varargin)
%
% Match a Halpha line profile using the line profile library flux_array.
%
% Input:
%
% mode		0 search over entire library grid (specified by flux_grid)
%        	1 custom grid search-- see 'SearchGrid' varargin
%        	2 custom grid search followed by fmincon
% 		3 fmincon search only starting see 'X0' varargin or default
%		4 ga search: not tested or optimized
%
% wv_obs	wavelength scale of observed line
% fl_obs	relative flux profile of observed line
% flux_aaray	5-D profile library
% flux_grid	structure array description of library profile
%
% varargin:
%
% 'SearchGrid'	[struct] user defined search grid
% 'X0'		(n,rho0,Rd,i) start point for fmincon
% 'UB'		upper bounds in (n,rho0,Rd,i)
% 'LB'		lower bounds in (n,rho0,Rd,i)
% 'InterpMeth'  [1] 0=nearest, 1=linear, 2=cubic
% 'Verbose'	[0] control screen output
% 'DoPlot'	[0] produce plot of best-fit profile
% 'FOM'		[2] Figure-of-merit to use (see compare_halpha_profile.m)
%
% Output:
%
% pbest		(n,rho0,Rd,i) parameters of best-fit profile
% models_save	structure array of FoM and parameters of all models
%               considered. This will null in the case of a non-linear
%               minimzation search on FoM but will contain all of the
%               searched models in the case of a grid search.
%
% Requires: profile_interp.m, compare_halpha_profile.m
%
% Notes:
%
% Typical Uses:
%
% ASigut Febraury 5, 2018. 13 March 2018
%
function [pbest,models_save]=match_halpha_profile(mode,wv_obs,fl_obs,flux_array,flux_grid,varargin)

pbest=[];
models_save.fom=[];
models_save.i=[];
models_save.n=[];
models_save.rd=[];
models_save.lrho=[];

if mod(length(varargin),2) ~= 0
  disp(' ')
  disp('Error(match_halpha_profile): mis-match (odd number) of vargargin inputs')
  disp(' ')
  return
end

verbose=0;
do_plot=0;
fom_type=2;

%
% Default parameters for custom grid search... Specify a very minimal grid by
% default as this option will usually be followed by fmincon refinement. Unclear
% if the "Big" grid actually works better ...
%
% "Big" 1500 models
%
%user_grid.n=[1.50 2.00 2.50 3.00 3.50 4.00];
%user_grid.rd=[5 15 20 35 50];
%user_grid.lrho=log10([1.00e-12 5.00e-12 1.00e-11 5.00e-11 1.00e-10]);
%user_grid.i=[0:10:90];
% 
% "Small" 135 models
%
user_grid.n=[1.50 2.50 3.50];
user_grid.rd=[5 20 50];
user_grid.lrho=log10([1.00e-12 1.00e-11 1.00e-10]);
user_grid.i=[10 30 50 70 90];

%
% Default parameters for fconmin and ga...
%
x0_start=[2.5 -11.0 25.0 54.0];
ub=[4.0 log10(2.50e-10) 50.0 90.0];
lb=[1.5 log10(1.00e-12)  5.0  0.0];

%
% Default to linear interpolation.
%
interp_method=1;

for i=1:2:length(varargin)

    switch lower(varargin{i})
      case 'verbose',
         verbose=varargin{i+1};
      case 'doplot',
         do_plot=varargin{i+1};
      case 'searchgrid',
         user_grid=varargin{i+1};
      case 'x0',
         x0_start=varargin{i+1};
      case 'ub',
         ub=varargin{i+1};
      case 'lb',
         lb=varargin{i+1};
      case 'interpmeth',
         interp_method=varargin{i+1};
      case 'fom',
         fom_type=varargin{i+1};
      otherwise,
         disp(sprintf('WARNING(match_halpha_profile): unknown varargin %s',varargin{i}))
      end

end

if mode <= 2

   disp(' ')

   if mode == 0
      disp('Grid search at computed grid resolution')
      grid.i=flux_grid.i;
      grid.n=flux_grid.n;
      grid.lrho=flux_grid.rho;
      grid.rd=flux_grid.rd;
%
% Want to ensure only the computed lirary profiles are used... set 
% interpolation method to nearest grid point.
%
      interp_method=0;
   elseif mode == 1
%     disp('Grid search at computed custom grid resolution')
      grid=user_grid;
   else
%     disp('Grid search at computed custom grid resolution followed by fmincon')
      grid=user_grid;
   end

   ntot=length(grid.i)*length(grid.n)*length(grid.lrho)*length(grid.rd);

%  disp(sprintf('Total number of models searched and returned = %i',ntot))

   disp(' ')

   nmod=0;
   fom_best=3e+33;

   for ip=grid.i
    for np=grid.n
        for rdp=grid.rd
            for lrhop=grid.lrho

                rhop=10^lrhop;
                [wv,fl]=profile_interp(flux_array,flux_grid,np,rhop,rdp,ip,'Method',interp_method);
                fom=compare_halpha_profile(wv_obs,fl_obs,wv,fl,fom_type);
               
                if fom < fom_best
                   fom_best=fom;
%
% Store the best parameters in case these is a fmincon restart.
%
                   pbest=[np rhop rdp ip];
                end

                nmod=nmod+1;
%               if mod(nmod,100) == 0 & verbose > 0
%                  disp(sprintf('Processed up to model %i',nmod))
%               end
%
% Save the results for all models ...
%
                models_save(nmod).fom=fom;
                models_save(nmod).i=ip;
                models_save(nmod).lrho=lrhop;
                models_save(nmod).rd=rdp;
                models_save(nmod).n=np;

            end
        end
     end
   end

end

if mode <= 3

   if verbose > 0
%     disp(' ')
%     disp('      fmincon minimization')
%     disp(' ')
   end
%
% Start from the best point from the grid search if requested.
%
   if mode == 2
      x0_start=pbest;
      x0_start(2)=log10(x0_start(2));
      disp(sprintf('      Starting from previous grid search: %7.2f %7.2f %7.2f %7.2f',...
         x0_start(1),x0_start(2),x0_start(3),x0_start(4)))
   end

   if verbose > 1
      options=optimoptions('fmincon','Display','iter');
   else 
      options=optimoptions('fmincon','Display','off');
   end

   [x,fval,exitflag,output]=fmincon(@fom_profile,x0_start,[],[],[],[],lb,ub,[],options);

   fom_best=fval;

   pbest=[x(1) 10.^x(2) x(3) x(4)];

   clear('models_save');

   models_save.fom=fval;
   
else

   if verbose > 0
      disp(' ')
      disp('Genetic minimization')
      disp(' ')
   end

   nvars=4;

   if verbose > 1
      options=optimset('Display','iter');
   else
      options=optimset('Display','off');
   end

   [x,fval,exitflag,output]=ga(@fom_profile,nvars,[],[],[],[],lb,ub,[],[],options);

   fom_best=fval;

   pbest=[x(1) 10.^x(2) x(3) x(4)];

end

if verbose > -1
   disp(' ')
   disp(sprintf('      Best-fit fom = %9.3e  n = %5.2f rho0 = %10.3e Rd = %6.2f i = %7.2f',...
     fom_best,pbest(1),pbest(2),pbest(3),pbest(4)))
   disp(' ')
end

if do_plot > 0
   fighand=figure;
   plot(wv_obs,fl_obs,'ko','MarkerSize',6,'MarkerFaceColor',0.9.*[1 1 1])
   hold('on')
   [wv,fl]=profile_interp(flux_array,flux_grid,pbest(1),pbest(2),pbest(3),pbest(4));
   plot(wv,fl,'r-','LineWidth',2.0)
   hold('off')
   myfig_labels(fighand,'Wavelength (Ang)','Relative Flux',16);
end

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Internal function for the profile fit...
%
  function fom=fom_profile(x)

           ntry=x(1);
           rhotry=10.^x(2);
           rdtry=x(3);
           itry=x(4);

           [wv,fl]=profile_interp(flux_array,flux_grid,ntry,rhotry,rdtry,itry,'Method',2);
           fom=compare_halpha_profile(wv_obs,fl_obs,wv,fl,fom_type);

  end

end
