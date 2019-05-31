function spotFinderM
% Manual tracking version of spotFinder. Version  of 02/17/2010.
% This is a GUI-based program which manually detects spots and places them
% into previously detected meshes. Currently the program runs from MATLAB
% only. 
% 
% To use:
% 
% Load (fluorescence) signal images selecting the folder with a TIFF files
%     sequence.
% Load meshes selecting the file with meshes, previously detected with
%     CellTracker. The data may already contain spots, but this is not
%     necessary.
% When the files are loaded, the program will not display the images
%     automatically, you have to click on any navigation button described
%     below. The frame and cell number will be displayed to the image
%     window title.
% Buttons Previous cell / Next cell will cycle through all cells and frames.
% Buttons Frame-1 / Frame+1 cycle through each frame for the same cell.
% Buttons Cell-1 / Cell+1 cycle through each cell on the same frame.
% Only all spots together can be deleted for a particular cell with
%     Clear spots button.
% After you are done, save the data with the Save meshes button.
% By default the spots data is saved into .spots substructure in the
%     cellList{frame}{cell} structure for each cell. To change the name
%     of the substructure change it in the Field box.
% All manually detected spots will have the zero magnitude (i.e. the
%     magnitude field in the .spots substructure will be all zeros).

bformats = checkbformats(1);

handles.control = figure('pos',[500 500 250 215],'Toolbar','none','Menubar','none','NumberTitle','off','IntegerHandle','off','KeyPressFcn',@keypress,'Name','Manual spotFinder','CloseRequestFcn',@mainguiclosereq);
color = get(handles.control,'color');
handles.loadimages = uicontrol(handles.control,'units','pixels','Position',[10 185 110 22],'String','Load images','backgroundcolor',color,'callback',@loadimages);
handles.loadimageschk = uicontrol(handles.control,'style','checkbox','units','pixels','Position',[130 185 110 22],'String','Use stack files','backgroundcolor',color,'callback',@loadimages);
uicontrol(handles.control,'style','text','units','pixels','Position',[121 160 36 17],'String','Field:','HorizontalAlignment','right','backgroundcolor',color);
handles.spotsname = uicontrol(handles.control,'style','edit','units','pixels','Position',[160 160 80 22],'String','spots','backgroundcolor',[1 1 1]);
handles.loadmesh = uicontrol(handles.control,'units','pixels','Position',[10 160 110 22],'String','Load meshes','backgroundcolor',color,'callback',@loadmesh);
handles.savemesh = uicontrol(handles.control,'units','pixels','Position',[10 135 110 22],'String','Save meshes','backgroundcolor',color,'callback',@savemesh);

handles.prevcell = uicontrol(handles.control,'units','pixels','Position',[10 85 110 22],'String','Previous cell','backgroundcolor',color,'callback',@changecell);
handles.nextcell = uicontrol(handles.control,'units','pixels','Position',[130 85 110 22],'String','Next cell','backgroundcolor',color,'callback',@changecell);
handles.framem1 = uicontrol(handles.control,'units','pixels','Position',[10 60 110 22],'String','Frame-1','backgroundcolor',color,'callback',@changecell);
handles.framep1 = uicontrol(handles.control,'units','pixels','Position',[130 60 110 22],'String','Frame+1','backgroundcolor',color,'callback',@changecell);
handles.cellm1 = uicontrol(handles.control,'units','pixels','Position',[10 35 110 22],'String','Cell-1','backgroundcolor',color,'callback',@changecell);
handles.cellp1 = uicontrol(handles.control,'units','pixels','Position',[130 35 110 22],'String','Cell+1','backgroundcolor',color,'callback',@changecell);
handles.clear = uicontrol(handles.control,'units','pixels','Position',[10 10 110 22],'String','Clear spots','backgroundcolor',color,'callback',@clearspots);

