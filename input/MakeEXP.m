clear; clc;

%% ================= 路径 =================
INDIR = 'M:\NCEP NCAR Reanalysis\';
OPDIR = 'M:\CMEMS_glorys12v1\monthly\make_files\';

if ~exist(OPDIR,'dir'); mkdir(OPDIR); end

%% ================= MITgcm 网格 =================
dx = 1/12; dy = 1/12;
x0 = 100; y0 = -20;
mx = 2280; my = 600;

lon_new = x0 + dx*(0:mx-1);
lat_new = y0 + dy*(0:my-1);

nt =360;
%% ================= 文件列表 =================
% fn2 = fullfile(INDIR,'dlwrf.sfc.mon.mean_1948_2025.nc');
% fn3 = fullfile(INDIR,'dswrf.sfc.mon.mean_1948_2025.nc');
% fn4 = fullfile(INDIR,'ulwrf.sfc.mon.mean_1948_2025.nc');
% fn5 = fullfile(INDIR,'uswrf.sfc.mon.mean_1948_2025.nc');

fn1 = fullfile(INDIR,'air.2m.mon.mean_1948_2025.nc');
fn6 = fullfile(INDIR,'uwnd.10m.mon.mean_1948_2025.nc');
fn7 = fullfile(INDIR,'vwnd.10m.mon.mean_1948_2025.nc');
fn8 = fullfile(INDIR,'prate.mon.mean_1948_2025.nc');
fn9 = fullfile(INDIR,'shum.2m.mon.mean_1948_2025.nc');

% nlwrs_fff = nan(mx,my,nt);
% nswrs_fff = nan(mx,my,nt);

atemp_fff = nan(mx,my,nt);
shum_fff  = nan(mx,my,nt);
uwnd_fff  = nan(mx,my,nt);
vwnd_fff  = nan(mx,my,nt);
prt_fff   = nan(mx,my,nt);

% ================ 读网格 =================
lon = double(ncread(fn1,'lon'));
lat = double(ncread(fn1,'lat'));

% ================ 读数据 =================
% dlw = single(ncread(fn2,'dlwrf'));
% dsw = single(ncread(fn3,'dswrf'));
% ulw = single(ncread(fn4,'ulwrf'));
% usw = single(ncread(fn5,'uswrf'));

airt = single(ncread(fn1,'air'));
uwnd = single(ncread(fn6,'uwnd'));
vwnd = single(ncread(fn7,'vwnd'));
prt = single(ncread(fn8,'prate'));
shum = single(ncread(fn9,'shum'));

%% ================= 处理 ================    
% nlw = ulw(:,:,541:900) - dlw(:,:,541:900); 
% nsw = usw(:,:,541:900) - dsw(:,:,541:900); 
airt = airt(:,:,541:900); 
uwnd = uwnd(:,:,541:900); 
vwnd = vwnd(:,:,541:900); 
shum = shum(:,:,541:900); 
prt = prt(:,:,541:900)/1000.0; 
clear ulw dlw usw dsw

% nsw_f = flip(nsw,2);
% nlw_f = flip(nlw,2);
airt_f = flip(airt,2);
uwnd_f = flip(uwnd,2);
vwnd_f = flip(vwnd,2);
shum_f = flip(shum,2);
prt_f = flip(prt,2);

lat1 = flip(lat);
[x1, y1] = meshgrid(lon, lat1);
[x2, y2] = meshgrid(lon_new, lat_new);

for tt= 1:nt
    tt
    % 线性插值    
%     nlw_ff = interp2(x1, y1,nlw_f(:,:,tt)',x2, y2,'linear');
%     nsw_ff = interp2(x1, y1,nsw_f(:,:,tt)',x2, y2,'linear');  
    airt_ff = interp2(x1, y1,airt_f(:,:,tt)',x2, y2,'linear');
    uwnd_ff = interp2(x1, y1,uwnd_f(:,:,tt)',x2, y2,'linear'); 
    vwnd_ff = interp2(x1, y1,vwnd_f(:,:,tt)',x2, y2,'linear');
    shum_ff = interp2(x1, y1,shum_f(:,:,tt)',x2, y2,'linear');     
    prt_ff = interp2(x1, y1,prt_f(:,:,tt)',x2, y2,'linear');
    
%     nlwrs_fff(:,:,tt) = double(nlw_ff');
%     nswrs_fff(:,:,tt) = double(nsw_ff');
    atemp_fff(:,:,tt) = double(airt_ff');
    uwnd_fff(:,:,tt)  = double(uwnd_ff');
    vwnd_fff(:,:,tt)  = double(vwnd_ff');
    shum_fff(:,:,tt)  = double(shum_ff');
    prt_fff(:,:,tt)   = double(prt_ff');

    clear nlw_ff airt_ff  nsw_ff uwnd_ff vwnd_ff shum_ff prt_ff  

end

%% ================= 打开二进制文件 =================
ieee='b'; prec='real*4';
opdir='M:\CMEMS_glorys12v1\monthly\make_files\';

% fid = fopen([opdir,'/nlwrs_ncep_1993-2022.bin12'],'w','b'); fwrite(fid,nlwrs_fff,prec); fclose(fid);
% fid = fopen([opdir,'/nswrs_ncep_1993-2022.bin12'],'w','b'); fwrite(fid,nswrs_fff,prec); fclose(fid);
fid = fopen([opdir,'/atemp_ncep_1993-2022.bin12'],'w','b'); fwrite(fid,atemp_fff,prec); fclose(fid);
fid = fopen([opdir,'/uwnd_ncep_1993-2022.bin12'],'w','b'); fwrite(fid,uwnd_fff,prec); fclose(fid);
fid = fopen([opdir,'/vwnd_ncep_1993-2022.bin12'],'w','b'); fwrite(fid,vwnd_fff,prec); fclose(fid);
fid = fopen([opdir,'/shum_ncep_1993-2022.bin12'],'w','b'); fwrite(fid,shum_fff,prec); fclose(fid);
fid = fopen([opdir,'/prt_ncep_1993-2022.bin12'],'w','b'); fwrite(fid,prt_fff,prec); fclose(fid);


disp('=== MakeSSvar.m DONE ===');

