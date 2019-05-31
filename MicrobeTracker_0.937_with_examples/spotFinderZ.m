function spotFinderZ
% Version 0.50 of 06/14/2012

% clear microbeTracker data from old sessions, if any
global handles
if ~isempty(who('handles')) && isfield(handles,'maingui') && ishandle(handles.maingui)
    choice = questdlg('Another MicrobeTracker or SpotFinder session is running. Close it and continue?','Question','Close & continue','Keep & exit','Close & continue');
    if strcmp(choice,'Keep & exit')
        return
    else
        if ~isempty(who('handles')) && isstruct(handles)
            fields = fieldnames(handles);
            for q1=1:length(fields)
                cfield = [];
                eval(['cfield = handles.' fields{q1} ';'])
                if ishandle(cfield)
                    delete(cfield);
                elseif isstruct(cfield)
                    fields2 = fieldnames(cfield);
                    for q2=1:length(fields2)
                        eval(['if ishandle(cfield.' fields2{q2} '), delete(cfield.' fields2{q2} '); end'])
                    end
                end
            end
        end
    end
end

% detect if Bioformats is installedcurrentdir = fileparts(mfilename('fullpath'));
bformats = checkbformats(1);
global handles %#ok<REDEF>

panelshift=0;
handles.maingui = figure('pos',[250 250 280 270+panelshift],'Toolbar','none','Menubar','none','Name','spotFinderZ 0.50','NumberTitle','off','IntegerHandle','off','Resize','off','KeyPressFcn',@mainkeypress);
handles.normpanel = uibuttongroup('units','pixels','pos',[145 89+panelshift 130 175],'SelectionChangeFcn',@checkchange_cbk);
handles.outputpanel = uipanel('units','pixels','pos',[8 74+panelshift 130 165]);
% handles.processpanel = uibuttongroup('units','pixels','pos',[7 7 267 60],'SelectionChangeFcn',@intfltchng_cbk);
set(handles.maingui,'Color',get(handles.normpanel,'BackgroundColor'));

uicontrol(handles.normpanel,'units','pixels','Position',[5 152 118 16],'Style','text','String','Normalization','FontWeight','bold','HorizontalAlignment','center');
uicontrol(handles.normpanel,'units','pixels','Position',[5 137 118 16],'Style','text','String','(requires subt. bgrnd)','HorizontalAlignment','center');
handles.norm1 = uicontrol(handles.normpanel,'units','pixels','Position',[5 115 120 16],'Style','radiobutton','String','No normalization','KeyPressFcn',@mainkeypress);
handles.norm2 = uicontrol(handles.normpanel,'units','pixels','Position',[5 93 120 16],'Style','radiobutton','String','Cell','KeyPressFcn',@mainkeypress);
handles.norm3 = uicontrol(handles.normpanel,'units','pixels','Position',[5 71 120 16],'Style','radiobutton','String','Frame','KeyPressFcn',@mainkeypress);
handles.norm4 = uicontrol(handles.normpanel,'units','pixels','Position',[5 49 120 16],'Style','radiobutton','String','Stack','KeyPressFcn',@mainkeypress);
handles.normM = uicontrol(handles.normpanel,'units','pixels','Position',[5 26 120 16],'Style','checkbox','String','Data from meshes','Enable','off','KeyPressFcn',@mainkeypress);
uicontrol(handles.normpanel,'units','pixels','Position',[5 3 100 16],'Style','text','String','Divide by','HorizontalAlignment','Left');
handles.normF = uicontrol(handles.normpanel,'units','pixels','Position',[57 5 59 16],'Style','edit','BackgroundColor',[1 1 1],'String','1');

uicontrol(handles.outputpanel,'units','pixels','Position',[6 142 120 16],'Style','text','String','Output','FontWeight','bold','HorizontalAlignment','center');
handles.outimg = uicontrol(handles.outputpanel,'units','pixels','Position',[5 124 120 16],'Style','checkbox','String','Images','Callback',@checkchange_cbk,'KeyPressFcn',@mainkeypress);
handles.outsaveimg = uicontrol(handles.outputpanel,'units','pixels','Position',[35 105 90 16],'Style','checkbox','String','Save','Enable','off','KeyPressFcn',@mainkeypress);
handles.outshowmesh = uicontrol(handles.outputpanel,'units','pixels','Position',[35 86 90 16],'Style','checkbox','String','Show meshes','Enable','off','KeyPressFcn',@mainkeypress);
handles.outmesh = uicontrol(handles.outputpanel,'units','pixels','Position',[5 66 120 16],'Style','checkbox','String','Meshes','Callback',@checkchange_cbk,'KeyPressFcn',@mainkeypress);
handles.outfile = uicontrol(handles.outputpanel,'units','pixels','Position',[35 47 90 16],'Style','checkbox','String','File','Enable','off','KeyPressFcn',@mainkeypress);
handles.outscreen = uicontrol(handles.outputpanel,'units','pixels','Position',[35 28 90 16],'Style','checkbox','String','Screen','Enable','off','KeyPressFcn',@mainkeypress);
uicontrol(handles.outputpanel,'units','pixels','Position',[5 5 30 16],'Style','text','String','Field','HorizontalAlignment','left','KeyPressFcn',@mainkeypress);
handles.outfield = uicontrol(handles.outputpanel,'units','pixels','Position',[35 5 90 16],'Style','edit','String','spots','BackgroundColor',[1 1 1]);

handles.helpbtn = uicontrol(handles.maingui,'units','pixels','Position',[10 245+panelshift 125 20],'String','Help','Callback',@help_cbk,'Enable','on','KeyPressFcn',@mainkeypress);
handles.loadstack = uicontrol(handles.maingui,'units','pixels','Position',[151 71+panelshift 130 14],'Style','checkbox','String','Use stack files','Value',1,'Enable','on','KeyPressFcn',@mainkeypress);

% handles.parambtn = uicontrol(handles.processpanel,'units','pixels','Position',[5 32 125 22],'String','Params','Callback',@params_cbk);
% handles.adjustbtn = uicontrol(handles.processpanel,'units','pixels','Position',[135 32 125 22],'String','Adjust','Callback',@run_cbk);
% handles.run = uicontrol(handles.processpanel,'units','pixels','Position',[5 6 255 22],'String','Run','Callback',@run_cbk);
handles.parambtn = uicontrol(handles.maingui,'units','pixels','Position',[13 39+panelshift 125 22],'String','Params','Callback',@params_cbk,'KeyPressFcn',@mainkeypress);
handles.adjustbtn = uicontrol(handles.maingui,'units','pixels','Position',[143 39+panelshift 125 22],'String','Adjust','Callback',@run_cbk,'KeyPressFcn',@mainkeypress);
handles.run = uicontrol(handles.maingui,'units','pixels','Position',[13 13+panelshift 255 22],'String','Run','Callback',@run_cbk,'KeyPressFcn',@mainkeypress);
handles.calculate = [];
handles.rangec = uicontrol(handles.maingui,'units','pixels','pos',[8 13 145 16],'Style','text','String','Use range of frames:','visible','off');
handles.range1 = uicontrol(handles.maingui,'units','pixels','pos',[150 13 50 18],'Style','edit','String','','BackgroundColor',[1 1 1],'Visible','off');
handles.range2 = uicontrol(handles.maingui,'units','pixels','pos',[210 13 50 18],'Style','edit','String','','BackgroundColor',[1 1 1],'Visible','off');
drawnow

se{1} = strel('arbitrary',[0 0 0 0 0; 0 0 0 0 0; 1 1 1 1 1; 0 0 0 0 0; 0 0 0 0 0]);
se{2} = strel('arbitrary',[1 0 0 0 0; 0 1 0 0 0; 0 0 1 0 0; 0 0 0 1 0; 0 0 0 0 1]);
se{3} = strel('arbitrary',[0 0 1 0 0; 0 0 1 0 0; 0 0 1 0 0; 0 0 1 0 0; 0 0 1 0 0]);
se{4} = strel('arbitrary',[0 0 0 0 1; 0 0 0 1 0; 0 0 1 0 0; 0 1 0 0 0; 1 0 0 0 0]);

