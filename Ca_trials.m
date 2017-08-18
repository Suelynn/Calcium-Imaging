function [Ca_spikes_byTrial]= Ca_trials(Ca_events, starttrial)

c=size(starttrial);
interval=[];

for i=1:c(2)-1
    d=[starttrial(i),starttrial(i+1)];
    interval=[interval;d];
end 

time=0;
steps=interval(:,2)-interval(:,1);
ending=max(Ca_events(:,1))+1-max(max(interval));
steps=[steps;ending];
z=size(steps);

Ca_spikes_byTrial=[];

for i=1:z(1)
     this_trial=Ca_events(find(Ca_events(:,1)<time+steps(i)&(Ca_events(:,1)>=time)),:);
     f=size(this_trial);
     time_spikePair=cell(1,f(2)-1);
     
        for neuron_num=2:f(2)
            g=find(this_trial(:,neuron_num)>0);
            if numel(g)>0
            Ca_spikes=[this_trial(g,1),this_trial(g,neuron_num)];
            time_spikePair(neuron_num-1)={Ca_spikes};
            end
        end
        
        Ca_spikes_byTrial=[Ca_spikes_byTrial;time_spikePair];
     time=time+steps(i);
     

end
        
end