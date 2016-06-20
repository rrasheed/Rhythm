function WHIRL2
close all
% Description: Adaption of whirl.m written by Dr. Matthew Kay to a 
% graphical user interface for designating silhouettes of panoramic imaging 
% geometry.
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
degreeEdit = uicontrol('Parent',pR,'Style','edit','String','',...
    'FontSize',12,'Position',[130 190 40 20],'Callback',{@degreeEdit_callback});
imagesTxt = uicontrol('Parent',pR,'Style','text','String','Images Acquired:',...
    'HorizontalAlignment','Right','FontSize',12,'Position',[20 160 105 20]);
imagesEdit = uicontrol('Parent',pR,'Style','edit','String','',...
    'FontSize',12,'Position',[130 160 40 20],'Callback',{@imagesEdit_callback});

% Threshold value
threshTxt = uicontrol('Parent',pR,'Style','text','String','Threshold Value:',...
    'FontSize',12,'HorizontalAlignment','Right','Position',[20 130 105 20]);
threshEdit = uicontrol('Parent',pR,'Style','edit','String','0.350',...
    'FontSize',12,'Position',[130 130 40 20],'Callback',{@threshEdit_callback});

% Load background images
loadBkgdButton = uicontrol('Parent',pR,'Style','pushbutton','String',...
    'Load Backgrounds','FontSize',12,'Position',[25 70 145 20],...
    'Callback',{@loadBkgdButton_callback});

% Above or below threshold designation
abThreshPop = uicontrol('Parent',pR,'Style','popupmenu','String',...
    {'---','Above','Below'},'Position',[65 100 112 20],'Callback',...
    {@abThreshPop_callback});

% Use old thresholds or set new thresholds
useThreshButton = uicontrol('Parent',pR,'Style','pushbutton','String',...
    'Use Old','FontSize',12,'Position',[25 40 70 20],'Callback',...
    {@useThreshButton_callback});
setThreshButton = uicontrol('Parent',pR,'Style','pushbutton','String',...
    'Set New','FontSize',12,'Position',[100 40 70 20],'Callback',...
    {@setThreshButton_callback});

% Message center text box
msgCenter = uicontrol('Parent',pR,'Style','text','String','','FontSize',...
    12,'Position',[180 130 340 80]);

% Allow all GUI structures to be scaled when window is dragged
set([pR,silhView,hDirButton,hDirTxt,degreeTxt,degreeEdit,imagesTxt,imagesEdit,...
    threshTxt,threshEdit,loadBkgdButton,msgCenter,abThreshPop,useThreshButton,...
    setThreshButton,iDirButton,iDirTxt],'Units','normalized')

% Center GUI on screen
movegui(pR,'center')
set(pR,'Visible','on')

%% Create handles
handles.hdir = [];
handles.bdir = [];
handles.dtheta = [];
handles.n_images = [];
handles.oldDir = pwd;
handles.fileList = [];
handles.sfilename = [];
handles.ndigits = [];
handles.def_thresh = [];
handles.aabb = [];


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
        % check which list items are directories and which are files
        checkFiles = zeros(size(fileList,1),1);
        for n = 1:length(checkFiles)
           checkFiles(n) = fileList(n).isdir; 
        end
        % grab indices of the files that are directories
        checkFiles = checkFiles.*(1:length(checkFiles))';
        checkFiles = unique(checkFiles);
        checkFiles = checkFiles(2:end);
        % remove directories from file list
        fileList(checkFiles) = [];
        
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
           handles.n_images = str2double(source.String); 
        end
    end

%% Above or below threshold
    function abThreshPop_callback(source,~)
        if source.Value == 1
            handles.aabb = [];
        elseif source.Value == 2
            handles.aabb = 1;
        else
            handles.aabb = 0;
        end
    end

%% Load background images
    function loadBkgdButton_callback(~,~)
        % Check for already established threshold values
        cd(handles.hdir)
        fid=fopen('thresharr.dat');
        if fid~=-1
            set(msgCenter,'String','Found thresharr.dat!');
            fclose(fid);
            loadthresh=1;
        else
            set(msgCenter,'String','Could not find thresharr.dat!');
            loadthresh=0;
        end
        
        % Load thresholds or set a default threshold
        if loadthresh
            pickThresh = questdlg('USE OLD THRESHOLDS OR ESTABLISH NEW ONES?',...
                'Old vs. New','OLD','NEW','Old');
            % Handle response
            switch pickThresh
                case 'Old'
                    loadthresh = 1;
                case 'New'
                    loadthresh = 0;
            end
        end
        
        end
end