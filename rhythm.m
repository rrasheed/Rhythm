function rhythm
% close all; clc;
%% RHYTHM (01/27/2012)
% Matlab software for analyzing optical mapping data
%
% By Matt Sulkin, Jake Laughner, Xinyuan Sophia Cui, Jed Jackoway
% Washington University in St. Louis -- Efimov Lab
%
% Currently maintained by: Christopher Gloschat [Jan. 2015 - Present]
%
% For any questions and suggestions, please email us at:
% cgloschat@gmail.com or igor@wustl.edu
%
% Modification Log:
% Jan. 23, 2015 - 1) Size of tools adjusted for MATLAB 2014a to constrain 
% all tools and labels to their groups. Mostly cosmetic adjustment. 2) I
% built in fail safes to prevent the GUI from doing undesired things. For
% example, if cancel was selected after clicking get directory it set the
% directory to root. Now it will only set the directory if a directory is
% set.
%
% Jan. 26, 2015 - The invert_cmap function was added to facilitate the
% inversion of the default colormap used for maps of activation time and
% action potential duration.
%
% Feb. 9, 2015 - With the MATLAB2014b release multiple commands in the
% visualization toolkit were changed. Among these were the video writer
% commands and the command for tracking mouse clicks on the GUI. These
% commands have been updated and RHYTHM should now be functional on 2014b.
%
% Feb. 24, 2016 - The GUI has been streamlined to reduce clutter and create
% a space for plugins created by future users.
%
%

%% Create GUI structure
scrn_size = get(0,'ScreenSize');
f = figure('Name','RHYTHM','Visible','off','Position',[scrn_size(3),scrn_size(4),1250,730],'NumberTitle','Off');
% set(f,'Visible','off')

% Load Data
p1 = uipanel('Title','Display Data','FontSize',11,'Position',[.01 .01 .98 .98]);
filelist = uicontrol('Parent',p1,'Style','listbox','String','Files','Position',[10 240 150 450],'Callback',{@filelist_callback});
selectdir = uicontrol('Parent',p1,'Style','pushbutton','FontSize',11,'String','Select Directory','Position',[10 205 150 30],'Callback',{@selectdir_callback});
loadfile = uicontrol('Parent',p1,'Style','pushbutton','FontSize',11,'String','Load','Position',[85 175 75 30],'Callback',{@loadfile_callback});
refreshdir = uicontrol('Parent',p1,'Style','pushbutton','FontSize',11,'String','Refresh Directory','Position',[10 145 150 30],'Callback',{@refreshdir_callback});

togbDataType = uicontrol('Parent',p1,'Style', 'togglebutton','FontSize',11,'String', 'Voltage', 'Position', [10 175 75 30], 'Callback', {@TogB_data});
set(togbDataType, 'value',1);   % Set to On (Voltage) state


% Movie Screen for Optical Data
movie_scrn = axes('Parent',p1,'Units','Pixels','YTick',[],'XTick',[],'Position',[170, 190, 500,500]);

% Movie Slider for Controling Current Frame
movie_slider = uicontrol('Parent',f, 'Style', 'slider','Position', [183, 180, 502, 20],'SliderStep',[.001 .01],'Callback',{@movieslider_callback});
addlistener(movie_slider,'ContinuousValueChange',@movieslider_callback);

% Mouse Listening Function
set(f,'WindowButtonDownFcn',{@button_down_function});
set(f,'WindowButtonUpFcn',{@button_up_function});
set(f,'WindowButtonMotionFcn',{@button_motion_function});

% Signal Display Screens for Optical Action Potentials
signal_scrn1 = axes('Parent',p1,'Units','Pixels','Color','w','XTick',[],'Position',[710,572,498,120]);
signal_scrn2 = axes('Parent',p1,'Units','Pixels','Color','w','XTick',[],'Position',[710,444,498,120]);
signal_scrn3 = axes('Parent',p1,'Units','Pixels','Color','w','XTick',[],'Position',[710,316,498,120]);
signal_scrn4 = axes('Parent',p1,'Units','Pixels','Color','w','XTick',[],'Position',[710,188,498,120]);
signal_scrn5 = axes('Parent',p1,'Units','Pixels','Color','w','Position',[710,60,498,120]);
xlabel('Time (sec)');
expwave_button = uicontrol('Parent',p1,'Style','pushbutton','FontSize',11,'String','Export OAPs','Position',[1115 1 90 30],'Callback',{@expwave_button_callback});
expwavecsv_button = uicontrol('Parent',p1,'Style','pushbutton','FontSize',11,'String','Export OAP CSVs','Position',[720 1 110 30],'Callback',{@expwavecsv_button_callback});
starttimesig_text = uicontrol('Parent',p1,'Style','text','FontSize',11,'String','Start Time','Position',[830 9 55 15]);
starttimesig_edit = uicontrol('Parent',p1,'Style','edit','FontSize',11,'Position',[890 5 55 23],'Callback',{@starttimesig_edit_callback});
endtimesig_text = uicontrol('Parent',p1,'Style','text','FontSize',11,'String','End Time','Position',[945 9 52 15]);
endtimesig_edit = uicontrol('Parent',p1,'Style','edit','FontSize',11,'Position',[1000 5 55 23],'Callback',{@endtimesig_edit_callback});
resettime_button = uicontrol('Parent',p1,'Style','pushbutton','FontSize',11,'String','Reset','Position',[1055 1 50 30],'Callback',{@resettime_button_callback});

% Sweep Bar Display for Optical Action Potentials
sweep_bar = axes ('Parent',p1,'Units','Pixels','Layer','top','Position',[710,55,500,735]);
set(sweep_bar,'NextPlot','replacechildren','Visible','off')

% Video Control Buttons and Optical Action Potential Display
play_button = uicontrol('Parent',p1,'Style','pushbutton','FontSize',11,'String','Play Movie','Position',[215 141 100 30],'Callback',{@play_button_callback});
stop_button = uicontrol('Parent',p1,'Style','pushbutton','FontSize',11,'String','Stop Movie','Position',[315 141 100 30],'Callback',{@stop_button_callback});
dispwave_button = uicontrol('Parent',p1,'Style','pushbutton','FontSize',11,'String','Display Wave','Position',[415 141 100 30],'Callback',{@dispwave_button_callback});
expmov_button = uicontrol('Parent',p1,'Style','pushbutton','FontSize',11,'String','Export Movie','Position',[515 141 100 30],'Callback',{@expmov_button_callback});

