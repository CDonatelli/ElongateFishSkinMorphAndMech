function [] = ImJ2csv(IJtab, csvNameAll, csvNameMean)

numPts = length(IJtab)/11;     %Determine number of points

%Initial Fish Stuff
check = 0;
while check == 0
    prompt = {  'Stiffness (R):',...
                'Wobble Amplitude:',...
                'Distance From Nose (R Points):'...
                'Distance From Nose (JMP Points):'};
%                 'Individual Name'};
    dlg_title = 'Fish Info';
    num_lines = 1;
    defaultans = {'0','0','0','0','0'};
    answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
    
    stiffness       = str2num(answer{1});
    wobble          = str2num(answer{2});
    RdFromNose      = str2num(answer{3});
    IJdFromNose    = str2num(answer{4});
%     indivName       = answer{5};
    
    if length(IJdFromNose) ~= numPts
        disp('Number of points doesn''t match distances entered')
        check = 0;
    else
        check = 1;
    end
end

horizSeptInd = 1:11:length(IJtab);     %Extract horizontal septum angles  
horizSeptAngles = IJtab(horizSeptInd);

ind=1:length(IJtab);                   %Extract fiber angles
fiberInd = setdiff(ind,horizSeptInd);
fiberAngles = IJtab(fiberInd);

MATtabAll   = zeros(10*numPts,4);
MATtabMean  = zeros(2*numPts,3); 
%MATtabAll = [Angle  CorrAngles  b/f  dFromNose]
%MATtabMean = [MeanCorrAngle b/f dFromNose]
meanIndiv = {};

for i = 1:numPts                %Loop through points measured
    ind = i*10;
    HZA = horizSeptAngles(i);   %Horizontal Septum Angle for this point
    % Fiber Angles for this point
    angles = fiberAngles(ind-9:ind);
    MATtabAll(ind-9:ind,1) = angles;   %Add uncorrected angles to array
    newAngF = [];
    newAngB = []; 
    BorF = [];
    %Coded for fish facing Left
    for j = 1:5                 %For sept-->tail facing fibers
        if angles(j) > 0
            newAngF = [newAngF; angles(j) - HZA];
        else
            newAngF = [newAngF; (angles(j)+180) - HZA];
        end
        BorF = [BorF;1];
    end
    for j = 6:10                %For sept-->head facing fibers
        if angles(j) > 0
            newAngB = [newAngB; (180-angles(j)) + HZA];
        else
            newAngB = [newAngB; abs(angles(j)) + HZA];
        end
        BorF = [BorF;0];
    end
    MATtabAll(ind-9:ind,3) = BorF;     %Add Forward or Backwards indicators to Array
    MATtabAll(ind-9:ind,2) = [newAngF;newAngB];   %Add Corrected Angles to Array
    MATtabAll(ind-9:ind,4) = IJdFromNose(i);
    
    MATtabMean(i+(i-1),1)   = mean(newAngF);
    MATtabMean(i+i,1)       = mean(newAngB);
    MATtabMean(i+(i-1),2)   = 0;
    MATtabMean(i+i,2)       = 1;
    MATtabMean(i+(i-1),3)   = IJdFromNose(i);
    MATtabMean(i+i,3)       = IJdFromNose(i);
end

fIndex = 1:2:2*numPts;
bIndex = 2:2:2*numPts;

MATtabTwist = zeros(length(stiffness)*2,5);
[MTrow, MTcol] = size(MATtabTwist);
half = MTrow/2;
% MATtabMean = [MeanCorrAngle b/f dFromNose]
% MATtabTwist = [dFromNose  FiberAngle  BorF  Stiffness  Wobble]
interpForAngle = interp1(   MATtabMean(fIndex, 3), ...
                            MATtabMean(fIndex, 1), ...
                            RdFromNose );
                
interpBakAngle = interp1(   MATtabMean(bIndex, 3), ...
                            MATtabMean(bIndex, 1), ...
                            RdFromNose );
MATtabTwist(:,1)                = [RdFromNose'; RdFromNose'];
MATtabTwist(1:half,2)           = interpForAngle;
MATtabTwist((half+1):MTrow,2)   = interpBakAngle;
MATtabTwist(1:half,3)           = 1;
MATtabTwist((half+1):MTrow,3)   = 0;
MATtabTwist(:,4)                = [stiffness'; stiffness'];
MATtabTwist(:,5)                = [wobble'; wobble'];



% for i = 1:length(RdFromNose)-1
%     range = [RdFromNose(i), RdFromNose(i+1)];
%     stiffRange = [stiffness(i), stiffness(i+1)];
%     wobRange = [wobble(i), wobble(i+1)];
%     % see if there are any points measured between two twist points
%     inRange = find(JMPdFromNose > range(1) & JMPdFromNose < range(2));
%     if isempty(inRange)     % if there aren't, do nothing
%     else                    % if there are, interpolate stiffness + wobble
%         x1 = range(1); x2 = range(2);
%         Sy1 = stiffRange(1); Sy2 = stiffRange(2);
%         m = (Sy2-Sy1)/(x2-x1);
%         b = Sy1 - (m*x1);
%         MATtabMean(inRange+(i-1),4) = (m*JMPdFromNose(inRange)+b);
%         MATtabMean(inRange+i,4) = (m*JMPdFromNose(inRange)+b);
%         
%         Wy1 = stiffRange(1); Wy2 = stiffRange(2);
%         m = (Wy2-Wy1)/(x2-x1);
%         b = Wy1 - (m*x1);
%         MATtabMean(inRange+(i-1),4) = (m*JMPdFromNose(inRange)+b);
%         MATtabMean(inRange+i,4) = (m*JMPdFromNose(inRange)+b);
%     end
%     
% %     equalTo = find(JMPdFromNose == range(1));
% %     if isempty(equalTo)
% %     else
% %         MATtabMean(i+(i-1),4) = (stiffRange(equalTo));
% %         MATtabMean(i+i,4) = (stiffRange(equalTo));
% %     end
% %     
% %     if i == length(RdFromNose)-1
% %         equalLast = find(JMPdFromNose == range(2));
% %         if isempty(equalLast)
% %         else
% %             MATtabMean(i+(i-1),4) = (stiffRange(equalLast));
% %             MATtabMean(i+i,4) = (stiffRange(equalLast));
% %         end
% %     else
% %     end
%     
% end
% 
% for i = 1:length(RdFromNose)
%     % see if there are points measured at the same place as twist points
%     equalTo = find(JMPdFromNose == RdFromNose(i));
%     if isempty(equalTo)
%     else
%         MATtabMean(equalTo+(equalTo-1),4) = (stiffness(i));
%         MATtabMean(equalTo+equalTo,4) = (stiffness(i));
%     end
% end

   csvwrite(csvNameAll, MATtabAll);
%    csvwrite(csvNameMean, MATtabMean);
   csvwrite(csvNameMean, MATtabTwist);

end
