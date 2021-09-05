function Sub_ft=sub_classify(im_nmf_2D,class_endmem)
% Dim_red=20;
Phi=[];
[L,C] = kmeans_1(im_nmf_2D,class_endmem, []);%im_nmf_2D B*(M*N)
mixed=im_nmf_2D;
c=class_endmem;%这里讲M1*N1改为MN注意后面也改了
 End_mem=C;%centroid';
% Abun = hyperFcls(  im_nmf_2D, C);
 for i=1:size(C,2)
 [Abun(:,i)] = hyperCem(im_nmf_2D, C(:,i));
%          [Abun(:,i)] = hyperMatchedFilter(im_nmf_2D, C(:,i));
 end
Abun= Abun';
Sub_ft=Abun';
end