% Signal Conditioning Button Group and Buttons
cond_sig = uibuttongroup('Parent',p1,'Title','Condition Signals','FontSize',11,'Position',[0.01 0.015 .255 .18]);
removeBG_button = uicontrol('Parent',cond_sig,'Style','checkbox','FontSize',11,'String','Remove Bkgrd','Position',[5 92 150 25]);
bg_thresh_label = uicontrol('Parent',cond_sig,'Style','text','FontSize',11,'String','BG','Position',[32 67 77 25]);
perc_ex_label = uicontrol('Parent',cond_sig,'Style','text','FontSize',11,'String','EX','Position',[33 47 76 25]);
bg_thresh_edit = uicontrol('Parent',cond_sig,'Style','edit','FontSize',11,'String','0.3','Position',[112 75 35 18]);
perc_ex_edit = uicontrol('Parent',cond_sig,'Style','edit','FontSize',11,'String','0.5','Position',[112 55 35 18]);
bin_button  = uicontrol('Parent',cond_sig,'Style','checkbox','FontSize',11,'String','Box Blur','Position',[160 92 150 25]);
filt_button = uicontrol('Parent',cond_sig,'Style','checkbox','FontSize',11,'String','Filter','Position',[160 64 150 25]);
removeDrift_button = uicontrol('Parent',cond_sig,'Style','checkbox','FontSize',11,'String','Drift','Position',[160 36 150 25]);
norm_button  = uicontrol('Parent',cond_sig,'Style','checkbox','FontSize',11,'String','Normalize','Position',[5 36 125 15]);
apply_button = uicontrol('Parent',cond_sig,'Style','pushbutton','FontSize',11,'String','Apply','Position',[3 2 150 30],'Callback',{@cond_sig_selcbk});
%Pop-up menu options
bin_popup = uicontrol('Parent',cond_sig,'Style','popupmenu','FontSize',11,'String',{'3 x 3', '5 x 5', '7 x 7', '9 x 9', '15 x 15', '45 x 45'},'Position',[234 88 75 25]);
filt_popup = uicontrol('Parent',cond_sig,'Style','popupmenu','FontSize',11,'String',{'[0 50]','[0 75]', '[0 100]', '[0 150]'},'Position',[219 61 90 25]);
drift_popup = uicontrol('Parent',cond_sig,'Style','popupmenu','FontSize',11,'String',{'1st Order','2nd Order', '3rd Order', '4th Order'},'Position',[210 34 99 25]);
export_button = uicontrol('Parent',cond_sig,'Style','pushbutton','FontSize',11,'String','Export Data','Position',[160 2 145 30],'Callback',{@export_callback});
set(filt_popup,'Value',3)

% Optical Action Potential Analysis Button Group and Buttons
% Create Button Group
anal_data = uibuttongroup('Parent',p1,'Title','Analyze Data','FontSize',11,'Position',[0.275 0.015 .272 .180]);

anal_select = uicontrol('Parent',anal_data,'Style','popupmenu','FontSize',11,'String',{'-----','Activation','Conduction','APD','Phase','Dominant Frequency'},'Position',[5 85 165 25],'Callback',{@anal_select_callback});

% Invert Color Map Option
invert_cmap = uicontrol('Parent',anal_data,'Style','checkbox','FontSize',11,'String','Invert Colormaps','Position',[175 88 150 25],'Visible','on','Callback',{@invert_cmap_callback});

% Mapping buttons
starttimemap_text = uicontrol('Parent',anal_data,'Style','text','FontSize',11,'String','Start','Position',[12 57 57 25],'Visible','on');
starttimemap_edit = uicontrol('Parent',anal_data,'Style','edit','FontSize',11,'Position',[72 62 45 22],'Visible','on','Callback',{@maptime_edit_callback});
endtimemap_text = uicontrol('Parent',anal_data,'Style','text','FontSize',11,'String','End','Position',[12 30 54 25],'Visible','on');
endtimemap_edit = uicontrol('Parent',anal_data,'Style','edit','FontSize',11,'Position',[72 35 45 22],'Visible','on','Callback',{@maptime_edit_callback});
createmap_button = uicontrol('Parent',anal_data,'Style','pushbutton','FontSize',11,'String','Calculate Map','Position',[10 2 110 30],'Visible','on','Callback',{@createmap_button_callback});
% APD specific buttons
minapd_text = uicontrol('Parent',anal_data,'Style','text','FontSize',11,'String','Min APD','Visible','on','Position',[125 57 57 25]);
minapd_edit = uicontrol('Parent',anal_data,'Style','edit','FontSize',11,'String','0','Visible','on','Position',[180 62 45 22],'Callback',{@minapd_edit_callback});
maxapd_text = uicontrol('Parent',anal_data,'Style','text','FontSize',11,'String','Max APD','Visible','on','Position',[125 30 54 25]);
maxapd_edit = uicontrol('Parent',anal_data,'Style','edit','FontSize',11,'String','1000','Visible','on','Position',[180 35 45 22],'Callback',{@maxapd_edit_callback});
percentapd_text= uicontrol('Parent',anal_data,'Style','text','FontSize',11,'String','%APD','Visible','on','Position',[230 57 45 25]);
percentapd_edit= uicontrol('Parent',anal_data,'Style','edit','FontSize',11,'String','0.8','Visible','on','Position',[275 62 45 22],'callback',{@percentapd_edit_callback});
remove_motion_click = uicontrol('Parent',anal_data,'Style','checkbox','FontSize',11,'String','Remove','Visible','on','Position',[230 35 100 25]);
remove_motion_click_txt = uicontrol('Parent',anal_data,'Style','text','FontSize',11,'String','Motion','Visible','on','Position',[248 15 50 25]);
calc_apd_button = uicontrol('Parent',anal_data,'Style','pushbutton','FontSize',11,'String','Regional APD','Position',[125 2 103 30],'Callback',{@calc_apd_button_callback});

% Allow all GUI structures to be scaled when window is dragged
set([f,p1,filelist,selectdir,refreshdir,loadfile, togbDataType,movie_scrn,movie_slider, signal_scrn1,signal_scrn2,signal_scrn3,...
    signal_scrn4,signal_scrn5,sweep_bar,play_button,stop_button,dispwave_button,expmov_button,cond_sig,removeBG_button,...
    bg_thresh_label,perc_ex_label,bg_thresh_edit,perc_ex_edit,bin_button,filt_button,removeDrift_button,norm_button,...
    apply_button,bin_popup,filt_popup,drift_popup,export_button,anal_data,anal_select,invert_cmap,starttimemap_text,...
    starttimemap_edit,endtimemap_text,endtimemap_edit,createmap_button,minapd_text,minapd_edit,maxapd_text,maxapd_edit,...
    percentapd_text,percentapd_edit,remove_motion_click,remove_motion_click_txt,calc_apd_button,expwave_button,expwavecsv_button,...
    starttimesig_text,starttimesig_edit,endtimesig_text,endtimesig_edit,resettime_button],'Units','normalized')

% Disable buttons that will not be needed until data is loaded
set([removeBG_button,bg_thresh_edit,bg_thresh_label,perc_ex_edit,perc_ex_label,bin_button,filt_button,removeDrift_button,norm_button,...
    apply_button,bin_popup,filt_popup,drift_popup,anal_select,starttimemap_edit,starttimemap_text,endtimemap_edit,endtimemap_text,...
    createmap_button,minapd_edit,minapd_text,maxapd_edit,maxapd_text,percentapd_edit,percentapd_text,remove_motion_click,remove_motion_click_txt,...
    calc_apd_button,play_button,stop_button,dispwave_button,expmov_button,starttimesig_edit,endtimesig_edit,expwave_button,expwavecsv_button,loadfile,...
    refreshdir,invert_cmap,export_button,resettime_button],'Enable','off')

% Hide all analysis buttons
set([invert_cmap,starttimemap_text,starttimemap_edit,endtimemap_text,...
    endtimemap_edit,createmap_button,minapd_text,minapd_edit,maxapd_text,...
    maxapd_edit,percentapd_text,percentapd_edit,remove_motion_click,...
    calc_apd_button,remove_motion_click_txt],'Visible','off')

% % 
% Center GUI on screen
movegui(f,'center')
set(f,'Visible','on')

%% Create handles
handles.filename = [];
handles.cmosData = [];
handles.rawData = [];
handles.dataType = 'v'; % v for voltage, c for calcium
handles.time = [];
handles.wave_window = 1;
handles.normflag = 0;
handles.Fs = 1000; % this is the default value. it will be overwritten
handles.starttime = 0;
handles.fileLength = 1;
handles.endtime = 1;
handles.grabbed = -1;
handles.M = []; % this handle stores the locations of the markers
handles.slide=-1; % parameter for recognize clicking location
%%minimum values pixels require to be drawn
handles.minVisible = 6;
handles.normalizeMinVisible = .3;
handles.cmap = colormap('jet'); %saves the default colormap values
handles.apdC = [];  % variable for storing apd calculations

