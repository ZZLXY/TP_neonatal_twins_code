% Install the libsvm-3.22 toolbox (Chang & Lin, 2011) before running this script 
addpath(genpath('XXX/libsvm-3.22'));
% Read you data files
load('your_data_file.mat'); 
%The data file includes:
% 1）Activity_3Subdivision: A matrix that stores the variables to be predicted.
% 2）FCPattern_3Subdivision: A cell array that stores the feature matrices.
% 3）sigpair: A pre-defined matrix that stores the label pairs of the features and their corresponding performances. 
%            These labels will be used below to identify which features and performances to use for each prediction task.
% 4）subseq: A matrix that stores the pre-generated random numbers, which 
%            are used to shuffle the true data for the permutation test.

[nTask, ~] = size(sigpair); 

for iterationno=1:nTask 
    %Find the variable that is currently being predicted
    performanceindex=sigpair(iterationno,2); 
    tempperformance=Activity_3Subdivision(:,performanceindex); 
    
    tempnanindex=find(isnan(Activity_3Subdivision(:,performanceindex))); 
    tempperformance(tempnanindex')=[];
    
    %Find the feature matrix that is currently being used
    tempregion_specfic_data=FCPattern_3Subdivision{sigpair(iterationno,1)}; 
    tempregion_specfic_data(tempnanindex',:)=[]; 
    
    % Perform the prediction
    [performance_fc_pearson(iterationno), performance_fc_pearson_p(iterationno)]=SVR_continuous_label_normalization(tempregion_specfic_data, tempperformance);
    
    % Perform the prediction based on shuffled data
   for shuffleno=1:10000
       % Shuffle the data based on pre-generated random numbers
       tempperformanceshuffle=tempperformance(subseq(:,shuffleno));

       [performance_fc_pearson_permutation(iterationno,shuffleno), performance_fc_pearson_p_permutation(iterationno,shuffleno)]=SVR_continuous_label_normalization(tempregion_specfic_data, tempperformanceshuffle);

       clear tempregion_specfic_datashuffle tempperformanceshuffle;
   end
    clear tempregion_specfic_data;
    clear temp*;
end

 save('Results/PredictResults.mat', 'performance_fc_pearson', 'performance_fc_pearson_permutation', 'performance_fc_pearson_p','performance_fc_pearson_p_permutation');
 
