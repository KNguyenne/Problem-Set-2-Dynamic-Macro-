% Đọc dữ liệu từ file CSV 
clc
clear
close all

% This file is to split firms into large and small firms depending on the size of the firms' revenue

data = readtable('Vietnam_2005_2009_2015.csv', 'VariableNamingRule', 'preserve');

% Define column names
id_col = 'id2015';
l1_col = 'l1';
n5a_col = 'n5a';
n5b_col = 'n5b';

n2a_col = 'n2a';
n2e_col = 'n2e';
n2f_col = 'n2f';
n2b_col = 'n2b';
n2i_col = 'n2i';
n3_col  = 'n3';
d2_col = 'd2';
k11_col = 'k11';


% Filter rows with valid data
validRows = ...
    ~isnan(data.(id_col)) & ...
    data.(l1_col) ~= 0 & ...
    data.(n5a_col) ~= -9 & ...
    data.(n5b_col) ~= -9 & ...
    data.d2 ~= -9 & ...
    ~ismember(data.(n2a_col), [-7, -8]) & ...
    ~ismember(data.(n2e_col), [-7, -8]) & ...
    ~ismember(data.(n2f_col), [-7, -8]) & ...
    ~ismember(data.(n2b_col), [-7, -8]) & ...
    ~ismember(data.(k11_col), [-8, -9]) & ...
    ~ismember(data.(n3_col), [-7, -9]);

filteredData = data(validRows, :);

% Compute median of l1
filteredData.avg_revenue = filteredData.(d2_col)/1e6;
median_avg_revenue = median(filteredData.avg_revenue);

% Assign group labels
group = strings(height(filteredData), 1);
group(filteredData.avg_revenue > median_avg_revenue) = "large";
group(filteredData.avg_revenue < median_avg_revenue) = "small";
group(filteredData.avg_revenue == median_avg_revenue) = "large";

% Compute capital in millions
capital_mil = (filteredData.(n5a_col) + filteredData.(n5b_col)) / 1e6;

% Compute total cost
filteredData.total_cost = (filteredData.(n2a_col) + ...
             filteredData.(n2e_col) + ...
             filteredData.(n2f_col) + ...
             filteredData.(n2b_col))/ 1e6;


% Compute profit
filteredData.profit = filteredData.avg_revenue - filteredData.total_cost;

% Compute debt
filteredData.debt = filteredData.k11 / 1e6;

% Create the result table
resultTable = table( ...
    filteredData.(id_col), ...
    group, ...
    capital_mil, ...
    filteredData.total_cost, ...
    filteredData.avg_revenue, ...
    filteredData.debt, ...
    filteredData.profit, ...
    'VariableNames', {'id2015', 'group', 'capital', 'total_cost', ...
    'avg_revenue', 'debt','profit'});

% Display the result
disp(resultTable);

% Select variables of interest
capital = resultTable.capital;
total_cost = resultTable.total_cost;
avg_revenue = resultTable.avg_revenue;
debt = resultTable.debt;
profit = resultTable.profit;

% Combine into matrix
analysisVars = [capital, total_cost, avg_revenue, debt, profit];

% Remove rows with any NaN
validRows = all(~isnan(analysisVars), 2);
cleanedVars = analysisVars(validRows, :);

% Compute correlation matrix
corrMatrix = corr(cleanedVars, 'Type', 'Pearson');

% Define variable names
varNames = {'Investment', 'Total_Cost', 'Avg_Revenue', 'Debt', 'Profit'};

% Display the correlation matrix
disp('Correlation matrix between financial variables:');
disp(array2table(corrMatrix, 'VariableNames', varNames, 'RowNames', varNames));