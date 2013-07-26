% This function gives out training data from the raw data. Raw data
% requires some filtratin and correction to generate training data. 

function [data,numFiltered] = giveRealData(data_file_name ,ManIDList,preFilterFlag)

    if nargin<3
        preFilterFlag=1;
    end
    
    if nargin<2
        ManIDList=[1 2 3 4 5 6 7 8 9 10 11 12];
    end
    
    if nargin>2 && isempty(ManIDList)
         ManIDList=[1 2 3 4 5 6 7 8 9 10 11 12];
    end

   exprData = xlsread(data_file_name); % reads data from an excel sheet
   data = translate_data(exprData,ManIDList); % tranfer the maneuver IDs to 1 to 12
   data = filterzeros(data); % remove any zero(errors) in maneuver IDs
   numFiltered =0;
   
   if preFilterFlag==1
   [data,numFiltered] = filterConflicts(data); % remove conflicting maneuvers from data
   end
   
   
 end