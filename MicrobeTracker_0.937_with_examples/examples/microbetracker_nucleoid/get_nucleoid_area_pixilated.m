load('meshes.mat','cellList')
image = im2double(loadimagestack('fluo.tif'));

areamin = 50; % minimum size of a nucleoid in square pixels

nucleoidareaarray = []; % initialize array of nucleoid areas
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
        nucleoidmask = img2>g; % obtain the mask of the nucleoid
        regstats = regionprops(nucleoidmask);
        for i=1:length(regstats)
            if regstats(i).Area>=areamin
                nucleoidareaarray = [nucleoidareaarray regstats(i).Area]; % append the area to the array of areas
            end
        end
    end
end
figure % create a new figure
hist(nucleoidareaarray,20) % display a histogram of nucleoid areas
xlabel('Nucleoid area, px^2')
ylabel('Number of nucleoids')