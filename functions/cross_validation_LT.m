 function [a_opt b_opt] = cross_validation_LT(train_data, train_lab, n_fold, range, flag,c_option,kernel_option )
%[A_j B_j] =cross_validation_LT(trainset, train(2,:), min(G_fold),A_min,flag_cross,c,kerneloption);
%%% size of train_data is m*n, m is band number, n is number of samples;
%%% train_lab is the label of train_data��n_fold�Ǿ������۽�����֤��range�Ǻ�ѡA�ķ�Χ,rang<0��
%%% flag=0Ϊ����ͳһ��A,B��=1Ϊ���಻ͬ��A,B

%% first: divide train_data to n parts
clear id_nfold;
id_nfold=cell(n_fold,max(train_lab(:)));
for j=1:max(train_lab(:))
    id_i=find(train_lab==j);%��ȡ��i������
    num_class=max(fix(length(id_i)/n_fold),1);%�������ÿpart��Ӧ�÷ֶ��ٸ���Ҳ�����Լ�����    
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
    for j=1:k                     %k=16��������
        id_class=id_nfold{i}{j};  %{i}{j}��ָi��j��
        id_temp=[id_temp, id_class];
    end
    data_class=train_data(:,id_temp);
    lab_class=train_lab(id_temp);
    data_nfold{i}=data_class;
    lab_nfold{i}=lab_class;
end
%% step 2 ����n_fold������֤�� ����ֻ��һpart��Ϊ���Լ�������n-1��parts��Ϊѵ������n��parts�ֱ𶼻���Ϊһ�β��Լ�
%%%��ֻʾ��һ�ε�����

%next���ǵõ�����������ֵ,�����Ǹ�sigmoid����������,��Ҫ��ѵ�����ٲ��ԣ��õ����Լ��Ľ��val�����Լ�Ϊdata_nfold{pppp}��pppp�����ֻ��Ĳ��Լ�ָʾ
if flag == 0
CEE_set=cell(n_fold,1);
else 
CEE_set=cell(k,n_fold); %k=16,n_fold=2;
end
for pppp=1:n_fold%%pppp����ѡ�еĲ��Լ�
    test_train=data_nfold{pppp};    %ѡ�����Լ�
    train_data_sub=[];
    data_nfold_temp=data_nfold;
    lab_nfold_temp=lab_nfold;       
    data_nfold_temp{pppp}=[];       %�޳����Լ�
    lab_nfold_temp{pppp}=[];        %�޳����Լ�label
    train_data_sub=[];
    train_lab_sub=[];               
    for jk=1:n_fold                 %�ϲ�ѵ��������label
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
%���� [val]=SVM_predict......�Լ�д��ֵ��val����
%val�Ĵ�С��n_fold_one*k
%% ����A��B�ĺ�ѡֵ����
step_size=0.5;
A=[range:step_size:0]';%�����Լ����Զ���A��ȡֵ��Χ��������ͳһ����
max_val=max(val(:));%10;%�Լ�����B�ķ�Χ
min_val=min(val(:));%-10;%
min_B=0;%abs(max_val*A);
max_B=5;
step_b=step_size;%%�Լ�����
B=[min(min_B): step_b: max(max_B)];%�������Bͳһ���巶Χ��Ҳ���Լ�����
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
%% ����cross-entropy error
CEE=0;
lab=lab_nfold{pppp};%%�ڼ�����ѵ������pppp���Ǽ�

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
%% ����CEE�ǵ�����֤ʱ��õ���cross-entropy error���Ǹ���СΪsize(A)�ľ���CEE��i,j����ʾa=A��i,j��,b=B(i,j)��ʱ���cross-entropy error�������n_fold����������step 2������n�����Լ����n��CEE����
%% n��CEE(cross-entropy error)�������,Ȼ��ȡ�;������Сֵ����Ӧλ��Ϊ(row,col)
% [va idx]=min(CEE(:));
% a_opt=A(idx);
% b_opt=B(idx);
return