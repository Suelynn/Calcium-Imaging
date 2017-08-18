function [motion_byTrial, motion_bpodTimes]= motion_trials(motion_time, starttrial)

a=size(motion_time);
c=size(starttrial);
interval=[];

for i=1:c(2)-1
    d=[starttrial(i),starttrial(i+1)];
    interval=[interval;d];
end 

time=0;
steps=interval(:,2)-interval(:,1);
ending=max(motion_time(:,1))+1-max(max(interval));
steps=[steps;ending];
z=size(steps);

motion_byTrial=cell(z(1), 1);
motion_bpodTimes=cell(z(1), 1);

for i=1:z(1)
     logicalArray=motion_time(:,1)<time+steps(i)&motion_time(:,1)>=time;
     this_trial=motion_time(logicalArray,:);
     this_trialbpod=this_trial;
     this_trialbpod(:,1)=this_trialbpod(:,1)-time;
     
   
     motion_byTrial(i)={this_trial};
     motion_bpodTimes(i)={this_trialbpod};
     time=time+steps(i);
end
        