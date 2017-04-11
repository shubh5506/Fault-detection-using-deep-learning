clc,clear,close all;

%%Read csv_file.
filename='_slash_rosout.csv';
Data=xlsread(filename);
[col_InputData,row_InputData]=size(Data);
tempData=(isnan(Data)==0);
%%Transfer data into data to input to BP.
k=length(find(tempData(1,:)==1));
InputData=zeros(col_InputData,k);

% Regular the input data
k=1;i=1;
while(i<row_InputData)
    if tempData(1,i)==0
        i=i+1;
    else
        for j=2:col_InputData-1
            InputData(j,k)=Data(j,i)-(Data(j-1,i)+Data(j+1,i))/2;
        end
        Maxvalue=max(InputData(:,k));Minvalue=min(InputData(:,k));
        if Maxvalue~=Minvalue
            for j=1:col_InputData
                InputData(j,k)=(InputData(j,k)-Minvalue)/(Maxvalue-Minvalue);
            end
        end
        i=i+1;k=k+1;
    end
    
end

% Deep learning (maximum 50 times) per each input data
% and the error is set 0.01
i=1;y=[];
while(i<col_InputData+1)
    X=InputData(i,:);
    t=median(InputData);
    net = feedforwardnet(10);
    net = train(net,X,t);
    y = [y;net(X)];
    i=i+1;
end

Distance=[];
for i=1:col_InputData
    z=(y(i,:)-t);
    Distance=[Distance,sum(z.*z)];
end

Faultnum=find(Distance>0.5 & Distance<1);
% display the fault row in the file
Fault_ROW = Faultnum+1

