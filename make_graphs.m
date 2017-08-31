function [f1, f2, center_location, outcome_location, ca_spikes, ca_spikes_sorted]= make_graphs(centerTime, rewardTime, Ca_events, motion_time, SessionData, trialOutcome, trialType, align_timing)

[starttrial, Ca_spikes_byTrial, match_trial_startIndex, match_trial_endIndex, Ca_spikes_bpod, WaitForCenterPoke_Ca, RewardState_Ca, PunishState_Ca, DeliverStimulus_Ca, TrialOutcomes, TrialTypes]  = data_analysis(centerTime, rewardTime, Ca_events, SessionData);
index_trials=TrialOutcomes==trialOutcome&TrialTypes==trialType;

if strcmp('center', 'center')==1
    align_timing=WaitForCenterPoke_Ca;
elseif strcmp('reward', 'reward')==1
    align_timing=RewardState_Ca;
elseif strcmp('punish', 'punish')==1
    align_timing=PunishState_Ca;
end
    

[calcium_matrix]=index_matrix(Ca_spikes_bpod, index_trials, align_timing);
[f1, f2]=plot_calcium(calcium_matrix);

[motion_byTrial, motion_bpodTimes]= motion_trials(motion_time, starttrial);


%% Colormap_location; never made it into a function

%For TrialType1, rewarded trials-align to center

%index_trials=TrialTypes==1&TrialOutcomes==1;
motion=motion_bpodTimes(index_trials);

motion_centerport=repmat(motion,1);
motion_rewardport=repmat(motion,1);
motion_punishport=repmat(motion,1);

a=length(motion);

for i=1:a
    x=motion{i};
    reward=motion{i};
    punish=motion{i};
    
    WaitForCenterPoke=WaitForCenterPoke_Ca(index_trials);
    RewardState=RewardState_Ca(index_trials);
    PunishState=PunishState_Ca(index_trials);
    
 
    x(:,1)=x(:,1)-WaitForCenterPoke(i);
    reward(:,1)=reward(:,1)-RewardState(i);
    punish(:,1)=punish(:,1)-PunishState(i);
    
    motion_centerport{i}=x;
    motion_rewardport{i}=reward;
    motion_punishport{i}=punish;
end


motion_cut=repmat(motion_centerport, 1);
motion_align2outcome=repmat(motion_centerport, 1);
a=length(motion_cut);

for i=1:a
    this_trial=motion_centerport{i,1};
    reward_trial=motion_rewardport{i,1};
    punish_trial=motion_punishport{i,1};
    
    [dummy, center_location]=min((abs(this_trial(:,1))));
    [dummy_reward, reward_location]=min((abs(reward_trial(:,1))));
    [dummy_punish, punish_location]=min((abs(punish_trial(:,1))));
    
       if ~isnan(dummy_reward)
        port_reached=reward_trial(reward_location,2);
        port_location=reward_location;
       elseif ~isnan(dummy_punish)
           port_reached=punish_trial(punish_location,2);
           port_location=punish_location;
       end
    
    
%  center-assume all values beyond center port is motion error   
    y_max=this_trial(center_location,3);
    logical_ymax=this_trial(:,3)>y_max;
    this_trial(logical_ymax,3)=y_max;
    

    
%  assume all values at points beyond reward/punish port is motion error 
    logical_portreached=this_trial(:,2)<port_reached;
    this_trial(logical_portreached,2)=port_reached;

%   split trials into start2center, center2end
    start2center=this_trial(1:center_location-1,:);
    center2end=this_trial(center_location:end, :);

% limits based on values read off of motion detection software: upper right
% corner (-9.014, -4.994), upper left corner (3.191, -6.659), lower right
% corner (-9.156, -18.73), lower left corner (2.775, -18.3)

    y_min=-6.5;
    x_min=-9;
    x_max=3;
    
    logical_ymin1=center2end(:,3)<y_min;
    logical_ymin2=start2center(:,3)<y_min;
%     artifically set y values for long arm of T to 0
    center2end(logical_ymin1,3)=0;
    start2center(logical_ymin2,3)=0;
