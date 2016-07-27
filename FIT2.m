function FIT2
close all
% Description: Graphical user interface for analysis of panoramic data.
% Calibrates whole heart at 45 degree angle (negY, negX).
%
% Authors: Christopher Gloschat
% Date: June 8, 2016
%
% Modification Log:
% June 16, 2016 - introduced use of the function getpts_on_axes.m.
% Documentation can be found here:
% https://www.reddit.com/r/matlab/comments/3ga4d1/is_there_a_way_to_restrict_getpts_to_only_one/
% I made modficiations following the if statement at line 73 so I could get
% out axes values. 
%
% July 12, 2016 - added a save and load button so I don't have to start
% from scratch if I've done assignment of calibration points before.
%
%% Create GUI structure
% scrnSize = get(0,'ScreenSize');
pR = figure('Name','FUDGE IT 2.0','Visible','off',...
    'Position',[1 1 1060 1200],'NumberTitle','Off');
% Screens for anlayzing data
axesSize = 500;
globalView = axes('Parent',pR,'Units','Pixels','YTick',[],'XTick',[],...
    'Position',[540 160 axesSize axesSize]);
regionalView = axes('Parent',pR,'Units','Pixels','YTick',[],'XTick',[],...
    'Position',[20 160 axesSize axesSize]);
calibrationPts= axes('Parent',pR,'Units','Pixels','YTick',[],'XTick',[],...
    'Position',[20 680 axesSize axesSize]);
qualityPts = axes('Parent',pR,'Units','Pixels','YTick',[],'XTick',[],...
    'Position',[540 680 axesSize axesSize]);
% % globalView = axes('Parent',pR,'Units','Pixels','Position',[540 160 axesSize axesSize]);
% % regionalView = axes('Parent',pR,'Units','Pixels','Position',[20 160 axesSize axesSize]);
% % calibrationPts= axes('Parent',pR,'Units','Pixels','Position',[20 680 axesSize axesSize]);
% % qualityPts = axes('Parent',pR,'Units','Pixels','Position',[540 680 axesSize axesSize]);



% Select Directory
dirSelect = uicontrol('Parent',pR,'Style','pushbutton','FontSize',12,...
    'String','Select Directory','Position',[20 120 110 20],'Callback',...
    {@dirSelect_callback});
dirName = uicontrol('Parent',pR,'Style','edit','FontSize',12,'String',...
    '','Enable','off','HorizontalAlignment','Left','Position',[145 120 450 20]);

% Species I.D. Interfaces
speciesTxt = uicontrol('Parent',pR,'Style','text','FontSize',12,'String',...
    'Animal Species: ','HorizontalAlignment','Left','Position',[20 90 90 20]);
speciesDrop = uicontrol('Parent',pR,'Style','popupmenu','FontSize',12,...
    'String',{'---','1. Pig (BrainVision Cameras)','2. Rabbit','3. Pig (Andor Cameras)'},...
    'Position',[140 90 210 20],'Callback',{@speciesDrop_callback});

% Calibration Buttons
calibDirectText = uicontrol('Parent',pR,'Style','text','FontSize',12,'String',...
    'Calibration Direction: ','HorizontalAlignment','Left','Position',[20 60 120 20]);
calibDirectDrop = uicontrol('Parent',pR,'Style','popupmenu','FontSize',12,'String',...
    {'---','1. Clockwise','2. Counter-Clockwise'},'Position',...
    [140 60 150 20],'Callback',{@cwDrop_callback});
calibBlockText = uicontrol('Parent',pR,'Style','text','FontSize',12,'String',...
    'Calibration Block: ','HorizontalAlignment','Left','Position',[295 60 100 20]);
calibBlock = uicontrol('Parent',pR,'Style','popupmenu','FontSize',12,'String',...
    {'---','3/8 inch (pig w/ brainvision)','1/4 inch (rabbit)','0.6 inch (pig w/ Andor'},...
    'Position',[395 60 210 20]);
calibTypeTxt = uicontrol('Parent',pR,'String','Calibration Type',...
    'Style','text','HorizontalAlignment','Right','FontSize',12,...
    'Position',[355 90 95 20]);
calibType = uicontrol('Parent',pR,'Style','popupmenu','Position',[450 90 110 20],...
    'String',{'Cube','Camera A','Camera B','Camera C','Camera D'},'FontSize',12);
calibCameraTxt = uicontrol('Parent',pR,'Style','text','FontSize',12,'String',...
    'Camera Type: ','HorizontalAlignment','Left','Position',[20 30 95 20]);
