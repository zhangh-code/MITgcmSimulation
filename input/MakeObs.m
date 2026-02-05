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
files = files(1:60);
nt = length(files);

fprintf('Total files: %d\n',nt);

u_IWf = nan(my,mz,nt);
u_IEf = nan(my,mz,nt);
u_ISf = nan(mx,mz,nt);
u_INf = nan(mx,mz,nt);
v_IWf = nan(my,mz,nt);
v_IEf = nan(my,mz,nt);
v_ISf = nan(mx,mz,nt);
v_INf = nan(mx,mz,nt);

t_IWf = nan(my,mz,nt);
t_IEf = nan(my,mz,nt);
t_ISf = nan(mx,mz,nt);
t_INf = nan(mx,mz,nt);
s_IWf = nan(my,mz,nt);
s_IEf = nan(my,mz,nt);
s_ISf = nan(mx,mz,nt);
s_INf = nan(mx,mz,nt);

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
    U = single(ncread(fn,'uo'));
    V = single(ncread(fn,'vo'));

    % ================ 经度排序对应 =================
    T = T(idx_lon,:,:);
    S = S(idx_lon,:,:);
    U = U(idx_lon,:,:);
    V = V(idx_lon,:,:);

    %% ================= West =================
    [~, ilon] = min(abs(lon - lon_new(1)));
    
    TW0 = squeeze(T(ilon,:,:))';  % [Nz_orig, Ny]
    SW0 = squeeze(S(ilon,:,:))';
    UW0 = squeeze(U(ilon,:,:))';
    VW0 = squeeze(V(ilon,:,:))';

    % 垂向线性插值    
    TW1 = interp1(dep,TW0,zg,'linear','extrap');
    SW1 = interp1(dep,SW0,zg,'linear','extrap'); 
    UW1 = interp1(dep,UW0,zg,'linear','extrap'); 
    VW1 = interp1(dep,VW0,zg,'linear','extrap'); 
    clear TW0 SW0 UW0 VW0
    
    TW2 = interp1(lat,TW1',lat_new,'linear','extrap');
    SW2 = interp1(lat,SW1',lat_new,'linear','extrap'); 
    UW2 = interp1(lat,UW1',lat_new,'linear','extrap'); 
    VW2 = interp1(lat,VW1',lat_new,'linear','extrap'); 
    clear TW1 SW1 UW1 VW1
    
    %NAN处理
    TW2 = fillmissing(TW2,'nearest',1);  % 沿行水平方向填充 NaN
    TW2 = fillmissing(TW2,'nearest',2);  % 沿行方向(深度)填充 NaN

    SW2 = fillmissing(SW2,'nearest',1);  % 沿行水平方向填充 NaN
    SW2 = fillmissing(SW2,'nearest',2);  % 沿行方向(深度)填充 NaN
    
    UW2 = fillmissing(UW2,'nearest',1);  % 沿行水平方向填充 NaN
    UW2 = fillmissing(UW2,'nearest',2);  % 沿行方向(深度)填充 NaN

    VW2 = fillmissing(VW2,'nearest',1);  % 沿行水平方向填充 NaN
    VW2 = fillmissing(VW2,'nearest',2);  % 沿行方向(深度)填充 NaN    
    
    t_IWf(:,:,it) = double(TW2);
    s_IWf(:,:,it) = double(SW2);
    u_IWf(:,:,it) = double(UW2);
    v_IWf(:,:,it) = double(VW2);
    clear TW2 SW2 UW2 VW2    
    %% ================= East =================
    [~, ilon] = min(abs(lon - lon_new(end)));

    TE0 = squeeze(T(ilon,:,:))';
    SE0 = squeeze(S(ilon,:,:))';
    UE0 = squeeze(U(ilon,:,:))';
    VE0 = squeeze(V(ilon,:,:))';

    TE1 = interp1(dep,TE0,zg,'linear','extrap');
    SE1 = interp1(dep,SE0,zg,'linear','extrap');
    UE1 = interp1(dep,UE0,zg,'linear','extrap');
    VE1 = interp1(dep,VE0,zg,'linear','extrap');
    clear TE0 SE0 UE0 VE0
    
    TE2 = interp1(lat,TE1',lat_new,'linear','extrap');
    SE2 = interp1(lat,SE1',lat_new,'linear','extrap'); 
    UE2 = interp1(lat,UE1',lat_new,'linear','extrap'); 
    VE2 = interp1(lat,VE1',lat_new,'linear','extrap'); 
    clear TE1 SE1 UE1 VE1
    
    %NAN处理
    TE2 = fillmissing(TE2,'nearest',1);  % 沿行水平方向填充 NaN
    TE2 = fillmissing(TE2,'nearest',2);  % 沿行方向(深度)填充 NaN

    SE2 = fillmissing(SE2,'nearest',1);  % 沿行水平方向填充 NaN
    SE2 = fillmissing(SE2,'nearest',2);  % 沿行方向(深度)填充 NaN
    
    UE2 = fillmissing(UE2,'nearest',1);  % 沿行水平方向填充 NaN
    UE2 = fillmissing(UE2,'nearest',2);  % 沿行方向(深度)填充 NaN

    VE2 = fillmissing(VE2,'nearest',1);  % 沿行水平方向填充 NaN
    VE2 = fillmissing(VE2,'nearest',2);  % 沿行方向(深度)填充 NaN  

    t_IEf(:,:,it) = double(TE2);
    s_IEf(:,:,it) = double(SE2);
    u_IEf(:,:,it) = double(UE2);
    v_IEf(:,:,it) = double(VE2);
    clear TE2 SE2 UE2 VE2  

    %% ================= South =================
    [~, ilat] = min(abs(lat - lat_new(1)));

    TS0 = squeeze(T(:,ilat,:))';
    SS0 = squeeze(S(:,ilat,:))';
    US0 = squeeze(U(:,ilat,:))';
    VS0 = squeeze(V(:,ilat,:))';

    TS1 = interp1(dep,TS0,zg,'linear','extrap');
    SS1 = interp1(dep,SS0,zg,'linear','extrap');
    US1 = interp1(dep,US0,zg,'linear','extrap');
    VS1 = interp1(dep,VS0,zg,'linear','extrap');
    clear TS0 SS0 US0 VS0
    
    TS2 = interp1(lon,TS1',lon_new,'linear','extrap');
    SS2 = interp1(lon,SS1',lon_new,'linear','extrap'); 
    US2 = interp1(lon,US1',lon_new,'linear','extrap'); 
    VS2 = interp1(lon,VS1',lon_new,'linear','extrap'); 
    clear TS1 SS1 US1 VS1    
    
    %NAN处理
    TS2 = fillmissing(TS2,'nearest',1);  % 沿行水平方向填充 NaN
    TS2 = fillmissing(TS2,'nearest',2);  % 沿行方向(深度)填充 NaN

    SS2 = fillmissing(SS2,'nearest',1);  % 沿行水平方向填充 NaN
    SS2 = fillmissing(SS2,'nearest',2);  % 沿行方向(深度)填充 NaN
    
    US2 = fillmissing(US2,'nearest',1);  % 沿行水平方向填充 NaN
    US2 = fillmissing(US2,'nearest',2);  % 沿行方向(深度)填充 NaN

    VS2 = fillmissing(VS2,'nearest',1);  % 沿行水平方向填充 NaN
    VS2 = fillmissing(VS2,'nearest',2);  % 沿行方向(深度)填充 NaN  

    t_ISf(:,:,it) = double(TS2);
    s_ISf(:,:,it) = double(SS2);
    u_ISf(:,:,it) = double(US2);
    v_ISf(:,:,it) = double(VS2);
    clear TS2 SS2 US2 VS2  

    %% ================= North =================
    [~, ilat] = min(abs(lat - lat_new(end)));

    TN0 = squeeze(T(:,ilat,:))';
    SN0 = squeeze(S(:,ilat,:))';
    UN0 = squeeze(U(:,ilat,:))';
    VN0 = squeeze(V(:,ilat,:))';

    TN1 = interp1(dep,TN0,zg,'linear','extrap');
    SN1 = interp1(dep,SN0,zg,'linear','extrap');
    UN1 = interp1(dep,UN0,zg,'linear','extrap');
    VN1 = interp1(dep,VN0,zg,'linear','extrap');
    clear TN0 SN0 UN0 VN0
    
    TN2 = interp1(lon,TN1',lon_new,'linear','extrap');
    SN2 = interp1(lon,SN1',lon_new,'linear','extrap'); 
    UN2 = interp1(lon,UN1',lon_new,'linear','extrap'); 
    VN2 = interp1(lon,VN1',lon_new,'linear','extrap'); 
    clear TN1 SN1 UN1 VN1   
    
    %NAN处理
    TN2 = fillmissing(TN2,'nearest',1);  % 沿行水平方向填充 NaN
    TN2 = fillmissing(TN2,'nearest',2);  % 沿行方向(深度)填充 NaN

    SN2 = fillmissing(SN2,'nearest',1);  % 沿行水平方向填充 NaN
    SN2 = fillmissing(SN2,'nearest',2);  % 沿行方向(深度)填充 NaN
    
    UN2 = fillmissing(UN2,'nearest',1);  % 沿行水平方向填充 NaN
    UN2 = fillmissing(UN2,'nearest',2);  % 沿行方向(深度)填充 NaN

    VN2 = fillmissing(VN2,'nearest',1);  % 沿行水平方向填充 NaN
    VN2 = fillmissing(VN2,'nearest',2);  % 沿行方向(深度)填充 NaN  

    t_INf(:,:,it) = double(TN2);
    s_INf(:,:,it) = double(SN2);
    u_INf(:,:,it) = double(UN2);
    v_INf(:,:,it) = double(VN2);
    clear TN2 SN2 UN2 VN2  


end

%% ================= 打开二进制文件 =================
ieee='b'; prec='real*4';
opdir='M:\CMEMS_glorys12v1\monthly\make_files\';

fid = fopen([opdir,'/West_u_glorys12v1_1993-1997.bin12'],'w','b'); fwrite(fid,u_IWf,prec); fclose(fid);
fid = fopen([opdir,'/East_u_glorys12v1_1993-1997.bin12'],'w','b'); fwrite(fid,u_IEf,prec); fclose(fid);
fid = fopen([opdir,'/North_u_glorys12v1_1993-1997.bin12'],'w','b');fwrite(fid,u_INf,prec); fclose(fid);
fid = fopen([opdir,'/South_u_glorys12v1_1993-1997.bin12'],'w','b');fwrite(fid,u_ISf,prec); fclose(fid);
fid = fopen([opdir,'/West_v_glorys12v1_1993-1997.bin12'],'w','b'); fwrite(fid,v_IWf,prec); fclose(fid);
fid = fopen([opdir,'/East_v_glorys12v1_1993-1997.bin12'],'w','b'); fwrite(fid,v_IEf,prec); fclose(fid);
fid = fopen([opdir,'/North_v_glorys12v1_1993-1997.bin12'],'w','b');fwrite(fid,v_INf,prec); fclose(fid);
fid = fopen([opdir,'/South_v_glorys12v1_1993-1997.bin12'],'w','b');fwrite(fid,v_ISf,prec); fclose(fid);
fid = fopen([opdir,'/East_temp_glorys12v1_1993-1997.bin12'],'w','b'); fwrite(fid,t_IEf,prec); fclose(fid);
fid = fopen([opdir,'/West_temp_glorys12v1_1993-1997.bin12'],'w','b'); fwrite(fid,t_IWf,prec); fclose(fid);
fid = fopen([opdir,'/North_temp_glorys12v1_1993-1997.bin12'],'w','b');fwrite(fid,t_INf,prec); fclose(fid);
fid = fopen([opdir,'/South_temp_glorys12v1_1993-1997.bin12'],'w','b');fwrite(fid,t_ISf,prec); fclose(fid);
fid = fopen([opdir,'/East_salt_glorys12v1_1993-1997.bin12'],'w','b'); fwrite(fid,s_IEf,prec); fclose(fid);
fid = fopen([opdir,'/West_salt_glorys12v1_1993-1997.bin12'],'w','b'); fwrite(fid,s_IWf,prec); fclose(fid);
fid = fopen([opdir,'/North_salt_glorys12v1_1993-1997.bin12'],'w','b');fwrite(fid,s_INf,prec); fclose(fid);
fid = fopen([opdir,'/South_salt_glorys12v1_1993-1997.bin12'],'w','b');fwrite(fid,s_ISf,prec); fclose(fid);

disp('=== MakeOBS.m DONE ===');

