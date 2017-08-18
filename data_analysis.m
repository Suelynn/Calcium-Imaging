function [starttrial, Ca_spikes_byTrial, match_trial_startIndex, match_trial_endIndex, Ca_spikes_bpod, WaitForCenterPoke_Ca, RewardState_Ca, PunishState_Ca, DeliverStimulus_Ca, TrialOutcomes, TrialTypes]  = data_analysis(centerTime, rewardTime, Ca_events, SessionData)

[centertrial_Times] = trial_data(centerTime);
[rewardtrial_Times] = trial_data(rewardTime);

[match_trial_startIndex, match_trial_endIndex]= match_trials(centertrial_Times, rewardtrial_Times, SessionData);
[starttrial]= start(centertrial_Times, SessionData, match_trial_startIndex);

[Ca_spikes_byTrial]= Ca_trials(Ca_events, starttrial);
[Ca_spikes_bpod, WaitForCenterPoke_Ca, RewardState_Ca, PunishState_Ca, DeliverStimulus_Ca, TrialOutcomes, TrialTypes] = alignTS(Ca_spikes_byTrial, SessionData, match_trial_startIndex, match_trial_endIndex, starttrial, centertrial_Times);
