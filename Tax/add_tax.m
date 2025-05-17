clear;
clc;
close all;

% Load the data
muc4a = readtable('muc4a.csv');
muc123a = readtable('muc123a.csv');
hh_expe = readtable('hhexpe08.csv');  
muc5b3 = readtable('muc5b3.csv');

merged = outerjoin(muc4a, muc123a, ...
                'Keys', {'tinh','huyen','xa', 'diaban', 'hoso', 'matv'}, ...
                'MergeKeys', true);
merged = outerjoin(merged, hh_expe, ...
                    'Keys', {'tinh','huyen','xa', 'diaban', 'hoso'}, ...
                    'MergeKeys', true);
merged = outerjoin(merged, muc5b3, ...
                    'Keys', {'tinh','huyen','xa', 'diaban', 'hoso'}, ...
                    'MergeKeys', true);

% Keep only household heads who are male
is_male_head = merged.m1ac3 == 1 & merged.m1ac2 == 1;
         
% Keep only valid income entries
valid_tax = merged.m5b3c1 == 403 & merged.m5b3c2 > 0 & ~ismissing(merged.m4ac11);

% Filter the merged table
filtered = merged(is_male_head & valid_tax, :);
            
            % Compute log tax
            i = filtered.m5b3c2;
            par.i = i ;
            log_tax = log(filtered.m5b3c2);
            par.tax = log_tax;
            % Group by age and compute mean log tax
            ages = filtered.m1ac5;
            [t, age_values] = findgroups(ages);
            mean_log_tax = splitapply(@mean, log_tax, t);
            
            % Exponentiate to get Gt
            Tt = exp(mean_log_tax);
            
            % Display results
            results = table(age_values, Tt, ...
                'VariableNames', {'Age', 'Tt'});
            disp(results);
            
            % Optional: save to CSV
            writetable(results, 'Tt_by_age.csv');