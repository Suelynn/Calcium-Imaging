
function [match_trial_startIndex, match_trial_endIndex, trial_outcome]= match_trials(centertrial_Times, rewardtrial_Times, SessionData)
j=1;

for i=1:length(centertrial_Times)-1
    if rewardtrial_Times(j)>centertrial_Times(i) && rewardtrial_Times(j)<centertrial_Times(i+1) && j<=length(rewardtrial_Times)
        trial_outcome(i)=1;
        j=j+1;
    else
        trial_outcome(i)=0;
    end
end

bpod_outcomes=SessionData.Outcomes;

bpod_outcomes(bpod_outcomes<0)=0;


dummy_trial_outcome=num2str(trial_outcome(1:9));
dummy_bpod_outcomes=num2str(bpod_outcomes);

str_index=strfind(dummy_bpod_outcomes, dummy_trial_outcome);
dummy_bpod_outcomes(str_index-3)='9';

match_trial_startIndex=find(str2num(dummy_bpod_outcomes)==9)+1;
match_trial_endIndex=match_trial_startIndex+length(trial_outcome);






