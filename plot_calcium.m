%function to plot scatter plots, calcium events vs time-all neurons plotted
%together as well as neuron by neuron

function [f1, f2]=plot_calcium(calcium_matrix)

a=size(calcium_matrix);


f1=figure;
for i=20
    x=calcium_matrix(:,i);
    x=cell2mat(x);
    
    if sum(abs(x))>0   
        b=round(a(2)/5);
        subplot(b,5,i)
        
        
        scatter(x(:,1),x(:,2))
        %xlim([-5 5])
        hold on;
        
%         xlabel('Time-Relative to Receipt of Reward (s)')
%         ylabel('Calcium Event')
       
    else
        zz = ['Neuron ' num2str(i) ' does not fire'];
        disp(zz)
    end
end

f2=figure;
legendInfo=cell(1, a(2));

for i=20
    x=calcium_matrix(:,i);
    x=cell2mat(x);
    
    if (sum(abs(x))>0)
    
    
    logicalArray = x(:,1) < 100 & x(:,1) > -100;
    x = x(logicalArray,:);
        if sum(logicalArray)>0
                    scatter(x(:,1),x(:,2));
                    legendInfo{i} = strcat('Neuron:  ', num2str(i));
                    hold on;
        else
        zz = ['Neuron ' num2str(i) ' does not fire within set limits'];
        disp(zz)
            
        end
    end
    
end 
        xx=zeros(1,31);
        yy=(0:30);
        legendInfo=legendInfo(~cellfun('isempty',legendInfo));
        legend(legendInfo)
        
        grid on;
        plot(xx,yy);
        hold on;
        %xlim([-5 5])
         
         title('Calcium Events by Neuron');
         xlabel('Time (s)')
         ylabel('Ca Fluorescence ') 
    


    