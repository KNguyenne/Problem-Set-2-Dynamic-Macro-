%% Solve class.

classdef solve
    methods(Static)
        %% Solve the model using BI. 
        function sol = lc(par)
            sol = struct();
            
            %% Extract parameters
            T = par.T;
            tr = par.tr;
            beta = par.beta;
            r = par.r;
            kappa = par.kappa;
        
            alen = par.alen;
            agrid = par.agrid;
        
            ylen = par.ylen;
            ygrid = par.ygrid;
            pmat = par.pmat;
        
            G = par.G;            
            
            %% Initialize containers
            v1 = nan(alen, T, ylen);
            a1 = nan(alen, T, ylen);
            c1 = nan(alen, T, ylen);
        
            amat = repmat(agrid, 1, ylen);
            ymat = repmat(ygrid, alen, 1);
        
            fprintf('------------Solving from the Last Period of Life.------------\n\n')
            % Inside the for loop over age
            for age = 1:T
                t = T - age + 1;
                if t == T
                    c1(:, T, :) = amat + kappa * ymat;
                    a1(:, T, :) = 0;
                    v1(:, T, :) = model.utility(c1(:, T, :), 0, par);
                else
                    for i = 1:ylen
                        if t < tr
                            tt = par.Tax(t); % Tax at age t
                            gt = tt;           % Government spending benefit at age t
                            yt = G(t) * ygrid(i);
                            ev = squeeze(v1(:, T - age + 2, :)) * pmat(i, :)';
                        else
                            tt=0;
                            gt=0;
                            yt = kappa * (G(tr - 1) * ygrid(i));
                            ev = squeeze(v1(:, T - age + 2, :)) * pmat(i, :)';
                        end
            
                        for p = 1:alen
                            % Consumption calculation with tax
                            ct = agrid(p) + yt - tt - (agrid / (1 + r));
                            ct(ct < 0.0) = 0.0;
            
                            % Utility calculation with government spending benefit
                            vall = model.utility(ct, gt, par) + beta * ev;
                            vall(ct <= 0.0) = -inf;
                            [vmax, ind] = max(vall);
            
                            v1(p, T - age + 1, i) = vmax;
                            c1(p, T - age + 1, i) = ct(ind);
                            a1(p, T - age + 1, i) = agrid(ind);
                        end
                    end
                end
            
                if mod(t, 5) == 0
                    fprintf('Age: %d.\n', t);
                end
            end
        
            fprintf('------------Life Cycle Problem Solved.------------\n')
        
            sol.c = c1;
            sol.a = a1;
            sol.v = v1;
        end
    end
end