params.dilateCount = 1;
params.getnearest = 0;
params.loCutoff = 1;
params.hiCutoff = 3;
params.minprefilterh = 0;
params.shiftlim = 0.01;
params.dmax = 6;
params.resize = 1;
params.ridges = 1;
params.scalefactor=1;
params.wmax = 20; % max width in pixels
params.wmin = 4; % min width in pixels
params.hmin = 0.001; % min height
params.ef2max = 30; % max relative squared error
params.vmax = 1; % max ratio of the variance to squared spot height
params.fmin = 0.01; % min ratio of the filtered to fitted spot (takes into account size and shape)
saveparamsFileName = '';

spotList = [];
integrmethod = [];
disk = [];
FirstFolder='';
spotFinderImageFile = '';
signalMeshFileName = '';
spotFinderMFCFile = '';
trainOnRange = false;
adjustmode = false;
w = [];
h = [];


    function mainkeypress(hObject, eventdata)
        c = get(handles.maingui,'CurrentCharacter');
        if isempty(c)
            return;
        elseif strcmp(c,'+') || double(c)==43 || strcmp(c,'=') || double(c)==61 % '+' - Perform training on a range of frames
            trainOnRange = true;
            panelshift=25;
            adjustmaingui
        elseif strcmp(c,'-') || double(c)==45 % '-' - Perform training on all frames
            trainOnRange = false;
            panelshift=0;
            adjustmaingui
        elseif double(c)==28 % left arrow - go to previous cell
            set(handles.maingui,'UserData',-1);
        elseif double(c)==29 % right arrow - go to next cell
            set(handles.maingui,'UserData',1);
        elseif double(c)==27 % ESC - stop
            set(handles.maingui,'UserData',0);
            stoprun;
        elseif double(c)==97 % 'a' - adjust contrast
            if isfield(h,'fig') && ishandle(h.fig) && isfield(h,'ax') && ishandle(h.ax)
                imcontrast(h.ax)
            end
        end
        function adjustmaingui
            pos = get(handles.maingui,'pos');
            set(handles.maingui,'pos',[pos(1) pos(2)+pos(4)-270-panelshift 280 270+panelshift]);
            set(handles.normpanel,'pos',[145 89+panelshift 130 175]);
            set(handles.outputpanel,'pos',[8 74+panelshift 130 165]);
            set(handles.helpbtn,'pos',[10 245+panelshift 125 20]);
            set(handles.loadstack,'pos',[151 71+panelshift 130 14]);
            set(handles.parambtn,'pos',[13 39+panelshift 125 22]);
            set(handles.adjustbtn,'pos',[143 39+panelshift 125 22]);
            set(handles.run,'pos',[13 13+panelshift 255 22]);
            if trainOnRange
                set(handles.rangec,'Visible','on')
                set(handles.range1,'Visible','on')
                set(handles.range2,'Visible','on')
            else
                set(handles.rangec,'Visible','off')
                set(handles.range1,'Visible','off')
                set(handles.range2,'Visible','off')
            end
            if ishandle(handles.calculate)
                set(handles.calculate,'pos',[143 13+panelshift 125 22]);
            end
        end
    end

    function intfltchng_cbk(hObject, eventdata)
        if get(handles.filter,'Value')==1
            set(handles.adjustbtn,'Enable','off');
            set(handles.thres1,'Enable','on');
            if get(handles.colocalize,'Value'), set(handles.thres2,'Enable','on'); end
        else
            set(handles.adjustbtn,'Enable','on');
            set(handles.thres1,'Enable','off');
            set(handles.thres2,'Enable','off');
        end
    end
    function params_cbk(hObject, eventdata)
        if isfield(handles,'params') && ishandle(handles.params), return; end
        handles.params = figure('pos',[270 300 240 385],'Toolbar','none','Menubar','none','Name','spotFinder params','NumberTitle','off','IntegerHandle','off','Resize','off','CloseRequestFcn',@paramsclosereq,'Color',get(handles.outputpanel,'BackgroundColor'));
        uicontrol(handles.params,'units','pixels','Position',[5 360 140 16],'Style','text','String','Expand cell, px','HorizontalAlignment','right');
        uicontrol(handles.params,'units','pixels','Position',[5 340 140 16],'Style','text','String','Exclude other cells','HorizontalAlignment','right');
        uicontrol(handles.params,'units','pixels','Position',[5 320 140 16],'Style','text','String','Low cutoff, px','HorizontalAlignment','right');
        uicontrol(handles.params,'units','pixels','Position',[5 300 140 16],'Style','text','String','High cutoff, px','HorizontalAlignment','right');
        uicontrol(handles.params,'units','pixels','Position',[5 280 140 16],'Style','text','String','Min filtered height, i.u.','HorizontalAlignment','right');
        uicontrol(handles.params,'units','pixels','Position',[5 260 140 16],'Style','text','String','Shift limit','HorizontalAlignment','right');
        uicontrol(handles.params,'units','pixels','Position',[5 240 140 16],'Style','text','String','Fit area size, px','HorizontalAlignment','right');
        uicontrol(handles.params,'units','pixels','Position',[5 220 140 16],'Style','text','String','Resize, times','HorizontalAlignment','right');
        uicontrol(handles.params,'units','pixels','Position',[5 200 140 16],'Style','text','String','Remove ridges','HorizontalAlignment','right');
        uicontrol(handles.params,'units','pixels','Position',[5 180 140 16],'Style','text','String','Scale factor','HorizontalAlignment','right');
        uicontrol(handles.params,'units','pixels','Position',[5 160 142 16],'Style','text','String','Max width squared, px^2','HorizontalAlignment','right');
        uicontrol(handles.params,'units','pixels','Position',[5 140 140 16],'Style','text','String','Min width squared, px^2','HorizontalAlignment','right');
        uicontrol(handles.params,'units','pixels','Position',[5 120 140 16],'Style','text','String','Min height, i.u.','HorizontalAlignment','right');
        uicontrol(handles.params,'units','pixels','Position',[5 100 140 16],'Style','text','String','Max rel. sq. error','HorizontalAlignment','right');
        uicontrol(handles.params,'units','pixels','Position',[5 80 140 16],'Style','text','String','Max var/sq. height ratio','HorizontalAlignment','right');
        uicontrol(handles.params,'units','pixels','Position',[5 60 140 16],'Style','text','String','Min filtered/fitted ratio','HorizontalAlignment','right');
        
        handles.OK = uicontrol(handles.params,'units','pixels','Position',[6 6 230 18],'String','OK','Callback',@paramsclosereq);
        handles.OK = uicontrol(handles.params,'units','pixels','Position',[6 30 110 18],'String','Save','Callback',@saveparams);
        handles.OK = uicontrol(handles.params,'units','pixels','Position',[126 30 110 18],'String','Load','Callback',@loadparams);
        
        handles.dilateCount = uicontrol(handles.params,'units','pixels','Position',[155 360 70 17],'Style','edit','String','','BackgroundColor',[1 1 1]);
        handles.getnearest = uicontrol(handles.params,'units','pixels','Position',[182 340 30 17],'Style','checkbox','String','');
        handles.loCutoff = uicontrol(handles.params,'units','pixels','Position',[155 320 70 17],'Style','edit','String','','BackgroundColor',[1 1 1]);
        handles.hiCutoff = uicontrol(handles.params,'units','pixels','Position',[155 300 70 17],'Style','edit','String','','BackgroundColor',[1 1 1]);
        handles.minprefilterh = uicontrol(handles.params,'units','pixels','Position',[155 280 51 17],'Style','edit','String','','BackgroundColor',[1 1 1]);
        handles.minprefilterhchk = uicontrol(handles.params,'units','pixels','Position',[207 280 30 17],'String','Test','Callback',@minprefilterhchk_cbk);
        handles.shiftlim = uicontrol(handles.params,'units','pixels','Position',[155 260 70 17],'Style','edit','String','','BackgroundColor',[1 1 1]);
        handles.dmax = uicontrol(handles.params,'units','pixels','Position',[155 240 70 17],'Style','edit','String','','BackgroundColor',[1 1 1]);
        handles.resize = uicontrol(handles.params,'units','pixels','Position',[155 220 70 17],'Style','edit','String','','BackgroundColor',[1 1 1],'Enable','on'); % TODO: test before enabling
        handles.ridges = uicontrol(handles.params,'units','pixels','Position',[182 200 70 17],'Style','checkbox','String','');
        handles.scalefactor = uicontrol(handles.params,'units','pixels','Position',[155 180 70 17],'Style','edit','String','','BackgroundColor',[1 1 1],'Enable','on'); % TODO: test before enabling
        handles.wmax = uicontrol(handles.params,'units','pixels','Position',[155 160 70 17],'Style','edit','String','','BackgroundColor',[1 1 1]);
        handles.wmin = uicontrol(handles.params,'units','pixels','Position',[155 140 70 17],'Style','edit','String','','BackgroundColor',[1 1 1]);
        handles.hmin = uicontrol(handles.params,'units','pixels','Position',[155 120 70 17],'Style','edit','String','','BackgroundColor',[1 1 1]);
        handles.ef2max = uicontrol(handles.params,'units','pixels','Position',[155 100 70 17],'Style','edit','String','','BackgroundColor',[1 1 1]);
        handles.vmax = uicontrol(handles.params,'units','pixels','Position',[155 80 70 17],'Style','edit','String','','BackgroundColor',[1 1 1]);
        handles.fmin = uicontrol(handles.params,'units','pixels','Position',[155 60 70 17],'Style','edit','String','','BackgroundColor',[1 1 1]);
        
        setparams
    end
    function setparams
        if ~isfield(handles,'params') || ~ishandle(handles.params), return; end
        set(handles.dilateCount,'String',num2str(params.dilateCount));
        set(handles.getnearest,'Value',params.getnearest);
        set(handles.loCutoff,'String',num2str(params.loCutoff));
        set(handles.hiCutoff,'String',num2str(params.hiCutoff));
        set(handles.minprefilterh,'String',num2str(params.minprefilterh));
        set(handles.resize,'String',num2str(params.resize));
        set(handles.ridges,'Value',params.ridges);
        set(handles.scalefactor,'String',num2str(params.scalefactor));
        set(handles.wmax,'String',num2str(params.wmax));
        set(handles.wmin,'String',num2str(params.wmin));
        set(handles.dmax,'String',num2str(params.dmax));
        set(handles.hmin,'String',num2str(params.hmin));
        set(handles.ef2max,'String',num2str(params.ef2max));
        set(handles.vmax,'String',num2str(params.vmax));
        set(handles.fmin,'String',num2str(params.fmin));
        set(handles.shiftlim,'String',num2str(params.shiftlim));
    end

    function saveparams(hObject, eventdata)
        [FileName,pathname] = uiputfile('*.sfp', 'Select file to put parameters to',saveparamsFileName);
        if(FileName==0), stoprun; return; end;
        saveparamsFileName = fullfile(pathname,FileName);
        getparams
        save(saveparamsFileName,'params')
    end

    function loadparams(hObject, eventdata)
        [FileName,pathname] = uigetfile('*.sfp', 'Select file to get parameters from',saveparamsFileName);
        if(FileName==0), stoprun; return; end;
        saveparamsFileName = fullfile(pathname,FileName);
        l = load('-mat',saveparamsFileName,'params');
        if isfield(l,'params')
            params = l.params;
        else
            disp('Wrong file type or file does not comtain parameters')
        end
        setparams
    end

    function paramsclosereq(hObject, eventdata)
        getparams
        delete(handles.params);
    end

    function getparams
        params.dilateCount = str2num(get(handles.dilateCount,'String'));
        params.getnearest = get(handles.getnearest,'Value');
        params.loCutoff = str2num(get(handles.loCutoff,'String'));
        params.hiCutoff = str2num(get(handles.hiCutoff,'String'));
        params.minprefilterh = str2num(get(handles.minprefilterh,'String'));
        params.resize = str2num(get(handles.resize,'String'));
        params.ridges = get(handles.ridges,'Value');
        params.shiftlim = str2num(get(handles.shiftlim,'String'));
        params.scalefactor = str2num(get(handles.scalefactor,'String'));
        params.wmax = str2num(get(handles.wmax,'String'));
        params.wmin = str2num(get(handles.wmin,'String'));
        params.dmax = str2num(get(handles.dmax,'String'));
        params.hmin = str2num(get(handles.hmin,'String'));
        params.ef2max = str2num(get(handles.ef2max,'String'));
        params.vmax = str2num(get(handles.vmax,'String'));
        params.fmin = str2num(get(handles.fmin,'String'));
    end

    function minprefilterhchk_cbk(hObject, eventdata)
        [filename,pathname] = uigetfile('*.*','Select image file to test',spotFinderMFCFile);
        if isequal(filename,0), return; end
        spotFinderMFCFile = fullfile(pathname,filename);
        getparams
        img = imread(spotFinderMFCFile);
        cimage0 = im2double(img);
        cimage0 = imresize(cimage0,params.resize);
        cimageF = filterimage(cimage0);
        if params.minprefilterh>0
            cimageF = cimageF.*(cimageF>params.minprefilterh);
        end
        figure('Name',['Filtered image, min height ' num2str(params.minprefilterh)])
        imshow(cimageF,[])
        colormap jet
        set(gca,'pos',[0 0 1 1])
    end

    function checkchange_cbk(hObject, eventdata)
        if hObject==handles.outmesh && get(handles.outmesh,'Value')==1
            set(handles.outscreen,'Enable','on')
            set(handles.outfile,'Enable','on')
        elseif hObject==handles.outmesh && get(handles.outmesh,'Value')==0
            set(handles.outscreen,'Enable','off')
            set(handles.outfile,'Enable','off')
        end

        if hObject==handles.outmesh && get(handles.outmesh,'Value')==1 && get(handles.outfile,'Value')==0
            set(handles.outscreen,'Value',1)
        elseif hObject==handles.outfile && get(handles.outscreen,'Value')==0 && get(handles.outfile,'Value')==0
            set(handles.outfile,'Value',1)
        end
        
        if hObject==handles.outimg && get(handles.outimg,'Value')==1
            set(handles.outsaveimg,'Enable','on')
            set(handles.outshowmesh,'Enable','on')
        elseif hObject==handles.outimg && get(handles.outimg,'Value')==0
            set(handles.outsaveimg,'Enable','off')
            set(handles.outsaveimg,'Value',0)
            set(handles.outshowmesh,'Enable','off')
            set(handles.outshowmesh,'Value',0)
        end
        
        if hObject==handles.normpanel && get(handles.norm1,'Value')==0
            set(handles.normM,'Enable','on');
        elseif hObject==handles.normpanel && get(handles.norm1,'Value')==1
            set(handles.normM,'Enable','off');
        end

    end

    function stoprun(hObject, eventdata)
        set(handles.parambtn,'Style','pushbutton','String','Params','Callback',@params_cbk);
        set(handles.adjustbtn,'Style','pushbutton','String','Adjust','Callback',@run_cbk);
        set(handles.run,'Style','pushbutton','Position',[13 13+panelshift 255 22],'String','Run','Callback',@run_cbk);
        if ishandle(handles.calculate), delete(handles.calculate); end
        set(handles.range1,'Enable','on')
        set(handles.range2,'Enable','on')
        if ~isempty(w) && ishandle(w), close(w); end
        if isfield(handles,'fig')&&ishandle(handles.fig), delete(handles.fig); end
    end
    function stop_cbk(hObject, eventdata)
        a = 'Yes';
        if isfield(handles,'params') && ishandle(handles.params), a = questdlg('Update parameters?','Question','Yes','No','Yes'); end
        if strcmp(a,'Yes')
            [params,spotList] = adjustparams(spotList,params);
            setparams
            disp('Exiting adjusting mode. Parameters updated.')
        else
            disp('Exiting adjusting mode. Parameters NOT updated.');
        end
        if ishandle(handles.maingui), set(handles.maingui,'UserData',0); end
        stoprun
    end
    function next_cbk(hObject, eventdata)
        set(handles.maingui,'UserData',1);
    end
    function prev_cbk(hObject, eventdata)
        set(handles.maingui,'UserData',-1);
    end

    function help_cbk(hObject, eventdata)
        folder = fileparts(which('spotFinderZ.m'));
        w = fullfile2(folder,'help','helpSpotFinder.htm');
        if ~isempty(w)
            web(w);
        end
    end

    function run_cbk(hObject, eventdata)
        if hObject==handles.adjustbtn
            adjustmode = true;
            set(handles.parambtn,'String','Previous','Callback',@prev_cbk);
            set(handles.adjustbtn,'String','Next','Callback',@next_cbk);
            set(handles.run,'Style','pushbutton','Position',[13 13+panelshift 125 22],'String','Stop','Callback',@stop_cbk);
            set(handles.range1,'Enable','off')
            set(handles.range2,'Enable','off')
            handles.calculate = uicontrol(handles.maingui,'units','pixels','Position',[143 13+panelshift 125 22],'String','Update params','Callback',@calc_cbk,'KeyPressFcn',@mainkeypress);
        else
            adjustmode = false;
        end
        inputType = 4;% removed input
        normType = get(handles.norm1,'Value') + 2*get(handles.norm2,'Value') + 3*get(handles.norm3,'Value') + 4*get(handles.norm4,'Value');
        normMesh = ~get(handles.norm1,'Value') && get(handles.normM,'Value');
        normF = str2num(get(handles.normF,'String'));
        outimg = get(handles.outimg,'Value');
        saveImg = get(handles.outsaveimg,'Value') && get(handles.outimg,'Value');
        showMesh = get(handles.outshowmesh,'Value') && get(handles.outimg,'Value');
        outfile = get(handles.outfile,'Value') && get(handles.outmesh,'Value');
        outscreen = get(handles.outscreen,'Value') && get(handles.outmesh,'Value');
        outfield = get(handles.outfield,'String');
        
