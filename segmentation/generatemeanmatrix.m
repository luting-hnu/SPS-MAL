function [meanmatrix,sup_img,indexes,mean_vec] = generatemeanmatrix (img,SegMap)
%by wuhui 2014/5/3
%输入超像素标号 每个超像素的所有像素点都变成灰度平均值
%revised by wuhui 14/5/7 输出超像素个数的平均值矩阵no_bands*maxsegments
%增添了输出sup_img与indexes
[no_lines, no_rows, no_bands] = size(img);


img = ToVector(img);
img = img';
meanmatrix=img;
MaxSegments=max(SegMap(:));
indexes={};%indexes里面是每块超像素对应的索引值
sup_img=[];
mean_vec=zeros(no_bands,MaxSegments);
for i=1:MaxSegments
    supind=find(SegMap==i);
    v=img(:,supind);
    meanv=mean(v,2);%列向量之间的平均值
    mean_vec(:,i)=meanv;
    indexes{i+1}=supind;
    sup_img(:,i+1) = meanv;
%     sup_img=[sup_img meanv];
    [a,~]=size(supind);
    for j=1:a
    meanmatrix(:,supind(j))=meanv;   %meanv is the mean of the superpixels.supind(i) is the location of superpixel.
    end
end
meanmatrix=meanmatrix';
meanmatrix=reshape(meanmatrix,no_lines, no_rows, no_bands);
    