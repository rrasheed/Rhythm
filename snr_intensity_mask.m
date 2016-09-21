function [intensity_mask, intensity_bg, roi] = snr_intensity_mask(cmos_data,bg_image)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION 
% snr_intensity_mask generates an intensity mask based on thresholding of
% fluorescent intensities
%
% INPUT
% cmos_data = conditioned signal corrected cmos data structure; NO NORM
% file_name = directory to save the matlab figure
% bg_image = background cmos image -> handles.bgRGB = real2rgb(handles.bg, 'gray');
%
% OUTPUT
% intensity_mask = mask based on intensity thresholding
%
% AUTHOR:
% Kedar Aras - created the original code that an intensity mask and an
%              image mask
% 
%
% DATE CREATED
% 07/10/2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%cmos_data = cmos_all_data.drift_cmos_data;
%identify intensity region
mask = ones(100,100);
intensity_bg = max(cmos_data,[],3);
intensity_fg = activecontour(intensity_bg, mask, 150);

%Mask based on region of interest (thresholded intensity values)
connected_regions = bwconncomp(intensity_fg); %find all connected regions
[biggest, ~] = max(cellfun(@numel, connected_regions.PixelIdxList)); % find biggest region
roi = bwareaopen(intensity_fg, round(0.25*biggest)); % remove connected regions of size less than 25% of the biggest region
intensity_mask = nan(100,100);
intensity_mask(roi == 1) = 1;
%intensity_mask = repmat(intensity_mask,[1 1 size(cmos_data,3)]);

%identify foreground region
%bg_image = bgimage;
mask_2 = ones(100,100);
gray_scale_bg = rgb2gray(bg_image);
fg_image = activecontour(gray_scale_bg, mask_2, 50);

%Mask based on region of interest (thresholded intensity values)
connected_regions = bwconncomp(fg_image); %find all connected regions
[biggest, ~] = max(cellfun(@numel, connected_regions.PixelIdxList)); % find biggest region
image_roi = bwareaopen(fg_image, round(0.25*biggest)); % remove connected regions of size less than 50 pixels
image_mask = nan(100,100);
image_mask(image_roi == 1) = 1;
%image_mask = repmat(image_mask,[1 1 size(cmos_data,3)]);

