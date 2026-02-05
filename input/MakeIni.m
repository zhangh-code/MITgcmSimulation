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
files = files(1:120);
nt = length(files);

fprintf('Total files: %d\n',nt);

t_ini = zeros(mx,my,mz);
s_ini = zeros(mx,my,mz);
u_ini = zeros(mx,my,mz);
v_ini = zeros(mx,my,mz);


%% ================= 时间循环 =================
for it = 2:nt
    
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

    [x1, y1] = meshgrid(lon, lat);
    [x2, y2] = meshgrid(lon_new, lat_new);
    
    % 水平线性插值
    print('水平线性插值')
    for iz = 1:length(dep)
        %iz
        T1(:,:,iz) = interp2(x1, y1,squeeze(T(:,:,iz))',x2, y2,'linear')';
        S1(:,:,iz) = interp2(x1, y1,squeeze(S(:,:,iz))',x2, y2,'linear')';
        U1(:,:,iz) = interp2(x1, y1,squeeze(U(:,:,iz))',x2, y2,'linear')';
        V1(:,:,iz) = interp2(x1, y1,squeeze(V(:,:,iz))',x2, y2,'linear')';    
    end
    clear T S U V 
    

    % 垂向线性插值   
    print('垂向线性插值')
    T2 = permute(T1,[3,2,1]); clear T1
    S2 = permute(S1,[3,2,1]); clear S1
    U2 = permute(U1,[3,2,1]); clear U1
    V2 = permute(V1,[3,2,1]); clear V1
    
    T3 = interp1(dep,T2,zg,'linear','extrap'); clear T2
    S3 = interp1(dep,S2,zg,'linear','extrap'); clear S2
    U3 = interp1(dep,U2,zg,'linear','extrap'); clear U2
    V3 = interp1(dep,V2,zg,'linear','extrap'); clear V2
    
    %NAN处理
    print('NAN处理')
    T1 = permute(T3,[3,2,1]); clear T3
    S1 = permute(S3,[3,2,1]); clear S3
    U1 = permute(U3,[3,2,1]); clear U3
    V1 = permute(V3,[3,2,1]); clear V3
    
    T1 = fillmissing(T1,'nearest',1);  % 沿行水平方向填充 NaN
    T1 = fillmissing(T1,'nearest',2);  %
    T1 = fillmissing(T1,'nearest',3);  % 沿行方向(深度)填充 NaN

    S1 = fillmissing(S1,'nearest',1);  % 沿行水平方向填充 NaN
    S1 = fillmissing(S1,'nearest',2);  %
    S1 = fillmissing(S1,'nearest',3);  % 沿行方向(深度)填充 NaN 

    U1 = fillmissing(U1,'nearest',1);  % 沿行水平方向填充 NaN
    U1 = fillmissing(U1,'nearest',2);  %
    U1 = fillmissing(U1,'nearest',3);  % 沿行方向(深度)填充 NaN

    V1 = fillmissing(V1,'nearest',1);  % 沿行水平方向填充 NaN
    V1 = fillmissing(V1,'nearest',2);  %
    V1 = fillmissing(V1,'nearest',3);  % 沿行方向(深度)填充 NaN 
    
    t_ini = t_ini + double(T1); clear T1
    s_ini = s_ini + double(S1); clear S1
    u_ini = u_ini + double(U1); clear U1
    v_ini = v_ini + double(V1); clear V1

end
t_ini(:,:,1)
%% ================= 打开二进制文件 =================
t_ini = t_ini ./ nt;
s_ini = s_ini ./ nt;
u_ini = u_ini ./ nt;
v_ini = v_ini ./ nt;

ieee='b'; prec='real*4';
opdir='M:\CMEMS_glorys12v1\monthly\make_files\';

fid = fopen([opdir,'/t_ini_glorys12v1_mean_1993_2002.bin12'],'w','b'); fwrite(fid,t_ini,prec); fclose(fid);
fid = fopen([opdir,'/s_ini_glorys12v1_mean_1993_2002.bin12'],'w','b'); fwrite(fid,s_ini,prec); fclose(fid);
fid = fopen([opdir,'/u_ini_glorys12v1_mean_1993_2002.bin12'],'w','b'); fwrite(fid,u_ini,prec); fclose(fid);
fid = fopen([opdir,'/v_ini_glorys12v1_mean_1993_2002.bin12'],'w','b'); fwrite(fid,v_ini,prec); fclose(fid);

disp('=== MakeIni.m DONE ===');

