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
        
            G = par.G;   % G(1),…,G(T)
            rho = par.rho;
            
            %% Initialize containers
            v1 = nan(alen, T, ylen);
            a1 = nan(alen, T, ylen);
            c1 = nan(alen, T, ylen);
        
            amat = repmat(agrid, 1, ylen);
            ymat = repmat(ygrid, alen, 1);
        
            fprintf('------------Solving from the Last Period of Life.------------\n\n')
            for age = 1:T
                t = T - age + 1;
        
                if t == T
                    c1(:, T, :) = amat + kappa * ymat;
                    a1(:, T, :) = 0;
                    v1(:, T, :) = model.utility(c1(:, T, :), par);
                 else
                    for i = 1:ylen
                     if t < tr
                yt = G(t) * ygrid(i);
                ev = squeeze( v1(:,T-age+2,:) ) * pmat(i,:)';
                     else
                yt = kappa * (G(tr-1) * ygrid(i));
                ev = v1(:,T-age+2,i);
                    end

                        for p = 1:alen % Loop over the a-states.
                            
                            % Consumption
                            ct = agrid(p)+yt-(agrid./(1+r)); % Possible values for consumption, c = a + y - (a'/(1+r)), given a and y.
                            ct(ct<0.0) = 0.0;
    
                            % Solve the maximization problem.
                            vall = model.utility(ct,par) + beta*ev; % Compute the value function for each choice of a', given a.
                            vall(ct<=0.0) = -inf; % Set the value function to negative infinity when c <= 0.
                            [vmax,ind] = max(vall); % Maximize: vmax is the maximized value function; ind is where it is in the grid.
        
                            v1(p,T-age+1,i) = vmax; % Maximized v.
                            c1(p,T-age+1,i) = ct(ind); % Optimal c'.
                            a1(p,T-age+1,i) = agrid(ind); % Optimal a'.
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