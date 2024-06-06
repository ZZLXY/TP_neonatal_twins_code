function m = Calculate_FC_Seed_to_Voxel(SubID)

%Defining where are the runs, the run number, and the path of the runs
RunPath = 'you data path';
RunDir(1) = dir([RunPath filesep '*RWCFS']);

RunNum = length(RunDir);

%OUTPUT PATH
OutputPath = 'The output path';
SubregionLabel = {'XXX', 'XXX', 'XXX'};

% Defining ROI Mask
ROI = load_nii('XXX'); 
ROIMask = double(ROI.img);
[Dim1, Dim2, Dim3] = size(ROIMask);
%Load seed mask
Seedregion = load_nii('XXX'); 
SeedregionMask = double(Seedregion.img);
SeedRegionNum=max(max(max(SeedregionMask)));
for SubRegion = 1:SeedRegionNum
    SubRegion_FCMap = zeros(Dim1, Dim2, Dim3);
    SubRegion_index = find((SeedregionMask>(SubRegion-0.5))&(SeedregionMask<(SubRegion+0.5)));
    for Run = 1:RunNum
        SubDir = dir([RunPath filesep RunDir(Run).name filesep 'Sub*']); 
        RootFolder = [RunPath filesep RunDir(Run).name filesep SubDir(SubID).name];
        %load the data of subjects
        SubData = load_nii([RootFolder filesep 'XXX.nii']);
        SubMap = double(SubData.img);
        [sDim1,sDim2,sDim3,sDim4] = size(SubMap);
        Sub_tmp=reshape(SubMap, sDim1*sDim2*sDim3, sDim4); 
        CurrentSubRegion_tmp = mean(Sub_tmp(SubRegion_index,:));
        for i = 1:Dim1
            for j = 1:Dim2
                for k = 1:Dim3
                    if ROIMask(i,j,k) == 1
                        SubMap_Voxel_t = reshape(SubMap(i,j,k,:),1,sDim4);
                        FC = corrcoef(CurrentSubRegion_tmp, SubMap_Voxel_t, 'row','complete');
                        FC_Fisher = 0.5*log((1 + FC(1,2))./(1 - FC(1,2)));
                        SubRegion_FCMap(i,j,k) = SubRegion_FCMap(i,j,k) + FC_Fisher/RunNum;
                    else
                        SubRegion_FCMap(i,j,k) = 0;
                    end
                end
            end
        end
    end
    Curr_SubregionFC = ROI;
    Curr_SubregionFC.img = SubRegion_FCMap;
    save_nii(Curr_SubregionFC,[OutputPath filesep SubregionLabel{SubRegion} filesep SubDir(SubID).name '.nii' ]);
end

m = 'finished';