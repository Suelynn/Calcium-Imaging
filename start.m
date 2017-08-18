function [starttrial]= start(centertrial_Times, SessionData, match_trial_startIndex)

j=match_trial_startIndex+1;

for i=2:length(centertrial_Times)
    starttrial(i)=centertrial_Times(i)-SessionData.RawEvents.Trial{1,j}.States.WaitForCenterPoke(2);
    if j<length(SessionData.TrialStartTimestamp)
    j=j+1;
    end
end