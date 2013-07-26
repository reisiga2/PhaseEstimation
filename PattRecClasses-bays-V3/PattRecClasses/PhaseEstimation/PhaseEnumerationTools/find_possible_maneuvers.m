
% This function gives all possible phases at one intersection. In generatl
% there are 12 possible maneuver at one intersection. However, with a
% oneway leg or at a T-intersections this number reduces to smaller values.
% 

% input of this function is 'intersectionType'.

% output: a vector (V)  with 12 elements, where V(i) is a 0 or 1 falg to
% determine the possiblity of the ith maneuver. the order of the manuvers
% are as following: 
%SBT=1, SBR=2, SBL=3,
%WBT=4, WBR=5, WBL=6,
%NBT=7, NBR=8, NBL=9,
%EBT=10, EBR=11, EBL=12


function possibleManeuvers = find_possible_maneuvers(intersectionType)

numManeuvers =12; 

ManeuversID_from_leg = [1 2 3; 4 5 6; 7 8 9; 10 11 12]; % a vector that 
%identify the maneuvers ID of each leg, The firs row difines maneuver from
%north, second East, third, south and last west.

ManeuversID_to_leg = [5 7 12; 3 8 10; 1 6 11 ; 2, 4 ,9 ]; % maneuvers to the 
%leg, similar to previous one.
    
possibleManeuvers=zeros(1,numManeuvers);

    if nargin<1
        intersectionType=[1,1,1,1];
    end
        
    for i=1:size(intersectionType,2)
        
          index1 = ManeuversID_from_leg(i,:); 
          index2 = ManeuversID_to_leg(i,:);
          
        if intersectionType(i)==1
               
            possibleManeuvers(index1) = 1;
            possibleManeuvers(index2) = 1;
         
        elseif intersectionType(i)==2
            
            possibleManeuvers(index1) = 0;
            possibleManeuvers(index2) = 0;
            
        elseif intersectionType(i)==3
            
            possibleManeuvers(index1) = 1;
            possibleManeuvers(index2) = 0;
            
        elseif intersectionType(i)==4
            
             possibleManeuvers(index1) = 0;
             possibleManeuvers(index2) = 1;
             
        end
        
    end




end
 
