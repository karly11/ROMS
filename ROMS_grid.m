%%
clear all

cd('/Volumes/karly/ROMS_Project/ECCO2')
fname = 'SSS_20120101T000000.nc';
xlon_ecco = ncread(fname,'LONGITUDE');
ylat_ecco = ncread(fname,'LATITUDE');

D = dir('*.nc');
nfile = length(D);
x_sfv = [2.5:10:357.5]; %2.5
y_sfv = [0]; %[-60:5:55];  %2.5
footprint = [100:-10:20];
    
sfv = NaN*ones(length(x_sfv),length(y_sfv),nfile,length(footprint));

% nfile=1;
tic

for ifile=1:nfile
    ifile
    fname = D(ifile).name;
    sss = ncread(fname,'SSS');
    indx=find(sss<-1.e20);
    sss(indx) = NaN;
    for ifoot=1:length(footprint)
        ifoot
        d0 = footprint(ifoot);
        for iy=1:length(y_sfv)
            iy
            xgrid = 180; ygrid = y_sfv(iy);
    %         [~,igridx] = min(abs(xgrid-xlon_ecco));
    %         [~,igridy] = min(abs(ygrid-ylat_ecco));
            [~,ix1] = min(abs((xgrid-1)-xlon_ecco));
            [~,iy1] = min(abs((ygrid-1)-ylat_ecco));
            [~,ix2] = min(abs((xgrid+1)-xlon_ecco));
            [~,iy2] = min(abs((ygrid+1)-ylat_ecco));
            xvec = xlon_ecco(ix1:ix2);
            yvec = ylat_ecco(iy1:iy2);
             wts = zeros(length(xvec),length(yvec));
            clear ix1 iy1
            for ix1=1:length(xvec)
                for iy1=1:length(yvec)
                    d = distance(xgrid,ygrid,xvec(ix1),yvec(iy1),6371);             
                    if (d<=d0)
                        wts(ix1,iy1) = exp( ...
                            -log(2)*(d / d0)^2);
                    end
                end
            end
            [~,iy1] = min(abs((ygrid-1)-ylat_ecco));
            [~,iy2] = min(abs((ygrid+1)-ylat_ecco));
            for ix=1:length(x_sfv)
                xgrid = x_sfv(ix);
                [~,ix1] = min(abs((xgrid-1)-xlon_ecco));
                [~,ix2] = min(abs((xgrid+1)-xlon_ecco));
                sss1 = sss(ix1:ix2,iy1:iy2,1);
                sfv(ix,iy,ifile,ifoot) = (std(sss1(:),wts(:))^2);
            end
        end 
    end
end
toc


%% Median and 95th Percentile

med = NaN*ones(length(x_sfv),length(y_sfv),length(footprint));
per95 = NaN*ones(length(x_sfv),length(y_sfv),length(footprint));


for ifoot=1:length(footprint)
    for iy=1:length(y_sfv)
        for ix=1:length(x_sfv)
%             junk = sort(sfv(find(~isnan(sfv(ix,iy,:,ifoot)))));
            med(ix,iy,ifoot) = median(squeeze(sfv(ix,iy,:,ifoot)),'omitnan');
            per95(ix,iy,ifoot) = prctile(squeeze(sfv(ix,iy,:,ifoot)),95);
        end
   end 
end
           

%% Scatter Plot

figure(1)

hold off
for ifoot=1:length(footprint)
    for iy=1:length(y_sfv)
        for ix=1:length(x_sfv)
%             for ifile=1:length(nfile)
                plot(footprint,squeeze(sfv(1,1,1,:))','k')
                hold on
%             end
        end
   end 
end

figure(2)

hold off
for ifoot=1:length(footprint)
    for iy=1:length(y_sfv)
        for ix=1:length(x_sfv)
            scatter(footprint,squeeze(med(1,1,:))','m')
            hold on
            scatter(footprint,squeeze(per95(1,1,:))','b')
            hold on
        end
   end 
end


%% Contour

figure(3)

contourf(squeeze(x_sfv,y_sfv,sfv,footprint))
colorbar
xlabel('\circE','fontsize',18)
ylabel('\circN','fontsize',18)
text(-125,10,'C','horizontalalignment','center','verticalalignment','middle','fontsize',18,'color','r')

%%
% [ax, p1, p2] = plotyy(y_sfv,per95(36,:),y_sfv,med(36,:),'scatter');
% line(y_sfv,per95(36,:))
% line(y_sfv,med(36,:),'Parent',ax(2))
% blue=[0 0 1];
% green=[0 1 0];
% set(p1,'cdata',green)
% set(p2,'cdata',blue)
% set(ax(1),'ycolor',green)
% set(ax(2),'ycolor',blue)
% ylabel(ax(1),'95th Percentile')
% ylabel(ax(2),'Median')
% xlabel('Footprint')
% 
% scatter(per95(:,:,1));
% hold on
% scatter(med);
% hold(ax(1),'on')
% scatter(ax(1),y_sfv,per95(36,:));
% hold(ax(2),'on')
% scatter(ax(2),y_sfv,med(36,:)) 
% hold on
% [ax,p1,p2] = plotyy(polyfit(y_sfv,per95(36,:),1),polyfit(y_sfv,med(36,:)));
% scatter(y_sfv,per95(36,:),'g','*')
% hold on
% scatter(y_sfv,med(36,:),'b','x')
% 
% hold(ax(1),'on')
% scatter(ax(1),y_sfv,per95(36,:));
% hold(ax(2),'on')
% scatter(ax(2),y_sfv,med(36,:)) 
