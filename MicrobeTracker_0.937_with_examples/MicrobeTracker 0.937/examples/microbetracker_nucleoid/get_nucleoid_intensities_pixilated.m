load('meshes.mat','cellList')
image = im2double(loadimagestack('fluo_subtracted.tif'));

nucleoidintarray = []; % initialize array of nucleoid intensities
cellintarray = []; % initialize array of cell intensities
for cell=1:length(cellList{1})
    if ~isempty(cellList{1}{cell})
        box = cellList{1}{cell}.box; % get the "box" around the cell
        mesh = cellList{1}{cell}.mesh; % get the cell mesh
        img1 = imcrop(image,box); % crop the image
        x0 = [mesh(:,1);flipud(mesh(1:end-1,3))]-box(1)+1; % convert mesh to a polygon
        y0 = [mesh(:,2);flipud(mesh(1:end-1,4))]-box(2)+1;
        cellmask = poly2mask(x0,y0,box(4)+1,box(3)+1); % obtain the mask of the cell
        img2 = img1-min(img1(:)); % normalize the image so that the intensity spans 0 to 1 range
        img2 = img2/max(img2(:));
        g = graythresh(img2(cellmask)); % calculate threshold separating the nucleoid
        nucleoidmask = (img2>g) & cellmask; % obtain the mask of the nucleoid
        nucleoidint = sum(img1(nucleoidmask))/sum(nucleoidmask(:)); % obtain the area of the nucleoid (in sq. pixels)
        cellint = sum(img1(cellmask))/sum(cellmask(:)); % obtain the area of the cell (in sq. pixels)
        nucleoidintarray = [nucleoidintarray nucleoidint];
        cellintarray = [cellintarray cellint];
    end
end
figure % create a new figure
bins = 0.00005:0.00005:0.0012;
hist([nucleoidintarray;cellintarray]',bins) % display a histogram of nucleoid areas
legend({'nucleoid intensity';'cell intensity'})
xlabel('Relative intensity')
ylabel('Number of cells')