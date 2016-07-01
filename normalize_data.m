function normData1 = normalize_data(data1,Fs)
%% The function normalizes CMOS data between 0 and 1

% INPUTS
% data1 = cmos (Voltage) data
% data2 = cmos (Calcium) data
% Fs = sampling frequency

% OUTPUT
% normData = normalized voltage data matrix
% normData2 = normalized calcium data matrix

% METHOD
% Normalize data finds the minimum, maximum, and the difference in
% data values. The normalized data subtracts off the minimum values and 
% divides by the difference between the min and max. 

%% Code
min_data1 = repmat(min(data1,[],3),[1 1 size(data1,3)]);
diff_data1 = repmat(max(data1,[],3)-min(data1,[],3),[1 1 size(data1,3)]);
normData1 = (data1-min_data1)./(diff_data1);
% % %% NON RECTANGULAR POLYGON MOD
% % min_data = repmat(min(data,[],2),[1 size(data,2)]);
% % diff_data = repmat(max(data,[],2),[1 size(data,2)])-min_data;
% % normData = (data-min_data)./diff_data;