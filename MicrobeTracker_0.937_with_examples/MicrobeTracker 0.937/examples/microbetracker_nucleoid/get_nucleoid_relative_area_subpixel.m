load('meshes.mat','cellList')
image = im2double(loadimagestack('fluo.tif'));

nucleoidrelareaarray = []; % initialize array of nucleoid areas
for cell=1:length(cellList{1})
    if ~isempty(cellList{1}{cell})
        box = cellList{1}{cell}.box; % get the "box" around the cell
        mesh = cellList{1}{cell}.mesh; % get the cell mesh
        img1 = imcrop(image,box); % crop the image
        x0 = [mesh(:,1);flipud(mesh(1:end-1,3))]-box(1)+1; % convert mesh to a polygon
        y0 = [mesh(:,2);flipud(mesh(1:end-1,4))]-box(2)+1;
        cellarea = polyarea(x0,y0); % calculate the area of the cell
        mask = poly2mask(x0,y0,box(4)+1,box(3)+1); % obtain the mask of the cell
        img2 = img1-min(img1(:)); % normalize the image so that the intensity spans 0 to 1 range
        img2 = img2/max(img2(:));
        g = graythresh(img2(mask)); % calculate threshold separating the nucleoid
        img2(~imdilate(mask,strel('square',3)))=0; % set the pixel values outside of the cell to zero
        c = contourf(img2,[g g]); % obtain the contour of the nucleoid or nucleoids
        close gcf % close the figure opened by contourf (an unfortunate side effect of this function)
        ind = 1; % set the index in the c-structure to 1 before cycling through
        nucleoidarea = 0; % preset the area of the nucleoids to 0 to be incremented in the cycle
        while ind<size(c,2) % cycle through the c-structure to parse out the polygons
            ctr = c(:,ind+1:ind+c(2,ind))';
            ind = ind+c(2,ind)+1;
            x1 = ctr(:,1); % get x and y coordinates of the polygon
            y1 = ctr(:,2);
            [x1a,y1a] = poly2cw(x1,y1); % converting the contours to clockwise to suppress polybool warnings
            [x2,y2] = polybool('intersection',x0,y0,x1a,y1a); % find te portions of the polygon inside the cell
            if ispolycw(x1,y1)
                nucleoidarea = nucleoidarea+polyarea(x2,y2); % clockwise polygon - increment total area
            else
                nucleoidarea = nucleoidarea-polyarea(x2,y2); %counterclockwise polygon - decrement area
            end
        end
        nucleoidrelareaarray = [nucleoidrelareaarray nucleoidarea/cellarea]; % add the relative area to an array
    end
end
figure % create a new figure
hist(nucleoidrelareaarray,20) % display a histogram of nucleoid areas
xlabel('Relative area occupied by nucleoids')
ylabel('Number of cells')