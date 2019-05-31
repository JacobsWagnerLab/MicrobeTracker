function spotvslength(cellList,varargin)
% spotvslength(cellList)
% spotvslength(cellList,pix2mu)
% 
% This function plots a digram of the number of spots vs. the length of a
% cell. The meshes and the spots have to be previously detected.
% 
% <cellList> is an array that contains the meshes. You can drag and drop
%     the file with the data into MATLAB workspace or open it using MATLAB
%     Import Tool. The default name of the variable is cellList, but it can
%     be renamed.
% <pix2mu> ? conversion factor from pixels to microns, the size of a pixel
%     in microns. 

pix2mu = 1;
pix2mucheck = false;
for i=length(varargin):-1:1
    if strcmp(class(varargin{i}),'double') && length(varargin{i})==1
        pix2mu = varargin{i};
        pix2mucheck = true;
    end
end

cellLength = [];
numberoffoci = [];
for frame=1:length(cellList)
    for cell=1:length(cellList{frame})
        if cell<=length(cellList{frame}) && ~isempty(cellList{frame}{cell}) && ...
                length(cellList{frame}{cell}.mesh)>4 && isfield(cellList{frame}{cell},'spots')
            cellLength = [cellLength cellList{frame}{cell}.length];
            numberoffoci = [numberoffoci length(cellList{frame}{cell}.spots.magnitude)];
        end
    end
end
plot (cellLength*pix2mu, numberoffoci,'.b');
set(gca,'FontSize',14)
ylabel('Number of foci','FontSize',16)
if pix2mucheck
    xlabel('Cell length, \mum','FontSize',16)
else
    xlabel('Cell length, pixels','FontSize',16)
end