%% All Callback functions


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% USER FUNCTIONALITY
%% Listen for mouse clicks for the point-dragger
% When mouse button is clicked and held find associated marker
    function button_down_function(obj,~)
        set(obj,'CurrentAxes',movie_scrn)
        ps = get(gca,'CurrentPoint');
        i_temp = round(ps(1,1));
        j_temp = round(ps(2,2));
        pad = 3;
        % if one of the markers on the movie screen is clicked
        if i_temp<=size(handles.cmosData,1) || j_temp<size(handles.cmosData,2) || i_temp>1 || j_temp>1
            if size(handles.M,1) > 0
                for i=1:size(handles.M,1)
                    % if i_temp == handles.M(i,1) && handles.M(i,2) == j_temp
                    if ((i_temp > handles.M(i,1) - pad) && (i_temp < handles.M(i,1) + pad)) && ((j_temp > handles.M(i,2) - pad) && (j_temp < handles.M(i,2) + pad))
                        handles.grabbed = i;
                        break
                    end
                end
            end
        end
    end
%% When mouse button is released
    function button_up_function(~,~)
        handles.grabbed = -1;
    end

%% Update appropriate screens or slider when mouse is moved
    function button_motion_function(obj,~)
        % Update movie screen marker location
        if handles.grabbed > -1
            set(obj,'CurrentAxes',movie_scrn)
            ps = get(gca,'CurrentPoint');
            i_temp = round(ps(1,1));
            j_temp = round(ps(2,2));
            if i_temp<=size(handles.cmosData,2) && j_temp<=size(handles.cmosData,1) && i_temp>1 && j_temp>1
                handles.M(handles.grabbed,:) = [i_temp j_temp];
                i = i_temp;
                j = j_temp;
                switch handles.grabbed
                    case 1
                        plot(handles.time,squeeze(handles.cmosData(j,i,:)),'b','LineWidth',2,'Parent',signal_scrn1)                    
                        signal_scrn1.YLabel.String = int2str([i j]);
                        handles.M(1,:) = [i j];
                    case 2
                        plot(handles.time,squeeze(handles.cmosData(j,i,:)),'g','LineWidth',2,'Parent',signal_scrn2)                    
                        signal_scrn2.YLabel.String = int2str([i j]);
                        handles.M(2,:) = [i j];
                    case 3
                        plot(handles.time,squeeze(handles.cmosData(j,i,:)),'m','LineWidth',2,'Parent',signal_scrn3)                    
                        signal_scrn3.YLabel.String = int2str([i j]);
                        handles.M(3,:) = [i j];
                    case 4
                        plot(handles.time,squeeze(handles.cmosData(j,i,:)),'k','LineWidth',2,'Parent',signal_scrn4)                    
                        signal_scrn4.YLabel.String = int2str([i j]);
                        handles.M(4,:) = [i j];
                    case 5
                        plot(handles.time,squeeze(handles.cmosData(j,i,:)),'c','LineWidth',2,'Parent',signal_scrn5)                    
                        signal_scrn5.YLabel.String = int2str([i j]);
                        handles.M(5,:) = [i j];
                end
                cla
                currentframe = handles.frame;
                currentTime = currentframe*1/handles.Fs;
                drawFrame(currentframe);
                M = handles.M; colax='bgmkc'; [a,~]=size(M);
                hold on
                for x=1:a
                    plot(M(x,1),M(x,2),'cs','MarkerSize',8,'MarkerFaceColor',colax(x),'MarkerEdgeColor','w','Parent',movie_scrn);
                    set(movie_scrn,'YTick',[],'XTick',[]);% Hide tick markes
                end
                hold off
            end
        end
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOAD DATA
%% List that contains all files in directory
    function filelist_callback(source,~)
        str = get(source, 'String');
        val = get(source,'Value');
        file = char(str(val));
        handles.filename = file;
    end


%% Choose data type: voltage or calcium
    function TogB_data(hObject,event)
        % hObject    handle to togglebutton1 (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)

        button_state = get(hObject,'Value');
        if button_state == get(hObject,'Max') % Voltage chosen
            handles.dataType = 'v'
            set(togbDataType, 'String', 'Voltage');
        elseif button_state == get(hObject,'Min') % Calcium chosen
            handles.dataType = 'c'
            set(togbDataType, 'String', 'Calcium');
        end
    end

%% Load selected files in filelist
    function loadfile_callback(~,~)
        if isempty(handles.filename)
            msgbox('Warning: No data selected','Title','warn')
        else
            % Clear off all images from previous set of data
            cla(movie_scrn); cla(signal_scrn1); cla(signal_scrn2); cla(signal_scrn3)
            cla(signal_scrn4); cla(signal_scrn5);  cla(sweep_bar)
            % Initialize handles
%             handles.M = []; % this handle stores the locations of the markers
            handles.normflag = 0;% this handle indicate if normalize is clicked
            handles.wave_window = 1;% this handle indicate the window number of the next wave displayed
            handles.frame = 1;% this handles indicate the current frame being displayed by the movie screen
            handles.slide=-1;% this handle indicate if the movie slider is clicked
            % Check for *.mat file, if none convert
            filename = [handles.dir,'/',handles.filename];
            
            
            % Check for existence of already converted *.mat file
            if exist([filename(1:end-3),'mat'],'file')
                Data = load([filename(1:end-3),'mat']);
                handles.cmosData = -1.*double(Data.data(:,:,2:end)); %voltage
