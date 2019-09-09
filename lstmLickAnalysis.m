function [data,licks,bouts,states] = lstmLickAnalysis(basedir,date,animal,redo)
savedir = [basedir '/' date '/' animal];
if (~exist([savedir '/states.mat'],'file') || strcmp(redo,'yes'))
    [data] = read_datafiles(basedir,date,animal);
    save([savedir '/data.mat'],'data','-mat')
    [licks] = findLicksWithLSTM(data,'yes');
    save([savedir '/licks.mat'],'licks','-mat')
    for i=1:length(data)
        [bouts] = getBouts2(licks{i},1.5);
        newbouts{i} = manual_stitch_bouts(data(i),bouts);
    end
    bouts=newbouts;
    save([savedir '/bouts.mat'],'bouts','-mat')
    [states] = get_behavior_states(bouts,data(1).tvec);
    save([savedir '/states.mat'],'states','-mat')
    manual_flag.done = 1;
    manual_flag.date = date;
    save([savedir '/manual_flag.mat'],'manual_flag','-mat')
else
    disp(['previous analysis present in ' savedir '. loading...'])
    data = load([savedir '/data.mat']); data=data.data;
    licks = load([savedir '/licks.mat']); licks=licks.licks;
    bouts = load([savedir '/bouts.mat']); bouts=bouts.bouts;
    states = load([savedir '/states.mat']); states=states.states;
    for i=1:length(data)
        [nl] = manualLickID(data(i),licks{i});
        newlicks{i} = nl;
        bouts{i} = getBouts2(nl,1.5);
    end
    [states] = get_behavior_states(bouts,data(1).tvec);
    licks = newlicks;
    save([savedir '/data.mat'],'data','-mat')
    save([savedir '/licks.mat'],'licks','-mat')
    save([savedir '/bouts.mat'],'bouts','-mat')
    save([savedir '/states.mat'],'states','-mat')
    manual_flag.done = 1;
    manual_flag.date = date;
    save([savedir '/manual_flag.mat'],'manual_flag','-mat')
end
end

