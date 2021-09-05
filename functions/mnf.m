function [ X,X1] = mnf( X,k,H,W,B)
% --------------����������루MNF��------------
% �����ݽ���MNF�任,����ȡ����.
%   Input:
%       X:Ҫ���б任�����ݾ���,H-by-W-by-B
%       k:Ҫ��ȡ�ĳɷ���,��Ϊ��,�� k=B
%   Output:
%       X:����MNF�任��ľ���,H-by-W-by-k
%       SNR:�����,(B,1)
% [H,W,B] = size(X);
addpath('matlab_hyperspectral_toolbox_v0.05');
if(~isa(X,'double'))
    X = double(X);
end
% ת��Ϊ��ά����(p,N),p=B,N=H*W
% X = hyperConvert2d(X);
[p, N] = size(X);% p=B,N=H*W
if ~exist('k','var') || isempty(k)
    k = p;
end
%% Step 1 ����ԭʼЭ�������sigmaZ �� ����Э�������
% ����ԭʼ���ݵ�Э�������sigmaZ
sigmaZ = cov(X');% (p,p)
% ת��Ϊ��ά�����Թ�������Э�������
X = hyperConvert3d(X,H,W,p);% (H,W,B)
% ��������Э�������
dX = zeros(H-1,W,p);
for i=1:(H-1)
    dX(i, :, :) = X(i, :, :) - X(i+1, :, :);
end
dX = hyperConvert2d(dX);
sigmaN = cov(dX');% (p,p)
%% Step 2 �������Э��������������������׼��
% �������Э��������������������׼��
[V,D] = eig(sigmaN);% V:(p.p),
[C,I]=sort(diag(D),'descend');% ����������
V = V(:,I);D=diag(C);
P = V/sqrt(D); % ��׼��
%% Step 3 ���������ݽ��б�׼PCA�任
% �����ݽ��б�׼PCA�任
sigmaAdj = P'*sigmaZ*P;
[V,D]=eig(sigmaAdj);
[C,I]=sort(diag(D),'descend');
V = V(:,I);D=diag(C);
M = P*V;
M = M(:,1:k);
% ����SNR
SNR = diag(D);% (p,1)
% ����MNF�任
X = M'*hyperConvert2d(X);% (p,N)
% ת��Ϊ����������
X1 = hyperConvert3d(X, H, W, p);% (H,W,B)=(H,W,p)

