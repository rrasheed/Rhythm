function WHIRL2
close all
% Description: Adaption of whirl.m written by Dr. Matthew Kay to a 
% graphical user interface for designating silhouettes of panoramic imaging 
% geometry. Make sure the camera calibration files Par.dat and Rc.dat are
% located in the home directory prior to initiating GUI.
%
% Author: Christopher Gloschat
% Date: June 20, 2016


%% Create GUI structure
% scrnSize = get(0,'ScreenSize');
pR = figure('Name','WHIRL 2.0','Visible','off',...
    'Position',[1 1 540 800],'NumberTitle','Off');
% Screens for anlayzing data
axesSize = 500;
silhView = axes('Parent',pR,'Units','Pixels','YTick',[],'XTick',[],...
    'Position',[20 280 axesSize axesSize]);

% Selection of home directory
hDirButton = uicontrol('Parent',pR,'Style','pushbutton','String','Home Directory',...
    'FontSize',12,'Position',[25 250 100 20],'Callback',{@hDirButton_callback});
hDirTxt = uicontrol('Parent',pR,'Style','edit','String','','FontSize',11,...
    'Enable','off','HorizontalAlignment','Left','Position',[130 250 390 20]);
% Selection of image directory
iDirButton = uicontrol('Parent',pR,'Style','pushbutton','String','Image Directory',...
    'FontSize',12,'Position',[25 220 100 20],'Callback',{@iDirButton_callback});
iDirTxt = uicontrol('Parent',pR,'Style','edit','String','','FontSize',12,...
    'Enable','off','HorizontalAlignment','Left','Position',[130 220 390 20]);

% Rotation and images settings for analysis
degreeTxt = uicontrol('Parent',pR,'Style','text','String','Degrees Per Step:',...
    'HorizontalAlignment','Right','FontSize',12,'Position',[20 190 105 20]);
degreeEdit = uicontrol('Parent',pR,'Style','edit','String','5',...
    'FontSize',12,'Position',[130 190 40 20],'Callback',{@degreeEdit_callback});
imagesTxt = uicontrol('Parent',pR,'Style','text','String','Images Acquired:',...
    'HorizontalAlignment','Right','FontSize',12,'Position',[20 160 105 20]);
imagesEdit = uicontrol('Parent',pR,'Style','edit','String','72',...
    'FontSize',12,'Position',[130 160 40 20],'Callback',{@imagesEdit_callback});

% Threshold value
threshTxt = uicontrol('Parent',pR,'Style','text','String','Threshold Value:',...
    'FontSize',12,'HorizontalAlignment','Right','Position',[315 70 105 20]);
threshEdit = uicontrol('Parent',pR,'Style','edit','String','0.350',...
    'FontSize',12,'Position',[425 70 40 20],'Callback',{@threshEdit_callback});
threshApply = uicontrol('Parent',pR,'Style','pushbutton','String','Apply',...
    'FontSize',12,'Position',[470 70 40 20],'Callback',{@threshApply_callback});
threshAdd = uicontrol('Parent',pR,'Style','pushbutton','String','Add',...
    'FontSize',12,'Position',[425 40 40 20],'Callback',{@threshAdd_callback});
threshMinus = uicontrol('Parent',pR,'Style','pushbutton','String',...
    'Minus','FontSize',12,'Position',[470 40 40 20],'Callback',{@threshMinus_callback});
silhSave = uicontrol('Parent',pR,'Style','pushbutton','String','Save',...
    'FontSize',12,'Position',[375 40 40 20],'Callback',{@silhSave_callback});
silhProcess = uicontrol('Parent',pR,'Style','pushbutton','String','Process',...
    'FontSize',12,'Position',[375 10 40 20],'Callback',{@silhProcess_callback});

% Load background images
loadBkgdButton = uicontrol('Parent',pR,'Style','pushbutton','String',...
    'Load Backgrounds','FontSize',12,'Position',[25 70 145 20],...
    'Callback',{@loadBkgdButton_callback});

% Above or below threshold designation
abThreshPop = uicontrol('Parent',pR,'Style','popupmenu','String',...
    {'Above','Below'},'Position',[65 100 112 20],'Callback',...
    {@abThreshPop_callback});

% Switch between images
imNumEdit = uicontrol('Parent',pR,'Style','edit','FontSize',12,...
    'String','1','Position',[225 70 40 20],'Callback',{@imNumEdit_callback});
