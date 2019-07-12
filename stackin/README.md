# stackin
2019-05-08

stackin is a new repository meant to be loaded as a submodule into MATLAB for use with cardiac electrophysiology analysis
tools such as Camat and RHYTHM.

Dependencies for Nikon .ND2 and Zeiss .LSM loading:
Bio-Formats Matlab from Open Microscopy Environment (OME)
https://github.com/ome/bio-formats-matlab/tree/master/src

Dependencies for Andor .SIF and .SIFX loading:
Proprietary .SO or .DLL blobs from Andor and binds in C to create mex.

stackin has functions that can be used to load in image stacks (videos) while respecting the frame rate (fps) or period (dt)
of the video.

- Open .TIF/.TIFF files, especially those taken with MetaMorph 7.5 TIFF format
- Open Andor .SIF and .SIFX files, using some proprietary blobs
- Open Nikon .ND2 or Zeiss .LSM using Bio-formats-matlab
