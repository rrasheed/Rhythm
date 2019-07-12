function [data3, fps, fname, pname]=tifopen(source)

% Open TIFF files, especially those taken with MetaMorph 7.5 TIFF format
% 2018-08-06 ver 1.0 RJ3
% 2019-05-07 ver 1.1 RJ3 - modified "nImage-1" correction and manual fps
% enter if not detected.

seed='';

switch nargin
    case 0 % source was unspecified
        [fname,pname]=uigetfile({'*.tif';'*.tiff'},'Select a TIFF Stack',seed);
        source=[pname,fname];    
    case 1 % file source was specified
        fname=[]; % these output vars will be blank, since source was specified
        pname=[]; % these output vars will be blank, since source was specified
end

init=imfinfo(source);
nImages=length(init);

try
    endTime=datetime(init(nImages).DateTime,'InputFormat','yyyyMMdd HH:mm:ss.SSS');
    startTime=datetime(init(1).DateTime,'InputFormat','yyyyMMdd HH:mm:ss.SSS');
    totalTime=endTime-startTime;
    dt=milliseconds(totalTime)/(nImages-1);
    fps=1/(dt/1000);
catch
    fps=input('Please enter the fps=')
end

imageW=init(1).Width;
imageH=init(1).Height;
data3=zeros(imageH,imageW,nImages,'uint16');

%iminfoTable = struct2table(init(1), 'AsArray',true)

for p=1:nImages
    data3(:,:,p)=imread(source,'index',p,'Info',init);
end