calibCameraType = uicontrol('Parent',pR,'Style','popupmenu','FontSize',12,...
    'String',{'---','iDS_UI_3220CP-M-GL_with_f1.2','brainvision_ultimaL',...
    'watec_with_f8.5 (pig)','watec_with_f12.5 (rabbit)','E4300',...
    'interpolated_dalsa'},'Position',[140 30 230 20]);
calibrate = uicontrol('Parent',pR,'Style','pushbutton','FontSize',12,...
    'String','Calibrate','Position',[375 30 100 20],'Callback',{@calibrate_callback});
calPtEdit = uicontrol('Parent',pR,'Style','edit','FontSize',12,...
    'String','1','Position',[660 90 40 20],'Callback',{@calPtEdit_callback});
calPtInc = uicontrol('Parent',pR,'Style','pushbutton','FontSize',12,...
    'String',char(8594),'Position',[705 90 40 20],'Callback',{@calPtInc_callback});
calPtDec = uicontrol('Parent',pR,'Style','pushbutton','FontSize',12,...
    'String',char(8592),'Position',[615 90 40 20],'Callback',{@calPtDec_callback});
calPtSel = uicontrol('Parent',pR,'Style','pushbutton','FontSize',12,...
    'String','Select','Position',[750 90 70 20],'Callback',{@calPtSel_callback});
calPtLoad = uicontrol('Parent',pR,'Style','pushbutton','FontSize',12,...
    'String','Load','Position',[750 60 70 20],'Callback',{@calPtLoad_callback});
calPtSave = uicontrol('Parent',pR,'Style','pushbutton','FontSize',12,...
    'String','Save','Position',[825 60 70 20],'Callback',{@calPtSave_callback});
calPtClear = uicontrol('Parent',pR,'Style','pushbutton','FontSize',12,...
    'String','Clear','Position',[825 90 70 20],'Callback',{@calPtClear_callback});
calPtFinish = uicontrol('Parent',pR,'Style','pushbutton','FontSize',12,...
    'String','Finish','Position',[900 90 70 20],'Callback',{@calPtFinish_callback});
unitNormTxt = uicontrol('Parent',pR,'Style','text','FontSize',12,...
    'String','Unit Normal: ','HorizontalAlignment','Left','Position',[615 120 70 20]);
unitNormEdit = uicontrol('Parent',pR,'Style','edit','Enable','off','FontSize',12,...
    'String','[-,-,-]','Position',[690 120 60 20]);
positionTxt = uicontrol('Parent',pR,'Style','text','FontSize',12,...
    'String','Position: ','Position',[755 120 65 20]);
positionEdit = uicontrol('Parent',pR,'Style','edit','Enable','off','FontSize',12,...
    'String','[-,-,-]','Position',[820 120 75 20]);
msgCenterTxt = uicontrol('Parent',pR,'Style','text','FontSize',12,...
    'String','Message Center:','Position',[615 60 100 20]);
msgCenterContent = uicontrol('Parent',pR,'Style','text','String','',...
    'Position',[615 10 280 50]);

%Allow all GUI structures to be scaled when window is dragged
set([pR,globalView,regionalView,calibrationPts,qualityPts,calibBlockText,...
    calibBlock,speciesTxt,speciesDrop,calibDirectText,calibDirectDrop,...
    calibrate,dirSelect,dirName,calPtEdit,calPtInc,calPtDec,calPtSel,...
    unitNormEdit,unitNormTxt,positionEdit,positionTxt,calPtClear,calPtFinish,...
    msgCenterTxt,msgCenterContent,calibCameraTxt,calibCameraType,calibType,...
    calibTypeTxt,calPtSave,calPtLoad],'Units','normalized')

% Center GUI on screen
movegui(pR,'center')
set(pR,'MenuBar','none','Visible','on')

%% Create Handles %%
% User defined values
handles.zrange = [60 30]; 
handles.method = 2;
handles.expDir = []; % experimental directory
handles.speciesID = 0; % experimental species
handles.species = [];
handles.angle = [45 45 315 225 135]; % the mapping cameras are currently labeled CW
handles.plane1fname = [];
handles.plane2fname = [];
handles.data = [];                  % calibration data
handles.calStep = 1;                % calibration index value
handles.xi = [];                    % x positions of the calibration points
handles.yi = [];                   % y positions of the calibraiton points
handles.calibXi = [];
handles.calibYi = [];
handles.camera = [];
handles.skipInd = [];                 % skipped calibration points
handles.CT = [];
handles.CMOScams = 'ABCD';


