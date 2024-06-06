clear;
clc;
% define the path of FC matrix
SubPath = 'XXX';
Sub = dir([SubPath filesep 'Sub*']);

SubNum = length(Sub);

% load the TP mask
TP = load_nii('XXX/TP.nii');
IndexMap = double(TP.img);
[nDim1,nDim2,nDim3]=size(IndexMap);
TP_Index = find(IndexMap == 1);

Left_TP = load_nii('XXX/Left_TP.nii');
Left_TPMap = double(Left_TP.img);
Left_TP_Index = find(Left_TPMap == 1);
Hemi_Index{1} = Left_TP_Index;
[ialeft, left_loc]=ismember(Left_TP_Index,TP_Index);
LR_loc{1} = left_loc;

Right_TP = load_nii('XXX/Right_TP.nii');
Right_TPMap = double(Right_TP.img);
Right_TP_Index = find(Right_TPMap == 1);
Hemi_Index{2} = Right_TP_Index;
[iaright, right_loc]=ismember(Right_TP_Index,TP_Index);
LR_loc{2} = right_loc;

Hemisphere = {'Left', 'Right'};

% define the output path
OutputPath = 'XXX';
mkdir(OutputPath);
Group_SilhouetteValue = zeros(2,8);
Individual_SilhouetteValue = zeros(SubNum, 8, 2);

% Parcellating the left or right TP into 2-8 subdivisions separately.
for ParcelNum = 2:8
    mkdir([OutputPath filesep 'Parcel' num2str(ParcelNum)]);
    Sub_OutPutPath = [OutputPath filesep 'Parcel' num2str(ParcelNum)];
    for hemi = 1:length(Hemisphere)
        Group_Coassignment = zeros(length(LR_loc{hemi}), length(LR_loc{hemi}));
        Individual_ParcelLabel = zeros(length(LR_loc{hemi}), SubNum);
        % subject level
        for sub = 1:SubNum
            % load FC matrix of the participants
            load([ SubPath filesep Sub(sub).name]); %matrix name is 'FCMatrix'
            FCMatrix = FCMatrix(LR_loc{hemi}, :);
            FCMatrix = zscore(FCMatrix);  
            [idx,cent,sumdist] = kmeans(FCMatrix,ParcelNum,'Distance','sqeuclidean','Display','final','Replicates',100); 
            Individual_ParcelLabel(:, sub) = idx;
            [Individual_silh,~] = silhouette(FCMatrix,idx,'sqeuclidean');
            Individual_SV = mean(Individual_silh);
            Individual_SilhouetteValue(sub, ParcelNum, hemi) = Individual_SV;
            Individual_Coassignment = zeros(length(LR_loc{hemi}), length(LR_loc{hemi}));
            for v1 = 1:length(LR_loc{hemi})
                for v2 = 1:length(LR_loc{hemi})
                    if idx(v1) == idx(v2)
                        Individual_Coassignment(v1, v2) = 1;
                    else
                        Individual_Coassignment(v1, v2) = 0;
                    end
                end
            end
            Group_Coassignment = Group_Coassignment + Individual_Coassignment;
        end
        save([Sub_OutPutPath filesep Hemisphere{hemi} '_Individual_ParcelLabel.mat'], 'Individual_ParcelLabel');
        
        % group level
        Average_Coassignment = Group_Coassignment/SubNum;
        Average_Coassignment = zscore(Average_Coassignment); 
        [Group_idx,Group_cent,Group_sumdist] = kmeans(Average_Coassignment,ParcelNum,'Distance','sqeuclidean','Display','final','Replicates',100);
        save([Sub_OutPutPath filesep Hemisphere{hemi} '_Group_idx.mat'], 'Group_idx');
        Parcel = [Hemi_Index{hemi} Group_idx];
        [Group_silh,h] = silhouette(Average_Coassignment,Group_idx,'sqeuclidean');
        save([Sub_OutPutPath filesep Hemisphere{hemi} '_Voxel_Group_SilhouetteValue.mat'], 'Group_silh');
        xlabel('Silhouette Value');
        ylabel('Cluster');
        saveas(h, [Sub_OutPutPath filesep Hemisphere{hemi} '_Silhouette_Plot.jpg']);
        Group_SilhouetteValue(hemi, ParcelNum) = mean(Group_silh);
        ParcelMap = zeros(size(IndexMap));
        for i = 1:length(Group_idx)
            ParcelMap(Parcel(i,1)) = Parcel(i,2);
        end
        
        % Saving the final partition map
        OutputMap = TP;
        OutputMap.img = ParcelMap;
        save_nii(OutputMap, [Sub_OutPutPath filesep Hemisphere{hemi} '_ParcelMap.nii']);
    end
end

% plot the silhouette value
SVplot = plot(Group_SilhouetteValue');
xlabel('Number of Cluster','FontSize',18);
ylabel('Silhouette Value','FontSize',18);
SVplot(1).LineWidth = 2;
SVplot(2).LineWidth = 2;
SVplot(1).Color = 'r';
SVplot(2).Color = 'b';
SVplot(1).Marker = '*';
SVplot(2).Marker = '.';
SVplot(1).MarkerSize = 15;
SVplot(2).MarkerSize = 30;
legend('Left TP', 'Right TP','FontSize',15)
saveas(h, [OutputPath filesep 'Group_SilhouetteValue_Plot.jpg']);
save([OutputPath filesep 'Group_SilhouetteValue.mat'],'Group_SilhouetteValue');