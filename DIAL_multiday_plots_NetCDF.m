clear all; close all;
tic

DIAL=1;
date = '01 Jul 2014'; % FRAPPE (no WS)
days = 50; skip = 5; % days to plot and days to skip ticks for plots
%date = '27 May 2015'; %PECAN (no WS)
%days =50; skip = 5; % days to plot and days to skip ticks for plots ** 'skip' must evenly divide into 'days'
date = '24 Apr 2017'; % Perdigao 
days = 55; skip = 5;
date = '15 May 2017'; % Perdigao 
days = 3; skip = 1;
date = '24 May 2017'; % Perdigao 
days = 10; skip = 2;
date = '27 Oct 2018'; % RELAMPAGO high data rate  
days = 20; skip = 2;
date = '16 Nov 2018'; % RELAMPAGO low data rate
days = 10; skip = 2;
date = '31 Oct 2018'; % RELAMPAGO high data rate  
days = 16; skip = 2;

%DIAL=2;
%date = '28 Jul 2017'; % DLB-HSRL and WV-DIAL @ LAFE 
%days = 40; skip = 4;
%date = '14 Aug 2017'; % DLB-HSRL and WV-DIAL @ LAFE 
%days = 3; skip = 1;
%date = '12 Oct 2017'; % DLB-HSRL and WV-DIAL @ LAFE 
%days = 21; skip = 3;
%date = '03 Jan 2018'; % DLB-HSRL and WV-DIAL post LAFE finalizing rack mounting
%days = 21; skip = 3;
%date = '05 Aug 2017'; % Perdigao 
%days = 10; skip = 2;

font_size = 36; % use this for 2018a version
%font_size = 14; % use this for 2015a version
%font_size = 16; % use this for 2015a version
%font_size = 28; % use this for 2014a version
WS = 1; % set to 1 for using the weather station data (after Jan 2016)

%include sonde data 0=off 1=on
sonde = 0;
%replot time vs range images at start of processing 0=off 1=on
replot = 1;
%save figures at end of processing 0=off 1=on
save_figs = 0;
%Wide field channel 0=off 1=on
near_field = 0;  % now the HSRL channel

%number of accumulations 
if datenum(date)>=datenum('16 Nov 2018')&& datenum(date)<=datenum('18 Dec 2018')
  accum = 32000; %  
  bin_duration = 500;  % ns 
  RB_scale = 1; % use to keep the arbitrary units of RB scale the same before
else
  accum = 14000; %this was changed before perdigao need to get the date
  bin_duration = 250;  % ns (this change from 50 to 500 on 14-June-2014)
  RB_scale = 1;
end
  
C = importdata('NCAR_C_Map.mat');
%C2 = importdata('NCAR_C2_Map.mat');
%cd('/Users/spuler/Desktop/FRAPPE_PECAN') % point to the directory where data is stored 
%cd('/Users/spuler/Desktop/WV_DIAL_data/') % point to the directory where data is stored 
%cd('/Volumes/documents/WV_DIAL_data/') % point to the directory where data is stored 
%cd('/Volumes/documents/WV_DIAL_data/processed_data_20min') % point to the directory where data is stored 
cd('/Volumes/documents/WV_DIAL_data/MPD1_processed_data') % point to the directory where data is stored 
%bin duration in ns