%                 handles.cmosData = double(Data.data(:,:,2:end)); %calcium
                handles.Fs = Data.Fs;
                handles.bg = mean(Data.data(:,:,1:4),3); % voltage or calcium? change -1.*
                andor=1;
                % Convert data and save out *.mat file
            elseif exist([filename(1:end-3),'sif'],'file')    
                [~, Data, fps, ~,~,~]=sifopen(filename);
                cmosData = -1.*Data;
                %cmosData = flipdim(cmosData,1);
                handles.cmosData = double(cmosData(:,:,2:end));
                handles.Fs = fps;
                handles.bg = mean(-1.*cmosData(:,:,1:4),3); 
                andor=1; % variable to detect if andor data is being used
            elseif exist([filename(1:end-3),'tif'],'file') || exist([filename(1:end-3),'tiff'],'file')
                [Data, fps, ~,~]=tifopen(filename);
                if(handles.dataType == 'v')
                    cmosData = -1.*double(Data); % For Voltage
                    %cmosData = flipdim(cmosData,1);
                    handles.cmosData = double(cmosData(:,:,2:end));
                    handles.Fs = fps;
                    handles.bg = mean(-1.*cmosData(:,:,1:4),3); % For Voltage
                else
                    cmosData = double(Data); % For Calcium
                    %cmosData = flipdim(cmosData,1);
                    handles.cmosData = double(cmosData(:,:,2:end));
                    handles.Fs = fps;
                    handles.bg = mean(cmosData(:,:,1:4),3); % For Calcium
                end
                andor=1; % variable to detect if andor data is being used
            else
                andor=0;
                CMOSconverter(handles.dir,handles.filename); 
                Data = load([filename(1:end-3),'mat']);
            end
            
            % Check for dual camera data
            if isfield(Data,'cmosData2')
                %pop-up window for camera choice
                questdual=questdlg('Please choose a camera', 'Camera Choice', 'Camera1', 'Camera2', 'Camera1');
                % Load Camera1 data
                if strcmp(questdual,'Camera1')
                    handles.cmosData = double(Data.cmosData(:,:,2:end));
                    handles.bg = double(Data.bgimage);
                end
                % Load Camera2 data
                if strcmp(questdual,'Camera2')
                    handles.cmosData = double(Data.cmosData2(:,:,2:end));
                    handles.bg = double(Data.bgimage2);
                end
                % Save out the frequency, cameras alternate, divide by 2
                handles.Fs = double(Data.frequency);
                % Save out pacing spike. Note: Data.channel1 is not
                % necessarily the ecg channel. Correspondes to analog1
                % input to SciMedia box
                handles.ecg = Data.channel{1}(1:size(Data.channel{1},2)/2)*-1;
            elseif andor~=1
                % Load from single camera
                handles.cmosData = double(Data.cmosData(:,:,2:end));
                handles.bg = double(Data.bgimage);
                % Save out pacing spike
                handles.ecg = Data.channel{1}(2:end)*-1;
                % Save out frequency
                handles.Fs = double(Data.frequency);
            end
            
            % Save a variable to preserve  the raw cmos data
            handles.cmosRawData = handles.cmosData;
            % Convert background to grayscale 
            handles.bgRGB = real2rgb(handles.bg, 'gray');
            %%%%%%%%% WINDOWED DATA %%%%%%%%%%
            handles.matrixMax = .9 * max(handles.cmosData(:));
            % Initialize movie screen to the first frame
            set(f,'CurrentAxes',movie_scrn)
            
            G = real2rgb(handles.bg, 'gray');
            Mframe = handles.cmosData(:,:,handles.frame);
            J = real2rgb(Mframe, 'jet');
            A = real2rgb(Mframe >= handles.minVisible, 'gray');
            I = J .* A + G .* (1-A);
            handles.movie_img = image(I,'Parent',movie_scrn);
            set(movie_scrn,'NextPlot','replacechildren','YLim',[0.5 size(I,1)+0.5],...
                'YTick',[],'XLim',[0.5 size(I,2)+0.5],'XTick',[])
            % Scale signal screens and sweep bar to appropriate time scale
            timeStep = 1/handles.Fs;
            handles.time = 0:timeStep:size(handles.cmosData,3)*timeStep-timeStep;
            set(signal_scrn1,'XLim',[min(handles.time) max(handles.time)])
            set(signal_scrn1,'NextPlot','replacechildren')
            set(signal_scrn2,'XLim',[min(handles.time) max(handles.time)])
            set(signal_scrn2,'NextPlot','replacechildren')
            set(signal_scrn3,'XLim',[min(handles.time) max(handles.time)])
            set(signal_scrn3,'NextPlot','replacechildren')
            set(signal_scrn4,'XLim',[min(handles.time) max(handles.time)])
            set(signal_scrn4,'NextPlot','replacechildren')
            set(signal_scrn5,'XLim',[min(handles.time) max(handles.time)])
            set(signal_scrn5,'NextPlot','replacechildren')
            set(sweep_bar,'XLim',[min(handles.time) max(handles.time)])
            set(sweep_bar,'NextPlot','replacechildren')
            % Fill times into activation map editable textboxes
            handles.starttime = 0;
            handles.endtime = max(handles.time);
            set(starttimesig_edit,'String',num2str(handles.starttime))
            set(endtimesig_edit,'String',num2str(handles.endtime))
            set(starttimemap_edit,'String',num2str(handles.starttime))
            set(endtimemap_edit,'String',num2str(handles.endtime))
            % Initialize movie slider to the first frame
            set(movie_slider,'Value',0)
            drawFrame(1);
            % Enable signal processing and analysis tools
            set([removeBG_button,bg_thresh_edit,bg_thresh_label,perc_ex_edit,...
                perc_ex_label,bin_button,filt_button,removeDrift_button,norm_button,...
                apply_button,bin_popup,filt_popup,drift_popup,play_button,anal_select,...
                stop_button,dispwave_button,expmov_button,starttimesig_edit,...
                endtimesig_edit,resettime_button,expwave_button,expwavecsv_button,export_button],'Enable','on')
        end
    end

%% Select directory for optical files
    function selectdir_callback(~,~)
        dir_name = uigetdir; %commented out on 2017-11-29
