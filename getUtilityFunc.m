function [func] = getUtilityFunc(driveDir,animal,dates)
allLickOnsets = [];
for i=1:length(dates)
    curdir = [driveDir '/' dates{i} '/' animal];
    licks = load([curdir '/licks.mat']); licks=licks.licks;
    allLickOnsets = [allLickOnsets [licks{1}.onset] [licks{2}.onset]];
end

parmhat = expfit(allLickOnsets);
func = @(t) exp(-t/parmhat);
end

