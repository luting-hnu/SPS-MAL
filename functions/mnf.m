function [ X,X1] = mnf( X,k,H,W,B)
% --------------最大噪声分离（MNF）------------
% 对数据进行MNF变换,并提取特征.
%   Input:
%       X:要进行变换的数据矩阵,H-by-W-by-B
%       k:要提取的成分数,若为空,则 k=B
%   Output:
%       X:经过MNF变换后的矩阵,H-by-W-by-k
%       SNR:信噪比,(B,1)
% [H,W,B] = size(X);
addpath('matlab_hyperspectral_toolbox_v0.05');
if(~isa(X,'double'))
    X = double(X);
end
% 转换为二维数据(p,N),p=B,N=H*W
% X = hyperConvert2d(X);
[p, N] = size(X);% p=B,N=H*W
if ~exist('k','var') || isempty(k)
    k = p;
end
%% Step 1 计算原始协方差矩阵sigmaZ 和 噪声协方差矩阵
% 计算原始数据的协方差矩阵sigmaZ
sigmaZ = cov(X');% (p,p)
% 转化为三维矩阵以估算噪声协方差矩阵
X = hyperConvert3d(X,H,W,p);% (H,W,B)
% 估算噪声协方差矩阵
dX = zeros(H-1,W,p);
for i=1:(H-1)
    dX(i, :, :) = X(i, :, :) - X(i+1, :, :);
end
dX = hyperConvert2d(dX);
sigmaN = cov(dX');% (p,p)
%% Step 2 求得噪声协方差矩阵的特征向量并标准化
% 求得噪声协方差矩阵的特征向量并标准化
[V,D] = eig(sigmaN);% V:(p.p),
[C,I]=sort(diag(D),'descend');% 按降序排列
V = V(:,I);D=diag(C);
P = V/sqrt(D); % 标准化
%% Step 3 对噪声数据进行标准PCA变换
% 对数据进行标准PCA变换
sigmaAdj = P'*sigmaZ*P;
[V,D]=eig(sigmaAdj);
[C,I]=sort(diag(D),'descend');
V = V(:,I);D=diag(C);
M = P*V;
M = M(:,1:k);
% 计算SNR
SNR = diag(D);% (p,1)
% 进行MNF变换
X = M'*hyperConvert2d(X);% (p,N)
% 转换为数据立方体
X1 = hyperConvert3d(X, H, W, p);% (H,W,B)=(H,W,p)