%% Select Experimental Directory
    function dirSelect_callback(~,~)
        % select experimental directory
        handles.expDir = uigetdir;
        % populate text field
        set(dirName,'String',handles.expDir)        
    end

%% Select Species I.D.
    function speciesDrop_callback(source,~)
        % Save out species i.d.
        handles.speciesID = get(source,'Value')-1;
        if handles.speciesID==1
            handles.species='pig_brainvision';
        elseif handles.speciesID==2
            handles.species='rabbit';
        elseif handles.speciesID==3
            handles.species='pig_andor';
        end
    end

%% Select Calibration Direction
    function cwDrop_callback(source,~)
        % Save out calibration direction
        tmp = get(source,'Value');
        if tmp == 1
            handles.calibDirect = '';
        elseif tmp == 2
            handles.calibDirect = 'cw';
        elseif tmp == 3
            handles.calibDirect = 'ccw';
        end
    end

%% Calibrate
    function calibrate_callback(~,~)
        % select the calibration file
        [handles.calfilename,handles.calpathname] = uigetfile('*.tiff','Pick calibration file.');
        if handles.calfilename ~= 0
            % load calibration image
            a = imread([handles.calpathname handles.calfilename]);
            handles.a=a(:,:,1);
            handles.aInfo = imfinfo([handles.calpathname handles.calfilename]);
            
            % plane 1 calibration filenames
            CT = get(calibType,'Value');
            calibNum = 1;

            % create filenames for calibration block locations and normals
            [plane1fname,plane2fname] = getCalibInfo(CT);
            handles.plane1fname = plane1fname;
            handles.plane2fname = plane2fname;

            % create calibration point variables
            handles.calpts_nd = [];
            
            % load calibration block files
            fid=fopen(sprintf('/Users/Chris/Documents/MATLAB/Panoramic/Calibrate/calpts/%s/%s',...
                handles.species,plane1fname));
            if fid~=-1
                fclose(fid);
                fprintf('Loading %s ...\n',handles.plane1fname);
                calpts1=load(sprintf('/Users/Chris/Documents/MATLAB/Panoramic/Calibrate/calpts/%s/%s',...
                    handles.species,plane1fname));
            else
                fprintf('Could not load %s!',plane1fname);
                return
            end
            fid=fopen(sprintf('/Users/Chris/Documents/MATLAB/Panoramic/Calibrate/calpts/%s/%s',...
                handles.species,plane2fname));
            if fid~=-1
                fclose(fid);
                fprintf('Loading %s ...\n',plane2fname);
                calpts2=load(sprintf('/Users/Chris/Documents/MATLAB/Panoramic/Calibrate/calpts/%s/%s',...
                    handles.species,plane2fname));
            else
                fprintf('Could not load %s\n!',plane2fname);
                return
            end
            handles.calpts_nd = [calpts1;calpts2];       % nondimensional calibration point positions in cube basis
            % Preallocate the data variable
            handles.data = zeros(size(handles.calpts_nd,1),8);
            
            % Update unit normal and Position fields
            set(unitNormEdit,'String',['[' num2str(handles.calpts_nd(1,1))...
                ',' num2str(handles.calpts_nd(1,2)) ',' ...
                num2str(handles.calpts_nd(1,3)) ']'])
            set(positionEdit,'String',['[' num2str(handles.calpts_nd(1,4))...
                ',' num2str(handles.calpts_nd(1,5)) ',' ...
                num2str(handles.calpts_nd(1,6)) ']'])
            
            % Preallocate xi and yi calibration coordinate variables
            handles.xi = zeros(size(handles.calpts_nd,1),1);
            handles.yi = zeros(size(handles.calpts_nd,1),1);
            handles.calibTxt = cell(length(handles.xi),1);
            handles.calibXi = zeros(size(handles.calpts_nd,1),1);
            handles.calibYi = zeros(size(handles.calpts_nd,1),1);
            
            % Launch calibration images
            axes(globalView)
            handles.A = image(handles.a);
            colormap('gray')
            set(globalView,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[])
            title('Global View','FontSize',12)
            axes(regionalView)
            set(regionalView,'Color',[0.5 0.5 0.5])
            title('Regional View','FontSize',12)
            axes(calibrationPts)
            image(handles.a)
            set(calibrationPts,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[])
            title('Calibration Points','FontSize',12)
            colormap('gray')
            axes(qualityPts)
            image(handles.a)
            set(qualityPts,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[])
            colormap('gray')
            title('Quality Control','FontSize',12)
        end
    end

