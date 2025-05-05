%% File Info.

%{

    model.m
    -------
    This code sets up the model.

%}

%% Model class.

classdef model
    methods(Static)
        %% Set up structure array for model parameters and set the simulation parameters.
        
        function par = setup()            
            %% Structure array for model parameters.
            
            par = struct();
            
            %% Preferences.

            par.T = 61; % Last period of life.
            par.tr = 41; % First period of retirement.
            
            par.beta = 0.94; % Discount factor: Lower values of this mean that consumers are impatient and consume more today.
            par.gamma = 2.0; % CRRA: Higher values of this mean that consumers are risk averse and do not want to consume too much today.
            
            assert(par.T > par.tr,'Cannot retire after dying.\n')
            assert(par.beta > 0.0 && par.beta < 1.0,'Discount factor should be between 0 and 1.\n')
            assert(par.gamma > 0.0,'CRRA should be at least 0.\n')

            %% Prices and Income.

            par.r = 0.03; % Interest rate.
            par.kappa = 0.6; % Share of income as pension.

            par.gamma_eps = 0.07; % Std. dev of productivity shocks.
            par.rho = 0.85; % Persistence of AR(1) process.
            par.mu = 0.0; % Intercept of AR(1) process.

            assert(par.kappa >= 0.0 && par.kappa <= 1.0,'The share of income received as pension should be from 0 to 1.\n')
            assert(par.gamma_eps > 0,'The standard deviation of the shock must be positive.\n')
            assert(abs(par.rho) < 1,'The persistence must be less than 1 in absolute value so that the series is stationary.\n')

            %% Simulation parameters.

            par.seed = 2025; % Seed for simulation.
            par.TT = 100; % Number of time periods.
            par.NN = 3000; % Number of people.

            %% Load age‐specific income scale G_t
            G_data = readtable('G_by_age.csv');    
            % assume the column is literally named 'G'
            par.G = G_data.Gt;                        

        end
        %% Generate state grids.
        
        function par = gen_grids(par)
            %% Capital grid.

            par.alen = 300; % Grid size for a.
            par.amax = 30.0; % Upper bound for a.
            par.amin = 0.0; % Minimum a.
            
            assert(par.alen > 5,'Grid size for a should be positive and greater than 5.\n')
            assert(par.amax > par.amin,'Minimum a should be less than maximum value.\n')
            
            par.agrid = linspace(par.amin,par.amax,par.alen)'; % Equally spaced, linear grid for a and a'.
                
            %% Discretized income process.
                  
            par.ylen = 7; % Grid size for y.
            par.m = 3; % Scaling parameter for Tauchen.
            
            assert(par.ylen > 3,'Grid size for A should be positive and greater than 3.\n')
            assert(par.m > 0,'Scaling parameter for Tauchen should be positive.\n')
            
            [ygrid,pmat] = model.tauchen(par.mu,par.rho,par.gamma_eps,par.ylen,par.m); % Tauchen's Method to discretize the AR(1) process for log productivity.
            par.ygrid = exp(ygrid); % The AR(1) is in logs so exponentiate it to get A.
            par.pmat = pmat; % Transition matrix.
        
        end
        
        %% Tauchen's Method
        
        function [y,pi] = tauchen(mu,rho,gamma,N,m)
            %% Construct equally spaced grid.
        
            ar_mean = mu/(1-rho); % The mean of a stationary AR(1) process is mu/(1-rho).
            ar_sd = gamma/((1-rho^2)^(1/2)); % The std. dev of a stationary AR(1) process is gamma/sqrt(1-rho^2)
            
            y1 = ar_mean-(m*ar_sd); % Smallest grid point is the mean of the AR(1) process minus m*std.dev of AR(1) process.
            yn = ar_mean+(m*ar_sd); % Largest grid point is the mean of the AR(1) process plus m*std.dev of AR(1) process.
            
	        y = linspace(y1,yn,N); % Equally spaced grid.
            d = y(2)-y(1); % Step size.
	        
	        %% Compute transition probability matrix from state j (row) to k (column).
        
            ymatk = repmat(y,N,1); % States next period.
            ymatj = mu+rho*ymatk'; % States this period.
        
	        pi = normcdf(ymatk,ymatj-(d/2),gamma) - normcdf(ymatk,ymatj+(d/2),gamma); % Transition probabilities to state 2, ..., N-1.
	        pi(:,1) = normcdf(y(1),mu+rho*y-(d/2),gamma); % Transition probabilities to state 1.
	        pi(:,N) = 1 - normcdf(y(N),mu+rho*y+(d/2),gamma); % Transition probabilities to state N.
	        
        end
        
        %% Utility function.
        
        function u = utility(c,par)
            %% CRRA utility.
            
            if par.gamma == 1
                u = log(c); % Log utility.
            else
                u = (c.^(1-par.gamma))./(1-par.gamma); % CRRA utility.
            end
      end 
    end
end