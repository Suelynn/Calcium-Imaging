%function to index calcium matrix - sorted by trial type/outcome and
%aligned to event

function [calcium_matrix]=index_matrix(Ca_spikes_bpod, index_trials, align_timing)

a=size(Ca_spikes_bpod);
pre_calcium_matrix=Ca_spikes_bpod(index_trials',:);

% pre_calcium_matrix=cell(length(index_trials), a(2));
% 
% for i=1:length(index_trials) %Ca spike matrix of rewarded trials
%     index_spikes={Ca_spikes_bpod{index_trials(i),:}};
%     
%     pre_calcium_matrix(i,:)=index_spikes;
% end

b=size(pre_calcium_matrix);
calcium_matrix=cell(b(1), b(2));

for i=1:b(1) %for 1:n indexed trials in new pre_calcium_matrix
    spike_index=[find(~cellfun(@isempty,pre_calcium_matrix(i,:)))];
    
    align_timing_perTrial=align_timing(index_trials);
   
    for j=1:length(spike_index)
                x=pre_calcium_matrix{i,spike_index(j)};
                x(:,1)=x(:,1)-align_timing_perTrial(i);
                calcium_matrix{i,spike_index(j)}=x;
    end
    
end