if DIAL==2
  cd('/Volumes/documents/WV_DIAL_data/MPD2_processed_data') % point to the directory where data is stored 
  bin_duration = 250;  % ns (this change from 500 to 250 for DIAL#2 on 2014)
  near_field = 1;  % now the HSRL channel
end

gate = round((bin_duration*1e-9*3e8/2)*10)/10


for i=1:days
  if i==1  
    if exist(strcat(date, '.mat'))==2
      load(strcat(date, '.mat'))
    end
    range_limit = size(N_avg,2);
    N_avg_FF=N_avg;
    RB_FF=RB;
    OD_FF=OD;
    background_FF_on = background_on;
    background_FF_off = background_off;
    lambda_FF_on = lambda_all;
    lambda_FF_off = lambda_all_off;
    duration=time_new;
    if WS==1
      surf_T = Surf_T;
      surf_P = Surf_P;
      surf_AH = Surf_AH;
      i_off = I_off;
      i_on = I_on;
      p_on = P_on;
      p_off = P_off;
      t_bench = T_bench;
    end
  else
    date = datestr(addtodate(datenum(date), 1, 'day'), 'dd mmm yyyy');
    if exist(strcat(date, '.mat'))==2
      load(strcat(date, '.mat'))
    end
    range_limit_ch = size(N_avg,2);
    if range_limit_ch < range_limit
        range_limit = range_limit_ch;
    end
    N_avg_FF = vertcat(N_avg_FF(:,1:range_limit), N_avg(2:end,1:range_limit));
    RB_FF = vertcat(RB_FF(:,1:range_limit), RB(2:end,1:range_limit));
    OD_FF= vertcat(OD_FF(:,1:range_limit), OD(2:end,1:range_limit));
    duration = vertcat(duration, time_new(2:end));
    background_FF_on = vertcat(background_FF_on, background_on(2:end));
    background_FF_off = vertcat(background_FF_off, background_off(2:end));
    lambda_FF_on = vertcat(lambda_FF_on, lambda_all(2:end));
    lambda_FF_off = vertcat(lambda_FF_off, lambda_all_off(2:end));
    if WS==1
      surf_T = vertcat(surf_T,Surf_T(2:end,:));
      surf_P = vertcat(surf_P,Surf_P(2:end,:));
      surf_AH = vertcat(surf_AH, Surf_AH(2:end,:));
      i_off = vertcat(i_off,I_off(2:end,:));
      i_on = vertcat(i_on, I_on(2:end,:));
      p_on = vertcat(p_on, P_on(2:end,:));  
      p_off = vertcat(p_off, P_off(2:end,:)); 
      t_bench = vertcat(t_bench, T_bench(2:end,:));  
    end
  end
end

%stop


scrsz = get(0,'ScreenSize');
size=[scrsz(4)/2 scrsz(4)/10 scrsz(3)/1 scrsz(4)/2];

if days == 1
  xData =  linspace(fix(min(duration)),  ceil(max(duration)), 25);
else
  xData =  linspace( fix(min(duration)),  ceil(max(duration)), round((ceil(max(duration))-fix(min(duration)))/skip)+1 );
 % xData =  linspace(fix(min(duration)),  round(max(duration)), 36);
end
x = (duration)';
y = (range(1:range_limit)./1e3);

if replot==1
 % plot Narrow water vapor in g/m^3
 figure('Position',size)
 Z = double(real(N_avg_FF'.*1e6./6.022E23.*18.015));  %number density in mol/cm3(1e6 cm3/m3)/(N_A mol/mole)*(18g/mole)
 % Z(isnan(Z)) = -1;
 set(gcf,'renderer','zbuffer');
 h = pcolor(x,y,Z);
 set(h, 'EdgeColor', 'none');
 colorbar('EastOutside');
 axis([fix(min(x)) ceil(max(x)) 0 6])
 caxis([0 18]);
 colormap(C)
 %colormap(perula)
 %shading interp
 % P_t = get(hh, 'Position');
 % set(hh,'Position', [P_t(1) P_t(2)+0.1 P_t(3)])
 ylabel('Height (km, AGL)','fontweight','b','fontsize',font_size); 
 set(gca, 'XTick',  xData)
 set(gca,'TickDir','out');
 set(gca,'TickLength',[0.005; 0.0025]);
 if days == 1
   datetick('x','HH:MM','keeplimits', 'keepticks');
   xlabel('Time (UTC)','fontweight','b','fontsize',font_size);
   hh = title({[date,'DIAL Water Vapor (g/m^{3})']},'fontweight','b','fontsize',font_size);
 else
   datetick('x','dd-mmm-yy','keeplimits', 'keepticks');
   hh = title({'DIAL Water Vapor (g/m^{3})'},'fontweight','b','fontsize',font_size);
 end
 set(gca,'Fontsize',font_size,'Fontweight','b');
 
 
 % plot Narrow RB
 figure('Position',size)
 %Z = double(log10((real(RB_FF')./RB_scale)));
 Z = double((real(RB_FF')./RB_scale));
 %Z_mask = Z;
 %Z_mask(RB_FF'<5) = NaN;
 % Z(isnan(Z)) = -1;
 set(gcf,'renderer','zbuffer');
 h = pcolor(x,y,Z);
%h = pcolor(x,y,Z_mask);
 set(h, 'EdgeColor', 'none');
 colorbar('EastOutside');
 axis([fix(min(duration)) ceil(max(duration)) 0 12])
 caxis([1e1 1e7]);
 colormap(C)
 %colormap(perula)
 %shading interp
 % P_t = get(hh, 'Position');
 % set(hh,'Position', [P_t(1) P_t(2)+0.2 P_t(3)])
 ylabel('Height (km, AGL)','fontweight','b','fontsize',font_size);
 set(gca, 'XTick',  xData)
 set(gca,'TickDir','out');
 set(gca,'TickLength',[0.005; 0.0025]);
 if days == 1
   datetick('x','HH:MM','keeplimits', 'keepticks');
   xlabel('Time (UTC)','fontweight','b','fontsize',font_size);
  % hh = title({[date,'DIAL Relative Backscatter (C/ns km^2)']},'fontweight','b','fontsize',font_size);
   hh = title({[date,'DIAL Attenuated Backscatter (A.U.)']},'fontweight','b','fontsize',font_size);
 else
   datetick('x','dd-mmm-yy','keeplimits', 'keepticks');
 %  hh = title({'DIAL Relative Backscatter (C/ns km^2)'},'fontweight','b','fontsize',font_size);
    hh = title({'DIAL Attenuated Backscatter (A.U.)'},'fontweight','b','fontsize',font_size);
 end
 set(gca,'Fontsize',font_size,'Fontweight','b');
set(gca,'Zscale', 'log')
set(gca,'Colorscale', 'log')
set(gca,'Zscale', 'linear')

 
% plot the background
  figure('Position',size)
  if near_field==1 
    len1= length(duration);
    len2 = length(background_FF_on);
    len3 = length(background_FF_off); % HSRL molecular channel

    len = vertcat(len1, len2, len3);
    plot_end = min(len);  
    semilogy(duration(1:plot_end), background_FF_on(1:plot_end), 'r', duration(1:plot_end), background_FF_off(1:plot_end), 'k') 
  else
    semilogy(duration, background_FF_off, 'black')
  end
  axis([fix(min(duration)) ceil(max(duration)) 1e2 1e7])
  ylabel('Offline background C/s', 'Fontsize', font_size, 'Fontweight', 'b');  
  grid on
  %hold on
  %  semilogy(duration, 5e6, 'green', 'Linewidth', 2)    % Add a horizontal line to show the 5Mc/s linearity limit
  %hold off
  if near_field==1  
  legend('WV Online  ', 'WV Offline  ', 'HSRL molecular  ', 'HSRL combined  ','Location', 'NorthWest');
  else
   legend('WV Online  ', 'WV Offline  ', 'Location', 'NorthWest');
  end
  set(gca, 'XTick',  xData)
  set(gca,'TickDir','out');
  set(gca,'TickLength',[0.005; 0.0025]);
  if days == 1
    datetick('x','HH:MM','keeplimits', 'keepticks');
    xlabel('Time (UTC)','fontweight','b','fontsize',font_size); 
    hh = title({[date,'Background']},'fontweight','b','fontsize',font_size);
  else
    datetick('x','dd-mmm-yy','keeplimits', 'keepticks');
    hh = title({'DIAL Background'},'fontweight','b','fontsize',font_size); 
  end
  set(gca,'Fontsize',font_size,'Fontweight','b');
  
  
% plot column OD for the Narrow  
  figure('Position',size)
  Z = double(real(OD_FF'));
  set(gcf,'renderer','zbuffer');
  h = pcolor(x,y,Z);
  set(h, 'EdgeColor', 'none');
  colorbar('EastOutside');
  axis([fix(min(duration)) ceil(max(duration)) 0 12])
  caxis([-0.1 2]);
  colormap(C)
  title({('  Column Optical Depth, Narrow Field  ')},...
       'fontweight','b','fontsize',font_size)
  xlabel('Time (UTC)','fontweight','b','fontsize',font_size); 
  ylabel('Height (km, AGL)','fontweight','b','fontsize',font_size); 
  set(gca, 'XTick',  xData)
  set(gca,'TickDir','out');
  set(gca,'TickLength',[0.005; 0.0025]);
  if days == 1
    datetick('x','HH:MM','keeplimits', 'keepticks');
    xlabel('Time (UTC)','fontweight','b','fontsize',font_size); 
  else
    datetick('x','dd-mmm-yy','keeplimits', 'keepticks');
  end
  set(gca,'Fontsize',font_size,'Fontweight','b');

  
  plot1 = OD_FF(:,round(2500/gate));
  plot2 = OD_FF(:,round(5000/gate));
  %window = ones(1,1)/1;
  %plot1s = filter2(window, plot1);
  %plot2s = filter2(window, plot2);
  dd = pwd; % get the current path
  cd('/Users/spuler/Desktop/WV_DIAL/Matlab/')
    plot1s = ndnanfilter(plot1,'rectwin', 20); 
    plot2s = ndnanfilter(plot2,'rectwin', 20);
  cd(dd)
  
% plot column optical depth at 5km and 2.5km as function of time
  figure('Position',size)
  plot(duration, plot1s, 'b',duration, plot2s, 'k', 'LineWidth', 2)
  axis([fix(min(duration)) ceil(max(duration)) 0 2.5])
  ylabel('OD', 'Fontsize', font_size, 'Fontweight', 'b');
  grid on
  legend('OD at 2.5km', 'OD at 5.0km','Location', 'NorthWest');
  set(gca, 'XTick',  xData)
  set(gca,'TickDir','out');
  set(gca,'TickLength',[0.005; 0.0025]);
  if days == 1
    datetick('x','HH:MM','keeplimits', 'keepticks');
    xlabel('Time (UTC)','fontweight','b','fontsize',font_size); 
    hh = title({[date,'DIAL Column OD']},'fontweight','b','fontsize',font_size);
  else
    datetick('x','dd-mmm-yy','keeplimits', 'keepticks');
       hh = title({'DIAL Column OD'},'fontweight','b','fontsize',font_size); 
  end
  set(gca,'Fontsize',font_size,'Fontweight','b');
  
 if WS==1
 % plot housekeeping data
   figure1 = figure('Position',size);
   subplot1=subplot(2,1,1,'Parent',figure1,'YGrid','on', 'XGrid','on');
   box(subplot1,'on');
   hold(subplot1,'all');
  % plot(duration, (i_off),'b','LineWidth',2,'DisplayName','i_{off}') % these plot diode Temps
  % plot(duration, (i_on),'r','LineWidth',2, 'DisplayName','i_{on}')
%   plot(duration, (t_hsrl),'g','LineWidth',2, 'DisplayName','T_{hsrl}')
   axis([fix(min(duration)) ceil(max(duration)) -inf inf])
   YTick = [100 120 140 160 180];
   ylabel('seed Temp, C', 'Fontsize', font_size, 'Fontweight', 'b');  
   datetick('x','dd-mmm-yy','keeplimits', 'keepticks');
   set(gca,'Fontsize',font_size,'Fontweight','b');
   % Plot the temperature data
   subplot2=subplot(2,1,2,'Parent',figure1,'YGrid','on', 'XGrid','on');
   box(subplot2,'on');
   hold(subplot2,'all');
   %plot(duration, T_bench,'r', 'LineWidth',1, 'DisplayName','T bench')
   plot(duration, surf_T, 'b', 'LineWidth',1, 'DisplayName','Surface T')
   axis([fix(min(duration)) ceil(max(duration)) -inf inf]);   % -20 40])
      YTick = [-25 0 25 50];
   ylabel('temperature, C', 'Fontsize', font_size, 'Fontweight', 'b'); 
   datetick('x','dd-mmm-yy','keeplimits', 'keepticks');
   set(gca,'Fontsize',font_size,'Fontweight','b');
   % Create legend
   legend(subplot1,'show'); 
   legend(subplot2,'show');
   %link the x axis for all 3 subplots
   ax(1)=subplot(2,1,1);
   ax(2)=subplot(2,1,2);
   % plot power on right y-axis of the upper plot (% assumes 5% pickoff)
   ax(3) = axes('Position',get(ax(1),'Position'));
   plot(duration, (p_off/1000),'b--','LineWidth', 1, 'DisplayName','P_{off}') % changed from 0.05 to 0.0425
   hold on
   plot(duration, p_on/1000,'r--', 'LineWidth',1, 'DisplayName','P_{on}')
   %plot(duration, p_hsrl/2500,'g--', 'LineWidth',1, 'DisplayName','P_{hsrl}')
   axis([fix(min(duration)) ceil(max(duration)) -inf inf])
   %ax(3).YTick = [20 22.5 25 27.5 30 32.5 35 37.5 40];
   set(ax(3),'Color','none')
   set(ax(3),'YAxisLocation','right')
   set(ax(3),'XAxisLocation','bottom')
   datetick('x','dd-mmm-yy','keeplimits', 'keepticks');
   ylabel('transmitted energy, uJ', 'Fontsize', font_size, 'Fontweight', 'b');  
   set(gca,'Fontsize',font_size,'Fontweight','b');
   legend('show')
   set(legend(ax(3)),'Color','white')
   %change backgroud color to transparent
   
   % plot Surface pressure right y-axis of the lower plot
   ax(4) = axes('Position',get(ax(2),'Position'));
   plot(duration, surf_P, 'b--','LineWidth', 1, 'DisplayName','Surf P') 
   axis([fix(min(duration)) ceil(max(duration)) -inf inf])
   set(ax(4),'Color','none')
   set(ax(4),'YAxisLocation','right')
   set(ax(4),'XAxisLocation','bottom')
   datetick('x','dd-mmm-yy','keeplimits', 'keepticks');
   ylabel('surface pressure, atm', 'Fontsize', font_size, 'Fontweight', 'b');  
   set(gca,'Fontsize',font_size,'Fontweight','b');
   legend('show')
   set(legend(ax(3)),'Color','white')
   %change backgroud color to transparent
      
   legend(ax(1),'Location','NorthWest') 
   legend(ax(2),'Location','NorthWest') 
   linkaxes(ax, 'x');
   hold off;
 end
 
 
 
 
if save_figs==1
  %cd('/Users/spuler/Desktop/WV_DIAL_data/plots/') % point to the directory where data is stored 
  cd('/Volumes/documents/WV_DIAL_data/plots/') % point to the directory where data is stored 
  date=datestr(nanmean(time_new), 'yyyymmdd');
  
  %size = [scrsz(4)/2 scrsz(4)/10 scrsz(3)/1 scrsz(4)/2]; % use for standard plots
  size = [scrsz(4)/1 scrsz(4)/1 scrsz(3)/0.35 scrsz(4)/2.05]; % use for long plots 
  %size = [scrsz(4)/1 scrsz(4)/1 scrsz(3)/0.51 scrsz(4)/2]; % use for Perdigao BAMS plots 
  %size = [scrsz(4)/1 scrsz(4)/1 scrsz(3)/2 scrsz(4)/2]; % use for day plots 
  %size = [scrsz(4)/1 scrsz(4)/1 scrsz(3)/1 scrsz(4)/2.2]; % use for AMT sized 3-day plots (with large font)
  
  FigH = figure(1);
%  set(gca,'Fontsize',36,'Fontweight','b'); % use for Perdigao BAMS plots 
  set(FigH, 'PaperUnits', 'points', 'PaperPosition', size);
  name=strcat(date, 'H2O_multi'); 
  print(FigH, name, '-dpng', '-r300') % set the resolution as 300 dpi
 
  FigH = figure(2);
 % set(gca,'Fontsize',36,'Fontweight','b'); % use for Perdigao BAMS plots 
  set(FigH, 'PaperUnits', 'points', 'PaperPosition', size);
  name=strcat(date, 'RB_multi'); 
  print(FigH, name, '-dpng', '-r300') % set the resolution as 300 dpi;
  
  FigH = figure(3);
 % set(gca,'Fontsize',36,'Fontweight','b');
  set(FigH, 'PaperUnits', 'points', 'PaperPosition', size);
  name=strcat(date, 'background_multi'); 
  print(FigH, name, '-dpng', '-r300') % set the resolution as 300 dpiFigH = figure(1);
  
  FigH = figure(5);
 %  set(gca,'Fontsize',36,'Fontweight','b');
  set(FigH, 'PaperUnits', 'points', 'PaperPosition', size);
  name=strcat(date, 'column_OD_multi'); 
  print(FigH, name, '-dpng', '-r300') % set the resolution as 300 dpiFigH = figure(1);
  
  if WS==1
      size2 = [scrsz(4)/1 scrsz(4)/1 scrsz(3)/0.35 scrsz(4)/1]; % use for long plots 
      FigH = figure(6);
     % set(gca,'Fontsize',36,'Fontweight','b');
      set(FigH, 'PaperUnits', 'points', 'PaperPosition', size2);
      name=strcat(date, 'Housekeeping'); 
      print(FigH, name, '-dpng', '-r300') % set the resolution as 300 dpiFigH = figure(1);
  end
   
end
 
  name=strcat(date, '_WV_2CH'); 
 
end


 

 
toc
