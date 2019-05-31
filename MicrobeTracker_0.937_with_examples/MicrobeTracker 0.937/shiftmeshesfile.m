function shiftmeshesfile(x,y)
                
[filename,pathname] = uigetfile('*.mat', 'Enter a filename to get meshes from');
if(filename==0), return; end;
filename1 = fullfile(pathname,filename);
load(filename1,'cellList');

for frame=1:length(cellList)
    for cell=1:length(cellList{frame})
        if ~isempty(cellList{frame}{cell}) && isfield(cellList{frame}{cell},'mesh') && size(cellList{frame}{cell}.mesh,2)==4
            mesh = cellList{frame}{cell}.mesh;
            mesh(:,[1 3])=mesh(:,[1 3])+x; mesh(:,[2 4])=mesh(:,[2 4])+y;
            cellList{frame}{cell}.mesh = mesh;
        end
    end
end

[filename,pathname] = uiputfile('*.mat', 'Enter a filename to save shifted meshes to');
if isequal(filename,0), return; end;
if length(filename)<=4
    filename = [filename '.mat'];
elseif ~strcmp(filename(end-3:end),'.mat')
    filename = [filename '.mat'];
end
filename = fullfile(pathname,filename);
if ~strcmp(filename,filename1), copyfile(filename1,filename,'f'); end
save(filename,'cellList','-append');