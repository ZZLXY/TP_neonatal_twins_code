% Install the libsvm-3.22 toolbox (Chang & Lin, 2011) before running the script 

addpath(genpath('XXX/libsvm-3.22'));
load('your_data_file.mat');% Read you data files
[nTask, ~] = size(sigpair);
for iterationno=1:nTask 
    performanceinex=sigpair(iterationno,2); 
    
    tempnanindex=find(isnan(Activity_3Subdivision(:,performanceinex))); 
    tempperformance=Activity_3Subdivision(:,performanceinex);  %Find the variable that is currently being predicted

    tempperformance(tempnanindex')=[];
    
    tempR2R_region=FCPattern_3Subdivision{sigpair(iterationno,1)}; %Find the feature matrix that will be used
    tempR2R_region(tempnanindex',:)=[]; 

    tempN=N-length(tempnanindex);

    tempregion_specfic_data=tempR2R_region; 

   for shuffleno=1:10000
       % Shuffle the data based on pre-generated random numbers
       tempregion_specfic_datashuffle=tempregion_specfic_data(subseq{1,subi}(:,shuffleno),:);
       tempperformanceshuffle=tempperformance(subseq{1,subi}(:,shuffleno));

       [performance_fc_pearson(iterationno,shuffleno), performance_fc_pearson_p(iterationno,shuffleno)],...
           =SVR_continuous_label_normalization(tempregion_specfic_data, tempperformance, 'Normalize');

       [performance_fc_pearson_permutation(iterationno,shuffleno), performance_fc_pearson_p_permutation(iterationno,shuffleno)],...
           =SVR_continuous_label_normalization(tempregion_specfic_data, tempperformanceshuffle, 'Normalize');

       clear tempregion_specfic_datashuffle tempperformanceshuffle;
   end
    clear tempregion_specfic_data;
    clear temp*;
end

 save(['Results/PredictResults.mat'],'performance_fc_pearson', 'performance_fc_pearson_permutation',...
     'performance_fc_pearson_p','performance_fc_pearson_p_permutation');
