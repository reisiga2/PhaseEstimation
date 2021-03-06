% this function finds the two type of errors. One type of error is when we
% lable a maneuver with a phase which does not contain that maneuver(Em). The
% other is when we lable a maneuver with a phase that contains the maneuver
% but is not the correct phase(Ep). 

%input: 
%phaseManeuvers: is a matrix where each row corresponds to each phase and
%each column correspond to the maneuver. If a phase contains a maneuver
%the corresponding element get the maneuver ID (1,2,3, ...).for example if
%phase 3 contained maneuver 5 the PhaseManeuvers(3,5)=5 and if it does not
%contain maneuver 6, PhaseManeuvers(3,6)=0.

% data

function [Ep, Em] = Find_TwoType_Errors(data,phases, inferredPhaseSequence)

         Em_count=0;         % a counter for number of errors
         Ep_count=0;        % a counter for number of errors 
         
         realPhaseSequence = (data(:,3))';
         ManeuverSequence = (data(:,1))';
         
    for i= 1: size(data(:,1),1)
        if (realPhaseSequence(i)~=inferredPhaseSequence(i))
            if phases(inferredPhaseSequence(i),ManeuverSequence(i))==1
                    Ep_count =Ep_count+1;
                
            else
                    Em_count = Em_count+1;
            end
            
        end
    end
                Em = Em_count*100/size(data,1); 
                Ep = Ep_count*100/size(data,1);
                
end