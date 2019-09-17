function [] = addLicksAndCorrect(basedir,date,animal)
savedir = [basedir '/' date '/' animal];
if (~exist([savedir '/licks.mat'],'file'))
    error('No lick file to correct')
else
    licks = load([savedir '/licks.mat']); licks = licks.licks;
    data = load([savedir '/data.mat']); data=data.data;
end
for i=1:length(licks)
    licks{i} = addLicks(data(i),licks{i},savedir,licks,i);
end
save([savedir '/licks.mat'],'licks','-mat')
for i=1:length(licks)
    tempBout = getBouts2(licks{i},1.5);
    newbouts = manual_stitch_bouts(data(i),tempBout);
    bouts{i} = newbouts;
end
save([savedir '/bouts.mat'],'bouts','-mat')
[states] = get_behavior_states(bouts,data(1).tvec);
save([savedir '/states.mat'],'states','-mat')
manual_flag.done = 1;
manual_flag.date = date;
save([savedir '/manual_flag.mat'],'manual_flag','-mat')
end