%% Ask to input images and meshes
        disp(' ')
        if get(handles.loadstack,'Value')
            if bformats
                [filename,pathname] = uigetfile('*.*','Select file with signal images',spotFinderImageFile);
            else
                [filename,pathname] = uigetfile({'*.tif';'*.tiff'},'Select file with signal images',spotFinderImageFile);
            end
            if isempty(filename)||isequal(filename,0), stoprun; return, end
            spotFinderImageFile = fullfile2(pathname,filename);
            images = loadimagestack(spotFinderImageFile,1);
        else
            folder = uigetdir(FirstFolder,'Select folder with signal images');
            if isempty(folder)||isequal(folder,0), stoprun; return, end
            images = loadimageseries(folder,1);
            FirstFolder = folder;
        end
        L1 = size(images,3);
        pause(0.1);
        try
            [FileName,PathName] = uigetfile2('*.mat','Select file with signal meshes',signalMeshFileName);
        catch
            stoprun;
        end
        if isempty(FileName)||isequal(FileName,0), stoprun; return, end
        signalMeshFileName = [PathName '/' FileName];
        try
            load(signalMeshFileName,'cellList');
        catch
            stoprun;
        end
        if length(cellList)>size(images,3), cellList = cellList(1:size(images,3)); end
        if length(cellList)<size(images,3), for i=length(cellList):size(images,3), cellList{i}=[]; end; end
        