cellList = [];
cell = 1;
frame = 1;
handles.fig = 1;
key = '';
images = [];
spotFinderMImagesFolder = '';
spotFinderMMeshesFile = '';
cellList = [];
dspspots = -1;
spots = [];
lst = [];


    function mainguiclosereq(hObject, eventdata)
        if isfield(handles,'fig') && ishandle(handles.fig), delete(handles.fig); end
        delete(handles.control)
    end

    function keypress(hObject, eventdata)
        key = '';
        if hObject==handles.control || hObject==handles.fig, key = eventdata.Key; end
        if strcmp(key,'leftarrow') || strcmp(key,'rightarrow') || strcmp(key,'uparrow') || strcmp(key,'downarrow') || strcmp(key,'n') || strcmp(key,'p')
            changecell(hObject, eventdata)
        end
        key = '';
    end

    function loadmesh(hObject, eventdata)
        [FileName,PathName] = uigetfile2('*.mat','Select file with signal meshes',spotFinderMMeshesFile);
        if isempty(FileName)||isequal(FileName,0), return, end
        spotFinderMMeshesFile = [PathName '/' FileName];
        lst = load(spotFinderMMeshesFile,'cellList');
        cellList = lst.cellList;
    end

    function savemesh(hObject, eventdata)
        [FileName,PathName] = uiputfile('*.mat','Select file with signal meshes',spotFinderMMeshesFile);
        if isempty(FileName)||isequal(FileName,0), return, end
        spotFinderMMeshesFile = [PathName '/' FileName];
        % save(spotFinderMMeshesFile,'cellList');
        lst.cellList = cellList;
        save(spotFinderMMeshesFile,'-struct','lst')
    end

    function loadimages(hObject, eventdata)
        if get(handles.loadimageschk,'Value')
            if bformats
                [filename,pathname] = uigetfile('*.*','Select file with signal images',spotFinderMImagesFolder);
            else
                [filename,pathname] = uigetfile({'*.tif';'*.tiff'},'Select file with signal images',spotFinderMImagesFolder);
            end
            if isempty(filename)||isequal(filename,0), stoprun; return, end
            spotFinderMImagesFolder = fullfile2(pathname,filename);
            images = loadimagestack(spotFinderMImagesFolder,1);
        else
            folder = uigetdir(spotFinderMImagesFolder,'Select folder with signal images');
            if isempty(folder) || isequal(folder,0), return, end
            spotFinderMImagesFolder = folder;
            images = loadimageseries(folder,1);
        end
    end

    function changecell(hObject, eventdata)
        if isempty(cellList), disp('No cellList loaded'); return; end
        if isempty(images), disp('No images loaded'); return; end
        
        % selet the frame and cell
        if hObject==handles.framem1 || strcmp(key,'downarrow')
            framenew = frame;
            while true
                framenew = framenew-1;
                if framenew<1
                    framenew = length(cellList);
                    if framenew == frame, disp(['No cell number ' num2str(cell) ' found']), return; end
                elseif cell<=length(cellList{framenew}) && ~isempty(cellList{framenew}{cell}) && length(cellList{framenew}{cell}.mesh)>4
                    frame = framenew;
                    break;
                end
            end
        elseif hObject==handles.framep1 || strcmp(key,'uparrow')
            framenew = frame;
            while true
                framenew = framenew+1;
                if framenew>length(cellList)
                    framenew = 1;
                    if framenew == frame, disp(['No cell number ' num2str(cell) ' found']), return; end
                elseif cell<=length(cellList{framenew}) && ~isempty(cellList{framenew}{cell}) && length(cellList{framenew}{cell}.mesh)>4
                    frame = framenew;
                    break;
                end
            end
        elseif hObject==handles.cellm1 || strcmp(key,'leftarrow')
            cellnew = cell;
            while true
                cellnew = cellnew-1;
                if cellnew<1
                    cellnew = length(cellList{frame});
                    if cellnew == cell, disp(['No cell on frame ' num2str(frame) ' found']), return; end
                elseif cellnew<=length(cellList{frame}) && ~isempty(cellList{frame}{cellnew}) && length(cellList{frame}{cellnew}.mesh)>4
                    cell = cellnew;
                    break;
                end
            end
        elseif hObject==handles.cellp1 || strcmp(key,'rightarrow')
            cellnew = cell;
            while true
                cellnew = cellnew+1;
                if cellnew>length(cellList{frame})
                    cellnew = 1;
                    if cellnew == cell, disp(['No cell on frame ' num2str(frame) ' found']), return; end
                elseif cellnew<=length(cellList{frame}) && ~isempty(cellList{frame}{cellnew}) && length(cellList{frame}{cellnew}.mesh)>4
                    cell = cellnew;
                    break;
                end
            end
        elseif hObject==handles.prevcell || strcmp(key,'p')
            cellnew = cell;
            framenew = frame;
            while true
                cellnew = cellnew-1;
                if cellnew<1
                    framenew = framenew-1;
                    if framenew<1, framenew = length(cellList); end
                    cellnew = length(cellList{framenew});
                    if cellnew == cell && framenew == frame, disp('No cell found in the meshes file'), return; end
                elseif cellnew<=length(cellList{framenew}) && ~isempty(cellList{framenew}{cellnew}) && length(cellList{framenew}{cellnew}.mesh)>4
                    cell = cellnew;
                    frame = framenew;
                    break;
                end
            end
        elseif hObject==handles.nextcell || strcmp(key,'n')
            cellnew = cell;
            framenew = frame;
            while true
                cellnew = cellnew+1;
                if cellnew>length(cellList{framenew})
                    framenew = framenew+1;
                    if framenew>length(cellList), framenew = 1; end
                    cellnew = 1;
                    if cellnew == cell && framenew == frame, disp('No cell found in the meshes file'), return; end
                elseif cellnew<=length(cellList{framenew}) && ~isempty(cellList{framenew}{cellnew}) && length(cellList{framenew}{cellnew}.mesh)>4
                    cell = cellnew;
                    frame = framenew;
                    break;
                end
            end
        end
        
        % display the image, draw mesh & existing spots
        box = cellList{frame}{cell}.box;
        img0 = imcrop(images(:,:,frame),box);
        if ishandle(handles.fig)
            figure(handles.fig)
        else
            handles.fig=figure('WindowButtonDownFcn',@selectclick,'KeyPressFcn',@keypress); 
            s = get(handles.fig,'pos');
            s = [(s(1:2)+round(s(3:4)/2))-200 400 400];
            set(handles.fig,'pos',s)
            handles.ax = axes;
        end
        set(handles.fig,'Name',['Frame ' num2str(frame) ', cell ' num2str(cell)])
        s = get(handles.fig,'pos');
        s = [(s(1:2)+round(s(3:4)/2))-200 400 400];
        plot(0,0);
        imshow(img0,[]);
        set(handles.fig,'pos',s)
        set(handles.ax,'pos',[0 0 1 1]);
        hold on
        mesh = cellList{frame}{cell}.mesh;
        mesh = [mesh(:,1)-box(1)+1 mesh(:,2)-box(2)+1 mesh(:,3)-box(1)+1 mesh(:,4)-box(2)+1];
        plot(mesh(:,1),mesh(:,2),'-g',mesh(:,3),mesh(:,4),'-g')
        if isfield(cellList{frame}{cell},get(handles.spotsname,'String'))
            eval(['spots = cellList{frame}{cell}.' get(handles.spotsname,'String') ';']);
            x = spots.x - box(1)+1;
            y = spots.y - box(2)+1;
        else
            x=[];
            y=[];
        end
        dspspots = plot(x,y,'.r','MarkerSize',15);
        hold off
        pause(0.1);
    end

    function selectclick(hObject, eventdata)
        if ~ishandle(handles.fig) || ~ishandle(handles.ax), return; end
        ps = get(handles.ax,'CurrentPoint');
        xlimit = get(handles.ax,'XLim');
        ylimit = get(handles.ax,'YLim');
        xc = ps(1,1);
        yc = ps(1,2);
        if xc<xlimit(1) || xc>xlimit(2) || yc<ylimit(1) || yc>ylimit(2), return; end
        if ishandle(dspspots), delete(dspspots); end
        dspspots = -1;
        box = cellList{frame}{cell}.box;
        if strcmp(get(handles.fig,'SelectionType'),'extend')
            % delete an existing spot
            x = spots.x-box(1)+1;
            y = spots.y-box(2)+1;
            dst = (x-xc).^2+(y-yc).^2;
            [mindst,ind] = min(dst);
            if mindst>10, return; end
            fields = fieldnames(spots);
            for f=1:length(fields)
                spots.(fields{f}) = spots.(fields{f})([1:ind-1 ind+1:end]);
            end
            
        else
            % add a new spot
            if isfield(cellList{frame}{cell},get(handles.spotsname,'String'))
                eval(['spots = cellList{frame}{cell}.' get(handles.spotsname,'String') ';']);
            else
                spots.x = [];
                spots.y = [];
                spots.l = [];
                spots.d = [];
                spots.b = [];
                spots.w = [];
                spots.h = [];
                spots.magnitude = [];
                spots.positions = [];
            end
            mesh = cellList{frame}{cell}.mesh;
            stplng = cellList{frame}{cell}.steplength;
            [lc,dc]=projectToMesh(xc+box(1)-1,yc+box(2)-1,mesh,stplng);
            spots.x = [spots.x xc+box(1)-1];
            spots.y = [spots.y yc+box(2)-1];
            spots.l = [spots.l lc];
            spots.d = [spots.d dc];
            spots.b = [spots.d 0];
            spots.w = [spots.d 0];
            spots.h = [spots.d 0];
            spots.magnitude = [reshape(spots.magnitude,1,[]) 0];
            spots.positions = round(spots.l); % TODO: correct this, currently only an approximation
        end
        eval(['cellList{frame}{cell}.' get(handles.spotsname,'String') '=spots;']);
        hold on       
        x = spots.x - box(1)+1;
        y = spots.y - box(2)+1;
        dspspots = plot(x,y,'.r','MarkerSize',15);
        hold off
    end

    function clearspots(hObject, eventdata)
        if ~ishandle(handles.fig) || ~ishandle(handles.ax), return; end
        spots.x = [];
        spots.y = [];
        spots.l = [];
        spots.d = [];
        spots.b = [];
        spots.w = [];
        spots.h = [];
        spots.magnitude = [];
        spots.positions = [];
        eval(['cellList{frame}{cell}.' get(handles.spotsname,'String') '=spots;']);
        if ishandle(dspspots), delete(dspspots); end
        dspspots = -1;
    end
end

function [d,e] = uigetfile2(a,b,c)
    f=true;
    while f
        try
            [d,e] = uigetfile(a,b,c);
            f=false;
        catch
            pause(0.01)
            f=true;
        end
    end
end