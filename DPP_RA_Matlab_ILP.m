m = input('Enter the number of services: ');
f1=xlsread('S:\QoSData.xlsx',1,'B1:AB1');
f2=xlsread('S:\QoSData.xlsx',1,'B2:AB2');
f3=xlsread('S:\QoSData.xlsx',1,'B3:AB3');

workload1=xlsread('S:\QoSData.xlsx',1,'B4:AB4');
workload2=xlsread('S:\QoSData.xlsx',1,'B5:AB5');
workload3=xlsread('S:\QoSData.xlsx',1,'B6:AB6');
w=[workload1,workload2,workload3];
%sus_qos1 = [8,10,7,9,11,6,8,10,13,4,6,7,10,14];
%sus_qos2=[10,11,8,9,10,6,8,9,11,3,5,7,10,13];
sus_qos1=xlsread('S:\QoSData.xlsx',1,'B7:AB7');
sus_qos2=xlsread('S:\QoSData.xlsx',1,'B8:AB8');
sus_qos3=xlsread('S:\QoSData.xlsx',1,'B9:AB9');

[~,instance_type] = xlsread('S:\QoSData.xlsx',1,'B10:CD10');
w_input= zeros(m,1);
for i=1:m
    w_input(i)=input(strcat('Enter the forecast workload for service_',num2str(i),': '));
end
reqQoS = input('Enter the end-to-end latency constraint value: ');
% combine cost vector
f=[f1,f2,f3];
fsize=size(f,2);
% Construct the A matrix
A = zeros( 2*m , fsize);% 2*m because 1 m rows to satisfy W constraints, 1 m rows to guarantee resource allocation at each layer
for i=1:m
    for j=(i-1)*(fsize/m)+1:i*(fsize/m)
        A(i,j)= -w(j);
        A(i+m,j) = -1;
    end
end
% construct b vector
b=zeros(size(A,1),1);
for i=1:2*m
    if(i<=m)
        b(i) = -w_input(i);
    else
        b(i) = -0.01;
    end
end

% construct QoS vector
combinedQoS=[sus_qos1,sus_qos2,sus_qos3];

% Assigning  Aeq and beq in standard format of Aeq*x=beq (equality constraint)
Aeq = zeros(size(combinedQoS,2),size(combinedQoS,2));
beq = zeros(size(combinedQoS,2),1);
[r,c]=size(combinedQoS);
for i=1:c/m
    if (combinedQoS(i) + combinedQoS(i+c/m) + combinedQoS(i+(2*c/m))) > reqQoS
        Aeq(i,i)=1;
        Aeq(i+c/m,i+c/m)=1;
        Aeq(i+(2*c/m),i+(2*c/m))=1;
        beq(i,1)=0;
        beq(i+c/m,1)=0;
        beq(i+(2*c/m),1)=0;
    end
end

% creating lower bound and upper bound
lb = zeros(size(combinedQoS,2),1); %minimum 0 instance can be used
ub = ones(size(combinedQoS,2),1);
ub(1:end) = inf; % no limit on maximum number of instances to use
intcon = 1:size(combinedQoS,2); %
% Now solving using intlinprog function.
options = optimoptions('intlinprog','Heuristics','intermediate');
%options = optimoptions(@intlinprog,'OutputFcn',@savemilpsolutions,'PlotFcn',@optimplotmilp);
x0=[];
[x,fval,exitflag,output] = intlinprog(f,intcon,A,b,Aeq,beq,lb,ub,x0,options);
fprintf('No of instances required:\n');
for i=1:size(x,1)
    if x(i)~=0
        inst_tp=string(instance_type(i));
        fprintf('%6.2f', x(i));
        fprintf(' X %s ', inst_tp)
        if i<=fsize/m
            fprintf(' for service S1,');
            fprintf (' with QoS:%d\n', combinedQoS(i));
            
        elseif i <=2*fsize/m
            fprintf(' for service S2,');
            fprintf (' with QoS:%d\n', combinedQoS(i));
            
        else
            fprintf(' for service S3,');
            fprintf (' with QoS:%d\n', combinedQoS(i));
        end
    end
end
fprintf(', and the optimal cost is:$%f\n', fval);


