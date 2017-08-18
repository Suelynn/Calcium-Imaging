%Function [append_Caevents] adds Ca events to matrix. Originally designed
%to add pre-center poke events from n+1 trial to n trial. Therefore, matrix
%holding Ca events for trial n includes start of trial n ---- aligned event
%(center/reward/punishment etc) --- aligned event(center/reward/punishment
%etc) for trial n+1. Time is added by taking the abs value of time from n+1 
%trial to 0, plus duration of last trial(i.e. if looking at Ca events from 
%start trial 1 to center of trial 2, take absolute value of negative time elements

function [Caevents_add_nextTrial] = appendCa_matrix(first_matrix, add_centerTimes, Alignment_correction, starttrial, Ca_events)

a=size(add_centerTimes);
Caevents_add_nextTrial=repmat(first_matrix,1);

c=size(starttrial);
interval=[];

for i=1:c(2)-1
    d=[starttrial(i),starttrial(i+1)];
    interval=[interval;d];
end 

steps=interval(:,2)-interval(:,1);
ending=max(Ca_events(:,1))+1-max(max(interval));
steps=[steps;ending];

for i=2:a(1)-1 %for each trial except the first in the centercalcium_matrix, find neurons that fire
    spike_index=[find(~cellfun(@isempty,add_centerTimes(i,:)))];
        
    for j=1:length(spike_index) %find neurons that fire in appended matrix 
                random=add_centerTimes{i,spike_index(j)};
                logicalArray = random(:,1) < 0;
                random = random(logicalArray,:);
                             
                random(:,1)=random(:,1)+steps(i-1)+Alignment_correction(i);
                
                y=Caevents_add_nextTrial{i-1,spike_index(j)};
                z=[y;random];
                Caevents_add_nextTrial{i-1,spike_index(j)}=z;
                
                
    end
    
end