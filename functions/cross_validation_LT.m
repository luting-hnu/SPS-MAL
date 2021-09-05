 function [a_opt b_opt] = cross_validation_LT(train_data, train_lab, n_fold, range, flag,c_option,kernel_option )
%[A_j B_j] =cross_validation_LT(trainset, train(2,:), min(G_fold),A_min,flag_cross,c,kerneloption);
%%% size of train_data is m*n, m is band number, n is number of samples;
%%% train_lab is the label of train_data。n_fold是决定几折交叉验证。range是候选A的范围,rang<0。
%%% flag=0为各类统一的A,B，=1为各类不同的A,B

%% first: divide train_data to n parts
clear id_nfold;
id_nfold=cell(n_fold,max(train_lab(:)));
for j=1:max(train_lab(:))
    id_i=find(train_lab==j);%提取第i类样本
    num_class=max(fix(length(id_i)/n_fold),1);%计算该类每part里应该分多少个，也可以自己定义    
    for i=1:n_fold       
        id_temp=id_i( 1+(i-1)*num_class : min(i*num_class,length(id_i)) );
        id_nfold{i}{j}=id_temp;
    end
end
k=max(train_lab(:));
data_nfold=cell(n_fold, 1);     %n_fold=2
lab_nfold=cell(n_fold, 1);
for i=1:n_fold
    id_temp=[];
    for j=1:k                     %k=16是种类数
        id_class=id_nfold{i}{j};  %{i}{j}是指i行j列
        id_temp=[id_temp, id_class];
    end
    data_class=train_data(:,id_temp);
    lab_class=train_lab(id_temp);
    data_nfold{i}=data_class;
    lab_nfold{i}=lab_class;
end
%% step 2 根据n_fold交叉验证， 轮流只有一part作为测试集，其他n-1个parts作为训练集，n个parts分别都会作为一次测试集
%%%我只示范一次的例子

%next就是得到分类器决策值,就是那个sigmoid函数的输入,需要先训练，再测试，得到测试集的结果val，测试集为data_nfold{pppp}，pppp就是轮换的测试集指示
if flag == 0
CEE_set=cell(n_fold,1);
else 
CEE_set=cell(k,n_fold); %k=16,n_fold=2;
end
for pppp=1:n_fold%%pppp就是选中的测试集
    test_train=data_nfold{pppp};    %选出测试集
    train_data_sub=[];
    data_nfold_temp=data_nfold;
    lab_nfold_temp=lab_nfold;       
    data_nfold_temp{pppp}=[];       %剔除测试集
    lab_nfold_temp{pppp}=[];        %剔除测试集label
    train_data_sub=[];
    train_lab_sub=[];               
    for jk=1:n_fold                 %合并训练集及其label
        if ~isempty(lab_nfold_temp{jk})
            train_data_sub=[train_data_sub, data_nfold_temp{jk}];
            train_lab_sub=[train_lab_sub, lab_nfold_temp{jk}];
        end
    end
    xtest = [ones(size(test_train',1),1) test_train'];
    xapp  = [train_lab_sub' train_data_sub'];
[TTrain,TTest,TrainAC,accur_ELM,TY,label] = ...
    elm_kernel(xapp , xtest, 1 , c_option,'RBF_kernel',kernel_option);
val=TY';%-min(TY(:));
%比如 [val]=SVM_predict......自己写，值给val变量
%val的大小是n_fold_one*k
%% 构造A和B的候选值矩阵
step_size=0.5;
A=[range:step_size:0]';%步长自己可以定；A的取值范围，所有类统一定义
max_val=max(val(:));%10;%自己定义B的范围
min_val=min(val(:));%-10;%
min_B=0;%abs(max_val*A);
max_B=5;
step_b=step_size;%%自己定义
B=[min(min_B): step_b: max(max_B)];%所有类的B统一定义范围，也可自己定义
A=repmat(A,[1 length(B)]);
B=repmat(B,[size(A,1) 1]);
f_sigmoid=cell(size(val,1),size(val,2));
sum_sample=cell(size(val,1),1);
for i=1:size(val,1)
    sum_sigmoid=0;
    for j=1:size(val,2)
        f_sigmoid{i}{j}=1./(1+exp(val(i,j)*A+B));
        sum_sigmoid=sum_sigmoid+f_sigmoid{i}{j};
%         f_sigmoid{i}{j}=1./(1+exp(val(i,j)*A+B));
    end
    sum_sample{i}=sum_sigmoid;
end
%% 计算cross-entropy error
CEE=0;
lab=lab_nfold{pppp};%%第几个是训练集，pppp就是几

if flag==0   
for i=1:size(val,1)
    lab_i=lab(i);
%     for j=1:size(val,2)
        CEE=CEE+(-log(f_sigmoid{i}{lab_i}./(sum_sample{i})+1e-12));
%     end
end
[va idx]=min(CEE(:));
a_opt0=A(idx);
b_opt0=B(idx);
% fprintf('When fold = %1.0f, opt_A = %1.1f, and opt_B= %1.1f \n', pppp, a_opt, b_opt);
CEE_set{pppp}=CEE;
CEE_set_min(pppp)=min(CEE(:));

else  
    13579
    for jjk=1:k
        CEE_sub_class=0;
        id_class_t=find(lab==jjk);
        for jjk2=1:length(id_class_t)
            CEE_sub_class=CEE_sub_class+(-log(f_sigmoid{id_class_t(jjk2)}{jjk}./(sum_sample{id_class_t(jjk2)})+1e-12));
        end
        CEE_set{jjk}{pppp}=CEE_sub_class;
        [va idx]=min(CEE_sub_class(:));
        a_opt=A(idx);
        b_opt=B(idx);
    end      
end

end

if flag == 1
    for jjk=1:k
        num_t=0;
        for jjk2=1:pppp
            num_t=num_t+CEE_set{jjk}{jjk2};
        end
        [va idx]=min(num_t(:));
        a_opt=A(idx);
        b_opt=B(idx);
    12345678
    end
else
    num_t=0;
    for jjk=1:pppp
        num_t=num_t+CEE_set{jjk};
    end
    [va idx]=min(num_t(:));
    a_opt=A(idx);
    b_opt=B(idx);
%     fprintf('Averaging CEE of %1.0f folds and when class = %1.0f th class, opt_A = %1.1f, and opt_B= %1.1f \n',n_fold,  jjk, a_opt, b_opt);
end
%% 以上CEE是单次验证时候得到的cross-entropy error，是个大小为size(A)的矩阵，CEE（i,j）表示a=A（i,j）,b=B(i,j)，时候的cross-entropy error。如果是n_fold方法，返回step 2，根据n个测试集求出n个CEE矩阵。
%% n个CEE(cross-entropy error)矩阵相加,然后取和矩阵的最小值，对应位置为(row,col)
% [va idx]=min(CEE(:));
% a_opt=A(idx);
% b_opt=B(idx);
return