imNumInc = uicontrol('Parent',pR,'Style','pushbutton','FontSize',12,...
    'String',char(8594),'Position',[270 70 40 20],'Callback',{@imNumInc_callback});
imNumDec = uicontrol('Parent',pR,'Style','pushbutton','FontSize',12,...
    'String',char(8592),'Position',[180 70 40 20],'Callback',{@imNumDec_callback});

% Message center text box
msgCenter = uicontrol('Parent',pR,'Style','text','String','','FontSize',...
    12,'Position',[180 130 340 80]);

% Allow all GUI structures to be scaled when window is dragged
set([pR,silhView,hDirButton,hDirTxt,degreeTxt,degreeEdit,imagesTxt,imagesEdit,...
    threshTxt,threshEdit,loadBkgdButton,msgCenter,abThreshPop,iDirButton,...
    iDirTxt,imNumEdit,imNumInc,imNumDec,threshApply,threshAdd,threshMinus,...
    silhSave,silhProcess],'Units','normalized')

% Center GUI on screen
movegui(pR,'center')
set(pR,'MenuBar','none','Visible','on')

%% Create handles
handles.hdir = [];
handles.bdir = [];
handles.dtheta = str2double(get(degreeEdit,'String'));
handles.n_images = str2double(get(imagesEdit,'String'));
handles.oldDir = pwd;
handles.fileList = [];
handles.sfilename = [];
handles.ndigits = [];
handles.def_thresh = str2double(get(threshEdit,'String'));
handles.aabb = str2double(get(threshEdit,'String'));
handles.thresharr = zeros(1,handles.n_images);
handles.loadClicked = 0;
handles.currentImage = 1;
handles.silhs = [];


%% Select the directory with the heart background images
    function hDirButton_callback(~,~)
         % select experimental directory
        handles.hdir = uigetdir;
        % populate text field
        set(hDirTxt,'String',handles.hdir)
        % change directory
        cd(handles.hdir)
    end

