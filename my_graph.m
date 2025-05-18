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
        end
   function [] = plot_simulations()
    %% Settings
    betas = [0.90, 0.92, 0.94, 0.96];
    gammas = [2.00, 3.00, 4.00, 5.00];
    
    %% 1. Vary β, fix γ = 2.00
    gamma_fixed = 2.00;
    figure_counter = 1;
    for i = 1:length(betas)
        par = model.setup();
        par.beta = betas(i);
        par.gamma = gamma_fixed;
        par = model.gen_grids(par);
        sol = solve.lc(par);
        sim = simulate.lc(par, sol);
        
        figure(figure_counter)
        subplot(2,1,1)
        plot(1:par.T, mean(sim.csim,2), 'LineWidth', 2)
        title(['Consumption profile, β=', num2str(betas(i)), ', γ=2.0'])
        xlabel('Age'), ylabel('Consumption')

        subplot(2,1,2)
        plot(1:par.T, mean(sim.asim,2), 'LineWidth', 2)
        title(['Wealth profile, β=', num2str(betas(i)), ', γ=2.0'])
        xlabel('Age'), ylabel('Wealth')
        
        figure_counter = figure_counter + 1;
    end

    %% 2. Vary γ, fix β = 0.96
    beta_fixed = 0.96;
    for i = 1:length(gammas)
        par = model.setup();
        par.beta = beta_fixed;
        par.gamma = gammas(i);
        par = model.gen_grids(par);
        sol = solve.lc(par);
        sim = simulate.lc(par, sol);
        
        figure(figure_counter)
        subplot(2,1,1)
        plot(1:par.T, mean(sim.csim,2), 'LineWidth', 2)
        title(['Consumption profile, β=0.96, γ=', num2str(gammas(i))])
        xlabel('Age'), ylabel('Consumption')

        subplot(2,1,2)
        plot(1:par.T, mean(sim.asim,2), 'LineWidth', 2)
        title(['Wealth profile, β=0.96, γ=', num2str(gammas(i))])
        xlabel('Age'), ylabel('Wealth')
        
        figure_counter = figure_counter + 1;
    end

    %% 3. Heatmap: average wealth for all β and γ
    avg_wealth = zeros(length(betas), length(gammas));
    for i = 1:length(betas)
        for j = 1:length(gammas)
            par = model.setup();
            par.beta = betas(i);
            par.gamma = gammas(j);
            par = model.gen_grids(par);
            sol = solve.lc(par);
            sim = simulate.lc(par, sol);
            avg_wealth(i,j) = mean(sim.asim(:));
        end
    end

    figure(figure_counter)
    imagesc(gammas, betas, avg_wealth)
    colorbar
    xlabel('\gamma'), ylabel('\beta')
    title('Average Wealth Heatmap')
    set(gca, 'YDir', 'normal') % to align (0,0) to bottom-left
end

    
    end
end