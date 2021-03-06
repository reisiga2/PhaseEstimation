% this script finds error with respect to both transition probs and illegal
% maneuver probs. 

clear all
close all

DwellingW =300;
transtitionW =1.01;

[phases, numPhases] = EnumeratePhases([1 1 1 1],1); % [1 1 1 1] full fourway intersection, 1: consider right turns.
partPhases = phases(1:8,:); 

priorParameters = give_DrichletParameter...
    (partPhases,transtitionW ,DwellingW,1,1); % fixed priors. you can change the priors to get different results. 
iteration = 30; 

ProhibitManProb=0;
%case A: No illegal maneuver
% emissionProbs = [0 1 0 39 5 5 0 1 0 39 5 5;...
%                  39 5 5 0 1 0 39 5 5 0 1 0;...
%                  0 1 0 0 1 48 0 1 0 0 1 48]; % data generated based on these ratios. we considered three phase intersection.
% % %Case B: some illegal maneuver
  emissionProbs = [1 2 1 36 5 5 1 2 1 36 5 5;...
                  36 5 5 1 2 1 36 5 5 1 2 1;...
                  1 2 1 1 2 43 1 2 1 1 2 43];



epsTranstion=0.01;
epsEmissin =0.1 ;

maxMesh = 1/size(phases,1); % maximum value that transition probability can take

if(epsTranstion>maxMesh)
    epsepsTranstion= maxMesh-0.000001;
end

transitionProb_from_i_to_j = 0.000001:epsTranstion:maxMesh;
illegalManProb = 0:epsEmissin:2;

error = zeros(size(illegalManProb,2),size(transitionProb_from_i_to_j,2));
percError=zeros(size(illegalManProb,2),size(transitionProb_from_i_to_j,2));
errorSum = zeros(size(illegalManProb,2),size(transitionProb_from_i_to_j,2));


for k=1:iteration
 tic;   
    data = ...
    loadIntersectionData('syntethicFixedTime',[], 0,...
    [1 2 3],emissionProbs,[10 10],[10 10 5; 25 25 10],... %[10 10] gives min and max num of cycles.
    [],[],[],[]); 
    
    for i= 1: size(illegalManProb,2)
        
        for j=1:size(transitionProb_from_i_to_j,2)
        initialHmm = ...
    initiateIntersectionHMM(data,partPhases,transitionProb_from_i_to_j(j),illegalManProb(i));

    hmm=train(initialHmm,(data(:,1))',size((data(:,1)),1),...
        priorParameters.initials,priorParameters.transitionMatrix,...
        priorParameters.emissionMatrix);
        
    
    inferredPhaseSequence = viterbi(hmm,(data(:,1))' );

    [error(i,j),percError(i,j)]= find_error(data,inferredPhaseSequence);
        end
    end
    errorSum=errorSum+percError;
    
  toc;
end


errorAverage = errorSum/iteration;
Y=illegalManProb;
X=transitionProb_from_i_to_j;


% this generates a contour plot.
figure
v=[0.2 0.5 0.8 1 1.2 1.5 2 3.5 5 10 15 20 40 60];     
[C,h]= contour(X,Y,errorAverage,v);
set(h,'ShowText','on','TextStep',get(h,'LevelStep'))
xlabel('a (Transition probability)');
ylabel('b(%) Emission Probability');
colormap cool
title('Error(%)')

% this generates a 3d plot
figure
surf(X,Y,errorAverage)
xlabel('a ');
ylabel('b(%)');
zlabel('Error(%)');
view([40,25])
 title('Bayesian Method, alpha_d_w_e_l_l=300, alpha_t_r_a_n_s=1.01');
%title('Baum-Welch algorithm')




% this generates a 2d  plot with colors .
errorAverageFlipped =  fliprows(errorAverage) ;
figure
imagesc(X,Y,errorAverageFlipped)
colorbar;
caxis([0, 50]);
gca()
xlabel('a ');
ylabel('b(%)');
set(gca,'YTick',0:0.5:2);
set(gca,'YTickLabel',{'2','1.5','1','0.5','0'})
title('Error(%)');

