function [R2] = cross_validation_R2(predicted_value, observed_value)

%% This function is used to compute the cross-validation R2 for SVR analysis following Poldrack et al., 2020, JAMA psychiatry



top=abs(predicted_value-observed_value).^2;
topsum=sum(top(:));
bottom=abs((mean(observed_value))-observed_value).^2;
bottomsum=sum(bottom(:));

R2=1-(topsum/bottomsum);