%% Select image directory
    function iDirButton_callback(~,~)
        % select experimental directory
        handles.bdir = uigetdir;
        % populate text field
        set(iDirTxt,'String',['...' handles.bdir(length(handles.hdir)+1:end)])
        % change directory
        cd(handles.bdir)
        % list of files in the directory
        fileList = dir;
        % grab files that are tiffs
        checkFiles = zeros(size(fileList,1),1);
        for n = 1:length(checkFiles)
            if length(fileList(n).name) > 4
                checkFiles(n) = strcmp(fileList(n).name(end-3:end),'tiff');
            else
                checkFiles(n) = 0;
            end
        end
        % grab indices of the files that are tiffs
        checkFiles = checkFiles.*(1:length(checkFiles))';
        checkFiles = unique(checkFiles);
        checkFiles = checkFiles(2:end);
        % remove directories from file list
        fileList = fileList(checkFiles);
        
        % identify period that separates the name and file type
        charCheck = zeros(length(fileList(1).name),1);
        for n = 1:length(charCheck)
            % char(46) is a period
            charCheck(n) = fileList(1).name(n) == char(46);
            if charCheck(n) == 1
                middleInd = n;
                break
            end
        end
        % assign the file type
        handles.sfilename = fileList(1).name(middleInd+1:end);
        
        % identify numeric portion of filenames
        nameInd = 1:middleInd-1;
        numCheck = 48:57;
        nameInd = repmat(nameInd,[length(numCheck) 1]);
        numCheck = repmat(numCheck',[1 size(nameInd,2)]);
        numCheck = fileList(1).name(nameInd) == char(numCheck);
        numCheck = sum(numCheck).*(1:size(nameInd,2));
        numCheck = unique(numCheck);
        if length(numCheck) > 1
            numCheck = numCheck(2:end);
        end
        % number of digits in filenames
        handles.ndigits = length(numCheck);
        
        % assign filename
        handles.bfilename = fileList(1).name(1:numCheck(1)-1);
        
        % assign start number for the silhouettes files
        handles.sdigit = fileList(1).name(numCheck(end));
        
        % save out filenames
        handles.fileList = fileList;
        
        % preallocate space for silhouettes
        
    end

%% Set the number of degrees per step
    function degreeEdit_callback(source,~)
        if isnan(str2double(source.String))
            errordlg('Value must be positive and numeric','Invalid Input')
            set(degreeEdit,'String','')
        elseif str2double(source.String) <= 0
            errordlg('Value must be positive and numeric','Invalid Input')
            set(degreeEdit,'String','')
        else
            handles.dtheta = str2double(source.String);
        end
    end

%% Set the number of background images acquired
    function imagesEdit_callback(source,~)
        if isnan(str2double(source.String))
            errordlg('Value must be positive and numeric','Invalid Input')
            set(imagesEdit,'String','')
        elseif str2double(source.String) <= 0
            errordlg('Value must be positive and numeric','Invalid Input')
            set(imagesEdit,'String','')
        else
            handles.n_images = str2double(source.String);
        end
    end

%% Set the threshold for identifying the silhouettes
    function threshEdit_callback(source,~)
        if isnan(str2double(source.String))
            errordlg('Value must be positive and numeric','Invalid Input')
            set(threshEdit,'String','')
        elseif str2double(source.String) <= 0
            errordlg('Value must be positive and numeric','Invalid Input')
            set(threshEdit,'String','')
        else
            handles.def_thresh = str2double(source.String);
            handles.thresharr = handles.thresharr + handles.def_thresh;
        end
    end

%% Apply threshold to images
    function threshApply_callback(~,~)
        % Clear axes
        cla(silhView)
        % Plot image to axes
        fname = handles.fileList(handles.currentImage).name;
        a = imread(fname);
        a = rgb2gray(a);
        a = double(a);
        handles.a = a/max(max(a(:,:,1)));
        axes(silhView)
        imagesc(handles.a)
        colormap('gray')
        set(silhView,'XTick',[],'YTick',[])
        % Calculate the outline based on the specified threshold settings
        [bw] = calcSilh(handles.a,handles.def_thresh,handles.aabb);
        handles.silhs(:,:,handles.currentImage) = bw;
        % Find outline and superimpose on image
        outline = bwperim(bw,8);
        [or,oc]=find(outline);
        axes(silhView)
        hold on
        plot(oc,or,'y.');
        hold off
        
        stats = regionprops(bw,'all');
        % Image area
        handles.area(handles.currentImage) = stats.Area;
        % Limits of image in x and y coordinates
        lims = stats.BoundingBox;
        xl1=ceil(lims(1));
        yl1=ceil(lims(2));
        xl2=xl1+lims(3);
        yl2=yl1+lims(4);
        % limits
        handles.lims(handles.currentImage,:) = [xl1 xl2 yl1 yl2];
        
    end

%% Add to the silhouette
    function threshAdd_callback(~,~)
        % Define region to add to silhouette
        CI = handles.currentImage;
        axes(silhView)
        add = roipoly;
        if ~isempty(add)
            handles.silhs(:,:,CI) = handles.silhs(:,:,CI) + add;
            handles.silhs(:,:,CI) = handles.silhs(:,:,CI) > 0;
            
            % Replot image
            cla(silhView)
            axes(silhView)
            imagesc(handles.a)
            colormap('gray')
            set(silhView,'XTick',[],'YTick',[])
            
            % Calculate and  plot new outline
            outline = bwperim(handles.silhs(:,:,CI),8);
            [or,oc]=find(outline);
            axes(silhView)
            hold on
            plot(oc,or,'y.');
            hold off
            
            stats = regionprops(handles.silhs(:,:,CI),'all');
            % Image area
            handles.area(handles.currentImage) = stats.Area;
            % Limits of image in x and y coordinates
            lims = stats.BoundingBox;
            xl1=ceil(lims(1));
            yl1=ceil(lims(2));
            xl2=xl1+lims(3);
            yl2=yl1+lims(4);
            % limits
            handles.lims(handles.currentImage,:) = [xl1 xl2 yl1 yl2];
            
        end
    end

%% Subtract from the silhouette
    function threshMinus_callback(~,~)
        % Define region to add to silhouette
        CI = handles.currentImage;
        axes(silhView)
        minus = roipoly;
        if ~isempty(minus)
            handles.silhs(:,:,CI) = handles.silhs(:,:,CI) - minus;
            handles.silhs(:,:,CI) = handles.silhs(:,:,CI) > 0;
            
            % Replot image
            cla(silhView)
            axes(silhView)
            imagesc(handles.a)
            colormap('gray')
            set(silhView,'XTick',[],'YTick',[])
            
            % Calculate and  plot new outline
            outline = bwperim(handles.silhs(:,:,CI),8);
            [or,oc]=find(outline);
            axes(silhView)
            hold on
            plot(oc,or,'y.');
            hold off
            
            stats = regionprops(handles.silhs(:,:,CI),'all');
            % Image area
            handles.area(handles.currentImage) = stats.Area;
            % Limits of image in x and y coordinates
            lims = stats.BoundingBox;
            xl1=ceil(lims(1));
            yl1=ceil(lims(2));
            xl2=xl1+lims(3);
            yl2=yl1+lims(4);
            % limits
            handles.lims(handles.currentImage,:) = [xl1 xl2 yl1 yl2];
        end
    end

%% Above or below threshold
    function abThreshPop_callback(source,~)
        if source.Value == 1
            handles.aabb = 1;
        else
            handles.aabb = 0;
        end
    end

%% Load background images
    function loadBkgdButton_callback(~,~)
        % Check for already established silhouettes
        cd(handles.hdir)
        fid=fopen('silhs1.mat');
        if fid~=-1
            set(msgCenter,'String','Found silhouettes!');
            fclose(fid);
            issilh=1;
        else
            set(msgCenter,'String','Could not find silhouettes!');
            issilh=0;
        end
        
        % Change current directory to heart geometry directory
        cd(handles.bdir)
        
        % Load thresholds or set a default threshold
        if issilh
            pickSilh = questdlg('FOUND SILHS1.MAT! USE OLD SILHOUETTES OR ESTABLISH NEW ONES?',...
                'Old vs. New','OLD','NEW','OLD');
            % Handle response
            switch pickSilh
                case 'OLD'
                    loadsilh = 1;
                case 'NEW'
                    loadsilh = 0;
            end
        end
        
        % Prep image variable
        fname = handles.fileList(handles.currentImage).name;
        a = imread(fname);
        a = rgb2gray(a);
        a = double(a);
        handles.a = a/max(max(a(:,:,1)));
        
        % Determine thresholds four silhouettes
        if issilh == 1 && loadsilh == 1
            % Load established silhouettes
            cd(handles.hdir)
            silhs = [];
            lims = [];
            area = [];
            load('silhs1.mat')
            handles.lims = lims;
            handles.area = area;
            handles.silhs = silhs;
            % Setup first threshold
            bw = handles.silhs(:,:,handles.currentImage);
            cd(handles.bdir)
            % Establish thresholds
        else
            % Preallocate space for silhouettes
            handles.silhs = zeros(size(handles.a,1),size(handles.a,2),...
                size(handles.thresharr,2));
            % Calculate the outline based on the specified threshold settings
            [bw] = calcSilh(handles.a,handles.def_thresh,handles.aabb);
            handles.silhs(:,:,handles.currentImage) = bw;
        end
        % Plot image to plot
        axes(silhView)
        imagesc(handles.a)
        colormap('gray')
        set(silhView,'XTick',[],'YTick',[])
        
        % Find outline and superimpose on image
        outline = bwperim(bw,8);
        [or,oc]=find(outline);
        axes(silhView)
        hold on
        plot(oc,or,'y.');
        hold off
        
        stats = regionprops(bw,'all');
        % Image area
        handles.area(handles.currentImage) = stats.Area;
        % Limits of image in x and y coordinates
        lims = stats.BoundingBox;
        xl1=ceil(lims(1));
        yl1=ceil(lims(2));
        xl2=xl1+lims(3);
        yl2=yl1+lims(4);
        % limits
        handles.lims(handles.currentImage,:) = [xl1 xl2 yl1 yl2];
        
        % Disable button
        set(loadBkgdButton,'Enable','off')
        handles.loadClicked = 1;
        
    end

%% Callback for saving silhouettes
    function silhSave_callback(~,~)
        currentdir = pwd;
        cd(handles.hdir)
        silhs = handles.silhs;
        lims = handles.lims;
        area = handles.area;
        save('silhs1.mat','silhs','lims','area')
        cd(currentdir)
    end

%% Callback for processing silhouettes
    function silhProcess_callback(~,~)
        % Determine front back positions
        r=0:handles.dtheta:(handles.n_images*handles.dtheta-1);
        if rem(360,handles.dtheta)==0
            % Determine front/back positions
            frontback=1;
            rr=zeros(length(r),5).*NaN;
            r1=find(r-180<0);
            r2=find(r-180>=0);
            rr(1:length(r1),1)=r(r1)';
            rr(1:length(r2),2)=r(r2)';
            rr(1:length(r1),3)=r1';
            rr(1:length(r2),4)=r2';
            rnot=find(isnan(rr(:,1)) & isnan(rr(:,2)));
            rr(rnot,:)=[];
            sprintf('Front/Back positions:')
            disp('Front : Back : Front Index : Back Index : ?')
            disp(rr)
            clear r1 r2 rnot
        else
            
            % No front/back images
            frontback=0;
            rr=zeros(size(r,2),5).*NaN;
            rr(:,1)=r';
            disp(rr(:,1))
            sprintf('No Front/Back positions!')
        end
        
        % Ask user if they wish to reduce redundancy
        if frontback
            go=1;
            while go
                collapseSilhs = questdlg(['USE LARGEST SILHOUETTES TO COLLAPSE'...
                    ' REDUNDANT INFORMATION IN FRONT/BACK SNAPSHOTS? [N]:'],...
                    'Collapse Redudant Silhouettes?','Yes','No','No');
                switch collapseSilhs
                    case 'Yes'
                        go = 0;
                        dofrontback = 1;
                    case 'No'
                        go = 0;
                        dofrontback = 0;
                end
            end
        end
        if dofrontback
            for i=1:size(rr,1)
                ars=[handles.area(rr(i,3)) handles.area(rr(i,4))];
                maxarsi=find(ars==max(ars));
                if maxarsi==1, rr(i,5)=rr(i,3); end;
                if maxarsi==2, rr(i,5)=rr(i,4); end;
            end
            disp('First 2 columns are snapshot angle.')
            disp('Next 2 columns are corresponding snapshot numbers.')
            disp('Last column is snapshot number of larger silhouette:')
            disp(rr)
            disp('Snapshots taken at these angles will be used.')
            disp('First column is snapshot number.')
            disp('Second column is the angle.')
            [rsort,isort]=sort(r(rr(:,5)));
            inumsort=rr(isort,5);
            irsort=[inumsort rsort'];
            disp([inumsort rsort'])
        else
            disp('Snapshots taken at these angles will be used.')
            disp('First column is snapshot number.')
            disp('Second column is the angle. ')
            rsort=r;
            inumsort=1:length(r);
            irsort=[inumsort' rsort'];
            disp([inumsort' rsort'])
        end
        silh = handles.silhs;
        lims = handles.lims;
        
        % Perform occluding contours cube carving
        cubeCarvingMod(handles.hdir,handles.silhs,handles.lims,...
            handles.dtheta,handles.n_images,dofrontback,r,rr,irsort,...
            inumsort,rsort)
    end


%% Callback for manually changing image number %%
    function imNumEdit_callback(source,~)
        % Grab edit box value
        val = str2double(get(source,'String'));
        if ~isnumeric(val) || isnan(val)
            set(imNumEdit,'String',num2str(handles.currentImage))
            msgbox('Must enter a positive numeric value.','Error','error')
        elseif val < 0
            set(imNumEdit,'String',num2str(handles.currentImage))
            msgbox('Must enter a positive numeric value.','Error','error')
        elseif val > handles.n_images
            set(imNumEdit,'String',num2str(handles.currentImage))
            msgbox('Must enter a value equal to or less than total number of images.',...
                'Error','error')
        else
            % Update current image value
            handles.currentImage = val;
            % Update silhouette window
            if handles.loadClicked
                % Clear axes
                cla(silhView)
                
                % Plot image to axes
                fname = handles.fileList(handles.currentImage).name;
                a = imread([handles.bdir '/' fname]);
                a = rgb2gray(a);
                a = double(a);
                handles.a = a/max(max(a(:,:,1)));
                axes(silhView)
                imagesc(handles.a)
                colormap('gray')
                set(silhView,'XTick',[],'YTick',[])
                
                % Calculate the outline based on the specified threshold settings
                if sum(sum(handles.silhs(:,:,handles.currentImage))) == 0
                    [bw] = calcSilh(handles.a,handles.def_thresh,handles.aabb);
                    handles.silhs(:,:,handles.currentImage) = bw;
                else
                    bw = handles.silhs(:,:,handles.currentImage);
                end
                
                % Find outline and superimpose on image
                outline = bwperim(bw,8);
                [or,oc]=find(outline);
                axes(silhView)
                hold on
                plot(oc,or,'y.');
                hold off
                
                stats = regionprops(bw,'all');
                % Image area
                handles.area(handles.currentImage) = stats.Area;
                % Limits of image in x and y coordinates
                lims = stats.BoundingBox;
                xl1=ceil(lims(1));
                yl1=ceil(lims(2));
                xl2=xl1+lims(3);
                yl2=yl1+lims(4);
                % limits
                handles.lims(handles.currentImage,:) = [xl1 xl2 yl1 yl2];
                
            end
        end
    end

%% Callback for incrementing image number
    function imNumInc_callback(~,~)
        % Update current image tracker
        val = handles.currentImage;
        if val+1 > handles.n_images
            handles.currentImage = 1;
            set(imNumEdit,'String',num2str(handles.currentImage))
        else
            handles.currentImage = val+1;
            set(imNumEdit,'String',num2str(handles.currentImage))
        end
        % Update silhouette window
        if handles.loadClicked
            
            % Create space at top of image
            % Added for initial data set MAY NOT BE NECESSARY IN THE FUTURE
            rm = zeros(size(handles.a,1),size(handles.a,2));
            rm(1:15,:) = 1;
            CI = handles.currentImage;
            handles.silhs(:,:,CI) = handles.silhs(:,:,CI) - rm;
            handles.silhs(:,:,CI) = handles.silhs(:,:,CI) > 0;
            
            % Clear axes
            cla(silhView)
            % Plot image to axes
            fname = handles.fileList(handles.currentImage).name;
            a = imread([handles.bdir '/' fname]);
            a = rgb2gray(a);
            a = double(a);
            handles.a = a/max(max(a(:,:,1)));
            axes(silhView)
            imagesc(handles.a)
            colormap('gray')
            set(silhView,'XTick',[],'YTick',[]);
            % Calculate the outline based on the specified threshold settings
            if sum(sum(handles.silhs(:,:,handles.currentImage))) == 0
                [bw] = calcSilh(handles.a,handles.def_thresh,handles.aabb);
                handles.silhs(:,:,handles.currentImage) = bw;
            else
                bw = handles.silhs(:,:,handles.currentImage);
            end
            % Find outline and superimpose on image
            outline = bwperim(bw,8);
            [or,oc]=find(outline);
            axes(silhView)
            hold on
            plot(oc,or,'y.');
            hold off
            
            stats = regionprops(bw,'all');
            % Image area
            handles.area(handles.currentImage) = stats.Area;
            % Limits of image in x and y coordinates
            lims = stats.BoundingBox;
            xl1=ceil(lims(1));
            yl1=ceil(lims(2));
            xl2=xl1+lims(3);
            yl2=yl1+lims(4);
            % limits
            handles.lims(handles.currentImage,:) = [xl1 xl2 yl1 yl2];
        end
    end

%% Callback for decrementing image number
    function imNumDec_callback(~,~)
        % Update current image tracker
        val = handles.currentImage;
        if val-1 == 0
            handles.currentImage = handles.n_images;
            set(imNumEdit,'String',num2str(handles.currentImage))
        else
            handles.currentImage = val-1;
            set(imNumEdit,'String',num2str(handles.currentImage))
        end
        % Update silhouette window
        if handles.loadClicked
            % Clear axes
            cla(silhView)
            % Plot image to axes
            fname = handles.fileList(handles.currentImage).name;
            a = imread([handles.bdir '/' fname]);
            a = rgb2gray(a);
            a = double(a);
            handles.a = a/max(max(a(:,:,1)));
            axes(silhView)
            imagesc(handles.a)
            colormap('gray')
            set(silhView,'XTick',[],'YTick',[]);
            % Calculate the outline based on the specified threshold settings
            if sum(sum(handles.silhs(:,:,handles.currentImage))) == 0
                [bw] = calcSilh(handles.a,handles.def_thresh,handles.aabb);
                handles.silhs(:,:,handles.currentImage) = bw;
            else
                bw = handles.silhs(:,:,handles.currentImage);
            end
            % Find outline and superimpose on image
            outline = bwperim(bw,8);
            [or,oc]=find(outline);
            axes(silhView)
            hold on
            plot(oc,or,'y.');
            hold off
            
            stats = regionprops(bw,'all');
            % Image area
            handles.area(handles.currentImage) = stats.Area;
            % Limits of image in x and y coordinates
            lims = stats.BoundingBox;
            xl1=ceil(lims(1));
            yl1=ceil(lims(2));
            xl2=xl1+lims(3);
            yl2=yl1+lims(4);
            % limits
            handles.lims(handles.currentImage,:) = [xl1 xl2 yl1 yl2];
            
        end
    end

end