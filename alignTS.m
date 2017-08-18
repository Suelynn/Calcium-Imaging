%Suelynn Ren

function [Ca_spikes_bpod, WaitForCenterPoke_Ca, RewardState_Ca, PunishState_Ca, DeliverStimulus_Ca, TrialOutcomes, TrialTypes] = alignTS(Ca_spikes_byTrial, SessionData, match_trial_startIndex, match_trial_endIndex, starttrial, centertrial_Times)

a=size(Ca_spikes_byTrial);
Ca_spikes_bpod=repmat(Ca_spikes_byTrial,1);

%% Align TrialStartTimes, in pseudocode: for i=1:x_ntrial, find neurons that spiked during x_ntrial and from those neurons, subtract start_trial time to align to start of trial 
for i=2:a(1)
    spike_index=find(~cellfun(@isempty,Ca_spikes_bpod(i,:)));
    
    for j=1:length(spike_index)
        
        x=Ca_spikes_bpod{i,spike_index(j)};
        x(:,1)=x(:,1)-starttrial(i);
  
        Ca_spikes_bpod{i,spike_index(j)}=x;
    end
end
%% Bpod Data


%WaitForCenterPoke Times
WaitForCenterPoke=cell(1, length(SessionData.TrialStartTimestamp));

for i=1:length(SessionData.TrialStartTimestamp)
    CenterPoke={SessionData.RawEvents.Trial{1,i}.States.WaitForCenterPoke(2)};
    WaitForCenterPoke(i)=CenterPoke;
end

WaitForCenterPoke_Ca=cell2mat(WaitForCenterPoke(match_trial_startIndex:match_trial_endIndex));
WaitForCenterPoke_Ca(1)=centertrial_Times(1);
Trial_correction=SessionData.RawEvents.Trial{1,match_trial_startIndex}.States.WaitForCenterPoke(2)-WaitForCenterPoke_Ca(1);

%Reward Times
RewardState=cell(1, length(SessionData.TrialStartTimestamp));

for i=1:length(SessionData.TrialStartTimestamp)
    Reward={SessionData.RawEvents.Trial{1,i}.States.Reward(2)};
    RewardState(i)=Reward;
end

RewardState_Ca=cell2mat(RewardState(match_trial_startIndex:match_trial_endIndex));
RewardState_Ca(1)=RewardState_Ca(1)-Trial_correction;


%Punishment Times
PunishState=cell(1, length(SessionData.TrialStartTimestamp));
for i=1:length(SessionData.TrialStartTimestamp)
    Punish={SessionData.RawEvents.Trial{1,i}.States.Punish(1)};
    PunishState(i)=Punish;
end

PunishState_Ca=cell2mat(PunishState(match_trial_startIndex:match_trial_endIndex));
PunishState_Ca(1)=PunishState_Ca(1)-Trial_correction;

%Stimulus Delivery Times
DeliverStimulus_Event=cell(1, length(SessionData.TrialStartTimestamp));
for i=1:length(SessionData.TrialStartTimestamp)
    DeliverStimulus={SessionData.RawEvents.Trial{1,i}.States.DeliverStimulus(1)};
    DeliverStimulus_Event(i)=DeliverStimulus;
end

DeliverStimulus_Ca=cell2mat(DeliverStimulus_Event(match_trial_startIndex:match_trial_endIndex));

%Trial Outcomes
TrialOutcomes=NaN(1, length(SessionData.TrialStartTimestamp));
for i=1:length(SessionData.TrialStartTimestamp)
    TrialOutcomes(i)=SessionData.Outcomes(i);
end
TrialOutcomes=TrialOutcomes(match_trial_startIndex:match_trial_endIndex);

%TrialType

TrialTypes=NaN(1, length(SessionData.TrialStartTimestamp));
for i=1:length(SessionData.TrialStartTimestamp)
    TrialTypes(i)=SessionData.TrialTypes(i);
end
TrialTypes=TrialTypes(match_trial_startIndex:match_trial_endIndex);

