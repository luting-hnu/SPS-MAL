
close all
clear all
clc
addpath('functions');
addpath('segmentation');
addpath('inddata');
addpath('segmentation\ERS');
no_sslsamples = 0;
SOASSL_IN_48=[];
ASSL_IN_48=[];
% betaa and suparray are two arays related with factors beta and N needed in superpixel generation process and MRF optimization.
tic
for i=1:10
    beta = 3;
    supN = 25;
% load image and ground truth
%     load IndiaP.mat;
%     path='.\inddata\';
%     tt = 'indexsel_india3_';
%     location_tt = [path,tt,num2str(i)];
%     load (location_tt);
%     classes=max(max(GroundT(:,2)));  %GroundT's second colunm is the label of  corresponding pixels.

%
%Pavia
load PaviaU;
load PaviaU_gt;
path='.\inddata\';
tt='indexsel_pavia3_';
location_tt=[path,tt,num2str(i)];
load(location_tt);
GroundT=double(paviaU_gt);
indGroundT=find(GroundT(:)>0);
classes=max(max(GroundT));
GroundT=[indGroundT,GroundT(indGroundT)];
img=paviaU;

%Salina data
% load Salinas_corrected;
% load Salinas_gt;
% path='.\inddata\';
% tt='indexsel_salinas2_';
% location_tt=[path,tt,num2str(i)];
% load(location_tt);
% GroundT=double(salinas_gt);
% indGroundT=find(GroundT>0);
% classes=max(max(GroundT));
% GroundT=[indGroundT,GroundT(indGroundT)];
% img=salinas_corrected;

[rows,cols,bands] = size(img);
img_pix = ToVector(img)';     
[img_pix] = scale_func(img_pix')';  

GroundT0=zeros(1,rows*cols);
GroundT0(GroundT(:,1))=GroundT(:,2);
GroundT0=GroundT0';           %GroundT0 is a groundtruth on the real map.1st colunm is pixel location.
[map_sup0 img_sup2 img_sup_sup]=Gen_sup(rows,cols,supN,img);  %≥ı ºsupN=50
Dim_red=2*classes;
img_sub=Gen_sub(img_pix,Dim_red,rows,cols,bands,classes,2);

%%
img_sub = ToVector(img_sub);
img_pix = img_pix';

[img_sup2 ] = scale_func(img_sup2);

img_pix=img_pix';%img_sup_sup';
img = img_sub';
img_sup=img_sup2';

classes       = max(GroundT(:,2));
trainall =GroundT';
train=trainall(:,indexsel);
test = trainall;
% arrange the image struct
img = struct('im',img,'s',[rows cols bands classes],'img_sup',img_sup,'img_pix',img_pix);
AL_method='BT';    %    RS  -- random selection  Entropy
                   %    MI  -- mutual information
                   %    BT  -- breaking ties
                   %    MBT -- modified breaking ties
candidate = test;   % candidate set
u =   15;          %  new samples per iteration
U =   15*u;          %  total size of actively selected samples
AL_sampling = struct('AL_method',AL_method,'candidate',candidate,'U',U,'u',u);
class_results= SOASSL_ELM_test1c(img,train,test,AL_sampling,no_sslsamples,beta);
class_results_all{i}=class_results;
end

toc
oa=0;
aa=0;
kappa=0;
ca=0;
map=[];
% save the experimental data
for i=1:10
    oa=class_results_all{i}.OA_fusion+oa;
    aa=class_results_all{i}.AA_fusion+aa;
    kappa=class_results_all{i}.kappa_fusion+kappa;
    ca=class_results_all{i}.CA_fusion+ca;
%     map=[map;SOASSL_IN_48(i).map10];
end
data=[oa/10;aa/10;kappa/10;(ca/10)'];
% dataname=['data',num2str(supN),'-',num2str(beta),'.mat'];
dataname=['pavia','supdata','-',num2str(beta),'.mat'];
% mapname=['map',num2str(supN),'-',num2str(beta),'.mat'];
save(dataname,'data');
SOASSL_IN_48=[];
ASSL_IN_48=[];

% xlswrite('results.xlsx',data,'sheet1');
% save ASSL_IN_48 ASSL_IN_48
% save SOASSL_IN_48 SOASSL_IN_48
