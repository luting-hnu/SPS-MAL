function class_fusion1=MRF_opt(beta,m1,n1,decision_values,test_labels,test_SL,class_num)
no_classes=class_num;

Dc_sum = log(decision_values+eps);%reshape((),[m1 n1 class_num]);
% Dc_sum = log(decision_value_sub+eps);%reshape((),[m1 n1 class_num]);
Result=zeros(m1*n1,1);

Dc = reshape(Dc_sum,[m1 n1 no_classes]);
Sc = ones(no_classes) - eye(no_classes);        
% beta=0.5;
        % Expantion Algorithm
gch = GraphCut('open', -Dc, beta*Sc);
[gch seg] = GraphCut('expand',gch);
gch = GraphCut('close', gch);

class_fusion1=seg(:);
end