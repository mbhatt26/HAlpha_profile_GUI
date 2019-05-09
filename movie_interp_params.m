function movie_interp_params(flux_array,flux_grid,Movie_Name);

if nargin == 2
   Movie_Name=[];
end

if ~isempty(Movie_Name)
   make_movie=1;
else
   make_movie=0;
end

Fmax=6;

n0=2.5;
rho0=5.0e-11;
rd0=25.0;
i0=60;
[wv_ref,fl_ref]=profile_interp(flux_array,flux_grid,n0,rho0,rd0,i0);

fh=figure(1);

nframe=0;

for ip=0:2:95
    i=min(ip,90);
    [wv,fl]=profile_interp(flux_array,flux_grid,n0,rho0,rd0,i);
    plot(wv,fl,'ko','MarkerFaceColor',0.8.*[1 1 1]) 
    hold('on')
    plot(wv,fl,'k-','LineWidth',2) 
    plot(wv_ref,fl_ref,'k:','LineWidth',1) 
    hold('off')
    text(0.1,0.9,['i=',num2str(i)],'sc','FontWeight','Bold')
    axis([6550 6575 0 Fmax])
    myfig_labels(fh,'Wavelength','Flux',16,'Title','Inclination')
    pause(0.1)
    if make_movie==1
       nframe=nframe+1;
       F(nframe)=getframe(gcf);
    end
end

pause(2.0)

for np=1.5:0.10:4.5
    n=min(np,4.0);
    [wv,fl]=profile_interp(flux_array,flux_grid,n,rho0,rd0,i0);
    plot(wv,fl,'ko','MarkerFaceColor',0.8.*[1 1 1]) 
    hold('on')
    plot(wv,fl,'k-','LineWidth',2) 
    plot(wv_ref,fl_ref,'k:','LineWidth',1) 
    hold('off')
    text(0.1,0.9,['n=',num2str(n)],'sc','FontWeight','Bold')
    axis([6550 6575 0 Fmax])
    myfig_labels(fh,'Wavelength','Flux',16,'Title','Index n')
    pause(0.1)
    if make_movie==1
       nframe=nframe+1;
       F(nframe)=getframe(gcf);
    end
end

pause(2.0)

for rdp=5:1:55.0
    rd=min(rdp,50);
    [wv,fl]=profile_interp(flux_array,flux_grid,n0,rho0,rd,i0);
    plot(wv,fl,'ko','MarkerFaceColor',0.8.*[1 1 1]) 
    hold('on')
    plot(wv,fl,'k-','LineWidth',2) 
    plot(wv_ref,fl_ref,'k:','LineWidth',1) 
    hold('off')
    text(0.1,0.9,['Rd=',num2str(rd)],'sc','FontWeight','Bold')
    axis([6550 6575 0 Fmax])
    myfig_labels(fh,'Wavelength','Flux',16,'Title','Disk Size')
    pause(0.1)
    if make_movie==1
       nframe=nframe+1;
       F(nframe)=getframe(gcf);
    end
end

pause(2.0)

for lrhop=-12.0:0.1:-9.1
    lrho=min(-9.6,lrhop);
    rho=10^lrho;
    [wv,fl]=profile_interp(flux_array,flux_grid,n0,rho,rd0,i0);
    plot(wv,fl,'ko','MarkerFaceColor',0.8.*[1 1 1]) 
    hold('on')
    plot(wv,fl,'k-','LineWidth',2) 
    plot(wv_ref,fl_ref,'k:','LineWidth',1) 
    hold('off')
    text(0.1,0.9,['log(rho)=',num2str(lrho)],'sc','FontWeight','Bold')
    axis([6550 6575 0 Fmax])
    myfig_labels(fh,'Wavelength','Flux',16,'Title','Density')
    pause(0.1)
    if make_movie==1
       nframe=nframe+1;
       F(nframe)=getframe(gcf);
    end
end

%
% Output the movie if requested.
if make_movie==1
   clf;
   movie(F);
   movie_file_name=[Movie_Name,'.avi'];
   disp(' ')
   disp(sprintf('Writing movie %s',movie_file_name));
   disp(' ')
   v=VideoWriter(movie_file_name,'Uncompressed AVI');
   v.FrameRate=5;
   open(v);
   writeVideo(v,F);
   close(v);
end
