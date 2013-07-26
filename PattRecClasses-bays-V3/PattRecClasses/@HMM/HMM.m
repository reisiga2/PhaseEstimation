classdef HMM < ProbGenModel    %HMM - class for Hidden Markov Models, representing    %statistical properties of random sequences.    %Each sample in the sequence is a scalar or vector, with fixed DataSize.    %    %Several HMM objects may be collected in a single multidimensional array.    %    %A HMM represents a random sequence(X1,X2,....Xt,...),    %where each element Xt can be a scalar or column vector.    %The statistical dependence along the (time) sequence is described    %entirely by a discrete Markov chain.    %    %A HMM consists of two sub-objects:    %1: a State Sequence Generator of type MarkovChain    %2: an array of output probability distributions, one for each state    %    %All states must have the same class of output distribution,    %such as GaussD, GaussMixD, or DiscreteD, etc.,    %and the set of distributions is represented by an object array of that class,    %although this is NOT required by general HMM theory.    %    %All output distributions must have identical DataSize property values.    %    %Any HMM output sequence X(t) is determined by a hidden state sequence S(t)    %generated by an internal Markov chain.    %    %The array of output probability distributions, with one element for each state,    %determines the conditional probability (density) P[X(t) | S(t)].    %Given S(t), each X(t) is independent of all other X(:).    %    %------- HMM Construction Example:    %mc=initErgodic(MarkovChain,nStates,stateDuration);%define type and size of MarkovChain    %h=HMM(mc,GaussMixD(5));%construct an HMM with desired type of output distribution    %h=h.init(xTraining, lxTraining);%crude initialization of output distributions    %h=h.train(xTraining, lxTraining, nIterations);    %---------------------------------    %    %References:    %Leijon, A. (20xx) Pattern Recognition. KTH, Stockholm.    %Rabiner, L. R. (1989) A tutorial on hidden Markov models    %	and selected applications in speech recognition.    %	Proc IEEE 77, 257-286.    %    %Arne Leijon, 2009-07-25    %           2011-05-27 minor cleanup    %           2011-08-03 new initialization methods    %Gustav Eje Henter 2011-11-23    %Arne Leijon, 2012-03-17: DataSize as class method, instead of Dependent Property        properties (Dependent)        nStates;%   number of MarkovChain states        %DataSize;% public Method: length of vectors in the output sequence        %           (must be equal for all states, i.e. all OutputDistr elements)    end    properties (Access=public)        StateGen;%=MarkovChain;%  the State Generator        OutputDistr;%=GaussD;%    the array of output distributions        %   (initialize to trivial default objects)    end    properties (Access=public)        UserData=[];%   free for any user-defined purpose        %       for example to name the modelled "pattern category".    end    methods (Access=public)        function h=HMM(varargin)%constructor method            %*** HMM Constructor Usage:            %h = HMM;            %   creates a HMM with one state and single std normal N(0,1) distribution.            %h = HMM(hmm);            %   just copies the given object.            %h=HMM(mc,pD)            %   creates a HMM with StateGen=mc, and OutputDistr=pD            %h = HMM(propertyName1,Value1,propertyName2,Value2)            %   creates a HMM with the given named class properties.            switch nargin                case 0%do nothing special                    %default set here as workaround for bug #461224 in Matlab R2008a                    h.StateGen=MarkovChain;%default                    h.OutputDistr=GaussD;%default                case 1                    hIn=varargin{1};                    if isa(hIn,'HMM')                        h=hIn;%just copy it                    else                        error('Input is not a HMM object');                    end;                otherwise% 2 or more arguments                    if ischar(varargin{1})                        h=setNamedProperties(h,varargin{:});%for backward compatibility                    else%a MarkovChain and a ProbDistr                        if isa(varargin{1},'MarkovChain')                            h.StateGen=varargin{1};                            h.OutputDistr=varargin{2};                        else%reverse argument order                            h.StateGen=varargin{2};                            h.OutputDistr=varargin{1};                        end;                    end;            end;        end;        function d=DataSize(hmm)%length of output column vector samples            d=hmm.OutputDistr(1).DataSize;%same for all OutputDistr elements        end        function hmm=init(hmm,xT,lxT)            %initialize hmm output distributions crudely to given observation data            %Input:            %xT=   matrix with one or several concatenated training sequences.            %      Observed vector samples are stored column-wise.            %lxT=  (optional) vector with lengths of training sub-sequences.            %lxT(r)=    length of r:th training sequence.            %           sum(lxT) == size(obsData,2)            if nargin <3                lxT=size(xT,2);%just a single sequence            end;            if numel(hmm.OutputDistr)~= hmm.StateGen.nExtStates%make sure we have right size                hmm.OutputDistr=repmat(hmm.OutputDistr(1),hmm.StateGen.nExtStates,1);            end;            if hmm.StateGen.isLeftRight                hmm=initLeftRight(hmm,xT,lxT);%by crude left-right data segmentation            else                hmm=initByCluster(hmm,xT,lxT);%by ProbDistr initialization method            end;        end        %------------------------   Signatures of separately defined methods:        [X,S]=rand(hmm,nSamples);%  generate random vector sequence        logP=logprob(hmm,x);%       log(probability densities) for observed vector sequence        [S,logP]=viterbi(hmm,x);%   find best state sequence for observed vector sequence        r=stateEntropyRate(hmm);%   entropy rate for MarkovChain state sequence        hmm=setStationary(hmm);%    set the MarkovChain for stationary state distribution        %        %-------------------------  High-level training methods:        %   standard training using a set of data sequences:        [hmm,logprobs]=train(hmm,xT,lxT,eta_init,eta_transition,nu,...            nIterations,minStep);        %        %-------------------------  Low-level training methods:        %   These low-level methods allow very large amounts of training data,        %   that cannot be stored in a single data set,        %   as required by method train.        aState=adaptStart(hmm);%initialize accumulator data structure for training        [aState,logP]=adaptAccum(hmm,aState,obsData);%collect sufficient statistics        %   without changing the object itself)        %   to be called repeatedly with different data subsets).        %   Results from adaptAccum must be stored externally,        %   if training is to be continued later, with new data.        hmm=adaptSet(hmm,aState,eta_init,eta_transition,nu);%finally adjust the object using accumulated statistics.        %        %-------------------------  Other utility methods:        function [gamma,c]=stateOccupancy(hmm,x)            %[gamma,c]=stateOccupancy(hmm,x)            %Calculates state occupancy probabilities for one single data sequence,            %using the forward and backward algorithms of the underlying MarkovChain.            %This is useful for forced alignment, among other things.            %            %Input:            %hmm= A single HMM object.            %x= An observation sequence (matrix), where each observation may be a            %   column vector.            %Result:            %gamma=matrix with normalized state probabilities, given all observations:            %	gamma(j,t)=P[S(t)=j|x(1)...x(t)...x(T), HMM]; t=1..T            %c=row vector with observation probabilities, given the HMM:            %	c(t)=P[x(t) | x(1)...x(t-1),HMM]; t=1..T            %	c(1)*c(2)*..c(t)=P[x(1)..x(t)| HMM]            [pX,lP] = prob(hmm.OutputDistr,x);            [gamma,c] = hmm.StateGen.forwardBackward(pX);            c(1:length(lP)) = c(1:length(lP)).*exp(lP); % Correct for lP scaling        end    end    %------------------------------------------------------------------------------------    methods%    get methods        function nS=get.nStates(hmm)            nS=hmm.StateGen.nExtStates;%determined by MarkovChain        end%         function nS=get.DataSize(hmm)%public method instead of Dependent Property%             nS=hmm.OutputDistr(1).DataSize;%determined by OutputDistr%         end% ********** changed Arne Leijon, 2012-03-17    end    methods%    set methods, with type check        function hmm=set.StateGen(hmm,mc)            if isa(mc,'MarkovChain')                hmm.StateGen=mc;            else                error('Must be a MarkovChain object');            end;        end        function hmm=set.OutputDistr(hmm,pD)            if isa(pD,'ProbDistr')%then it can be used                dSize=pD(1).DataSize;%must be equal for all HMM states                OKsize=1;                for i=2:numel(pD)                    OKsize=OKsize && (dSize==pD(i).DataSize);                end;                if OKsize                    hmm.OutputDistr=pD;                else                    error('All OutputDistr must have same DataSize');                end;            else                error('Cannot use this type of OutputDistr');            end        end    end    %-----------------------------    methods (Access=private)        function h=setNamedProperties(h,varargin)%for backward compatibility            %set named property value            %several (propName,value) pairs may follow.            property_argin = varargin;            while length(property_argin) >= 2,                propName = property_argin{1};                v = property_argin{2};                property_argin = property_argin(3:end);                switch propName                    case {'StateGen','Markov','MarkovChain'}% for backward compatibility                        h.StateGen=v;                    case 'OutputDistr'                        h.OutputDistr=v;                    otherwise                        error(['Cannot set property ',propName,' of HMM object']);                end;            end;        end        function hmm=initLeftRight(hmm,obsData,lData)            %initialize hmm.OutputDistr, assuming left-right structure            %copied from external InitLeftRightHMM, 2011-08-03, NOT TESTED            dSize=size(obsData,1);%vector size            nTrainingSeq=length(lData);            startIndex=cumsum([1,lData]);%of each separate training sequence            nStates=hmm.nStates;            pD=hmm.OutputDistr;%temp array            for i=1:nStates%use i:th consecutive segment of each training seq to init state i                xT=zeros(dSize,0);%to store training data for state i                for r=1:nTrainingSeq%collect i:th part of all training sequences                    dStart=startIndex(r)+round((i-1).*lData(r)./nStates);                    dEnd=startIndex(r)+round(i.*lData(r)./nStates)-1;                    xT=[xT,obsData(:,dStart:dEnd)];                end;                pD(i)=init(pD(i),xT);            end;            hmm.OutputDistr=pD;        end        function hmm=initByCluster(hmm,obsData,lData)            %initialize hmm.OutputDistr, assuming "ergodic-like" structure            %copied from external InitErgodicHMM, 2011-08-03, NOT TESTED            %using VQ clustering, and also assume adjacent observations belong together            hmm.OutputDistr=init(hmm.OutputDistr,obsData);%initialize with VQ clusters across all obsData                    %Improve the OutputDistr heuristically,             %using fixed initial MarkovChain state durations:            for i=1:5                %     figure;                %     plotCross(get(hmm,'OutputDistr'),[1 2],'rbgk');%******only for test                hTemp=train(hmm,obsData,eta_init,eta_transition,nu,...                    lData,1);%temporary trained copy                %to join connected obsData segments, with initially defined state durations                hmm.OutputDistr=hTemp.OutputDistr;%use only new OutputDistr            end;        end    endend