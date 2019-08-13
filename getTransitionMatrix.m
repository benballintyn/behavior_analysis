function [T] = getTransitionMatrix(stateSeqs,nLocations)
nDays = size(stateSeqs,1);
ntimepoints = size(stateSeqs,2);
T = zeros(nDays,nLocations,nLocations);
nT = zeros(nDays,nLocations,Nlocations);
for i=1:nDays
    for t=1:ntimepoints-1
        curState = stateSeqs(i,t);
        nextState = stateSeqs(i,t+1);
        nT(i,nextState,curState) = nT(i,nextState,curState)+1;
    end
    T(i,:,:) = nT(i,:,:)/(ntimepoints-1);
end
end

