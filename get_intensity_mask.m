function [intensity_mask, image_mask] = get_intensity_mask(cmos_data,file_name,bg_image)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION 
% get_intensity_mask generates an intensity mask based on thresholding of
% fluorescent intensities
%
% INPUT
% cmos_data = drift corrected cmos data structure
% file_name = directory to save the matlab figure
% bg_image = background cmos image
%
% OUTPUT
% intensity_mask = mask based on intensity thresholding
% image_mask = mask based on foreground image detection
%
% AUTHOR
% Kedar Aras
% 
% DATE CREATED
% 07/10/2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%cmos_data = cmos_all_data.drift_cmos_data;
%identify intensity region
mask = ones(100,100);
intensity_bg = max(cmos_data, [],3);
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

% plot the image intensity masks
fig_title = strcat('Intensity Masks');
fig = figure('Name', fig_title);

subplot(2,3,1)
imagesc(intensity_bg);
title('Intensity Image');
axis off

subplot(2,3,2)
imagesc(intensity_fg);
title('Coarse ROI');
axis off

subplot(2,3,3)
imagesc(roi);
title('Final ROI');
axis off

subplot(2,3,4)
imagesc(bg_image);
title('Background Image');
axis off

subplot(2,3,5)
imagesc(fg_image);
title('Coarse Foreground');
axis off

subplot(2,3,6)
imagesc(image_roi);
title('Final Foreground');
axis off

file = strrep(file_name, '/mat/', '/images/mat_fig/');
file = strrep(file, '.mat', '');
file = strcat(file, '-Mask.fig');
savefig(fig, file, 'compact');

file = strrep(file, 'mat_fig', 'png');
file = strrep(file, '.fig', '.png');
saveas(fig,file);


close;

end
