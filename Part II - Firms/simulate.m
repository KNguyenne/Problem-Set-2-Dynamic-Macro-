%% File Info.
%{
    simulate.m
    ----------
    This code simulates the model for multiple firms, including productivity
    and price shocks.
%}

%% Simulate class.
classdef simulate
    methods(Static)
        function sim = firm_dynamics(par, sol)
            %% Set up
            kgrid = par.kgrid;       % Capital grid
            Agrid = par.Agrid;       % Productivity grid
            pgrid = par.pgrid;       % Price grid

            vpol = sol.v;            % Value function
            kpol = sol.k;            % Capital policy
            ipol = sol.i;            % Investment policy
            rpol = sol.r;            % Revenue
            epol = sol.e;            % Expenditure
            ppol = sol.p;            % Profit

            T = par.T;               % Time periods
            N = par.N;               % Number of firms
            burn = T;                % Burn-in periods

            %% Containers for simulation results
            Asim = zeros(2*T, N);
            Psim = zeros(2*T, N);
            vsim = zeros(2*T, N);
            ksim = zeros(2*T, N);
            isim = zeros(2*T, N);
            esim = zeros(2*T, N);
            psim = zeros(2*T, N);

            %% Initialization
            rng(par.seed);           % Set random seed for reproducibility

            % Stationary distributions for A and P
            pmat0 = par.pmat^1000;
            pmat0 = pmat0(1,:);
            ppmat0 = par.pmat_p^1000;
            ppmat0 = ppmat0(1,:);

            % CDF matrices
            Acdf = cumsum(par.pmat, 2);       % For productivity
            Pcdf = cumsum(par.pmat_p, 2);     % For prices

            % Initial indices
            k0_ind = randsample(par.klen, N, true);
            A0_ind = randsample(par.Alen, N, true, pmat0);
            P0_ind = randsample(par.plen, N, true, ppmat0);

            %% Initial values
            for i = 1:N
                Asim(1,i) = Agrid(A0_ind(i));
                Psim(1,i) = pgrid(P0_ind(i));
                vsim(1,i) = vpol(k0_ind(i), A0_ind(i), P0_ind(i));
                ksim(1,i) = kpol(k0_ind(i), A0_ind(i), P0_ind(i));
                isim(1,i) = ipol(k0_ind(i), A0_ind(i), P0_ind(i));
                rsim(1,i) = rpol(k0_ind(i), A0_ind(i), P0_ind(i));
                esim(1,i) = epol(k0_ind(i), A0_ind(i), P0_ind(i));
                psim(1,i) = ppol(k0_ind(i), A0_ind(i), P0_ind(i));

                % Draw next productivity and price indices
                uA = rand;
                A0_ind(i) = find(uA <= Acdf(A0_ind(i), :), 1);

                uP = rand;
                P0_ind(i) = find(uP <= Pcdf(P0_ind(i), :), 1);
            end

            %% Simulation loop
            for t = 2:(2*T)
                for i = 1:N
                    % Find index of closest current capital
                    [~, kt_ind] = min(abs(kgrid - ksim(t-1,i)));

                    % Record states and policies
                    Asim(t,i) = Agrid(A0_ind(i));
                    Psim(t,i) = pgrid(P0_ind(i));
                    vsim(t,i) = vpol(kt_ind, A0_ind(i), P0_ind(i));
                    ksim(t,i) = kpol(kt_ind, A0_ind(i), P0_ind(i));
                    isim(t,i) = ipol(kt_ind, A0_ind(i), P0_ind(i));
                    rsim(t,i) = rpol(kt_ind, A0_ind(i), P0_ind(i));
                    esim(t,i) = epol(kt_ind, A0_ind(i), P0_ind(i));
                    psim(t,i) = ppol(kt_ind, A0_ind(i), P0_ind(i));

                    % Draw next productivity and price indices
                    uA = rand;
                    A0_ind(i) = find(uA <= Acdf(A0_ind(i), :), 1);

                    uP = rand;
                    P0_ind(i) = find(uP <= Pcdf(P0_ind(i), :), 1);
                end
            end

            %% Collect and burn-in
            sim = struct();
            sim.Asim = Asim(burn+1:end, :);
            sim.Psim = Psim(burn+1:end, :);
            sim.vsim = vsim(burn+1:end, :);
            sim.ksim = ksim(burn+1:end, :);
            sim.isim = isim(burn+1:end, :);
            sim.rsim = rsim(burn+1:end, :);
            sim.esim = esim(burn+1:end, :);
            sim.psim = psim(burn+1:end, :);

            %% Compute firm‐level summary revenue and classification
            
            avg_rev = mean(sim.rsim, 1);      % average revenues
            med_rev = median(avg_rev);        % scalar median revenue

            % Logical index for “large” firms
            is_large = avg_rev > med_rev;     % 1×N logical array

            % Store results back into sim
            sim.avg_rev    = avg_rev;
            sim.median_rev = med_rev;
            sim.is_large   = is_large;        % true = large, false = small
            sim.large_firms = find(is_large);      % indices of large firms
            sim.small_firms = find(~is_large);     % indices of small firms

            %% Split each time series into large vs. small
            fields = {'Asim','Psim','vsim','ksim','isim','rsim','esim','psim'};
            for f = 1:numel(fields)
                fld = fields{f};
                data = sim.(fld);      % T×N
                sim.([fld '_large']) = data(:, sim.large_firms);
                sim.([fld '_small']) = data(:, sim.small_firms);
            end
        end
    end
end