%% Asking for image names if images need to be saved
        if saveImg && ~adjustmode
            [FileName,pathname] = uiputfile('*.tif', 'Enter a filename for the first image',fileparts(signalMeshFileName));
            if(FileName==0), stoprun; return; end;
            if length(FileName)>4 && strcmp(FileName(end-3:end),'.tif'), FileName = FileName(1:end-4); end
            lng = size(images,3);
            ndig = ceil(log10(lng+1));
            istart = 1;
            for k=1:ndig
                if length(FileName)>=k && ~isempty(str2num(FileName(end-k+1:end)))
                    istart = str2num(FileName(end-k+1:end));
                else
                    k=k-1; %#ok<FXSET>
                    break
                end
            end
            outFileNameImg = [pathname, '/', FileName(1:end-k)];
        end
        
%% Ask for the output file name
        if outfile
            [FileName,PathName] = uiputfile('*.mat', 'Enter a filename to save the mesh to',signalMeshFileName);
            targetMeshFileName = [PathName '/' FileName];
        end
        
%% Get frame range
        if trainOnRange % && adjustmode
            range1 = str2num(get(handles.range1,'String'));
            if isempty(range1), range1 = 1; end
            range2 = str2num(get(handles.range2,'String'));
            if isempty(range2), range2 = L1; end
        else
            range1 = 1;
            range2 = L1;
        end
        framerange = [];
        for r = range1:range2
            if r<=length(cellList) && ~isempty(cellList{r})
                framerange = [framerange r];
            end
        end
        if isempty(framerange), return; end
        
%% Obtaining normalization data
        s2 = strel('disk',params.dilateCount);
        if ismember(normType,[2 3 4])
            signal = 0;
            area = 0;
            for frame=framerange
                cimage = im2double(images(:,:,frame));
                cimage = imresize(cimage,params.resize);
                for cell = 1:length(cellList{frame})
                    if ~isempty(cellList{frame}{cell}) && length(cellList{frame}{cell}.mesh)>1
                        if normMesh
                            a = cellList{frame}{cell}.area;
                            s = sum(cellList{frame}{cell}.signal1);
                        else
                            mesh = cellList{frame}{cell}.mesh;
                            box = cellList{frame}{cell}.box;
                            imgR = imcrop(cimage,box);
                            plgx = ([mesh(1:end-1,1);flipud(mesh(:,3))]-box(1)+1)*params.resize;
                            plgy = ([mesh(1:end-1,2);flipud(mesh(:,4))]-box(2)+1)*params.resize;
                            mask = imdilate(poly2mask(plgx,plgy,size(imgR,1),size(imgR,2)),s2);
                            s = sum(sum(mask));
                            a = polyarea(plgx,plgy);
                            if s>0, s = sum(sum(mask.*imgR))*a/s; end
                        end
                        if normType==2 % cell normalization
                            eval(['cellList{frame}{cell}.' outfield '.norm = a/s;']);
                        end
                        signal = signal + s;
                        area = area + a;
                    end
                end
                if normType==3 % frame normalization
                    for cell = 1:length(cellList{frame})
                        if ~isempty(cellList{frame}{cell}) && length(cellList{frame}{cell}.mesh)>1
                            eval(['cellList{frame}{cell}.' outfield '.norm = area/signal;']);
                        end
                    end
                    signal = 0;
                    area = 0;
                end
            end
            if normType==4 % stack normalization
                for frame=framerange
                    for cell = 1:length(cellList{frame})
                        if ~isempty(cellList{frame}{cell}) && length(cellList{frame}{cell}.mesh)>1
                            eval(['cellList{frame}{cell}.' outfield '.norm = area/signal;']);
                        end
                    end
                end
            end
        end
                        
        
