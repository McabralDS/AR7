function [angCorrigido] = correcaoAng(ang)

%% base
ang(1) = abs(ang(1) + 90);


if(ang(1) < 80 && ang(1) > 50)
        ang(1) = ang(1) - 5;
    else if (ang(1) <50)
            ang(1) = ang(1) - 3;
    else if(ang(1) > 120 )
            ang(1) = ang(1) + 2;        
        end
    end
end
if(ang(1) < 0)
    ang(1) = 0;
end
if(ang(1) > 180)
                ang(1) = 170;
            end
 
 
%% Ombro 
if( ang(2) < 0) 
    ang(2) = 0;
end


%% Cotovelo
if(ang(3) <=0 && ang(3) > -90)
     ang(3) = abs(ang(3) + 90);
else if(ang(3) > 0 && ang(3) < 120)
        ang(3) = abs(ang(3) - 90);
    else if(ang(3) < -90)
            ang(3) = 0;
        else if(ang(3) > 120)
                ang(3) = 120;
            end
        end
    end
end
     
angCorrigido = [ang(1); ang(2) ;ang(3)];

end
