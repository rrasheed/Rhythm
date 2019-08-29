function normData = normalize_data(data,Fs)
%% The function normalizes CMOS data between 0 and 1

% INPUTS
% data = cmos data
% Fs = sampling frequency

% OUTPUT
% normData = normalized data matrix

% METHOD
% Normalize data finds the minimum, maximum, and the difference in
% data values. The normalized data subtracts off the minimum values and 
% divides by the difference between the min and max. 

%% Code
disp('(normalize_data.m) Starting ')

disp('(normalize_data.m) Calculation min_data... ')
min_data = repmat(min(data,[],3), [1 1 size(data,3)]);

disp('(normalize_data.m) Calculation diff_data... ')
diff_data = repmat(max(data,[],3) - min(data,[],3), [1 1 size(data,3)]);
% normData = (data-min_data)./(diff_data);
% data_temp = data - min_data;

% Subtraction
disp('(normalize_data.m) Subtraction... ')
% data_temp = bsxfun(@minus, data, min_data);
data = bsxfun(@minus, data, min_data);
clear min_data

% Division
disp('(normalize_data.m) Division... ')
normData = rdivide(data, diff_data);
clear diff_data

disp('(normalize_data.m) Done ')
% % %% NON RECTANGULAR POLYGON MOD
% % min_data = repmat(min(data,[],2),[1 size(data,2)]);
% % diff_data = repmat(max(data,[],2),[1 size(data,2)])-min_data;
% % normData = (data-min_data)./diff_data;