%% Filtering and integrating images
        positions = {};
        Ncells1 = 0;
        Ncells2 = 0;
        Nspotstotal1 = 0; % Raw spots count
        Ispotstotal1 = 0; % Raw spots total intensity
        Nspotstotal2 = 0; % Good spots count
        Ispotstotal2 = 0; % Good spots total intensity
        msize = 1.5; % Prefilter range, must be >0
        x = repmat(1:ceil(msize)*2+1,ceil(msize)*2+1,1);
        y = repmat((1:ceil(msize)*2+1)',1,ceil(msize)*2+1);
        prefilter = exp(-((ceil(msize)+1-x).^2 + (ceil(msize)+1-y).^2) / msize^2);
        prefilter = prefilter/sum(sum(prefilter));
        
        if ~adjustmode
            w = waitbarN(0, 'Filtering / integrating images');
            for frame=framerange
                convertimages
                Ispotstotal1 = Ispotstotal1 + sum(sum(cimageF));
                Nspotstotal1 = Nspotstotal1 + sum(sum(cimageF>0));
                if params.getnearest, dmap = getdmap(cellList{frame},[],size(cimage),params.resize,ceil(params.dilateCount*1.5)); end
                for cell = 1:length(cellList{frame})
                    if ~isempty(cellList{frame}{cell}) && length(cellList{frame}{cell}.mesh)>1
                        Ncells1 = Ncells1 + 1;
                        % Get the data for all methods
                        if isfield(cellList{frame}{cell},outfield) && isfield(cellList{frame}{cell}.spots,outfield)
                            eval(['norm = cellList{frame}{cell}.' outfield '.norm;']);
                        else
                            norm = 1;
                        end
                        mesh = cellList{frame}{cell}.mesh;
                        box = cellList{frame}{cell}.box;
                        imgF = imcrop(cimageF,box)*norm;
                        imgR = imcrop(cimage,box)*norm;
                        plgx = ([mesh(1:end-1,1);flipud(mesh(:,3))]-box(1)+1)*params.resize;
                        plgy = ([mesh(1:end-1,2);flipud(mesh(:,4))]-box(2)+1)*params.resize;
                        if params.getnearest
                            dmapmsk = imcrop(dmap,box)>=...
                                      getdmap(cellList{frame}{cell},box,size(imgF),params.resize,ceil(params.dilateCount*1.5));
                        else
                            dmapmsk = [];
                        end
                        
                        % Parameters
                        scalefactor = params.scalefactor;
                        dmax = floor(params.dmax*scalefactor);

                        % Do fitting, keep only good spots
                        [spotlist,mask] = getspots(plgx,plgy,imgF,imgR,s2,dmax,dmapmsk);
                        %background/width/hight/sq.error/per.variance/filtered2fitted-ratio/exit
                        lst = getcorrectspots(spotlist,params);
                        spotlist2 = spotlist(lst,:);
                        spotlist3 = getspots2(spotlist2,imgR,mask,params.wmax*params.scalefactor,dmax,params.shiftlim);
                        %background/width/hight/sq.error/0/0/exit
                        %lst = getcorrectspots(spotlist3,params);
                        %spotlist3 = spotlist3(lst,:);
                        % if isempty(spotlist3), continue; end % no spots array for no spots

                        % Saving data
                        Ly = size(spotlist3,1);
                        if ~isempty(spotlist3)
                            spint = pi*spotlist3(:,2).*spotlist3(:,3); % spot intensities (pi*height*width^2)
                            X = spotlist3(:,8);
                            Y = spotlist3(:,9);
                            spb = spotlist3(:,1);
                            spw = sqrt(max(0,spotlist3(:,2)));
                            sph = spotlist3(:,3);
                        else
                            spint = [];
                            X = [];
                            Y = [];
                            spb = [];
                            spw = [];
                            sph = [];
                        end
                        Nspotstotal2 = Nspotstotal2 + Ly;
                        Ispotstotal2 = Ispotstotal2 + sum(spint);
                        stplng = cellList{frame}{cell}.steplength;
                        xarray = reshape(box(1)-1+Y,1,[]); % switch x and y
                        yarray = reshape(box(2)-1+X,1,[]); % switch x and y
                        larray = [];
                        darray = [];
                        iarray = [];
                        for sp = 1:Ly
                            i = Y(sp); % switch x and y
                            j = X(sp); % switch x and y
                            [l,d]=projectToMesh(box(1)-1+i,box(2)-1+j,mesh,stplng);
                            % d here is the distance to the backbone, currently unsigned
                            larray = [larray l];
                            darray = [darray d];
                            I = 0;
                            for k=1:size(mesh,1)-1
                                plgx = [mesh(k,[1 3]) mesh(k+1,[3 1])]-box(1)+1;
                                plgy = [mesh(k,[2 4]) mesh(k+1,[4 2])]-box(2)+1;
                                if inpolygon(i,j,plgx,plgy)
                                    I = k;
                                    break
                                end
                            end
                            iarray = [iarray I];
                        end
                        [slarray,IX] = sort(larray);
                        spots.l = slarray/params.resize;
                        spots.magnitude = reshape(spint(IX),1,[])/params.resize^2;
                        spots.w = reshape(spw(IX),1,[])/params.resize^2;
                        spots.h = reshape(sph(IX),1,[])/params.resize^2;
                        spots.b = reshape(spb(IX),1,[])/params.resize^2;
                        spots.d = darray(IX)/params.resize;
                        spots.x = xarray(IX)/params.resize;
                        spots.y = yarray(IX)/params.resize;
                        spots.positions = iarray(IX);
                        if outfile||outscreen||outimg
                            eval(['cellList{frame}{cell}.' outfield ' = spots;']);
                        end
                        if ~isempty(larray)
                            Ncells2 = Ncells2 + 1;
                        end

                        % Waitbar
                        waitbar((frame-1)/(L1),w,['Detecting spots, frame ' num2str(frame) ' cell ' num2str(cell)]);
                    end
                end % for cell=1:length(cellList{frame})
                [row,col,v] = find(cimageF);
                positions{frame} = [row,col,v];
                waitbar(frame/(L1),w);
            end % for frame=framerange
            disp(['Filtering/integration finished, processed ' num2str(L1) ' images']);
            disp(['Identified ' num2str(Nspotstotal1) ' non-normalized non-thresholded spots in ' num2str(Ncells1) ' cells']);
            disp(['Identified ' num2str(Nspotstotal2) ' positively identified spots in ' num2str(Ncells2) ' cells']);
            disp(['Mean magnitude of ''good'' spots: ' num2str(Ispotstotal2/Nspotstotal2)]);
        end
        
        if adjustmode
            lst = []; spotlist = [];
            h=createfigure; 
            handles.fig=h.fig;
            spotList = {};
            frind=1;
            frame=framerange(frind);
            cell = 0;
            goup = true;
            convertimages
            while true
                while true
                    if goup
                        cell=cell+1;
                        if cell==length(cellList{frame})+1
                            frind=mod(frind,length(framerange))+1;
                            frame=framerange(frind);
                            cell=1;
                            convertimages
                        end
                    else
                        cell=cell-1;
                        if cell<=0
                            frind=mod(frind-2,length(framerange))+1;
                            frame=framerange(frind);
                            cell=length(cellList{frame});
                            convertimages
                        end
                    end
                    if ~isempty(cellList{frame}) && ~isempty(cellList{frame}{cell}) && length(cellList{frame}{cell}.mesh)>1, break; end
                end
                if ~isempty(cellList{frame}{cell}) && length(cellList{frame}{cell}.mesh)>1
                    % Get the data for all methods
                    if isfield(cellList{frame}{cell},outfield) && isfield(cellList{frame}{cell}.spots,outfield)
                        eval(['norm = cellList{frame}{cell}.' outfield '.norm;']);
                    else
                        norm = 1;
                    end
                    mesh = cellList{frame}{cell}.mesh;
                    box = cellList{frame}{cell}.box;
                    imgF = imcrop(cimageF,box)*norm;
                    imgR = imcrop(cimage,box)*norm;
                    img0 = imcrop(cimage0,box)*norm;
                    plgx = [mesh(1:end-1,1);flipud(mesh(:,3))]-box(1)+1;
                    plgy = [mesh(1:end-1,2);flipud(mesh(:,4))]-box(2)+1;

                    % Parameters
                    scalefactor=params.scalefactor;
                    dmax = floor(params.dmax*scalefactor);

                    % Do fitting, keep only good spots
                    if ~isempty(spotList) && frame<=length(spotList) && ~isempty(spotList{frame}) ...
                            && cell<=length(spotList{frame}) && ~isempty(spotList{frame}{cell}) ...
                            && ~spotList{frame}{cell}.processed
                        spotlist = spotList{frame}{cell}.spotlist;
                        lst = spotList{frame}{cell}.lst;
                        disp(['Frame ' num2str(frame) ' cell ' num2str(cell) ', recorded spots displayed'])
                    else
                        spotlist = getspots(plgx,plgy,imgF,imgR,s2,dmax,[]);
                        %background/width/hight/sq.error/per.variance/filtered2fitted-ratio/exit
                        lst = getcorrectspots(spotlist,params);
                        spotList{frame}{cell}.spotlist = spotlist;
                        spotList{frame}{cell}.lst = lst;
                        spotList{frame}{cell}.processed = false;
                        disp(['Frame ' num2str(frame) ' cell ' num2str(cell) ', ' num2str(sum(lst)) '/' num2str(length(lst)) ' spots identified'])
                        %disp(spotlist)
                        %disp(find(lst))
                    end
                    h=dispspots(img0,spotlist,plgx,plgy,lst,h,frame,cell);
                    
                    while true
                        set(handles.maingui,'UserData',[]);
                        waitfor(handles.maingui,'UserData');
                        if ~ishandle(handles.maingui), return; end
                        u = get(handles.maingui,'UserData');
                        set(handles.maingui,'UserData',[]);
                        if u==0
                            return
                        elseif u==1
                            goup = true;
                            break
                        elseif u==-1
                            goup = false;
                            break
                        end
                    end
                end
            end % frame
            stoprun
        end
        
        function convertimages
            cimage0 = im2double(images(:,:,frame));
            cimage0 = imresize(cimage0,params.resize);
            cimageF = filterimage(cimage0);
            if params.minprefilterh>0
                cimageF = cimageF.*(cimageF>params.minprefilterh);
            end
            cimage  = imfilter(cimage0,prefilter,'replicate');
        end
        
%% Finding all spots regardless of the cells
        % if outimpos
        %     assignin('base','positions',positions);
        % end

%% Displaying and saving images
        if outimg==1 && ~adjustmode
            for frame=framerange
                figure
                if normType==1, s=', not normalized';
                elseif normType==2, s=', normalized by cell mean intensity';
                elseif normType==3, s=', normalized by frame mean intensity';
                elseif normType==4, s=', normalized by stack mean intensity';
                end
                img = images(:,:,frame);
                imshow(img,[])
                img2 = img*0;
                if exist('cellList','var')==1
                    mgn = [];
                    xpos = [];
                    ypos = [];
                    str = [];
                    for cell = 1:length(cellList{frame})
                        if ~isempty(cellList{frame}{cell}) && length(cellList{frame}{cell}.mesh)>1 && isfield(cellList{frame}{cell},outfield)
                            eval(['str = cellList{frame}{cell}.' outfield ';']);
                            mgn = [mgn str.magnitude];
                            xpos = [xpos str.x];
                            ypos = [ypos str.y];
                        end
                    end
                    if max(mgn)>1, mgn=mgn/max(mgn); end
                    hold on
                    if showMesh
                        for cell = 1:length(cellList{frame})
                            if ~isempty(cellList{frame}{cell}) && length(cellList{frame}{cell}.mesh)>1
                                mesh = cellList{frame}{cell}.mesh;
                                color = [0 1 0];
                                plot(mesh(:,1),mesh(:,2),mesh(:,3),mesh(:,4),'Color',color)
                                e = round(size(mesh,1)/2);
                                text(round(mean([mesh(e,1);mesh(e,3)])),round(mean([mesh(e,2);mesh(e,4)])),...
                                    num2str(cell),'HorizontalAlignment','center','FontSize',7,'color',color);
                            end
                        end
                    end
                    for i=1:length(mgn)
                        img2(min(size(img,1),max(1,round(ypos(i)))),min(size(img,2),max(1,round(xpos(i))))) = mgn(i)*intmax(class(img));
                        plot(xpos(i),ypos(i),'.','color',[mgn(i) 0 1-mgn(i)],'markersize',15)
                    end
                    hold off
                end
                warning off
                title(['Image ' num2str(frame) ' of ' num2str(L1) s])
                if saveImg
                    fnum = frame+istart-1;
                    cfilename = [outFileNameImg num2str(fnum,['%.' num2str(ndig) 'd']) '.tif'];
                    imwrite(img2,cfilename,'tif','Compression','none');
                end
                warning on
            end
        end

%% Saving data
        if outscreen, assignin('base','cellList',cellList); disp('Data was written to cellList array'); end
        if outfile
            if ~strcmp(signalMeshFileName,targetMeshFileName)
                copyfile(signalMeshFileName,targetMeshFileName,'f');
            end
            save(targetMeshFileName,'params','cellList','-append')
        end
        close(w);
% End of run_cbk function code
        
%% Nested functions
        function h=createfigure
            h.fig = figure('WindowButtonDownFcn',@selectclick,'KeyPressFcn',@figurekeypress,'CloseRequestFcn',@figureclosereq);
            % g = get(h.fig,'children');
            % delete(g);
            % h.ax = axes;
            s = get(h.fig,'pos');
            s = [s(1:2)-round(s(3:4)/2)-200 400 400];
            set(h.fig,'pos',s)
        end
        function calc_cbk(hObject, eventdata)
            [params,spotList] = adjustparams(spotList,params);
            setparams
        end
        function figureclosereq(hObject, eventdata)
            delete(h.fig);
            stop_cbk(hObject, eventdata)
        end
        function figurekeypress(hObject, eventdata)
            c = get(h.fig,'CurrentCharacter');
            if isempty(c)
                return;
            elseif double(c)==28 % left arrow - go to previous cell
                set(handles.maingui,'UserData',-1);
            elseif double(c)==29 % right arrow - go to next cell
                set(handles.maingui,'UserData',1);
            elseif double(c)==27 % ESC - stop
                set(handles.maingui,'UserData',0);
                stoprun;
            elseif double(c)==97 % 'a' - adjust contrast
                imcontrast(h.ax)
            end
        end
        function selectclick(hObject, eventdata)
            if ~ishandle(h.fig) ||  ~ishandle(h.ax) || isempty(spotlist), return; end
            ps = get(h.ax,'CurrentPoint');
            xlimit = get(h.ax,'XLim');
            ylimit = get(h.ax,'YLim');
            x = ps(1,1);
            y = ps(1,2);
            if x<xlimit(1) || x>xlimit(2) || y<ylimit(1) || y>ylimit(2), return; end
            dst = (y-spotlist(:,8)).^2+(x-spotlist(:,9)).^2;
            [mindst,minind] = min(dst);
            if mindst>mean(xlimit(2)-xlimit(1),ylimit(2)-ylimit(1))^2/10, return; end
            lst(minind) = ~lst(minind);
            spotList{frame}{cell}.lst(minind) = lst(minind);
            if lst(minind)
                set(h.spots(minind),'Color',[1 0.1 0]);
                disp('Selected spot:')
            else
                set(h.spots(minind),'Color',[0 0.8 0]);
                disp('Unselected spot:')
            end
            spotlist = spotList{frame}{cell}.spotlist;
            disp([' background: ' num2str(spotlist(minind,1))])
            disp([' squared width: ' num2str(spotlist(minind,2))])
            disp([' heigth: ' num2str(spotlist(minind,3))])
            disp([' relative squared error: ' num2str(spotlist(minind,4))])
            disp([' perimeter variance: ' num2str(spotlist(minind,5))])
            disp([' filtered/unfiltered ratio: ' num2str(spotlist(minind,6))])
        end
        function h = dispspots(img0,spotlist,plgx,plgy,lst,h,frame,spots)
            g = get(h.fig,'children');
            p = get(h.fig,'pos');
            set(h.fig,'Name',['Frame ' num2str(frame) ' cell ' num2str(cell)])
            p4old = p(4);
            p(4)=ceil(p(3)*size(img0,1)/size(img0,2));
            if p(2)+p4old-p(4)<0, scale=(p(2)+p4old)/p(4); p(3:4)=p(3:4)*scale; end
            p(2)=p(2)+p4old-p(4);
            delete(g);
            h.ax = axes('parent',h.fig);
            imshow(img0,[],'parent',h.ax)
            set(h.ax,'pos',[0 0 1 1],'NextPlot','add')
            plot(h.ax,plgx,plgy,'Color',[0 0.7 0])
            h.spots = [];
            for q=1:length(lst)
                if lst(q)
                    color = [1 0.1 0];
                else
                    color = [0 0.8 0];
                end
                spt = plot(h.ax,spotlist(q,9),spotlist(q,8),'.','Color',color);
                h.spots = [h.spots spt];
            end
            set(h.ax,'pos',[0 0 1 1],'NextPlot','replace')
            set(h.fig,'pos',p)
        end
    end

    function res = filterimage(img)
        img2 = img;% im2double(imread(['C:\Documents and Settings\Oleksii\Desktop\Audrey''s mRNA\gfps\0' num2str(k,'%02.2d') '.tif']));
        img2a = bpass(img2,params.loCutoff,params.hiCutoff);
        img2b = img2a;%imfilter(img2a,fspecial('disk',1));
        % img2b0 = img2b;
        % box = [693   646    63    71];
        img2c = repmat(img2b,[1 1 4]);
        if params.ridges
            for j=1:4, img2c(:,:,j) = img2b-imopen(img2b,se{j}); end
            img2b = min(img2c,[],3);
            img2b = bpass(img2b,params.loCutoff,params.hiCutoff);
        end
        res = img2b.*(imdilate(img2b,strel('arbitrary',[1 1 1; 1 1 1; 1 1 1]))==img2b).*(imerode(img2b,strel('disk',1))<img2b);
        % if integrmethod==2
        %     img2 = imfilter(img,disk);
        %     res = img2.*(res>0);
        % end
    end
end

%% Global functions
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

function res = bpass(image_array,lnoise,lobject)
    % Code 'bpass.pro' by John C. Crocker and David G. Grier (1997).
    % All comments are removed, see separate file version for details

    normalize = @(x) x/sum(x);

    image_array = double(image_array);
    r = -round(lobject):round(lobject);
    if lnoise>0, gaussian_kernel = normalize(exp(-(r/(2*lnoise)).^2)); else gaussian_kernel = double(r==0); end
    boxcar_kernel = normalize(ones(1,length(r)));

    gconv = conv2(image_array',gaussian_kernel','same');
    gconv = conv2(gconv',gaussian_kernel','same');

    bconv = conv2(image_array',boxcar_kernel','same');
    bconv = conv2(bconv',boxcar_kernel','same');

    filtered = gconv - bconv;

    filtered(1:(round(lobject)),:) = 0;
    filtered((end - lobject + 1):end,:) = 0;
    filtered(:,1:(round(lobject))) = 0;
    filtered(:,(end - lobject + 1):end) = 0;

    res = max(filtered,0);
end

function w=waitbarN(n,s)
    w = waitbar(n,s);
    p = rand^2;
    q = sin(rand*2*pi);
    color = [p (1-p)*q^2 (1-p)*(1-q^2)];
    set(findobj(w,'Type','patch'),'FaceColor',color,'EdgeColor',color)
    set(findobj(w,'Type','axes'),'Children',get(findobj(w,'Type','axes'),'Children'))
end

function dangle = cellangle(mesh1,mesh2)
    angle1 = angle(mesh1(1,1)-mesh1(end,1)+j*(mesh1(1,2)-mesh1(end,2)));
    angle2 = angle(mesh2(1,1)-mesh2(end,1)+j*(mesh2(1,2)-mesh2(end,2)));
    dangle = abs(mod(angle1-angle2+pi,2*pi)-pi);
end

function str = reorient(str)
    if isfield(str,'mesh'), str.mesh = flipud(str.mesh); end
    if isfield(str,'steplength'), str.steplength = flipud(str.steplength); end
    if isfield(str,'lengthvector'), str.lengthvector = flipud(str.lengthvector); end
    if isfield(str,'steparea'), str.steparea = flipud(str.steparea); end
    if isfield(str,'stepvolume'), str.stepvolume = flipud(str.stepvolume); end
    if isfield(str,'polarspots1'), str.polarspots1 = fliplr(str.polarspots1); end
    if isfield(str,'polarspots2'), str.polarspots2 = fliplr(str.polarspots2); end
    if isfield(str,'signal0'), str.signal0 = flipud(str.signal0); end
    if isfield(str,'signal1'), str.signal0 = fliplr(str.signal1); end
    if isfield(str,'signal2'), str.signal0 = fliplr(str.signal2); end
    if isfield(str,'polarity'), str.polarity = ~str.polarity; end
end

function B = im2double2(A)
    B = zeros(size(A),'double');
    for i=1:size(A,3)
        B(:,:,i) = im2double(A(:,:,i));
    end
end

function [spotlist,mask] = getspots(plgx,plgy,imgF,imgR,s2,dmax,dmapmsk)
    mask = imdilate(poly2mask(plgx,plgy,size(imgF,1),size(imgF,2)),s2);
    if ~isempty(dmapmsk)
        mask = mask.*dmapmsk;
    end
    [row,col] = find(imgF.*mask);
    Y = col;
    X = row;
    Ly = length(row);
    spotlist = zeros(Ly,7);

    msk = zeros(dmax*2-1);
    msk(dmax,dmax)=1;
    msk = imdilate(msk,strel('disk',dmax));
    D2 = repmat(reshape((-dmax+1):(dmax-1),1,[]),2*dmax-1,1).^2 +...
         repmat(reshape((-dmax+1):(dmax-1),[],1),1,2*dmax-1).^2;

    % 1st fit - fixed positions, individual spots
    for sp = 1:Ly
        % Prepare matrices for minimization
        box1(1:2) = max([Y(sp) X(sp)]-dmax+1,1);
        box1(3:4) = min([Y(sp) X(sp)]+dmax-1,[size(imgR,2) size(imgR,1)])-box1(1:2);
        box2(1:2) = max(0,dmax-[Y(sp) X(sp)])+1;
        box2(3:4) = box1(3:4);
        img2 = imcrop(imgR,box1);
        msk2 = imcrop(msk,box2).*imcrop(mask,box1);
        mskp = bwperim(imcrop(msk,box2));
        dst2 = imcrop(D2,box2);
        % Assign data
        dat = [mean(mean(img2)) dmax max(0,img2(dmax-max(0,dmax-X(sp)),dmax-max(0,dmax-Y(sp)))-mean(mean(img2)))];
        % Do minimization
        options = optimset('Display','off','MaxIter',300);
        [dat,fval,exitflag] = fminsearch(@gfit,dat,options);
        % Save for later
        spotlist(sp,1) = dat(1); % background
        spotlist(sp,2) = dat(2); % squared width of the spots
        spotlist(sp,3) = dat(3); % hight
        spotlist(sp,4) = gfit(dat)/(dat(3)^2); % rel. sq. error
        spotlist(sp,5) = var(imgR(mskp))/(dat(3)^2); % perimeter variance
        spotlist(sp,6) = imgF(X(sp),Y(sp))/dat(3); % filtered/fitted ratio
        spotlist(sp,7) = exitflag; % exit -1 / 0 / 1
        spotlist(sp,8) = X(sp);
        spotlist(sp,9) = Y(sp);
        
    end
    function res = gfit(in)
        % also uses:
        % ls (list of spots to fit)
        % wf - squared width of the spots, only those for ~ls are used
        % hf - hight of the spots
        % in = [b wv(1:n) hv(1:n)]
        b = in(1);
        wv = in(2);
        hv = in(3);
        M = b + exp(-dst2/wv)*hv;
        R = (msk2.*(M - img2)).^2;
        res = sum(sum(R));
        if b<0, res=res+(b/hv)^2; end
    end
end
function spotlist2 = getspots2(spotlist,imgR,mask,wmax,dmax,shiftlim)
    if isempty(spotlist); spotlist2 = []; return; end
    X = spotlist(:,8);
    Y = spotlist(:,9);
    m = size(imgR,1);
    n = size(imgR,2);
    Ly = size(spotlist,1);
    Xm = repmat(reshape(X,[1 1 Ly]),m,n);
    Ym = repmat(reshape(Y,[1 1 Ly]),m,n);
    Ix2 = repmat((1:m)',[1 n]);
    Iy2 = repmat(1:n,[m 1]);
    wf = spotlist(:,2);
    hf = spotlist(:,3);
    bf = spotlist(:,1);
    % bf = mean(b);
    Ix3 = repmat((1:m)',[1 n Ly-1]);
    Iy3 = repmat(1:n,[m 1 Ly-1]);
    spotlist2 = zeros(size(spotlist));
    msk = zeros(dmax*2-1);
    msk(dmax,dmax)=1;
    msk = imdilate(msk,strel('disk',dmax));
    D2 = repmat(reshape((-dmax+1):(dmax-1),1,[]),2*dmax-1,1).^2 +...
         repmat(reshape((-dmax+1):(dmax-1),[],1),1,2*dmax-1).^2;
    % 2nd fit - flexible positions
    for q = 1:2
        for sp = 1:Ly
            % Assign variable data
            box1(1:2) = max([Y(sp) X(sp)]-dmax+1,1);
            box1(3:4) = min([Y(sp) X(sp)]+dmax-1,[size(imgR,2) size(imgR,1)])-box1(1:2);
            box2(1:2) = max(0,dmax-[Y(sp) X(sp)])+1;
            box2(3:4) = box1(3:4);
            img2 = imcrop(imgR,box1);
            msk2 = imcrop(msk,box2).*imcrop(mask,box1);
            dst2 = imcrop(D2,box2);
            dat = [bf(sp) wf(sp) hf(sp) X(sp) Y(sp)];
            % Assign fixed data
            ls = true(1,Ly);
            ls(sp) = false;
            W = repmat(reshape(wf(ls),[1 1 Ly-1]),m,n);
            H = repmat(reshape(hf(ls),[1 1 Ly-1]),m,n);
            Xm3 = repmat(reshape(X(ls),[1 1 Ly-1]),m,n);
            Ym3 = repmat(reshape(Y(ls),[1 1 Ly-1]),m,n);
            D3 = (Xm3-Ix3).^2 + (Ym3-Iy3).^2;
            M0 = sum(exp(-D3./W).*H,3);
            % Do minimization
            options = optimset('Display','off','MaxIter',300);
            [dat,fval,exitflag] = fminsearch(@gfitpos,dat,options);
            bf(sp) = dat(1);
            wf(sp) = dat(2);
            hf(sp) = dat(3);
            X(sp) = dat(4);
            Y(sp) = dat(5);

            spotlist2(sp,1) = dat(1); % background
            spotlist2(sp,2) = dat(2); % spot width
            spotlist2(sp,3) = dat(3); % hight
            spotlist2(sp,4) = gfit(dat)/(dat(3)^2); % rel. sq. error
            % fields 5 & 6 are not filled in second pass
            spotlist2(sp,7) = exitflag; % exit -1 / 0 / 1
            spotlist2(sp,8) = dat(4);
            spotlist2(sp,9) = dat(5);
        end %
    end
    function res = gfit(in)
        b = in(1);
        wv = in(2);
        hv = in(3);
        M = b + exp(-dst2/wv)*hv;
        R = (msk2.*(M - img2)).^2;
        res = sum(sum(R));
    end
    function res = gfitpos(in)
        % also uses:
        % ls (indicates the spot to fit)
        % wf - width of the spot
        % hf - hight of the spot
        % in = [b wv(1:n) hv(1:n)]
        b = in(1);
        wv = in(2);
        hv = in(3);
        xv = in(4);
        yv = in(5);
        x0 = spotlist(sp,8);
        y0 = spotlist(sp,9);
        Xm = repmat(xv,m,n);
        Ym = repmat(yv,m,n);
        D2a = (Xm-Ix2).^2 + (Ym-Iy2).^2;
        M = M0 + b + exp(-D2a/wv)*hv;
        R = (mask.*(M - imgR)).^2;
        if isempty(shiftlim)||shiftlim<0, shiftlim = 0.01; end
        res = sum(sum(R))*(1+shiftlim*((x0-xv)^2+(y0-yv)^2))*(1+max(0,wv/wmax-1)^2)*(1+min(0,hv/mean(hf))^2);
        if b<0, res=res+(b/hv)^2; end
    end
end
function lst = getcorrectspots(spotlist,params)
    scalefactor=params.scalefactor;
    wmax = params.wmax*scalefactor; % max width in pixels
    wmin = params.wmin*scalefactor;
    hmin = params.hmin; % min height
    ef2max = params.ef2max; % max relative squared error
    vmax = params.vmax; % max ratio of the variance to squared spot height
    fmin = params.fmin; % min ratio of the filtered to fitted spot (takes into account size and shape)

    lst = ... % spotlist(:,1)>0 & ...
          spotlist(:,2)<wmax & spotlist(:,2)>wmin & spotlist(:,3)>hmin ...
        & spotlist(:,4)<ef2max ...
        & (spotlist(:,5)<vmax | spotlist(:,5)==0) ... % OK if zero
        & spotlist(:,6)>fmin ...
        & spotlist(:,7)==1;
end

function [params,spotList] = adjustparams(spotList,params)
    if isempty(spotList), return; end
    goodarray = [];
    badarray = [];
    for frame=1:length(spotList)
        for cell=1:length(spotList{frame})
            if ~isempty(spotList{frame}{cell}) && isfield(spotList{frame}{cell},'spotlist')
                spotlist = spotList{frame}{cell}.spotlist;
                lst = spotList{frame}{cell}.lst;
                cns = (spotlist(:,1)>0) & (spotlist(:,7)==1);
                cns = cns | lst;
                spotlist = spotlist(cns,:);
                lst = lst(cns);
                goodarray = [goodarray;[-spotlist(lst,2) spotlist(lst,2) spotlist(lst,3) -spotlist(lst,4) -spotlist(lst,5) spotlist(lst,6)]];
                badarray = [badarray;[-spotlist(~lst,2) spotlist(~lst,2) spotlist(~lst,3) -spotlist(~lst,4) -spotlist(~lst,5) spotlist(~lst,6)]];
                spotList{frame}{cell}.processed = true;
            end
        end
    end
    if isempty(goodarray) || isempty(badarray), return; end
    ngood = size(goodarray,1);
    nbad = size(badarray,1);
    fn = 0;
    par = min(goodarray,[],1);
    fp = sum(logical(prod((badarray>repmat(par,size(badarray,1),1))*1,2)));
    para = par;
    while true
        if fp<=1, break; end
        for c=1:6
            par2 = par;
            par2(c) = par2(c)+0.000000001;
            par2(c) = min(goodarray(logical(prod((goodarray>=repmat(par2,size(goodarray,1),1))*1,2)),c));
            fpa(c) = sum(logical(prod((badarray>repmat(par2,size(badarray,1),1))*1,2)));
            para(c) = par2(c);
        end
        [fp,ind]=min(fpa);
        par(ind) = para(ind);
        fn = fn + 1;
        % if fn>=fp-1, break; end
        if fn*nbad >= fp*ngood-1, break; end
    end
    for c=1:6
        parc = max(badarray(badarray(:,c)<par(c),c));
        if ~isempty(parc), par(c) = (par(c)*ngood+parc*nbad)/(ngood+nbad); end
    end
    % params.scalefactor = 1;
    params.wmax = -par(1);
    params.wmin = par(2);
    params.hmin = par(3);
    params.ef2max = -par(4);
    params.vmax = -par(5);
    params.fmin = par(6);
end

function res = getdmap(clist,box,sz,rs,n)
    if isempty(box)
        mask = 0;
        for cell=1:length(clist)
            if ~isempty(clist{cell}) && length(clist{cell}.mesh)>1
                mesh = clist{cell}.mesh;
                plgx = ([mesh(1:end-1,1);flipud(mesh(:,3))])*rs;
                plgy = ([mesh(1:end-1,2);flipud(mesh(:,4))])*rs;
                mask = mask+poly2mask(plgx,plgy,sz(1),sz(2));
            end
        end
    else
        mesh = clist.mesh;
        plgx = ([mesh(1:end-1,1);flipud(mesh(:,3))]-box(1)+1)*rs;
        plgy = ([mesh(1:end-1,2);flipud(mesh(:,4))]-box(2)+1)*rs;
        mask = poly2mask(plgx,plgy,sz(1),sz(2));
    end
    mask = ~mask;
    res = mask;
    se = strel('disk',1);
    for i=1:n
        mask = imerode(mask,se);
        res = res+mask;
    end
end