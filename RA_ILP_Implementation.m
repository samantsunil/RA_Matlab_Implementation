%DPP Resource Allocation with e2e constraints - Heuristic based implementation
m=input('Enter the number of DPP services in the pipeline (default 3):');
total_cost =0.0;
reqE2ELatency=input('Enter end-to-end latency constraint value: ');
minA = input('Enter the min QoS in service 2: ');
minB = input('Enter the min QoS in service 3: ');

    W=input('Enter the forecast workload for S1: ');
    W1=input('Enter the forecast workload for S2: ');
    W2=input('Enter the forecast workload for S3: ');
    tic;
    for k=1:m
        
            %f=[0.0385,0.0385,0.0385,0.0385,0.0385,0.0928,0.0928,0.0928,0.0928,0.0928,0.1856,0.1856,0.1856,0.1856,0.1856];
             f=[0.032,0.032,0.032,0.032,0.032,0.065,0.065,0.065,0.065,0.065,0.13,0.13,0.13,0.13,0.13]; % read workload vector for each service
            sus_workload=[1000,5000,10000,20000,30000,1000,5000,10000,20000,30000,1000,5000,10000,20000,30000];
            sus_qos=[8,11,14,22,29,7,9,10,13,18,5,7,8,10,12];
            instance_type_list=["micro","micro","micro","micro","micro","small","small","small","small","small","medium","medium","medium","medium","medium"];
            
            %Assigning A and b in Ax <= b (inequality constraint)
            A= -sus_workload;
            b= -W;
            % Assigning Aeq and beq in standard format Aeq*x=beq
            Aeq = zeros(size(sus_qos,2),size(sus_qos,2));
            beq = zeros(size(sus_qos,2),1);
            % implementation to satisfy QoS constraint.
            for i=1:size(sus_qos,2)
			  if k==1
			    checkVal = reqE2ELatency-minA-minB;
			  elseif k==2
			    checkVal = reqE2ELatency-minB;
			  else 
			  checkVal = reqE2ELatency;
			  end
                if sus_qos(i)>checkVal
                    Aeq(i,i)=1;
                    beq(i,1)=0;
                end
            end
            % Create lower bound and upper bound
            lb = zeros(size(sus_qos,2),1); %minimum 0 instance can be used
            ub = ones(size(sus_qos,2),1);
            ub(1:end) = inf; % no limit on maximum number of instances to use
            intcon = 1:size(sus_qos,2);
            x10=[];
            % Solve using intlinprog function.
            options1 = optimoptions('intlinprog','Heuristics','none');
            [x1,fval1] = intlinprog(f,intcon,A,b,Aeq,beq,lb,ub,x10,options1);
            %ff=@() intlinprog(f,intcon,A,b,Aeq,beq,lb,ub,x10,options1);
            %t1=timeit(ff,2);
            qos_array1 = zeros(1,m);
            idx=1;
            fprintf('Instances required for S_%d:\n',k);
            for i=1:size(x1,1)
                if x1(i)~=0
                    inst_tp=string(instance_type_list(i));
                    fprintf('%6.2f', x1(i));
                    fprintf(' X %s ', inst_tp)
                    fprintf('\nQoS in S1: %d\n', sus_qos(i));
                    qos_array1(idx)=sus_qos(i);
                    idx = idx+1;
                end
            end
            fprintf('total cost for S_%d: $%f\n', k, fval1);
            reqQoS = reqQoS-max(qos_array1);
            total_cost = total_cost+fval1;
        
        
            %f1=[0.0385,0.0385,0.0385,0.0385,0.0385,0.0385,0.0385,0.0928,0.0928,0.0928,0.0928,0.0928,0.0928,0.0928,0.0928,0.1856,0.1856,0.1856,0.1856,0.1856,0.1856,0.1856,0.1856,0.1856,0.1856,0.1856,0.1856];
            %f1=[0.032,0.032,0.032,0.032,0.032,0.032,0.032,0.065,0.065,0.065,0.065,0.065,0.065,0.065,0.065,0.13,0.13,0.13,0.13,0.13,0.13,0.13,0.13,0.13,0.13,0.13,0.13];
            %sus_workload1=[1000,5000,10000,20000,30000,40000,50000,1000,5000,10000,20000,30000,40000,50000,60000,1000,5000,10000,20000,30000,40000,50000,60000,70000,80000,90000,100000];
            %sus_qos1=[45,90,200,400,600,800,900,30,60,200,400,500,600,800,900,25,50,100,200,250,350,450,500,600,700,800,900];
            %instance_type_list1=["micro","micro","micro","micro","micro","micro","micro","small","small","small","small","small","small","small","small","medium","medium","medium","medium","medium","medium","medium","medium","medium","medium","medium","medium"];
            
            % for S3
            
            
            %f2=[0.032,0.032,0.032,0.065,0.065,0.065,0.065,0.065,0.13,0.13,0.13,0.13,0.13,0.13,0.13];
            %sus_workload2=[1000,5000,10000,1000,5000,10000,20000,30000,1000,5000,10000,20000,30000,40000,50000];
            %sus_qos2=[2,20,260,1,2,6,40,140,1,1,2,4,9,25,120];
            %instance_type_list2=["micro","micro","micro","small","small","small","small","small","medium","medium","medium","medium","medium","medium","medium"];
            
            %Assigning A and b in Ax <= b (inequality constraint)
            
       
        
    end
    toc;
    fprintf('Total cost of RA in DPP:$%f\n', total_cost);
    fprintf('End-to-end latency(should be +ve value):%d\n',reqQoS);

