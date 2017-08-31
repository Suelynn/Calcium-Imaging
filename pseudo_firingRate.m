%%Make colormap of firing rate vs. location by neuron. Sort neurons into sequence by median.
%%by Suelynn Ren sren1340@gmail.com. "Spiking" is mean calcium events per
%%time location, normalized by the time spent in that location as well as
%%max firing rate of each neuron. Scores are then weighted by percent
%%action trials (i.e. number of trials in which neuron responded/total
%%trials)

function [spike_bydistance_normalized, firingrate_by_location]=pseudo_firingRate(calcium_matrix, motion)



a=size(calcium_matrix);

x_min=cellfun(@min, motion, 'Uni',0);
x_min=cell2mat(x_min);
x_min=min(x_min(:,4));

x_max=cellfun(@max, motion, 'Uni',0);
x_max=cell2mat(x_max);
x_max=max(x_max(:,4));

x=x_min:0.01:x_max; %matched to rounded distance values

spike_bydistance=cell(length(x), a(2)+1);
spike_bydistance(:,1)=num2cell(x');

%motion=motion_outcomes;

percent_activeTrials=NaN(a(2),1);

for i=1:a(2) 
percent_activeTrials(i)=sum(~cellfun('isempty',(calcium_matrix(:,i))))/a(1);
end


for neuron_num=1:a(2) %for each neuron, find trials in which neuron spiked
trial_index=[find(~cellfun(@isempty,calcium_matrix(:,neuron_num)))];



    for j=1:length(trial_index) %for each trial
        cell_spike=cell2mat(calcium_matrix(trial_index(j),neuron_num));
        time_select = motion{trial_index(j)}(:,1);

        start_here=min(time_select);
        
        logical_range=cell_spike(:,1)>start_here;
        cell_spike=cell_spike(logical_range,:);
        
%         test_function=logical_range==0;
%         if sum(test_function)>0
%             display('test')
%         end

        p=size(cell_spike);
    
        for k=1:p(1) %for each spike event within a trial
        [m,n]=min(abs(time_select-cell_spike(k,1)));
        neuron_location=motion{trial_index(j)}(n,4);
        
        cell_spike(k,1)=neuron_location;
         normalize_time=numel(find(motion{trial_index(j)}(:,4)==neuron_location)); %time sampling rate for motion data
         cell_spike(k,2)=(cell_spike(k,2)/normalize_time);
        
        [dummy, this_cell]=min(abs(neuron_location-cell2mat(spike_bydistance(:,1))));

        spike_bydistance{this_cell, neuron_num+1}=[spike_bydistance{this_cell, neuron_num+1}; cell_spike(k,2)];
        end
    end
end

spike_bydistance_normalized=cellfun(@mean, spike_bydistance, 'UniformOutput', false);
spike_bydistance_normalized=cell2mat(spike_bydistance_normalized);

a=size(spike_bydistance_normalized);

for i=2:a(2)
 spike_bydistance_normalized(:,i) =(spike_bydistance_normalized(:,i)/max(spike_bydistance_normalized(:,i)))*percent_activeTrials(i-1);
end


firingrate_by_location=transpose(spike_bydistance_normalized(:,2:end));
x=spike_bydistance_normalized(:,1);
y=1:a(2);

figure(1)
imagesc(x,y,firingrate_by_location)
y=set(gca,'YLim',[0.5 (a(2)+0.5)]);

colorbar;

figure(2);
a=size(firingrate_by_location);
x=zeros(1,a(1));

for i=1:a(1)
   %x=firingrate_by_location(i,:);
   %y=find(~isnan(x));
   x(i)=median(find(~isnan(firingrate_by_location(i,:))));
end
   [waste,index]=sort(x,'descend');

a=size(spike_bydistance_normalized);
x=spike_bydistance_normalized(:,1);
imagesc(x,y, firingrate_by_location(index,:));
y=set(gca,'YLim',[0.5 a(2)-1],'YTick',1:(a(2)-1),'YTickLabel',{index'});
colorbar;



        
        
        