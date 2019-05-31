function data = loadimagestack(filename,varargin)
% loadedData = loadimagestack(pathToFolder,usewaitbar)
% 
% This finction loads images from a stack file into the 3D array loadedData
% 
% filename - name of the original stack file (must be TIFF or BioFormats
%     must be loaded, e.g. with checkbformats function)
% usewaitbar (optional) - 1 (true) to display a waitbar
% loadedData - x_dimension x y_dimension x number_of_images - stack of
%     loaded images

    if length(varargin)>=1 && varargin{1}==1, useWaitBar=true; else useWaitBar=false; end
    % loads image stacks using Bioformats
    % "n" - channel (1-phase, 2-extra, 3-signal1, 4-signal2)
    % "filename" - stack file name
    bformats = checkbformats(1);
    data = [];
    if (length(filename)>4 && strcmpi(filename(end-3:end),'.tif')) || (length(filename)>5 && strcmpi(filename(end-4:end),'.tiff'))
        % loading TIFF files
        try
            info = imfinfo(filename);
            numImages = numel(info);
            if useWaitBar, w = waitbar(0, 'Loading images, please wait...'); end
            lng = info(1).BitDepth;
            if lng==8
                cls='uint8';
            elseif lng==16
                cls='uint16';
            elseif lng==32
                cls='uint32';
            else
                disp('Error in image bitdepth loading multipage TIFF images: no images loaded');return;
            end
            data = zeros(info(1).Height,info(1).Width,numImages,cls);
            for i = 1:numImages
                img = imread(filename,i,'Info',info);
                data(:,:,i)=img;
                if useWaitBar, waitbar(i/numImages, w); end
            end
            if useWaitBar, close(w); end
            disp(['Loaded ' num2str(numImages) ' images from a multipage TIFF'])
        catch
            disp('Error loading multipage TIFF images: no images loaded');
        end
    elseif bformats
        % loading all formats other than TIFF
        try
            breader = loci.formats.ChannelFiller();
            breader = loci.formats.ChannelSeparator(breader);
            breader = loci.formats.gui.BufferedImageReader(breader);
            breader.setId(filename);
            numSeries = breader.getSeriesCount();
            if numSeries~=1, disp('Incorrect image stack format: no images loaded'); return; end; 
            breader.setSeries(0);
            wd = breader.getSizeX();
            hi = breader.getSizeY();
            shape = [wd hi];
            numImages = breader.getImageCount();
            if numImages<1, disp('Incorrect image stack format: no images loaded'); return; end;
            nBytes = loci.formats.FormatTools.getBytesPerPixel(breader.getPixelType());
            if nBytes==1
                cls = 'uint8';
            else
                cls = 'uint16';
            end
            data = zeros(hi,wd,num2str(numImages),cls);
            if useWaitBar, w = waitbar(0, 'Loading images, please wait...'); end
            for i = 1:numImages
                img = breader.openImage(i-1);
                pix = img.getData.getPixels(0, 0, wd, hi, []);
                arr = reshape(pix, shape)';
                if nBytes==1
                    arr2 = uint8(arr/256);
                else
                    arr2 = uint16(arr);
                end
                data(:,:,i)=arr2;
                if useWaitBar, waitbar(i/numImages, w); end
            end
            if useWaitBar, close(w); end
            disp(['Loaded ' num2str(numImages) ' images using BioFormats'])
        catch
            disp('Error loading images using BioFormats: no images loaded');
        end
    else % unsupported format of images
        disp('Error loading images: the stack must be in TIFF format for BioFormats must be loaded');
    end
end