%% Increment Calibration Number
    function calPtInc_callback(~,~)
        % Increment number
        step = handles.calStep;
        calpts = handles.calpts_nd;
        if step == size(handles.calpts_nd,1)
            step = 1;
            set(calPtEdit,'String',num2str(step))
        else
            step = step+1;
            set(calPtEdit,'String',num2str(step))
        end
        handles.calStep = step;
        
        % Update Unit Normals and Position fields
        set(unitNormEdit,'String',['[' num2str(calpts(step,1)) ',' ...
            num2str(calpts(step,2)) ',' num2str(calpts(step,3)) ']'])
        set(positionEdit,'String',['[' num2str(calpts(step,4)) ',' ...
            num2str(calpts(step,5)) ',' num2str(calpts(step,6)) ']'])
        
        % Update Global View
        axes(globalView)
        image(handles.a);
        set(globalView,'YTick',[],'XTick',[])
        colormap('gray')
        title('Global View','FontSize',12)
        % Update Regional View
        cla(regionalView)
        axes(regionalView)
        set(regionalView,'Color',[0.5 0.5 0.5])
        title('Regional View','FontSize',12)
        
        % Update Message Center
        set(msgCenterContent,'String','')
    end

%% Decrement Calibration Number
    function calPtDec_callback(~,~)
        % Increment number
        step = handles.calStep;
        calpts = handles.calpts_nd;
        if step == 1
            step = size(handles.calpts_nd,1);
            set(calPtEdit,'String',num2str(step))
        else
            step = step-1;
            set(calPtEdit,'String',num2str(step))
        end
        handles.calStep = step;
        
       % Update Unit Normals and Position fields
        set(unitNormEdit,'String',['[' num2str(calpts(step,1)) ',' ...
            num2str(calpts(step,2)) ',' num2str(calpts(step,3)) ']'])
        set(positionEdit,'String',['[' num2str(calpts(step,4)) ',' ...
            num2str(calpts(step,5)) ',' num2str(calpts(step,6)) ']'])
        
        % Update Global View
        axes(globalView)
        image(handles.a);
        set(globalView,'YTick',[],'XTick',[])
        colormap('gray')
        title('Global View','FontSize',12)
        % Update Regional View
        cla(regionalView)
        axes(regionalView)
        set(regionalView,'Color',[0.5 0.5 0.5])
        title('Regional View','FontSize',12)
        % Update Message Center
        set(msgCenterContent,'String','')
    end

%% Edit Calibration Number
    function calPtEdit_callback(source,~)
        % Grab edit box value
        val = get(source,'String');
        if ~isnumeric(str2double(val)) || isnan(str2double(val))
            set(calPtEdit,'String',num2str(handles.calStep))
            msgbox('Must enter a positive numeric value.','Error','error')
        elseif val < 0
            set(calPtEdit,'String',num2str(handles.calStep))
            msgbox('Must enter a positive numeric value.','Error','error')
        else
            step = str2double(val);
            handles.calStep = step;
            calpts = handles.calpts_nd;
            
            % Update Unit Normals and Position fields
            set(unitNormEdit,'String',['[' num2str(calpts(step,1)) ',' ...
                num2str(calpts(step,2)) ',' num2str(calpts(step,3)) ']'])
            set(positionEdit,'String',['[' num2str(calpts(step,4)) ',' ...
                num2str(calpts(step,5)) ',' num2str(calpts(step,6)) ']'])
        end
        
        % Update Global View
        axes(globalView)
        image(handles.a);
        set(globalView,'YTick',[],'XTick',[])
        colormap('gray')
        title('Global View','FontSize',12)
        % Update Regional View
        cla(regionalView)
        axes(regionalView)
        set(regionalView,'Color',[0.5 0.5 0.5])
        title('Regional View','FontSize',12)
        % Update Message Center
        set(msgCenterContent,'String','')
    end

