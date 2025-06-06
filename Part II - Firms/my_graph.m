%% File Info.
%{
    my_graph.m
    ----------
    This code plots the value and policy functions and the time path of the variables.
%}

%% Graph class.

classdef my_graph
    methods(Static)
        function [] = plot_policy(par, sol, sim)
          %% Fix p index to plot mid-price slice
            p_index = ceil(par.plen / 2);
            p_val = par.pgrid(p_index);
            
            %% Plot capital policy function across A
            figure(1)
            hold on
            for A_index = 1:par.Alen
                plot(par.kgrid, squeeze(sol.k(:, A_index, p_index)), 'DisplayName', ['$A = $', num2str(par.Agrid(A_index), '%.2f')])
            end
            xlabel({'$k_t$'}, 'Interpreter', 'latex')
            ylabel({'$k_{t+1}$'}, 'Interpreter', 'latex')
            title('Capital Policy Function across Productivity States', 'Interpreter', 'latex')
            legend('Interpreter','latex', 'Location','best')
            hold off
            
            %% Plot investment policy function across A
            figure(2)
            hold on
            for A_index = 1:par.Alen
                plot(par.kgrid, squeeze(sol.i(:, A_index, p_index)), 'DisplayName', ['$A = $', num2str(par.Agrid(A_index), '%.2f')])
            end
            xlabel({'$k_t$'}, 'Interpreter', 'latex')
            ylabel({'$i_{t}$'}, 'Interpreter', 'latex')
            title('Investment Policy Function across Productivity States', 'Interpreter', 'latex')
            legend('Interpreter','latex', 'Location','best')
            hold off
            
            %% Plot revenue function across A
            figure(3)
            hold on
            for A_index = 1:par.Alen
                plot(par.kgrid, squeeze(sol.r(:, A_index, p_index)), 'DisplayName', ['$A = $', num2str(par.Agrid(A_index), '%.2f')])
            end
            xlabel({'$k_t$'}, 'Interpreter', 'latex')
            ylabel({'$r_t$'}, 'Interpreter', 'latex')
            title('Revenue Function across Productivity States', 'Interpreter', 'latex')
            legend('Interpreter','latex', 'Location','best')
            hold off
            
            %% Plot expenditure function across A
            figure(4)
            hold on
            p_index = ceil(par.plen / 2);  % fix p
            for A_index = 1:par.Alen
                plot(par.kgrid, squeeze(sol.e(:, A_index, p_index)), ...
                     'DisplayName', ['$A = $', num2str(par.Agrid(A_index), '%.2f')])
            end
            xlabel({'$k_t$'}, 'Interpreter', 'latex')
            ylabel({'$e_t$'}, 'Interpreter', 'latex')
            title('Expenditure Function across Productivity States', 'Interpreter', 'latex')
            legend('Interpreter', 'latex', 'Location', 'best')
            hold off
            
            %% Plot profit function across A
            figure(5)
            hold on
            for A_index = 1:par.Alen
                plot(par.kgrid, squeeze(sol.p(:, A_index, p_index)), 'DisplayName', ['$A = $', num2str(par.Agrid(A_index), '%.2f')])
            end
            xlabel({'$k_t$'}, 'Interpreter', 'latex')
            ylabel({'$\pi_t$'}, 'Interpreter', 'latex')
            title('Profit Function across Productivity States', 'Interpreter', 'latex')
            legend('Interpreter','latex', 'Location','best')
            hold off
            
            %% Plot value function across A
            figure(6)
            hold on
            for A_index = 1:par.Alen
                plot(par.kgrid, squeeze(sol.v(:, A_index, p_index)), 'DisplayName', ['$A = $', num2str(par.Agrid(A_index), '%.2f')])
            end
            xlabel({'$k_t$'}, 'Interpreter', 'latex')
            ylabel({'$v_t$'}, 'Interpreter', 'latex')
            title('Value Function across Productivity States', 'Interpreter', 'latex')
            legend('Interpreter','latex', 'Location','best')
            hold off

            %% Time vector after burn-in
            T = par.T;
            tgrid = 1:T;

            %% Plot simulated productivity for large firms
            figure(7)
            plot(tgrid, sim.Asim_large)
            xlabel({'Time'}, 'Interpreter', 'latex')
            ylabel({'$A_t^{sim}$'}, 'Interpreter', 'latex')
            title('Simulated Productivity States (Large)')


            %% Plot simulated productivity for small firms
            figure(8)
            plot(tgrid, sim.Asim_small)
            xlabel({'Time'}, 'Interpreter', 'latex')
            ylabel({'$A_t^{sim}$'}, 'Interpreter', 'latex')
            title('Simulated Productivity States (Small)')

            %% Plot simulated prices for large firms
            figure(9)
            plot(tgrid, sim.Psim_large)
            xlabel({'Time'}, 'Interpreter', 'latex')
            ylabel({'$p_t^{sim}$'}, 'Interpreter', 'latex')
            title('Simulated Price Shocks (large)')

              %% Plot simulated prices for small firms
            figure(10)
            plot(tgrid, sim.Psim_small)
            xlabel({'Time'}, 'Interpreter', 'latex')
            ylabel({'$p_t^{sim}$'}, 'Interpreter', 'latex')
            title('Simulated Price Shocks (small)')


            %% Plot simulated capital for large firms
            figure(11)
            plot(tgrid, sim.ksim_large)
            xlabel({'Time'}, 'Interpreter', 'latex')
            ylabel({'$k_t^{sim}$'}, 'Interpreter', 'latex')
            title('Simulated Capital (Large)')


            %% Plot simulated capital
            figure(12)
            plot(tgrid, sim.ksim_small)
            xlabel({'Time'}, 'Interpreter', 'latex')
            ylabel({'$k_t^{sim}$'}, 'Interpreter', 'latex')
            title('Simulated Capital (small)')

            %% Plot simulated investment
            figure(13)
            plot(tgrid, sim.isim_large)
            xlabel({'Time'}, 'Interpreter', 'latex')
            ylabel({'$i_t^{sim}$'}, 'Interpreter', 'latex')
            title('Simulated Investment (large)')


            %% Plot simulated investment
            figure(14)
            plot(tgrid, sim.isim_small)
            xlabel({'Time'}, 'Interpreter', 'latex')
            ylabel({'$i_t^{sim}$'}, 'Interpreter', 'latex')
            title('Simulated Investment (small)')

            %% Plot simulated revenue
            figure(15)
            plot(tgrid, sim.rsim_small)
            xlabel({'Time'}, 'Interpreter', 'latex')
            ylabel({'$r_t^{sim}$'}, 'Interpreter', 'latex')
            title('Simulated Revenue')

        end
    end
end
