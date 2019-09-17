function [lickNet] = retrainLickNet(netType,dates,animals,batchSize)
[Xtr,Ytr,Xval,Yval,Xtst,Ytst] = convertLicks2LSTMinput('data',dates,animals,2000,.5);

nbatches = ceil(length(Xtr)/batchSize);
i=1;
initialLearnRate = .000005;
while i < nbatches
    try
        disp(['Batch ' num2str(i) ' / ' num2str(nbatches)])
        if (strcmp(netType,'2bottle'))
            lickNet = load(['analysis_code/bilstmLickNet2Bottle.mat']); lickNet=lickNet.bilstmLickNet;
        elseif (strcmp(netType,'3bottle'))
            lickNet = load(['analysis_code/bilstmLickNet3Bottle.mat']); lickNet=lickNet.bilstmLickNet;
        else
            error('Wrong netType given')
        end
        trRandInds = randperm(length(Xtr)); trRandInds=trRandInds(1:batchSize);
        valRandInds = randperm(length(Xval)); valRandInds=valRandInds(1:3000);
        options = trainingOptions('adam','MaxEpochs',50,'MiniBatchSize',128,...
                'Shuffle','every-epoch','ExecutionEnvironment','gpu',...
                'ValidationData',{Xval(valRandInds),Yval(valRandInds)},'ValidationFrequency',10,...
                'ValidationPatience',10,'Plots','training-progress',...
                'LearnRateSchedule','piecewise','LearnRateDropFactor',.5,...
                'LearnRateDropPeriod',1,'InitialLearnRate',initialLearnRate/i,'Plots','none');
        lickNet = trainNetwork(Xtr(trRandInds),Ytr(trRandInds),lickNet.Layers,options);
        if (strcmp(netType,'2bottle'))
            bilstmLickNet = lickNet;
            disp('saving ...')
            save('analysis_code/bilstmLickNet2Bottle.mat','bilstmLickNet','-mat')
        elseif (strcmp(netType,'3bottle'))
            disp('saving ...')
            save('analysis_code/bilstmLickNet3Bottle.mat','bilstmLickNet','-mat')
        else
            warning('netType for saving not recognized')
            error('netType for saving not recognized')
            break;
        end
        i = i+1;
    catch err
        warning('That annoying bug happened')
        continue;
    end
end
end