%% Select Calibration Point
    function calPtSel_callback(~,~)
        step = handles.calStep;
        % Provide user guidance in message center
        set(msgCenterContent,'String','')
        clear str
        str{1} = ['Select region on Global View where calibration point #'...
            num2str(step) ' is located. Select a single point and hit enter.'];
        str = textwrap(msgCenterContent,str);
        set(msgCenterContent,'String',str,'HorizontalAlignment','Left','FontSize',14)
        % function creates cross-hairs that only function over specified
        % axes
        crit = 0;
        while crit == 0
            [xi,yi]=getpts_on_axes(globalView);
            if length(xi) ~= 1
                set(msgCenterContent,'String','')
                clear str
                str{1} = ['Analysis will not proceed until a single point'...
                    ' is selected. Please try again, selecting a single'...
                    ' on the Global View and hitting enter.'];
                str = textwrap(msgCenterContent,str);
                set(msgCenterContent,'String',str,'HorizontalAlignment','Left','FontSize',14)
            else
                crit = 1;
            end
        end        
        xi = round(xi);     handles.xi(step) = xi;
        yi = round(yi);     handles.yi(step) = yi;
        handles.calibTxt{step} = num2str(step);
        handles.calibXi(step) = xi;
        handles.calibYi(step) = yi;       
        axes(globalView)
        hold on
        scatter(xi,yi,'r*','SizeData',96)
        hold off
       
        % put text on calibration image
        cla(calibrationPts)
        axes(calibrationPts)
        image(handles.a)
        set(calibrationPts,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[])
        title('Calibration Points','FontSize',12)
        colormap('gray')
        ind = handles.xi ~= 0;
        ind = ind.*(1:length(handles.xi))';
        ind = unique(ind);
        ind = ind(2:end);
        calibTxt = cell(length(ind),1);
        for n = 1:length(ind)
            calibTxt{n} = handles.calibTxt{ind(n)};
        end
        axes(calibrationPts)
        text(handles.xi(ind),handles.yi(ind),calibTxt,'FontSize',20,'Color','c')
        
        % establish zoom parameters
%         [anx,any] = size(handles.a);
        anx = get(globalView,'XLim');
        anx = floor(anx(2));
        any = get(globalView,'YLim');
        any = floor(any(2));
        if get(calibType,'Value') == 1
            halfrange=ceil(handles.zrange(1)/2);
        else
            halfrange=ceil(handles.zrange(2)/2);
        end
        if xi-halfrange<1
            xzmin=1;
        else
            xzmin=xi-halfrange;
        end
        if xi+halfrange>anx
            xzmax=anx;
        else
            xzmax=xi+halfrange;
        end
        if yi-halfrange<1
            yzmin=1;
        else
            yzmin=yi-halfrange;
        end
        if yi+halfrange>any
            yzmax=any;
        else
            yzmax=yi+halfrange;
        end
        azoom=handles.a(yzmin:yzmax,xzmin:xzmax);
        interpfactor=4;
        [azoomNx,azoomNy]=size(azoom);
        azoom2=imresize(azoom,[azoomNx,azoomNy],'bilinear');
        % establish x and y axis
        xVals = linspace(xzmin,xzmax,size(azoom2,1));
        yVals = linspace(yzmin,yzmax,size(azoom2,2));
        
        axes(regionalView)
        set(regionalView,'XLim',[xVals(1) xVals(end)],'YLim',[yVals(1) yVals(end)])
        image(xVals,yVals,azoom2)
