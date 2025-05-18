%% Simulate class.

classdef simulate
    methods(Static)
        %% Simulate the model. 
        
        function sim = lc(par,sol)            
            %% Set up.
            
            agrid = par.agrid; % Assets today (state variable).

            apol = sol.a; % Policy function for capital.
            cpol = sol.c; % Policy function for consumption.

            TT = par.TT; % Time periods.
            NN = par.NN; % People.
            T = par.T; % Life span.
            tr = par.tr; % Retirement.
            G = par.G; 

            kappa = par.kappa; % Share of income as pension.
            ygrid = par.ygrid; % Exogenous income.
            pmat = par.pmat; % Transition matrix.

            ysim = nan(TT,NN); % Container for simulated income.
            asim = nan(TT,NN); % Container for simulated savings.
            tsim = nan(TT,NN); % Container for simulated age.
            csim = nan(TT,NN); % Container for simulated consumption.
            usim = nan(TT,NN); % Container for simulated utility.
            
            %% Begin simulation.
            
            rng(par.seed);

            pmat0 = pmat^100; % Stationary distribution.
            cmat = cumsum(pmat,2); % CDF matrix.

            y0_ind = randsample(par.ylen,NN,true,pmat0(1,:))'; % Initial income index.
            a0_ind = randsample(par.alen,NN,true)'; % Initial wealth index.
            t0_ind = randsample(T,NN,1); % Start at age 1.
            yr = nan(NN,1); % Retirement income.

            for i = 1:NN % Person loop.
                if t0_ind(i) >= tr
                    yr(i) = ygrid(y0_ind(i)); % Store for pension.
                    ysim(1,i) = G(tr-1) .* kappa.*yr(i); % Pension in period 0 given age.
                else
                    ysim(1,i) = ygrid(y0_ind(i)); % Pension in period 0 given age.
                end

                % Initial period (age = 1)
                tsim(1,i) = t0_ind(i); % Age
                csim(1,i) = cpol(a0_ind(i), t0_ind(i), y0_ind(i)); % Consumption
                asim(1,i) = apol(a0_ind(i), t0_ind(i), y0_ind(i)); % Next period's assets
                
                if t0_ind(i) == tr-1
                    yr(i) = G(tr-1) .* ygrid(y0_ind(i)); % Set pension base
                elseif t0_ind(i) < tr-1
                    y1_ind = find(rand <= cmat(y0_ind(i), :), 1, 'first');
                    y0_ind(i) = y1_ind(1);
                end
            end

            usim(1,:) = model.utility(csim(1,:), par); % Initial utility

            %% Simulate endogenous variables.

            for j = 2:TT % Time loop.
                for i = 1:NN % Person loop.

                    age = tsim(j-1,i) + 1; % Current age

                    if age <= T % Alive
                        % Determine income
                        if age >= tr
                            ysim(j,i) = kappa * G(tr-1) * yr(i); % Pension
                        else
                            ysim(j,i) = G(age) .* ygrid(y0_ind(i)); % Working income
                        end
                        
                        tsim(j,i) = age;
                        at_ind = find(agrid == asim(j-1,i), 1);
                        csim(j,i) = cpol(at_ind, age, y0_ind(i));
                        asim(j,i) = apol(at_ind, age, y0_ind(i));
                        usim(j,i) = model.utility(csim(j,i), par);
                        
                        % Update income state if working and not retiring next period
                        if age == tr-1 % Retire next period
                            yr(i) = G(tr-1) .* ygrid(y0_ind(i)); % Set pension base
                        elseif age < tr-1
                            y1_ind = find(rand <= cmat(y0_ind(i), :), 1, 'first');
                            y0_ind(i) = y1_ind(1);
                        end
                    end
                end
            end

            sim = struct();
            sim.ysim = ysim;
            sim.asim = asim;
            sim.tsim = tsim;
            sim.csim = csim;
            sim.usim = usim;
        end
    end
end