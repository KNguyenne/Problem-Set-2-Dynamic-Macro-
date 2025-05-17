clear;
clc;
close all;

% Load the data
muc4a = readtable('muc4a.csv');
muc123a = readtable('muc123a.csv');
hh_expe = readtable('hhexpe08.csv');  
muc5b3 = readtable('muc5b3.csv');

% Merge tables on keys
merged = outerjoin(muc4a, muc123a, ...
    'Keys', {'tinh','huyen','xa', 'diaban', 'hoso', 'matv'}, ...
    'MergeKeys', true);
merged = outerjoin(merged, hh_expe, ...
    'Keys', {'tinh','huyen','xa', 'diaban', 'hoso'}, ...
    'MergeKeys', true);

% Keep only male household heads
is_male_head = merged.m1ac3 == 1 & merged.m1ac2 == 1;

% Define income variable names
incomeVars = {'m4ac11','m4ac12f','m4ac22f','m4ac21','m4ac25'};
for i = 1:numel(incomeVars)
    var = incomeVars{i};
    merged.(var)( isnan(merged.(var)) ) = 0;
end

% Compute total income
merged.totalIncome = sum( merged{:, incomeVars}, 2 );

% Filter for male household heads with valid income and age >= 18
ages = merged.m1ac5;
valid_income = merged.totalIncome > 0 & is_male_head & ages >= 18;
merged1 = merged(valid_income, :);

% Log income
log_income = log(merged1.totalIncome);
par.i = merged1.totalIncome;
par.income = log_income;

% Group by age and compute Gt
ages = merged1.m1ac5;
[G, age_values] = findgroups(ages);
mean_log_income = splitapply(@mean, log_income, G);
Gt = exp(mean_log_income);

% Output results
results = table(age_values, Gt, 'VariableNames', {'Age', 'Gt'});
disp(results);
writetable(results, 'G_by_age.csv');
