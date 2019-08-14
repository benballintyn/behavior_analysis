function [paramVals,paramNames,scores] = analzyeParamSlices(basedir,modelDir,subdir)
[paramVals,paramNames,scores] = getParamVals(basedir,modelDir,subdir);
info = load([basedir '/' modelDir '/' subdir '/' modelDir '.mat']); info=info.(modelDir);
for i=1:length(paramNames)
    for j=1:length(paramNames)
        if (i>=j)
            continue;
        else
            F = scatteredInterpolant(paramVals(:,i),paramVals(:,j),scores');
            xmin = info.lower_bounds(i); xmax = info.upper_bounds(i);
            ymin = info.lower_bounds(j); ymax = info.upper_bounds(j);
            dx = (xmax-xmin)/1000;
            dy = (ymax-ymin)/1000;
            [Xq,Yq] = meshgrid(xmin:dx:xmax,ymin:dy:ymax);
            Vq = F(Xq,Yq);
            figure;
            imagesc([xmin xmax],[ymin ymax],Vq); colormap(jet); colorbar(); caxis([0 ceil(max(scores))])
            set(gca,'ydir','normal')
            xlabel(paramNames{i}); ylabel(paramNames{j})
            hold on; plot(paramVals(:,i),paramVals(:,j),'.k','markersize',10)
        end
    end
end
[COEFF, SCORE, LATENT, TSQUARED, EXPLAINED, MU] = pca(paramVals);
cmap=jet;
colorScale = ceil(max(scores))/size(cmap,1);
colorInds = ceil(scores/colorScale);
figure;
scatter3(paramVals*COEFF(:,1),paramVals*COEFF(:,2),paramVals*COEFF(:,3),[],cmap(colorInds,:),'filled')
xlabel('PC 1'); ylabel('PC 2'); zlabel('PC 3')
figure;
plot(EXPLAINED)
title('Variance explained')

end

