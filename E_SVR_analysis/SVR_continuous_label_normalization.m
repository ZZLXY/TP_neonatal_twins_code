function [cor_temp_pearson,p_temp_pearson, Test_label_outcome, predicted_labels]=SVM_continuous_label_normalization(Subjects_Data, Subjects_Label, Pre_Method)
%
% Subject_Data:
%           m*n matrix
%           m is the number of subjects
%           n is the number of features
%
% Subject_Label:
%           array of 0 or 1, or continous variables
%
% ResultantFolder:
%           the path of folder storing resultant files
%

[Subjects_Quantity Feature_Quantity] = size(Subjects_Data);

for i = 1:Subjects_Quantity
    
    disp(['The ' num2str(i) ' iteration!']);
    
    Subjects_Data_tmp = Subjects_Data;
    Subjects_Label_tmp = Subjects_Label;
    % Select training data and testing data
    test_label = Subjects_Label_tmp(i);
    test_data = Subjects_Data_tmp(i, :);
    
    Subjects_Label_tmp(i) = [];
    Subjects_Data_tmp(i, :) = [];

    Training_all_data =Subjects_Data_tmp;
    Label=Subjects_Label_tmp;
    
    
    if strcmp(Pre_Method, 'Normalize')
        %Normalize
        MeanValue = mean(Training_all_data);
        StandardDeviation = sqrt(var(Training_all_data));
        [rows, columns_quantity] = size(Training_all_data);
        for j = 1:columns_quantity
            Training_all_data(:, j) = (Training_all_data(:, j) - MeanValue(j)) / StandardDeviation(j);
        end
        MeanValuelabel=mean(Label);
        StandardDeviationlabel = sqrt(var(Label));
        Label=(Label-MeanValuelabel)/StandardDeviationlabel;
        
        
    elseif strcmp(Pre_Method, 'Scale')
        % Scale to [0 1]
        MinValue = min(Training_all_data);
        MaxValue = max(Training_all_data);
        [rows, columns_quantity] = size(Training_all_data);
        for j = 1:columns_quantity
            Training_all_data(:, j) = (Training_all_data(:, j) - MinValue(j)) / (MaxValue(j) - MinValue(j));
        end
    end

    % SVR classification
    Label = reshape(Label, length(Label), 1);
    Training_all_data = double(Training_all_data);
    model(i) = svmtrain(Label, Training_all_data,'-s 3 -t 2');

    if strcmp(Pre_Method, 'Normalize')
        % Normalize
        test_data = (test_data - MeanValue) ./ StandardDeviation;
        test_label= (test_label- MeanValuelabel)/StandardDeviationlabel;
    elseif strcmp(Pre_Method, 'Scale')
        % Scale
        test_data = (test_data - MinValue) ./ (MaxValue - MinValue);
    end

    % predicts
    test_data = double(test_data);
    Test_label_outcome(i,1)=test_label;
    [predicted_labels(i,1), accuracy, tmp] = svmpredict(test_label, test_data, model(i));
    
end

[cor_temp_pearson,p_temp_pearson]=corr(predicted_labels,Test_label_outcome,'Type','Pearson','Tail','right');
