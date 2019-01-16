function [data3, fps, fname, pname]=tifopen(source)

% Open TIFF files, especially those taken with MetaMorph 7.5 TIFF format
% 2018-08-06 ver 1.0 RJ3

seed='/';
switch nargin
    case 0 % source was unspecified
        [fname,pname]=uigetfile({'*.tif';'*.tiff'},'Select a TIFF Stack',seed);
        source=[pname,fname];    
    case 1 % file source was specified
        fname=[]; % these output vars will be blank, since source was specified
        pname=[]; % these output vars will be blank, since source was specified
end

fprintf('tifopen called on: %s',source);
init=imfinfo(source);
nImages=length(init)
try %input DateTimes: yyyyMMdd HH:mm:ss.SSS
    endTime=datetime(init(nImages).DateTime,'InputFormat','yyyyMMdd HH:mm:ss.SSS');
    startTime=datetime(init(1).DateTime,'InputFormat','yyyyMMdd HH:mm:ss.SSS');
catch
    try %input DateTimes: yyyy:MM:dd HH:mm:ss
        endTime=datetime(init(nImages).DateTime,'InputFormat','yyyy:MM:dd HH:mm:ss');
        startTime=datetime(init(1).DateTime,'InputFormat','yyyy:MM:dd HH:mm:ss');
    catch ME
        msg = ['Failed to init start/end times:']
        init(1)
        causeException = MException('MATLAB:ORCA:tifopen',msg);
        ME = addCause(ME,causeException);
        rethrow(ME)
    end
end
totalTime=endTime-startTime;
dt=milliseconds(totalTime)/nImages
fps=1/(dt/1000)
imageW=init(1).Width;
imageH=init(1).Height;
data3=zeros(imageH,imageW,nImages,'uint16');
fprintf('Image size WxH: %s x %s', imageW, imageH);
fprintf('Video total time, frames: %s, %s', totalTime, nImages);
fprintf('dt: %s', dt);
fprintf('FPS: %s', fps);
%iminfoTable = struct2table(init(1), 'AsArray',true)

for p=1:nImages
    data3(:,:,p)=imread(source,'index',p,'Info',init);
end