%         image(xVals,yVals,azoom2,'XData',get(regionalView,'XLim'),'YData',get(regionalView,'YLim'))
        hold on
        colormap('gray')
        set(regionalView,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[])        
        title('Regional View','FontSize',12)
        % Provide user guidance in message center
        set(msgCenterContent,'String','')
        clear str
        str{1} = ['Define calibration point #' ...
            num2str(step) ' by clicking 4 points on the Reginoal View'...
            ' that define crosshairs. Consecutive points will be taken'...
            ' as colinear.'];
        str = textwrap(msgCenterContent,str);
        set(msgCenterContent,'String','')
        set(msgCenterContent,'String',str,'HorizontalAlignment','Left','FontSize',14)
        
        % Select points for crosshairs on regional view
        crit1 = 0;
        crit2 = 0;
        while crit1 == 0
            while crit2 == 0
                [cx,cy]=getpts_on_axes(regionalView);
                if length(cx) == 4
                    crit2 = 1;
                else
                    set(msgCenterContent,'String','')
                    clear str
                    str{1} = ['Analysis will not proceed until four points'...
                        ' are selected. Please try again selecting four points'...
                        ' on the Regional View that define a crosshair and hitting enter.'];
                    str = textwrap(msgCenterContent,str);
                    set(msgCenterContent,'String',str,'HorizontalAlignment','Left','FontSize',14)
                end
            end;
            scatter(cx,cy,'ro')
            
            % Plot first part of crosshairs on regional view
            absdiff=abs([cx(2)-cx(1),cy(2)-cy(1)]);   % Perform schnagagins to avoid infinite fits
            maxdiffi1=find(absdiff==max(absdiff));
            if maxdiffi1==1                           % then fit y=my1(x)+by1 for line1
                [Py1,~]=polyfit(cx(1:2),cy(1:2),1);
                my1=Py1(1);
                by1=Py1(2);
                ppx=cx(1)-(cx(2)-cx(1))/10:(cx(2)-cx(1))/10:cx(2)+(cx(2)-cx(1))/10;
                ppy=polyval(Py1,ppx);
                plot(ppx,ppy,'r-')
            else %then maxdiffi1=2                    % then fit x=mx1(y)+bx1 for line1
                [Px1,~]=polyfit(cy(1:2),cx(1:2),1);
                mx1=Px1(1);
                bx1=Px1(2);
                ppy=cy(1)-(cy(2)-cy(1))/10:(cy(2)-cy(1))/10:cy(2)+(cy(2)-cy(1))/10;
                ppx=polyval(Px1,ppy);
                plot(ppx,ppy,'r-')
            end
            
            % Plot second part of crosshairs on regional view
            absdiff=abs([cx(4)-cx(3),cy(4)-cy(3)]);   % Perform schnagagins to avoid infinite fits
            maxdiffi2=find(absdiff==max(absdiff));
            if maxdiffi2==1                           % then fit y=my2(x)+by2 for line2
                [Py2,~]=polyfit(cx(3:4),cy(3:4),1);
                my2=Py2(1);
                by2=Py2(2);
                ppx=cx(3)-(cx(4)-cx(3))/10:(cx(4)-cx(3))/10:cx(4)+(cx(4)-cx(3))/10;
                ppy=polyval(Py2,ppx);
                plot(ppx,ppy,'r-')
            else %then maxdiffi2=2                    % then fit x=mx2(y)+bx2 for line2
                [Px2,~]=polyfit(cy(3:4),cx(3:4),1);
                mx2=Px2(1);
                bx2=Px2(2);
                ppy=cy(3)-(cy(4)-cy(3))/10:(cy(4)-cy(3))/10:cy(4)+(cy(4)-cy(3))/10;
                ppx=polyval(Px2,ppy);
                plot(ppx,ppy,'r-')
            end
            
            % Plot point of intersection
            % Identify point of intersect
            if maxdiffi1==1 && maxdiffi2==1       % then y=my1(x)+by1 and y=my2(x)+by2
                xi=(by2-by1)/(my1-my2);
                yi=my2*xi+by2;
            elseif maxdiffi1==1 && maxdiffi2==2   % then y=my1(x)+by1 and x=mx2(y)+bx2
                yi=(my1*bx2+by1)/(1-my1*mx2);
                xi=mx2*yi+bx2;
            elseif maxdiffi1==2 && maxdiffi2==1   % then x=mx1(y)+bx1 and y=my2(x)+by2
                yi=(my2*bx1+by2)/(1-my2*mx1);
                xi=mx1*yi+bx1;
            elseif maxdiffi1==2 && maxdiffi2==2   % then x=mx1(y)+bx1 and x=mx2(y)+bx2
                yi=(bx2-bx1)/(mx1-mx2);
                xi=mx2*yi+bx2;
            end
            
            
            % If point of intersect is not on the visible axes
            set(regionalView,'XLim',[xzmin xzmax],'YLim',[yzmin yzmax])
            xLim = get(regionalView,'XLim');
            yLim = get(regionalView,'YLim');
            if xi < xLim(1) || xi > xLim(2)
                set(msgCenterContent,'String','')
                clear str
                str{1} = ['The points selected do not create a crosshair'...
                    ' in the field of view. Try again, first selecting two'...
                    ' points to define the horizontal and then selecting two'...
                    ' points to define the vertical. Finish by hittinge enter.'];
                str = textwrap(msgCenterContent,str);
                set(msgCenterContent,'String',str,'HorizontalAlignment','Left','FontSize',14)
                % Reset initial selection loop
                crit2 = 0;
                % Reset Regional View
                cla(regionalView)
                image(azoom2)
                set(regionalView,'Color',[0.5 0.5 0.5])
                title('Regional View','FontSize',12)    
            elseif yi < yLim(1) || yi > yLim(2)
                set(msgCenterContent,'String','')
                clear str
                str{1} = ['The points selected do not create a crosshair'...
                    ' in the field of view. Try again, first selecting two'...
                    ' points to define the horizontal and then selecting two'...
                    ' points to define the vertical. Finish by hitting enter.'];
                str = textwrap(msgCenterContent,str);
                set(msgCenterContent,'String',str,'HorizontalAlignment','Left','FontSize',14)
                % Reset initial selection loop
                crit2 = 0;
                % Reset Regional View
                cla(regionalView)
                image(azoom2)
                set(regionalView,'Color',[0.5 0.5 0.5])
                title('Regional View','FontSize',12)    
            else
                crit1 = 1;
            end
        end
        % Plot point of intersection
        plot(xi,yi,'go')
        