%     center2end(~logical_ymin,2)=NaN;
%     distance_travelled(i)=sum(abs(diff(center2end(:,3))))+sum(abs(diff(center2end(:,2))));
    
    
   distance2center=NaN(length(center2end),1);
   distance2center2=NaN(length(start2center),1);
   
   center_logical=center2end(:,3)~=0;
   center_logical2=start2center(:,3)~=0;
   
   index_firstleg=find(center_logical==1,1,'last');
   index_firstleg2=find(center_logical2==1,1,'first');

   while center_logical(index_firstleg)==1 && center_logical(index_firstleg+1)~=0 && center_logical(index_firstleg-1)~=1 && center_logical(index_firstleg-2)~=1
            center_logical=center_logical(1:index_firstleg-1);
            index_firstleg=find(center_logical==1,1,'last');
   end

    while center_logical2(index_firstleg2)==1 && center_logical2(index_firstleg2+1)~=1 && center_logical2(index_firstleg2-1)~=0 && center_logical2(index_firstleg2-2)~=0
            center_logical2=center_logical2(1:index_firstleg2-1);
            index_firstleg2=find(center_logical2==1,1,'first');
    end
   
    
   for yy=1:index_firstleg
    distance2center(yy)=y_max-center2end(yy,3);
   end
       
   for xx=index_firstleg+1:length(center2end)
           
   distance_firstleg=distance2center(index_firstleg);
   distance2center(xx)=distance_firstleg+abs(((center2end(xx,2)-center2end(index_firstleg+1,2))));
   end
   
   %%start2center
   
   for yy=index_firstleg2:length(start2center)
       
   distance2center2(yy)=y_max-start2center(yy,3);
       
   end
   
   for xx=1:index_firstleg2-1
           
   distance_firstleg2=distance2center2(index_firstleg2);
   distance2center2(xx)=distance_firstleg2+abs(((start2center(xx,2)-start2center(index_firstleg2-1,2))));
   
   end


   center2end=horzcat(center2end, distance2center);
   start2center=horzcat(start2center, -distance2center2);
   trial_complete=vertcat(start2center, center2end);
   
   align2outcome=center2end;
   outcome_reachedTS=trial_complete(port_location,1);
   align2outcome(:,1)=align2outcome(:,1)-outcome_reachedTS;
   
   [dummy_outcome, outcome_location]=min((abs(align2outcome(:,1))));
   align2outcome(:,4)=align2outcome(:,4)-align2outcome(outcome_location,4);
   align2outcome(:,4)=round(align2outcome(:,4)/max(abs(align2outcome(:,4))),2);
   
   
   motion_cut{i,1}=trial_complete;
   motion_align2outcome{i,1}=align2outcome;
   
   
end
   


a=length(motion_cut); %for each trial
for i=1:a
    motion_cut{i}(:,4)=round(motion_cut{i}(:,4)/max(abs(motion_cut{i}(:,4))),2);
end 

plot_data=NaN(a(1),2000);
trial_size=NaN(a(1),1);
trial_size_outcome=NaN(a(1),1);
align_zero=NaN(a(1),1);
align_outcome=NaN(a(1),1);

for i=1:a(1) %find 0 index values
    this_trial=(motion_cut{i,1}(:,1))';
    this_outcome=(motion_align2outcome{i,1}(:,1))';
    
    [dummy, align_zero(i)]=min((abs(this_trial)));
    [dummy, align_outcome(i)]=min((abs(this_outcome)));
end

for i=1:a(1)
    this_trial=(motion_cut{i,1}(:,4))';
    this_outcome=(motion_align2outcome{i,1}(:,4))';
    
    add_nan=max(align_zero)-align_zero(i);
    add_nan2outcome=max(align_outcome)-align_outcome(i);
    
    this_trial=horzcat(NaN(1,add_nan), this_trial);
    plot_data(i,(1:length(this_trial)))=this_trial;
    trial_size(i)=length(this_trial);
    
    this_outcome=horzcat(NaN(1,add_nan2outcome), this_outcome);
    plot_outcome(i,(1:length(this_outcome)))=this_outcome;
    trial_size_outcome(i)=length(this_outcome);
 
end
    

center_location=figure;
[m,n]=max(trial_size);
plot_data=plot_data(:,1:max(trial_size));

x=linspace(-0.0330*(max(align_zero)-1),0.0330*(m-max(align_zero)), m);
yy=size(motion_cut);
y=1:yy(1);

imagesc(x,y, plot_data);
colorbar;

outcome_location=figure;
[m,n]=max(trial_size_outcome);
plot_outcome=plot_outcome(:,1:max(trial_size_outcome));

x=linspace(-0.0330*(max(align_outcome)-1),0.0330*(m-max(align_outcome)), m);
yy=size(motion_align2outcome);
y=1:yy(1);

imagesc(x,y, plot_outcome);
colorbar;



% plot_data(find(isnan(plot_data)))=-1;







    





% for i=1:a(1)
%     x=motion_cut{i,1}(:,2);
%     binned_x=discretize(x, x_edges, 'Includededge', 'left');
%     motion_cut{i,1}(:,2)=binned_x;
% end
% 
% for i=1:a(1)
%     y=motion_cut{i,1}(:,3);
%     binned_y=discretize(y, y_edges, 'Includededge', 'left');
%     motion_cut{i,1}(:,3)=binned_y;
% end
% 
% 
% for i=1:a(1)
%     normalize_y=motion_cut{i,1};
%     logical=normalize_y(:,2)>= 16 & normalize_y(:,2)<= 23;
%     
%     fix_y=normalize_y(logical,:);
%     
%      max_y = max(fix_y(:,3));
%      min_y= min(fix_y(:,3));
%      index2 = find(fix_y(:,3)==max_y,1,'last');
%      index1 = find(fix_y(:,3)==min_y,1,'first');
%      
% %      slope=abs((fix_y(index1,3)-fix_y(index2,3))/(fix_y(index1,2)-fix_y(index2,2)));
% %     
% %     fix_y(:,3)= fix_y(:,3)/slope;
% %     fix_y(:,3)= fix_y(:,3)/max(fix_y(:,3));
% %     normalize_y(logical,3)=fix_y(:,3);
% 
%     normalize_y(~logical,3)=0.1;
%     normalize_y(logical,2)=(16+23)/2;
%     
%     motion_cut{i,1}=normalize_y;
%     
%     
% end

[spike_bydistance_normalized, firingrate_by_location, ca_spikes, ca_spikes_sorted]=pseudo_firingRate(calcium_matrix, motion_cut);