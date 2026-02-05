clear; clc;

%% ================= 路径 =================
INDIR = 'M:\CMEMS_glorys12v1\monthly\';
OPDIR = 'M:\CMEMS_glorys12v1\monthly\make_files\';

if ~exist(OPDIR,'dir'); mkdir(OPDIR); end

%% ================= MITgcm 网格 =================
dx = 1/12; dy = 1/12;
x0 = 100; y0 = -20;
mx = 2280; my = 600;

lon_new = x0 + dx*(0:mx-1);
lat_new = y0 + dy*(0:my-1);

%% ================= 垂向层 =================
zg = -single([ ...
    0,5,10,15,20,25,30,35,40,45,50,60,70,80,90,100,...
    125,150,200,250,300,400,500,600,700,800,900,1000,...
    1250,1500,2000,2500,3000,4000,5000 ]);

mz = length(zg);

%% ================= 文件列表 =================
files = dir(fullfile(INDIR,'mercatorglorys12v1_gl12_mean_*.nc'));
files = files(1:360);
nt = length(files);

fprintf('Total files: %d\n',nt);

SST = nan(mx,my,nt);
SSS = nan(mx,my,nt);

%% ================= 时间循环 =================
for it = 1:nt

    fn = fullfile(files(it).folder,files(it).name);
    fprintf('[%03d/%03d] %s\n',it,nt,files(it).name);

    % ================ 读网格 =================
    lon = double(ncread(fn,'longitude'));
    lat = double(ncread(fn,'latitude'));
    dep = -double(ncread(fn,'depth'));  % 注意负号

    % ================ 经度映射 0-360 并排序 =================
    lon(lon < 0) = lon(lon < 0) + 360;
    [lon, idx_lon] = sort(lon);
    
    % ================ 读数据 =================
    T = single(ncread(fn,'thetao'));
    S = single(ncread(fn,'so'));

    % ================ 经度排序对应 =================
    T = T(idx_lon,:,:);
    S = S(idx_lon,:,:);

    %% ================= SSS ================    
    SST0 = squeeze(T(:,:,1));  % [Nz_orig, Ny]
    SSS0 = squeeze(S(:,:,1));
    clear T S
    
    [x1, y1] = meshgrid(lon, lat);
    [x2, y2] = meshgrid(lon_new, lat_new);
    
    % 垂向线性插值    
    SST1 = interp2(x1, y1,SST0',x2, y2,'linear');
    SSS1 = interp2(x1, y1,SSS0',x2, y2,'linear');
    clear SST0 SSS0   
    
    %NAN处理
    SST1 = fillmissing(SST1,'nearest',2);  % 沿行水平方向填充 NaN
    SST1 = fillmissing(SST1,'nearest',1);  % 沿行方向(深度)填充 NaN

    SSS1 = fillmissing(SSS1,'nearest',2);  % 沿行水平方向填充 NaN
    SSS1 = fillmissing(SSS1,'nearest',1);  % 沿行方向(深度)填充 NaN
      
    SST(:,:,it) = double(SST1');
    SSS(:,:,it) = double(SSS1');

    clear SST1 SSS1    

end

%% ================= 打开二进制文件 =================
ieee='b'; prec='real*4';
opdir='M:\CMEMS_glorys12v1\monthly\make_files\';

fid = fopen([opdir,'/SST_glorys12v1_1993-2022.bin12'],'w','b'); fwrite(fid,SST,prec); fclose(fid);
fid = fopen([opdir,'/SSS_glorys12v1_1993-2022.bin12'],'w','b'); fwrite(fid,SSS,prec); fclose(fid);

disp('=== MakeSSvar.m DONE ===');

