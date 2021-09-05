function [meanmatrix,sup_img,indexes,mean_vec] = generatemeanmatrix (img,SegMap)
%by wuhui 2014/5/3
%���볬���ر�� ÿ�������ص��������ص㶼��ɻҶ�ƽ��ֵ
%revised by wuhui 14/5/7 ��������ظ�����ƽ��ֵ����no_bands*maxsegments
%���������sup_img��indexes
[no_lines, no_rows, no_bands] = size(img);


img = ToVector(img);
img = img';
meanmatrix=img;
MaxSegments=max(SegMap(:));
indexes={};%indexes������ÿ�鳬���ض�Ӧ������ֵ
sup_img=[];
mean_vec=zeros(no_bands,MaxSegments);
for i=1:MaxSegments
    supind=find(SegMap==i);
    v=img(:,supind);
    meanv=mean(v,2);%������֮���ƽ��ֵ
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
    