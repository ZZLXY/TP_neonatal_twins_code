function m = Calculate_FC_ROI_to_ROI(SubID)

%Defining where are the runs, the run number, and the path of the runs
RunPath = 'you data path';
RunDir(1) = dir([RunPath filesep '*RWCFS']);

RunNum = length(RunDir);

%OUTPUT PATH
OutputPath = 'XXX';

% Defining Seed path
ROIpath = 'XXX';
ROIname = dir([ROIpath filesep '*mask.nii']);

ROINum = length(ROIname); 

%LOAD TP SUBREGIONS MASK
TPSubregion = load_nii('XXX/*.nii'); 
TPSubregionMask = double(TPSubregion.img);
SubRegionNum=max(max(max(TPSubregionMask)));

%define the final FC matrix
SubRegionFC = zeros(SubRegionNum,ROINum);

for Run = 1:RunNum
    SubDir = dir([RunPath filesep RunDir(Run).name filesep 'Sub*']); 
    RootFolder = [RunPath filesep RunDir(Run).name filesep SubDir(SubID).name];
    %load the data of subjects
    SubData = load_nii([RootFolder filesep 'XXX.nii']);
    SubMap = double(SubData.img);
    [sDim1,sDim2,sDim3,sDim4] = size(SubMap);
    Sub_tmp=reshape(SubMap, sDim1*sDim2*sDim3,sDim4); 
    ROI_tmp = zeros(ROINum,sDim4);
    SubRegion_tmp = zeros(SubRegionNum, sDim4);
    for ROI = 1:ROINum
        CurrentROI = load_nii([ROIpath filesep ROIname(ROI).name]);
        CurrentROI_Mask = double(CurrentROI.img);
        index = find(CurrentROI_Mask == 1);
        SubROI_mean = mean(Sub_tmp(index, :));
        ROI_tmp(ROI,:) = SubROI_mean;
    end
    
    for SubRegion = 1:SubRegionNum
        SubRegion_index = find((TPSubregionMask>(SubRegion-0.5))&(TPSubregionMask<(SubRegion+0.5)));
        CurrentSubRegion_tmp = mean(Sub_tmp(SubRegion_index, :));
        SubRegion_tmp(SubRegion, :) = CurrentSubRegion_tmp;
    end
    
    for i = 1:ROINum
        CurrentROI_tmp = ROI_tmp(i,:);

        for j = 1:SubRegionNum
            Curr_SubRegion_tmp = SubRegion_tmp(j, :);

             FC = corrcoef(CurrentROI_tmp, Curr_SubRegion_tmp, 'row','complete');
             FC_Fisher = 0.5*log((1 + FC(1,2))./(1 - FC(1,2)));
             SubRegionFC(j,i) = SubRegionFC(j,i) + FC_Fisher/RunNum;
        end
    end 
end     
save([OutputPath filesep SubDir(SubID).name '.mat'], 'SubRegionFC'); 

m = 'finished';