%         xi=(xi-0.5)/interpfactor;      % image command plots images in range [0.5 N+0.5 0.5 M+0.5]
%         yi=(yi-0.5)/interpfactor;      % image command plots images in range [0.5 N+0.5 0.5 M+0.5]
%         
%         xi =xi + xzmin - 1;           % xi range is 0:anx-1
%         yi =yi + yzmin - 1;

        xi = round(xi);
        yi = round(yi);

        % put text on calibration image
        cla(qualityPts)
        axes(qualityPts)
        image(handles.a)
        set(qualityPts,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[])
        title('Quality Points','FontSize',12)
        colormap('gray')
        ind = handles.xi ~= 0;
        ind = ind.*(1:length(handles.xi))';
        ind = unique(ind);
        ind = ind(2:end);
        hold on
%         scatter(handles.xi(ind)+0.5,handles.yi(ind)+0.5,'ro')
        scatter(handles.xi(ind),handles.yi(ind),'ro')
        hold off
        
        % Save out the calibartion information
        handles.data(step,:)=[handles.calpts_nd(step,4:6) xi yi...
            handles.calpts_nd(step,1:3)];
       
    end

%% Clear Calibration Point
    function calPtClear_callback(~,~)
        % Clear data value
        step = handles.calStep;
        handles.data(step,:) = [0 0 0 0 0 0 0 0];
        handles.xi(step) = 0;
        handles.yi(step) = 0;
        
        % Reset Global Axes
        axes(globalView)
        handles.A = image(handles.a);
        colormap('gray')
        set(globalView,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[])        
        title('Global View','FontSize',12)
        
        % Reset Regional Axes
        cla(regionalView)
        axes(regionalView)
        set(regionalView,'Color',[0.5 0.5 0.5])
        title('Regional View','FontSize',12)
        
        % Reset Calibration Points Axes
        cla(calibrationPts)
        axes(calibrationPts)
        image(handles.a)
        set(calibrationPts,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[])
        title('Calibration Points','FontSize',12)
        colormap('gray')
        ind = handles.xi ~= 0;
        ind = ind.*(1:length(handles.xi))';
        ind = unique(ind);
        ind = ind(2:end);
        calibTxt = cell(length(ind),1);
        for n = 1:length(ind)
            calibTxt{n} = handles.calibTxt{ind(n)};
        end
        axes(calibrationPts)
        text(handles.xi(ind),handles.yi(ind),calibTxt,'FontSize',20,'Color','c')
        
        % Reset Quality Points Axes
        cla(qualityPts)
        axes(qualityPts)
        image(handles.a)
        set(qualityPts,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[])
        title('Quality Points','FontSize',12)
        colormap('gray')
        ind = handles.xi ~= 0;
        ind = ind.*(1:length(handles.xi))';
        ind = unique(ind);
        ind = ind(2:end);
        hold on
        scatter(handles.xi(ind),handles.yi(ind),'ro')
        hold off
        
    end

%% Calibration Finish %%
    function calPtFinish_callback(~,~)
        % grab current directory
        cDir = pwd;
        % change to experimental directory
        cd(handles.expDir)
        % Remove zeros from data
        tmp = handles.data(:,4) ~= 0;
        tmp = tmp.*(1:size(handles.data,1))';
        tmp = unique(tmp);
        if length(tmp) > 1
            tmp = tmp(2:end);
            handles.data = handles.data(tmp,:);
        end
            
        dataAll = handles.data;
                    
        % preallocate variables
        par = [];
        pos = [];
        iter = [];
        res = [];
        er = [];
        C = [];
        % grab the camera calibration spacing
        calselect = get(calibBlock,'Value');
        % conversion of units to mm
        if calselect == 2
            dataAll(:,1:3) = dataAll(:,1:3)*(25.4*3/8);
        elseif calselect == 3
            dataAll(:,1:3) = dataAll(:,1:3)*(25.4*1/4);
        elseif calselect == 4
            dataAll(:,1:3) = dataAll(:,1:3)*(25.4*0.6);
        end
      
        % save out calibration
        camNum = get(calibCameraType,'Value');
        camera = get(calibCameraType,'String');
        camera = camera{camNum};
        a = handles.a;
        calibVal = get(calibType,'Value');
        ang = handles.angle(calibVal);
        cwtxt = handles.calibDirect;
        
        calpts_nondim = handles.calpts_nd;
        data = dataAll;
        % calculate calibration
        [par,pos,iter,res,er,C,~]=cacal(camera,dataAll);
        % camera parameters
        pr = par;
        ps = pos;
        % save out parameters
        if get(calibType,'Value') == 1
            savecommand = 'save calGeo_%1.3d a calpts_nondim par pos iter res er C data camera ang cwtxt';
            savecommand = sprintf(savecommand,ang);
        else
            savecommand = 'save cal%s_%1.3d a calpts_nondim par pos iter res er C data camera ang cwtxt';
            savecommand = sprintf(savecommand,handles.CMOScams(calibVal-1),ang);
        end
        eval(savecommand)
        
        %-----------------------------------------
        % Calibrate
        [Xi,Yi]=pred(dataAll(:,1:3),pr,ps,camera);
        
        % Save calibration parameters
        if calibVal == 1
            posparfname = sprintf('calGeo_%1.3d.pospar',ang);
        else
            posparfname = sprintf('cal%s_%1.3d.pospar',handles.CMOScams(calibVal-1),ang);
        end
        posparfid=fopen(posparfname,'w');
        for i=1:6
            fprintf(posparfid,'%15e\n',pos(i));
        end
        for i=1:8
            fprintf(posparfid,'%15e\n',par(i));
        end
        fclose(posparfid);

        % Display calibrated points
        cla(qualityPts)
        axes(qualityPts)
        image(handles.a)
        set(qualityPts,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[])
        colormap('gray')
        hold on
        xi=handles.data(:,4);
        yi=handles.data(:,5);
