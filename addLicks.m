function [licks] = addLicks(data,licks)
datalength = length(data(1).raw_voltage);
wndwSize = 2000;
nwndws = ceil(datalength/wndwSize);
dataMax = max(data.raw_voltage);

onsetLineInds = [];
offsetLineInds = [];
nNew = 0;
speedFactor = 1;
offset = 0;
h = figure;
set(h,'KeyPressFcn',@KeyPressCb);
set(h,'Position',[200 200 1600 1000])
wndwNum = 1;
plotWindow(wndwNum);
function KeyPressCb(~,evnt)
    fprintf('key pressed: %s\n',evnt.Key);
    if strcmpi(evnt.Key,'leftarrow')
        onsetLineInds = [];
        offsetLineInds = [];
        nNew = 0;
        offset = 0;
        wndwNum = max(1,wndwNum-1);
        plotWindow(wndwNum)
    elseif strcmpi(evnt.Key,'rightarrow')
        if (length(onsetLineInds) ~= length(offsetLineInds))
            error('Unequal numbers of onset and offset indices for new licks')
        end
        onsets = data.tvec(onsetLineInds);
        onsetVals = data.raw_voltage(onsetLineInds);
        offsets = data.tvec(offsetLineInds);
        offsetVals = data.raw_voltage(offsetLineInds);
        for i=1:length(onsetLineInds)
            tmpLick.onset_ind = onsetLineInds(i);
            tmpLick.onset = onsets(i);
            tmpLick.onsetVal = onsetVals(i);
            tmpLick.offset_ind = offsetLineInds(i);
            tmpLick.offset = offsets(i);
            tmpLick.offsetVal = offsetVals(i);
            tmpLick.duration = tmpLick.offset - tmpLick.onset;
            tmpLick.raw_voltage = data.raw_voltage(tmpLick.onset_ind:tmpLick.offset_ind);
            tmpLick.smoothed_voltage = data.smoothed_voltage(tmpLick.onset_ind:tmpLick.offset_ind);
            [maxVal,maxInd] = max(tmpLick.raw_voltage);
            tmpLick.maxInd = tmpLick.onset_ind + maxInd - 1;
            tmpLick.maxTime = data.tvec(tmpLick.maxInd);
            tmpLick.maxVal = maxVal;
            tmpLick.solution = data.solution;
            laterLickInds = find([licks.onset] > tmpLick.offset);
            licks = [licks(1:(laterLickInds(1)-1)) tmpLick licks(laterLickInds)];
        end
        onsetLineInds = [];
        offsetLineInds = [];
        nNew = 0;
        offset = 0;
        wndwNum = min(wndwNum+1,nwndws);
        plotWindow(wndwNum)
    elseif strcmpi(evnt.Key,'n')
        nNew = nNew+1;
        mid_ind=makeOnsetOffsetLines(wndwNum);
        onsetLineInds = [onsetLineInds mid_ind-1];
        offsetLineInds = [offsetLineInds mid_ind+1];
        plotWindow(wndwNum)
    elseif strcmpi(evnt.Key,'q')
        if (nNew > 0)
            onsetLineInds(nNew) = onsetLineInds(nNew)-speedFactor;
            plotWindow(wndwNum)
        end
    elseif strcmpi(evnt.Key,'w')
        if (nNew > 0)
            onsetLineInds(nNew) = onsetLineInds(nNew)+speedFactor;
            plotWindow(wndwNum)
        end
    elseif strcmpi(evnt.Key,'a')
        if (nNew > 0)
            offsetLineInds(nNew) = offsetLineInds(nNew)-speedFactor;
            plotWindow(wndwNum)
        end
    elseif strcmpi(evnt.Key,'s')
        if (nNew > 0)
            offsetLineInds(nNew) = offsetLineInds(nNew)+speedFactor;
            plotWindow(wndwNum)
        end
    elseif ~isempty(regexp(evnt.Key,'\d','ONCE'))
        speedFactor = str2double(evnt.Key);
    elseif strcmpi(evnt.Key,'z')
        offset = offset - speedFactor;
        plotWindow(wndwNum)
    elseif strcmpi(evnt.Key,'x')
        offset = offset + speedFactor;
        plotWindow(wndwNum)
    elseif strcmpi(evnt.Key,'return')
        close all;
        return;
    end
end

function plotWindow(wndwNum)
    start_ind = (wndwNum-1)*wndwSize + 1 + offset;
    end_ind = min(datalength,wndwNum*wndwSize+offset);
    includedLickInds = find([licks.onset_ind] >= start_ind & [licks.onset_ind] <= end_ind);
    plot(data.tvec(start_ind:end_ind),data.raw_voltage(start_ind:end_ind))
    hold on;
    for i=1:length(includedLickInds)
        curLick = includedLickInds(i);
        lickOn = licks(curLick).onset;
        lickOff = licks(curLick).offset;
        lickMax = licks(curLick).maxTime;
        hold on;
        plot(lickOn,licks(curLick).onsetVal,'b*')
        plot(lickOff,licks(curLick).offsetVal,'r*')
        plot(lickMax,licks(curLick).maxVal,'k*')
    end
    if (length(onsetLineInds) ~= length(offsetLineInds))
        error('Different number of onsets and offsets')
    end
    tvecVals = data.tvec(onsetLineInds);
    for i=1:length(onsetLineInds)
        plot([tvecVals(i) tvecVals(i)],[0 dataMax],'b')
    end
    tvecVals = data.tvec(offsetLineInds);
    for i=1:length(offsetLineInds)
        plot([tvecVals(i) tvecVals(i)],[0 dataMax])
    end
    ylim([0 dataMax])
    hold off;
end

function mid_ind=makeOnsetOffsetLines(wndwNum)
    start_ind = (wndwNum-1)*wndwSize + 1;
    end_ind = min(datalength,wndwNum*wndwSize);
    mid_ind = floor((end_ind + start_ind + 1)/2);
end
uiwait;
end

