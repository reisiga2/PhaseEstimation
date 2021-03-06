% this script is to evaluate the error with respect to number of cycles at
% the intersection of a one way street with a two way street.  here we need
% to set the phases. as we did in our the conference  paper. 

% clear all
% close all
% clc;

allPhases = [ 0 0 0 0 0 0 0 0 0 1 1 1;...
            0 0 0 0 0 0 0 0 0 1 1 0;...
            0 0 0 0 0 0 0 0 0 0 0 1;...
            1 0 0 0 0 0 1 1 0 0 0 0;...
            1 0 1 0 0 0 1 1 0 0 0 0;...
            1 0 1 0 0 0 0 0 0 0 0 0;...
            0 0 1 0 0 0 0 0 0 0 0 0] ;

maxNumCycle = 50;
GeneratingPhases = [1,5]; % we generate phaes from phases 1 and 5. 
numManeuver =[5 5; 27 27];
iteration = 30;
initail_transitionProb_from_i_to_j_unif =0.1429;
initail_transitionProb_from_i_to_j=0.01;
initail_illegal_Man_Prob=0.1;
mu_t=1.0001;
mu_d=20;
c_p=1;
c_s=700;
c_t=300;
DiricParam = give_DrichletParameter...
    (allPhases, mu_t,mu_d,c_p,c_t,c_s);

emissionProbsGenData = [0.2 4 0.2 0.2 4 0.2 0.2 4 0.2 58.1 9  20;...
                        35  4 8.1 0.2 4 0.1 35 9 0.2 0.2 4 0.2]; % change this values to generate data differently or with more number of phases


% this is to get the errors for uniform distributed transitio probabiliteis
[numCycle_unif,averageError_unif ,averagePercError_unif] = ...
    find_error_vs_numCycles(allPhases, DiricParam,...
maxNumCycle,GeneratingPhases,emissionProbsGenData,numManeuver,iteration,...
     initail_transitionProb_from_i_to_j_unif, initail_illegal_Man_Prob);
%  
%  this is to get the errors for traffic specific transition probs.
% [numCycle,averageError ,averagePercError] = ...
%     find_error_vs_numCycles(allPhases, DiricParam,...
% maxNumCycle,GeneratingPhases,emissionProbsGenData,numManeuver,iteration,...
%      initail_transitionProb_from_i_to_j, initail_illegal_Man_Prob);
% %  
 
%  figure
%  plot(numCycle,averagePercError,'--r', 'lineWidth',2);
%  hold on
 plot(numCycle_unif,averagePercError_unif,'lineWidth',2)
%  xlabel('Length of dataset (in number of cycles)')
%  ylabel('Error(%)');
%  legend('a=0.01', 'a=0.1429')
 
 