% %         plot(xi+0.5,yi+0.5,'go','MarkerFaceColor','g');         % image command plots images in range [0.5 N+0.5 0.5 M+0.5]
% %         plot(Xi+0.5,Yi+0.5,'ro','MarkerFaceColor','r');         % image command plots images in range [0.5 N+0.5 0.5 M+0.5]
        plot(xi,yi,'go','MarkerFaceColor','g');         % image command plots images in range [0.5 N+0.5 0.5 M+0.5]
        plot(Xi,Yi,'ro','MarkerFaceColor','r'); 
        title('Predicted calibration points','FontSize',12);
%         jpegcommand=sprintf('print -djpeg Predicted%s.jpg',handles.calfilename(1:end-5));
%         eval(jpegcommand);
        % return to original directory
        cd(cDir)
        
    end

%% Save Calibration Points
    function calPtSave_callback(~,~)
        % grab current directory
        cDir = pwd;
        % change directory to experimental directory
        cd(handles.expDir)
        % grab points to save out
        xi = handles.xi;
        yi = handles.yi;
        data = handles.data;
        calibTxt = handles.calibTxt;
        % get calibration type
        calID = get(calibType,'Value');
        % assemble save out command
        if calID == 1
            tmp = sprintf('save calptsGeo_%1.3d xi yi data calibTxt',...
                handles.angle(calID));
            eval(tmp)
        else
            tmp = sprintf('save calpts%s_%1.3d xi yi data calibTxt',...
                handles.CMOScams(calID-1),handles.angle(calID));
            eval(tmp)
        end
        % return directory
        cd(cDir)
    end

%% Load Calibration Points
    function calPtLoad_callback(~,~)
        [filename,pathname] = uigetfile;
        if ~isempty(filename)
            %preallocate variables
            xi = [];
            yi = [];
            data = [];
            calibTxt = [];
            % load the points
            load([pathname filename])
            % save to handles
            handles.xi = xi;
            handles.yi = yi;
            handles.data = data;
            handles.calibTxt = calibTxt;
            % plot the points
            cla(qualityPts)
            axes(qualityPts)
            image(handles.a)
            set(qualityPts,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[])
            title('Quality Points','FontSize',12)
            colormap('gray')
            ind = handles.xi ~= 0;
            ind = ind.*(1:length(handles.xi))';
            ind = unique(ind);
            ind = ind(2:end);
            hold on
            scatter(handles.xi(ind),handles.yi(ind),'ro')
            hold off
            % plot the text
            cla(calibrationPts)
            axes(calibrationPts)
            image(handles.a)
            set(calibrationPts,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[])
            title('Calibration Points','FontSize',12)
            colormap('gray')
            ind = handles.xi ~= 0;
            ind = ind.*(1:length(handles.xi))';
            ind = unique(ind);
            ind = ind(2:end);
            calibTxt = cell(length(ind),1);
            for n = 1:length(ind)
                calibTxt{n} = handles.calibTxt{ind(n)};
            end
            axes(calibrationPts)
            text(handles.xi(ind),handles.yi(ind),calibTxt,'FontSize',20,'Color','c')
        end
    end
end