
function data = transformTomySystem(Sdata)

    SdataSize=size(Sdata,2);
    data = zeros(1, SdataSize);
    
    for i=1: SdataSize
        
          if(Sdata(i)==1)
            data(i)=10;
          elseif(Sdata(i)==2)
            data(i)= 12;
          elseif(Sdata(i)==3)
            data(i)= 4;
          elseif(Sdata(i)==4)
            data(i)= 6;
          elseif(Sdata(i)==5)
            data(i)= 7;
          elseif(Sdata(i)==6)
            data(i)= 9;
          elseif(Sdata(i)==7)
            data(i)= 1;
          elseif(Sdata(i)==8)
            data(i)= 2;
          elseif(Sdata(i)==9)
            data(i)= 11; 
          elseif(Sdata(i)==11)
            data(i)=5;
          elseif(Sdata(i)==13)
            data(i)= 8;
          elseif(Sdata(i)==15)
            data(i)= 3;
         end
    
    
    end


end