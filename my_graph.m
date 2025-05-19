%% File Info.

%{

    my_graph.m
    ----------
    This code plots the value and policy functions and the time path of the variables.

%}

%% Graph class.

classdef my_graph
    methods(Static)
        %% Plot value and policy functions.
        
        function [] = plot_policy(par,sol,sim)
            %% Plot consumption policy function.

            ystate = par.ygrid;
            age = linspace(1,par.T,par.T);
            
            figure(1)
            
            surf(age(1:5:end),ystate,squeeze(sol.c(1,1:5:end,:))')
                xlabel({'t'},'Interpreter','latex')
                ylabel({'$y_{t}$'},'Interpreter','latex') 
                zlabel({'$c_{t}$'},'Interpreter','latex') 
            title('Consumption Policy Function, Lowest $a_t$','Interpreter','latex')
            
            figure(2)
            
            surf(age(1:5:end),ystate,squeeze(sol.c(end,1:5:end,:))')
                xlabel({'t'},'Interpreter','latex')
                ylabel({'$y_{t}$'},'Interpreter','latex') 
                zlabel({'$c_{t}$'},'Interpreter','latex') 
            title('Consumption Policy Function, Highest $a_t$','Interpreter','latex')
            
            %% Plot saving policy function.
            
            figure(3)
            
            surf(age(1:5:end),ystate,squeeze(sol.a(1,1:5:end,:))')
                xlabel({'t'},'Interpreter','latex')
                ylabel({'$y_{t}$'},'Interpreter','latex') 
                zlabel({'$a_{t+1}$'},'Interpreter','latex') 
            title('Saving Policy Function, Lowest $a_t$','Interpreter','latex')
            
            figure(4)
            
            surf(age(1:5:end),ystate,squeeze(sol.a(end,1:5:end,:))')
                xlabel({'t'},'Interpreter','latex')
                ylabel({'$y_{t}$'},'Interpreter','latex') 
                zlabel({'$a_{t+1}$'},'Interpreter','latex') 
            title('Saving Policy Function, Highest $a_t$','Interpreter','latex')
            
            %% Plot value function.
            
            figure(5)
            
            surf(age(1:5:end),ystate,squeeze(sol.v(1,1:5:end,:))')
                xlabel({'t'},'Interpreter','latex')
                ylabel({'$y_{t}$'},'Interpreter','latex') 
                zlabel({'$v_t(a_t,t)$'},'Interpreter','latex')
            title('Value Function, Lowest $a_t$','Interpreter','latex')

            figure(6)
            
            surf(age(1:5:end),ystate,squeeze(sol.v(end,1:5:end,:))')
                xlabel({'t'},'Interpreter','latex')
                ylabel({'$y_{t}$'},'Interpreter','latex') 
                zlabel({'$v_t(a_t,t)$'},'Interpreter','latex')
            title('Value Function, Highest $a_t$','Interpreter','latex')

            %% Plot consumption policy function.

            lcp_c = nan(par.T,1);
            lcp_a = nan(par.T,1);
            lcp_u = nan(par.T,1);

            for i=1:par.T
                lcp_c(i) = mean(sim.csim(sim.tsim==i),"omitnan");
                lcp_a(i) = mean(sim.asim(sim.tsim==i),"omitnan");
                lcp_u(i) = mean(sim.usim(sim.tsim==i),"omitnan");
            end

            figure(7)
            
            plot(age,lcp_c)
                xlabel({'$Age$'},'Interpreter','latex')
                ylabel({'$c^{sim}_{t}$'},'Interpreter','latex') 
            title('LCP of Consumption')
            
            %% Plot saving policy function.
            
            figure(8)
            
            plot(age,lcp_a)
                xlabel({'$Age$'},'Interpreter','latex')
                ylabel({'$a^{sim}_{t+1}$'},'Interpreter','latex') 
            title('LCP of Savings')
            
            %% Plot value function.
            
            figure(9)
            
            plot(age,lcp_u)
                xlabel({'$Age$'},'Interpreter','latex')
                ylabel({'$u^{sim}_t$'},'Interpreter','latex') 
            title('LCP of Utility')   

        beta_list = [0.90, 0.92, 0.94, 0.96];
        num_betas = length(beta_list);
        lcp_c_all = nan(par.T, num_betas); % consumption
        lcp_a_all = nan(par.T, num_betas); % assets
        
        age = (1:par.T)'; % Define age vector
        
        for b = 1:num_betas
            % === Set Parameters ===
            par.beta = beta_list(b);
            par.ganma = 2.00;
        
            % === Solve model (assumed you have this function) ===
            sol = q_solve.cs_q_model_fin(par); 
        
            % === Simulate model ===
            sim = q_simulate.lc(par, sol);
        
            % === Compute Lifecycle Profiles ===
            for i = 1:par.T
                lcp_c_all(i, b) = mean(sim.csim(sim.tsim == i), 'omitnan');
                lcp_a_all(i, b) = mean(sim.Asim(sim.tsim == i), 'omitnan');
            end
        end
        % === Plot Lifecycle Profile of Consumption ===
        figure;
        plot(age, lcp_c_all, 'LineWidth', 1.5)
        xlabel('$Age$', 'Interpreter', 'latex')
        ylabel('$c^{sim}_t$', 'Interpreter', 'latex')
        legend(arrayfun(@(b) ['$\beta = $' num2str(b)], beta_list, 'UniformOutput', false), ...
            'Interpreter', 'latex', 'Location', 'best')
        title('Lifecycle Profile of Consumption', 'Interpreter', 'latex')
        grid on
        % === Plot Lifecycle Profile of Assets/Wealth ===
        figure;
        plot(age, lcp_a_all, 'LineWidth', 1.5)
        xlabel('$Age$', 'Interpreter', 'latex')
        ylabel('$a^{sim}_{t+1}$', 'Interpreter', 'latex')
        legend(arrayfun(@(b) ['$\beta = $' num2str(b)], beta_list, 'UniformOutput', false), ...
            'Interpreter', 'latex', 'Location', 'best')
        title('Lifecycle Profile of Wealth', 'Interpreter', 'latex')
        grid on
        
        sigma_list = [2.00, 3.00, 4.00, 5.00];
        beta_list = [0.90, 0.92, 0.94, 0.96];
        num_ganmas = length(sigma_list);
        num_betas = length(beta_list);
        
        avg_wealth_matrix = nan(num_betas, num_ganmas); % Rows: beta, Cols: gamma
        
        for i = 1:num_betas
            for j = 1:num_ganmas
                % Set parameter values
                par.beta = beta_list(i);
                par.ganma = ganma_list(j);
        
                % Solve and simulate 
                sol = q_solve.cs_q_model_fin(par); 
                sim = q_simulate.lc(par, sol); 
        
                % Compute average simulated wealth
                avg_wealth = mean(sim.Asim(:), 'omitnan');
                avg_wealth_matrix(i, j) = avg_wealth;
            end
        end
        % === Plot Heatmap ===
        figure;
        imagesc(ganma_list, beta_list, avg_wealth_matrix);
        colorbar;
        xlabel('$\gamma$', 'Interpreter', 'latex');
        ylabel('$\beta$', 'Interpreter', 'latex');
        title('Average Simulated Wealth (Heatmap)', 'Interpreter', 'latex');
        
        % Set x/y ticks
        set(gca, 'XTick', ganma_list);
        set(gca, 'YTick', beta_list);
        
        % Optional: Display numeric values on the heatmap
        textStrings = strtrim(cellstr(num2str(avg_wealth_matrix(:), '%.2f')));
        [x, y] = meshgrid(1:num_ganmas, 1:num_betas);
        text(x(:), y(:), textStrings, 'HorizontalAlignment', 'center', 'Color', 'w');
        
        end

    end
end