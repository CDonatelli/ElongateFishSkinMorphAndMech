Angle1 = Angle;
% fish_length=0.010 
% dim_length=blah %% CHANGE THIS PER FISH
a=1;
%newangle= zeros(dim_length,1);
flip_var=0;
newangle= zeros(99,1);
direction=char(zeros(99,1));
location=char(zeros(99,1));
x= zeros(99,1);
y= zeros(99,1);
for i=1:11:77%does this have to be exactly as long as the data set?
    if Angle1(i) < 0
            Angle1(i)= 180 + Angle1(i); % cut this, doesn't make sense
    end                                 % see notes in LA  
    % use if statement to check for negative horizontal septum and correct it
    for j=i+1:i+5
        if Angle1(j) < 0
            Angle1(j)= 180 + Angle1(j);  % change to be positive. not 180-
        end
        direction(a) = 'b';
        newangle(a) = Angle1(j) - Angle1(i);
  
     
        if newangle(a) < 0
            flip_var=flip_var+1;
            %keyboard;
            newangle(a)=newangle(a)+180;
        end
        x(a) =  X(j);
        y(a) = Y(j);
        a=a+1;
                if y(a)> Angle1(i)
                    location(a) ='v';
                end
                if y(a)< Angle1(i)
                    location(a) = 'd';
                end
                %will this work to make the dorsal or ventral column?
    end
    for j=i+6:i+10
        if Angle1(j) < 0
            Angle1(j)= 180 + Angle1(j);
        end
        if Angle1(j) > 90;
            Angle1(j) = 180- Angle1(j);
        end
        direction(a) = 'f';
        newangle(a) = Angle1(j) - Angle1(i);
        
         if newangle(a) < 0
            flip_var=flip_var+1;
            %keyboard;
            newangle(a)=newangle(a)+180;
        end
        x(a) =  X(j);
        y(a) = Y(j);
        a=a+1;
                if y(a)> Angle1(i)
                    location(a) ='v';
                end
                if y(a)< Angle1(i)
                    location(a) = 'd';
                end
    end
                %will this work to make the dorsal or ventral column?
end
JmpFile = table;
JmpFile.angle = newangle;
JmpFile.direction = direction;
JmpFile.location = location;
JmpFile.x = x;
JmpFile.y = y;
flip_var=flip_var

writetable(JmpFile, 'FiberAngles.txt');