%         dir_name = '/run/media/lab/Posnack-Heart/Mapping/Dual/';
        if dir_name ~= 0
            handles.dir = dir_name;
            search_name = [dir_name,'/*.rsh'];
            search_nameNew = [dir_name,'/*.gsh'];
            search_nameAndor = [dir_name,'/*.sif']; %adding Andor SIF support
            search_nameTif = [dir_name,'/*.tif']; %adding TIF support
            search_nameMAT = [dir_name,'/*.mat']; %adding MATLAB raw data, already converted
            files = struct2cell(dir(search_name));
            filesNew = struct2cell(dir(search_nameNew));
            filesAndor = struct2cell(dir(search_nameAndor));
            filesTif = struct2cell(dir(search_nameTif));
            filesMAT = struct2cell(dir(search_nameMAT));
            handles.file_list = [files(1,:)'; filesNew(1,:)';filesAndor(1,:)';filesTif(1,:)';filesMAT(1,:)'];
            set(filelist,'String',handles.file_list)
            handles.filename = char(handles.file_list(1));
            % enable the refresh directory and load file buttons
            set([loadfile,refreshdir],'Enable','on')
            % reset analysis window
            set(anal_select,'Value',1)
            set([invert_cmap,starttimemap_text,starttimemap_edit,endtimemap_text,...
                endtimemap_edit,createmap_button,minapd_text,minapd_edit,maxapd_text,...
                maxapd_edit,percentapd_text,percentapd_edit,remove_motion_click,...
                remove_motion_click_txt],'Visible','off','Enable','on')
            % turn off all other buttons
            set([removeBG_button,bg_thresh_edit,bg_thresh_label,perc_ex_edit,...
                perc_ex_label,bin_button,filt_button,removeDrift_button,norm_button,...
                apply_button,bin_popup,filt_popup,drift_popup,anal_select,...
                starttimemap_edit,starttimemap_text,endtimemap_edit,endtimemap_text,...
                createmap_button,minapd_edit,minapd_text,maxapd_edit,maxapd_text,...
                percentapd_edit,percentapd_text,remove_motion_click,remove_motion_click_txt,...
                play_button,stop_button,dispwave_button,expmov_button,starttimesig_edit,...
                endtimesig_edit,resettime_button,expwave_button,expwavecsv_button,invert_cmap,export_button],'Enable','off')
        end
    end

%% Refresh file list (in case more files are open after directory is selected)
    function refreshdir_callback(~,~)
        dir_name = handles.dir;
        search_name = [dir_name,'/*.rsh'];
        search_nameNew = [dir_name,'/*.gsh'];
        search_nameAndor = [dir_name,'/*.sif']; %adding Andor SIF support
        files = struct2cell(dir(search_name));
        filesNew = struct2cell(dir(search_nameNew));
        filesAndor = struct2cell(dir(search_nameAndor));
        handles.file_list = [files(1,:)'; filesNew(1,:)';filesAndor(1,:)'];
        set(filelist,'String',handles.file_list)
        handles.filename = char(handles.file_list(1));
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MOVIE SCREEN
%% Movie Slider Functionality
    function movieslider_callback(source,~)
        val = get(source,'Value');
        i = round(val*size(handles.cmosData,3))+1;
        handles.frame = i;
        if handles.frame == size(handles.cmosData,3) + 1
            i = size(handles.cmosData,3);
            handles.frame = size(handles.cmosData,3);
        end   
        % Update movie screen
        set(movie_scrn,'NextPlot','replacechildren','YTick',[],'XTick',[]);
        set(f,'CurrentAxes',movie_scrn)
        drawFrame(i);
        % Update markers on movie screen
        M = handles.M; colax='bgmkc'; [a,~]=size(M);
        hold on
        for x=1:a
            plot(M(x,1),M(x,2),'cs','MarkerSize',8,'MarkerFaceColor',colax(x),'MarkerEdgeColor','w','Parent',movie_scrn);
            set(movie_scrn,'YTick',[],'XTick',[]);% Hide tick markes
        end
        hold off
        % Update sweep bar
        set(f,'CurrentAxes',sweep_bar)
        a = [handles.time(i) handles.time(i)];b = [0 1]; cla
        plot(a,b,'r','Parent',sweep_bar)
        axis([handles.starttime handles.endtime 0 1])
        hold off; axis off
    end

%% Draw
    function drawFrame(frame)
        G = handles.bgRGB;
        Mframe = handles.cmosData(:,:,frame);
        if handles.normflag == 0
            Mmax = handles.matrixMax;
            Mmin = handles.minVisible;
            numcol = size(jet,1);
            J = ind2rgb(round((Mframe - Mmin) ./ (Mmax - Mmin) * (numcol - 1)), 'jet');
            A = real2rgb(Mframe >= handles.minVisible, 'gray');
        else
            J = real2rgb(Mframe, 'jet');
            A = real2rgb(Mframe >= handles.normalizeMinVisible, 'gray');
        end
        I = J .* A + G .* (1 - A);
        image(I,'Parent',movie_scrn);
        % Show current frame's timestamp at bottom right
        currentTime = frame * 1/handles.Fs;
        set(stop_button,'string',num2str(currentTime))
        axis('image')
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DISPLAY CONTROL
%% Play button functionality
    function play_button_callback(~,~)
        if isempty(handles.cmosData)
            msgbox('Warning: No data selected','Title','warn')
        else
            handles.playback = 1; % if the PLAY button is clicked
            startframe = handles.frame;
            % Update movie screen with new frames
            for i = startframe:5:size(handles.cmosData,3)
                if handles.playback == 1 % recheck if the PLAY button is clicked
                    set(movie_scrn,'NextPlot','replacechildren','YTick',[],'XTick',[]);
                    set(f,'CurrentAxes',movie_scrn)
                    drawFrame(i);
                    handles.frame = i;
                    % Update markers with each frame
                    M = handles.M;[a,~]=size(M); colax='bgmkc';
                    hold on
                    for x=1:a
                        plot(M(x,1),M(x,2),'cs','MarkerSize',8,'MarkerFaceColor',colax(x),'MarkerEdgeColor','w','Parent',movie_scrn)
                    end
                    pause(0.01)
                    % Update movie slider
                    set(movie_slider,'Value',(i-1)/size(handles.cmosData,3))
                    % Update sweep bar
                    set(f,'CurrentAxes',sweep_bar)
                    a = [handles.time(i) handles.time(i)];b = [0 1]; cla
                    plot(a,b,'r','Parent',sweep_bar)
                    axis([handles.starttime handles.endtime 0 1])
                    hold off; axis off
                    pause(0.01); pause(0.01)
                else
                    break
                end
            end
            handles.frame = min(handles.frame, size(handles.cmosData, 3));
            set(movie_scrn,'NextPlot','replacechildren','YTick',[],'XTick',[]);
            set(f,'CurrentAxes',movie_scrn)
            drawFrame(i);
            handles.frame = i;
            % Update makers with each frame
            M = handles.M;[a,~]=size(M); colax='bgmkc';
            hold on
            for x=1:a
                plot(M(x,1),M(x,2),'cs','MarkerSize',8,'MarkerFaceColor',colax(x),'MarkerEdgeColor','w','Parent',movie_scrn)
            end
            pause(0.01)
            % Update movie slider
            set(movie_slider,'Value',(i-1)/size(handles.cmosData,3))
            % Update sweep bar
            set(f,'CurrentAxes',sweep_bar)
            a = [handles.time(i) handles.time(i)];b = [0 1]; cla
            plot(a,b,'r','Parent',sweep_bar)
            axis([handles.starttime handles.endtime 0 1])
            hold off; axis off
        end
    end

%% Stop button functionality
    function stop_button_callback(~,~)
        handles.playback = 0;
    end

%% Display Wave Button Functionality
    function dispwave_button_callback(~,~)
        set(f,'CurrentAxes',movie_scrn)
        [c_click,r_click] = myginput(1,'circle');
        c = round(c_click); r = round(r_click); % c=X/width/Columns, r=Y/height/Rows
        
        % ensure pixel selected is within movie_scrn
        if c_click>size(handles.cmosData,2) || r_click>size(handles.cmosData,1) || c_click<=1 || r_click<=1
            % tell user to pick new pixel
            msgbox('Warning: Pixel Selection out of Boundary','Title','help')
        else
            check = 1;
        end
        
        if check == 1
            % Find the correct wave window
            if handles.wave_window == 6
                handles.wave_window = 1;
            end
            wave_window = handles.wave_window;
            % Show pixel location on Y axis of each wave window
            switch wave_window
                case 1
                    plot(handles.time,squeeze(handles.cmosData(r,c,:)),'b','LineWidth',2,'Parent',signal_scrn1)
                    handles.M(1,:) = [c r];
                    signal_scrn1.YLabel.FontSize = 8;
                    signal_scrn1.YLabel.String = int2str([c r]);
                case 2
                    plot(handles.time,squeeze(handles.cmosData(r,c,:)),'g','LineWidth',2,'Parent',signal_scrn2)
                    handles.M(2,:) = [c r];
                    signal_scrn2.YLabel.FontSize = 8;
                    signal_scrn2.YLabel.String = int2str([c r]);
                case 3
                    plot(handles.time,squeeze(handles.cmosData(r,c,:)),'m','LineWidth',2,'Parent',signal_scrn3)
                    handles.M(3,:) = [c r];
                    signal_scrn3.YLabel.FontSize = 8;
                    signal_scrn3.YLabel.String = int2str([c r]);
                case 4
                    plot(handles.time,squeeze(handles.cmosData(r,c,:)),'k','LineWidth',2,'Parent',signal_scrn4)
                    handles.M(4,:) = [c r];
                    signal_scrn4.YLabel.FontSize = 8;
                    signal_scrn4.YLabel.String = int2str([c r]);
                case 5
                    plot(handles.time,squeeze(handles.cmosData(r,c,:)),'c','LineWidth',2,'Parent',signal_scrn5)
                    handles.M(5,:) = [c r];
                    signal_scrn5.YLabel.FontSize = 8;
                    signal_scrn5.YLabel.String = int2str([c r]);
            end
        end
        handles.wave_window = wave_window + 1; % Dial up the wave window count
        % Update movie screen with new markers
        cla
        currentframe = handles.frame;
        drawFrame(currentframe);
        M = handles.M; colax='bgmkc'; [a,~]=size(M);
        hold on
        for x=1:a
            plot(M(x,1),M(x,2),'cs','MarkerSize',8,'MarkerFaceColor',colax(x),'MarkerEdgeColor','w','Parent',movie_scrn);
            set(movie_scrn,'YTick',[],'XTick',[]);% Hide tick markes
        end
        hold off
    end

%% Export movie to .avi file
%Construct a VideoWriter object and view its properties. Set the frame rate to 60 frames per second:
    function expmov_button_callback(~,~)        
        % Save the movie to the same directory as the cmos data
        % Request the directory for saving the file
        dir = uigetdir;
        % If the cancel button is selected cancel the function
        if dir == 0
            return
        end
        % Request the desired name for the movie file
        filename = inputdlg('Enter Filename:');
        filename = char(filename);
        % Check to make sure a value was entered
        if isempty(filename)
            error = 'A filename must be entered! Function cancelled.';
            msgbox(error,'Incorrect Input','Error');
            return
        end
        filename = char(filename);
        % Create path to file
        movname = [handles.dir,'/',filename,'.avi'];
        % Create the figure to be filmed        
        fig=figure('Name',filename,'NextPlot','replacechildren','NumberTitle','off',...
            'Visible','off','OuterPosition',[170, 140, 556,715]);
        % Start writing the video
        vidObj = VideoWriter(movname,'Motion JPEG AVI');
        open(vidObj);
        movegui(fig,'center')
        set(fig,'Visible','on')
        axis tight
        set(gca,'nextplot','replacechildren');
        % Designate the step of based on the frequency
        
        % Creat pop up screen; the start time and end time are determined
        % by the windowing of the signals on the Rhythm GUI interface
        
        % Grab start and stop time times and convert to index values by
        % multiplying by frequency, add one to shift from zero
        start = str2double(get(starttimesig_edit,'String'))*handles.Fs+1;   
        fin = str2double(get(endtimesig_edit,'String'))*handles.Fs+1;
        % Designate the resolution of the video: ex. 5 = every fifth frame
        step = 5;
        for i = start:step:fin
            % Plot sweep bar on bottom subplot
            subplot('Position',[0.05, 0.1, 0.9,0.15])
            a = [handles.time(i) handles.time(i)];
            %b = [min(handles.ecg) max(handles.ecg)];
            squeeze1=squeeze(handles.cmosData(64,64,:));
            b=[min(squeeze1) max(squeeze1)];
            cla
            plot(a,b,'r','LineWidth',1.5);hold on
            % Plot ecg data on bottom subplot
            subplot('Position',[0.05, 0.1, 0.9,0.15])
            % Create a variable for the endtime index
            endtime = round(handles.endtime*handles.Fs);
            % Plot the desired
            plot(handles.time(start:endtime),squeeze1(1:end-1));
            % 
%            axis([handles.time(start) round(handles.time(fin)) floor(min(squeeze1)) floor(max(squeeze1))])
            % Set the xick mark to start from zero
            xlabel('Time (sec)');hold on
            % Image movie frames on the top subplot
            subplot('Position',[0.05, 0.28, 0.9,0.68])
            % Update image
            G = handles.bgRGB;
            Mframe = handles.cmosData(:,:,i);
            if handles.normflag == 0
                Mmax = handles.matrixMax;
                Mmin = handles.minVisible;
                numcol = size(jet,1);
                J = ind2rgb(round((Mframe - Mmin) ./ (Mmax - Mmin) * (numcol - 1)), jet);
                A = real2rgb(Mframe >= handles.minVisible, 'gray');
            else
                J = real2rgb(Mframe, 'jet');
                A = real2rgb(Mframe >= handles.normalizeMinVisible, 'gray');
            end
            
            I = J .* A + G .* (1 - A);
            image(I);
            axis off; hold off
            F = getframe(fig);
            writeVideo(vidObj,F);% Write each frame to the file.
        end
        close(fig);
        close(vidObj); % Close the file.
    end
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% SIGNAL SCREENS
% %% Start Time Editable Textbox for Signal Screens
    function starttimesig_edit_callback(source,~)
        %get the val01 (lower limit) and val02 (upper limit) plot values
        val01 = str2double(get(source,'String'));
        val02 = str2double(get(endtimesig_edit,'String'));
        if val01 >= 0 && val01 <= (size(handles.cmosData,3)-1)*handles.Fs
            set(signal_scrn1,'XLim',[val01 val02]);
            set(signal_scrn2,'XLim',[val01 val02]);
            set(signal_scrn3,'XLim',[val01 val02]);
            set(signal_scrn4,'XLim',[val01 val02]);
            set(signal_scrn5,'XLim',[val01 val02]);
            set(sweep_bar,'XLim',[val01 val02]);
        else
            error = 'The START TIME must be greater than %d and less than %.3f.';
            msgbox(sprintf(error,0,max(handles.time)),'Incorrect Input','Warn');
            set(source,'String',0)
        end
        % Update the start time value
        handles.starttime = val01;
    end
% 
%% End Time Editable Textbox for Signal Screens
    function endtimesig_edit_callback(source,~)
        val01 = str2double(get(starttimesig_edit,'String'));
        val02 = str2double(get(source,'String'));
        if val02 >= 0 && val02 <= (size(handles.cmosData,3)-1)*handles.Fs
            set(signal_scrn1,'XLim',[val01 val02]);
            set(signal_scrn2,'XLim',[val01 val02]);
            set(signal_scrn3,'XLim',[val01 val02]);
            set(signal_scrn4,'XLim',[val01 val02]);
            set(signal_scrn5,'XLim',[val01 val02]);
            set(sweep_bar,'XLim',[val01 val02]);
        else
            error = 'The END TIME must be greater than %d and less than %.3f.';
            msgbox(sprintf(error,0,max(handles.time)),'Incorrect Input','Warn');
            set(source,'String',max(handles.time))
        end
        % Update the end time value
        handles.endtime = val02;
    end

        
%% Reset time range for Signal Screens
    function resettime_button_callback(~,~)
       timeStep = 1/handles.Fs;
       handles.time = 0:timeStep:size(handles.cmosData,3)*timeStep-timeStep;
       set(signal_scrn1,'XLim',[min(handles.time) max(handles.time)])
       set(signal_scrn1,'NextPlot','replacechildren')
       set(signal_scrn2,'XLim',[min(handles.time) max(handles.time)])
       set(signal_scrn2,'NextPlot','replacechildren')
       set(signal_scrn3,'XLim',[min(handles.time) max(handles.time)])
       set(signal_scrn3,'NextPlot','replacechildren')
       set(signal_scrn4,'XLim',[min(handles.time) max(handles.time)])
       set(signal_scrn4,'NextPlot','replacechildren')
       set(signal_scrn5,'XLim',[min(handles.time) max(handles.time)])
       set(signal_scrn5,'NextPlot','replacechildren')
       set(sweep_bar,'XLim',[min(handles.time) max(handles.time)])
       set(sweep_bar,'NextPlot','replacechildren')
       % Fill times into activation map editable textboxes
       handles.starttime = 0;
       handles.endtime = max(handles.time);
       set(starttimesig_edit,'String',num2str(handles.starttime))
       set(endtimesig_edit,'String',num2str(handles.endtime))
       set(starttimemap_edit,'String',num2str(handles.starttime))
       set(endtimemap_edit,'String',num2str(handles.endtime))
    end

%% Export signal waves to new screen
    function expwave_button_callback(~,~)
        M = handles.M; colax='bgmkc'; [a,~]=size(M);
        if isempty(M)
            msgbox('No wave to export. Please use "Display Wave" button to select pixels on movie screen.','Icon','help')
        else
            w=figure('Name','Signal Waves','NextPlot','add','NumberTitle','off',...
                'Visible','off','OuterPosition',[100, 50, 555,120*a+80]);
            for x = 1:a
                subplot('Position',[0.06 (120*(a-x)+70)/(120*a+80) 0.9 110/(120*a+80)])
                plot(handles.time,squeeze(handles.cmosData(M(x,2),M(x,1),:)),'color',colax(x),'LineWidth',2)
                xlim([handles.starttime handles.endtime]);
                hold on
                if x == a
                else
                    set(gca,'XTick',[])
                end
            end
            xlabel('Time (sec)')
            xtick()
            hold off
            movegui(w,'center')
            set(w,'Visible','on')
        end
    end

%% Export signal waves to CSV
    function expwavecsv_button_callback(~,~)
        % Modeled after aMap function
        % aMap(handles.cmosData,handles.a_start,handles.a_end,handles.Fs,handles.bg,handles.cmap,handles.filename,handles.dir);
        M = handles.M; [a,~]=size(M);
        
        if isempty(M)
            msgbox('No wave to export. Please use "Display Wave" button to select pixels on movie screen.','Icon','help')
        else
            % User prompt for input to create csv
            prompt1 = {'Save current signal waves as CSV?'};
            dlg_title1 = 'Save signal CSV';
            num_lines1 = [1 60];
            % Uses directory chosen for image sources
            direc=handles.dir;
            file = strtok(handles.filename,'.');    % Get filename without extension 
            handleXY = strsplit(int2str(handles.M(1,:)), ' ');
            file = strcat(file,'x',handleXY(1),'y',handleXY(2));    % Add marker coordinate to filename
            def1 = strcat(direc,'/Signals/',file,'.csv');
            answer = inputdlg(prompt1,dlg_title1,num_lines1,def1);
            % process user inputs
            if isempty(answer)      % cancel save if user clicks "cancel"
                return
            end
            filename = answer{1};
            filenameTemp = strsplit(filename,'.');
            % Get time series (in sec)
            t = flip(rot90(handles.starttime:1/handles.Fs:handles.endtime))
            % Get frames of interest
            startp = max([round(handles.starttime*handles.Fs) 1]);   % 1st frame minimum
            endp = round(handles.endtime*handles.Fs);
            % Add time and signal arrays into a final 2-D array
            signalData = squeeze(handles.cmosData(M(1,2),M(1,1),startp:endp-1));
            time = t(1:length(signalData));
            csvData = [time signalData];
            
            % create the Signals folder if it doesn't exist already.
            newSubFolder = strcat(direc,'/Signals/');
            if ~exist(newSubFolder, 'dir')
              mkdir(newSubFolder);
            end
            csvwrite(filename,csvData);
%             for x = 1:a
%                 % write each plot's data over the time series
%                 % TODO correct so every signal is writen to a column
%             end
            
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CONDITION SIGNALS
%% Condition Signals Selection Change Callback
    function cond_sig_selcbk(~,~)
        % Read check box
        removeBG_state =get(removeBG_button,'Value');
        bin_state = get(bin_button,'Value');
        filt_state = get(filt_button,'Value');
        drift_state = get(removeDrift_button,'Value');
        norm_state = get(norm_button,'Value');
        % Grab pop up box values
        bin_pop_state = get(bin_popup,'Value');
        % Create variable for tracking conditioning progress
        trackProg = [removeBG_state filt_state bin_state drift_state norm_state];
        trackProg = sum(trackProg);
        counter = 0;
        g1 = waitbar(counter,'Conditioning Signal');
        % Return to raw unfiltered cmos data
        cmosData = handles.cmosRawData;
        handles.normflag = 0; % Initialize normflag
        % Condition Signals
        % Remove Background
        if removeBG_state == 1
            % Update counter % progress bar
            counter = counter + 1;
            waitbar(counter/trackProg,g1,'Removing Background');
            bg_thresh = str2double(get(bg_thresh_edit,'String'));
            perc_ex = str2double(get(perc_ex_edit,'String'));
            cmosData = remove_BKGRD(cmosData,handles.bg,bg_thresh,perc_ex);
        end
        % Bin Data
        if bin_state == 1
            % Update counter % progress bar
            counter = counter + 1;
            waitbar(counter/trackProg,g1,'Binning Data');
            if bin_pop_state == 6
                bin_size = 45;
            elseif bin_pop_state == 5
                bin_size = 15;
            elseif bin_pop_state == 4
                bin_size = 9;
            elseif bin_pop_state == 3
                bin_size = 7;
            elseif bin_pop_state == 2
                bin_size = 5;
            else
                bin_size = 3;
            end
            cmosData = binning(cmosData,bin_size);
        end
        % Filter Data
        if filt_state == 1
            % Update counter % progress bar
            counter = counter + 1;
            waitbar(counter/trackProg,g1,'Filtering Data');
            filt_pop_state = get(filt_popup,'Value');
            if filt_pop_state == 4
                or = 100;
                lb = 0.5;
                hb = 150;
            elseif filt_pop_state == 3
                or = 100;
                lb = 0.5;
                hb = 100;
            elseif filt_pop_state == 2
                or = 100;
                lb = 0.5;
                hb = 75;
            else
                or = 100;
                lb = 0.5;
                hb = 50;
            end
            cmosData = filter_data(cmosData,handles.Fs, or, lb, hb);
        end
        % Remove Drift
        if drift_state == 1
            % Update counter % progress bar
            counter = counter + 1;
            waitbar(counter/trackProg,g1,'Removing Drift');
            % Gather drift values and adjust for drift
            ord_val = get(drift_popup,'Value');
            ord_str = get(drift_popup,'String');
            cmosData = remove_Drift(cmosData,ord_str(ord_val));
        end
        % Normalize Data
        if norm_state == 1
            % Update counter % progress bar
            counter = counter + 1;
            waitbar(counter/trackProg,g1,'Normalizing Data');
            % Normalize data
            cmosData = normalize_data(cmosData,handles.Fs);
            handles.normflag = 1;
        end
        % Delete the progress bar 
        delete(g1)
        % Save conditioned signal
        handles.cmosData = cmosData;
        % Update movie screen with the conditioned data
        set(f,'CurrentAxes',movie_scrn)
        cla
        handles.matrixMax = .9 * max(handles.cmosData(:));
        currentframe = handles.frame;
        if handles.normflag == 0
            drawFrame(currentframe);
            hold on
        else
            drawFrame(currentframe);
            caxis([0 1])
            hold on
        end
        set(movie_scrn,'YTick',[],'XTick',[]);% Hide tick markes
        % Update markers on movie screen
        M = handles.M;colax='bgmkc';[a,~]=size(M);
        hold on
        for x=1:a
            plot(M(x,1),M(x,2),'cs','MarkerSize',8,'MarkerFaceColor',colax(x),'MarkerEdgeColor','w','Parent',movie_scrn);
            set(movie_scrn,'YTick',[],'XTick',[]);% Hide tick markes
        end
        hold off
        % Update signal waves (yes this is ugly.  if you find a better way, please change)
        if a>=1
            plot(handles.time,squeeze(handles.cmosData(M(1,2),M(1,1),:)),'b','LineWidth',2,'Parent',signal_scrn1)
            if a>=2
                plot(handles.time,squeeze(handles.cmosData(M(2,2),M(2,1),:)),'g','LineWidth',2,'Parent',signal_scrn2)
                if a>=3
                    plot(handles.time,squeeze(handles.cmosData(M(3,2),M(3,1),:)),'m','LineWidth',2,'Parent',signal_scrn3)
                    if a>=4
                        plot(handles.time,squeeze(handles.cmosData(M(4,2),M(4,1),:)),'k','LineWidth',2,'Parent',signal_scrn4)
                        if a>=5
                            plot(handles.time,squeeze(handles.cmosData(M(5,2),M(5,1),:)),'c','LineWidth',2,'Parent',signal_scrn5)
                        end
                    end
                end
            end
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Data Analysis Selection
    function anal_select_callback(~,~)
        % Get the type of analysis
        anal_state = get(anal_select,'Value');
        % Adjustment of buttons based on analysis
        if anal_state == 1
            % Turn all buttons off and hide
            set([invert_cmap,starttimemap_text,starttimemap_edit,endtimemap_text,...
                endtimemap_edit,minapd_text,minapd_edit,maxapd_text,...
                maxapd_edit,percentapd_text,percentapd_edit,remove_motion_click,...
                remove_motion_click_txt,calc_apd_button],'Visible','off',...
                'Enable','off')
            % Turn createmap button off
            set(createmap_button,'Enable','off')            
        elseif anal_state == 2
            % Turn needed buttons on
            set([invert_cmap,starttimemap_text,starttimemap_edit,endtimemap_text,...
                endtimemap_edit,createmap_button],'Visible','on','Enable','on')
            % Turn unneeded buttons off
            set([minapd_text,minapd_edit,maxapd_text,maxapd_edit,percentapd_text,...
                percentapd_edit,remove_motion_click,remove_motion_click_txt,...
                calc_apd_button],'Visible','off','Enable','off')
        elseif anal_state == 3
            % Turn needed buttons on
            set([invert_cmap,starttimemap_text,starttimemap_edit,endtimemap_text,...
                endtimemap_edit,createmap_button],'Visible','on','Enable','on')
            % Turn unneeded buttons off
            set([minapd_text,minapd_edit,maxapd_text,maxapd_edit,percentapd_text,...
                percentapd_edit,remove_motion_click,remove_motion_click_txt,...
                calc_apd_button],'Visible','off','Enable','off')
        elseif anal_state == 4
            % Turn needed buttons on
            set([invert_cmap,starttimemap_text,starttimemap_edit,endtimemap_text,...
                endtimemap_edit,createmap_button,minapd_text,minapd_edit,maxapd_text,...
                maxapd_edit,percentapd_text,percentapd_edit,remove_motion_click,...
                calc_apd_button,remove_motion_click_txt],'Visible','on','Enable','on')
        elseif anal_state == 5
            % Turn on create map button
            set(createmap_button,'Visible','on','Enable','on')
            % Turn all buttons off except the create map button
            set([invert_cmap,starttimemap_text,starttimemap_edit,endtimemap_text,...
                endtimemap_edit,minapd_text,minapd_edit,maxapd_text,maxapd_edit,...
                percentapd_text,percentapd_edit,remove_motion_click,calc_apd_button,...
                remove_motion_click_txt],'Visible','off','Enable','off')
        elseif anal_state == 6
            % Turn on create map button
            set(createmap_button,'Visible','on','Enable','on')
            % Turn all buttons off except the create map button
            set([invert_cmap,starttimemap_text,starttimemap_edit,endtimemap_text,...
                endtimemap_edit,minapd_text,minapd_edit,maxapd_text,maxapd_edit,...
                percentapd_text,percentapd_edit,remove_motion_click,calc_apd_button,...
                remove_motion_click_txt],'Visible','off','Enable','off')
        end 
    end

%% Regional APD Calculation
    function calc_apd_button_callback(~,~)
        % Read APD Parameters
        handles.percentAPD = str2double(get(percentapd_edit,'String'));
        handles.maxapd = str2double(get(maxapd_edit,'String'));
        handles.minapd = str2double(get(minapd_edit,'String'));
        % Read remove motion check box
        remove_motion_state =get(remove_motion_click,'Value');
        axes(movie_scrn)
        coordinate=getrect(movie_scrn);
        gg=msgbox('Creating Regional APD...');
        apdCalc(handles.cmosData,handles.a_start,handles.a_end,handles.Fs,...
            handles.percentAPD,handles.maxapd,handles.minapd,remove_motion_state,...
            coordinate,handles.bg,handles.cmap);
        close(gg)
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INVERT COLORMAP: inverts the colormaps for all isochrone maps
    function invert_cmap_callback(~,~)
        % Function Description: The checkbox function like toggle button. 
        % There are only 2 options and since the box starts unchecked, 
        % checking it will invert the map, uncheckecking it will invert it 
        % back to its original state. As such no additional code is needed.
        
        % grab the current value of the colormap
        cmap = handles.cmap;
        % invert the existing colormap values
        handles.cmap = flipud(cmap);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ACTIVATION MAP
%% Callback for Start and End Time for Analysis
     function maptime_edit_callback(~,~)
         % get the bounds of the viewing window
         vw_start = str2double(get(starttimesig_edit,'String'));
         vw_end = str2double(get(endtimesig_edit,'String'));
         % get the bounds of the activation window
         a_start = str2double(get(starttimemap_edit,'String'));
         a_end = str2double(get(endtimemap_edit,'String'));
         if a_start >= 0 && a_start <= max(handles.time)
             if a_end >= 0 && a_end <= max(handles.time)
                 set(f,'CurrentAxes',sweep_bar)
                 a = [a_start a_start];b = [0 1];cla
                 plot(a,b,'g','Parent',sweep_bar)
                 hold on
                 a = [a_end a_end];b = [0 1];
                 plot(a,b,'-g','Parent',sweep_bar)
                 axis([vw_start vw_end 0 1])
                 hold off; axis off
                 hold off
                 handles.a_start = a_start;
                 handles.a_end = a_end;
             else
                 error = 'The END TIME must be greater than %d and less than %.3f.';
                 msgbox(sprintf(error,0,max(handles.time)),'Incorrect Input','Warn');
                 set(endtimemap_edit,'String',max(handles.time))
             end
         else
             error = 'The START TIME must be greater than %d and less than %.3f.';
             msgbox(sprintf(error,0,max(handles.time)),'Incorrect Input','Warn');
             set(starttimemap_edit,'String',0)
         end
     end
 
%% Button to create activation map
    function createmap_button_callback(~,~)
        % CHECK ANALYSIS MODE
        check = get(anal_select,'Value');
        % FOR ACTIVATION
        if check == 2
            gg=msgbox('Building  Activation Map...');
            % Activation map function
            aMap(handles.cmosData,handles.a_start,handles.a_end,handles.Fs,handles.bg,handles.cmap,handles.filename,handles.dir);
            close(gg)
        % FOR CONDUCTION VELOCITY
        elseif check == 3
            rect = getrect(movie_scrn);
            gg=msgbox('Building Conduction Velocity Map...');
            cMap(handles.cmosData,handles.a_start,handles.a_end,handles.Fs,handles.bg,rect);
            close(gg)
        % FOR ACTION POTENTIAL DURATION
        elseif check == 4
            gg=msgbox('Creating Global APD Map...');
            handles.percentAPD = str2double(get(percentapd_edit,'String'));
            apdMap(handles.cmosData,handles.a_start,handles.a_end,handles.Fs,handles.percentAPD,handles.cmap);
            close(gg)
        % FOR PHASE MAP CALCULATION
        elseif check == 5
            phaseMap(handles.cmosData,handles.starttime,handles.endtime,handles.Fs,handles.cmap);
        elseif check == 6
            gg=msgbox('Calculating Dominant Frequency Map...');
            calDomFreq(handles.cmosData,handles.Fs,handles.cmap);
            close(gg)
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Callback for exporting conditioned signals
function export_callback(~,~)
    % Choose location to save file and name of file
    dir = uigetdir;
    % If the cancel button is selected cancel the function
    if dir == 0
        return
    end
    % Request the desired name for the data file
    filename = inputdlg('Enter Filename:');
    filename = char(filename);
    % Check to make sure a value was entered
    if isempty(filename)
        error = 'A filename must be entered! Function cancelled.';
        msgbox(error,'Incorrect Input','Error');
        return
    end
    % Convert filename to a character string
    filename = char(filename);
    % Create path to file
    movname = [dir,'/',filename];
    % Save data
    cmosRawData = handles.cmosRawData;
    cmosData = handles.cmosData;
    analog = handles.ecg;
    bgMask = ~isnan(handles.cmosData(:,:,1));
    save(movname,'cmosData','cmosRawData','analog','bgMask')  
end

end

