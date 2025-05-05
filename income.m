clear;
clc;
close all;

            % Load the data
            muc4a = readtable('muc4a.csv');
            muc123a = readtable('muc123a.csv');
            hh_expe = readtable('hhexpe08.csv');  
            muc5b3 = readtable('muc5b3.csv');
        
            %% Income
            % Merge tables on keys: tinh, diaban, hoso, matv
            merged = outerjoin(muc4a, muc123a, ...
                'Keys', {'tinh','huyen','xa', 'diaban', 'hoso', 'matv'}, ...
                'MergeKeys', true);
            merged = outerjoin(merged, hh_expe, ...
                    'Keys', {'tinh','huyen','xa', 'diaban', 'hoso'}, ...
                    'MergeKeys', true);
            % Keep only household heads who are male
            is_male_head = merged.m1ac3 == 1 & merged.m1ac2 == 1;
         
            % Keep only valid income entries
            valid_income = merged.m4ac11 > 0 & ~ismissing(merged.m4ac11);
            
            % Filter the merged table
            merged1 = merged(is_male_head & valid_income, :);
            
            % Compute log income
            incomeVars = {'m4ac11','m4ac12f','m4ac22f','m4ac21','m4ac25'};
for i = 1:numel(incomeVars)
    v = incomeVars{i};
    merged1.(v)( isnan(merged1.(v)) ) = 0;
end
merged1.totalIncome = sum( merged1{:, incomeVars}, 2 );

            i = merged1.totalIncome;
            par.i = i ;
            log_income = log(merged1.totalIncome);
            par.income = log_income;

            ages = merged1.m1ac5;
            [G, age_values] = findgroups(ages);
            mean_log_income = splitapply(@mean, log_income, G);
            
            % Exponentiate to get Gt
            Gt = exp(mean_log_income);
            
            % Display results
            results = table(age_values, Gt, ...
                'VariableNames', {'Age', 'Gt'});
            disp(results);
            writetable(results, 'G_by_age.csv');

            %% Determinant of consumption
             % Merge tables on keys: tinh, diaban, hoso, matv
            merged2 = outerjoin(muc4a, muc5b3, ...
                'Keys', {'tinh','huyen','xa', 'diaban', 'hoso'}, ...
                'MergeKeys', true);
            merged2 = outerjoin(merged2, hh_expe, ...
                    'Keys', {'tinh','huyen','xa', 'diaban', 'hoso'}, ...
                    'MergeKeys', true);

