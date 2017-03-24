function varargout = carControl(varargin)
% CARCONTROL MATLAB code for carControl.fig
%      CARCONTROL, by itself, creates a new CARCONTROL or raises the existing
%      singleton*.
%
%      H = CARCONTROL returns the handle to a new CARCONTROL or the handle to
%      the existing singleton*.
%
%      CARCONTROL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CARCONTROL.M with the given input arguments.
%
%      CARCONTROL('Property','Value',...) creates a new CARCONTROL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before carControl_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to carControl_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help carControl

% Last Modified by GUIDE v2.5 10-Mar-2017 15:19:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @carControl_OpeningFcn, ...
                   'gui_OutputFcn',  @carControl_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before carControl is made visible.
function carControl_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to carControl (see VARARGIN)

% Choose default command line output for carControl
handles.output = hObject;
global iMapX;
global iMapY;
global iMapYaw;
% global pathX;
% global pathY;
iMapX = [0 0];
iMapY = [0 0];
iMapYaw = [0 0];
% pathX = [0 0];            ��path_painter�и�ֵ���ˣ���ע������˼·����ɾ
% pathY = [0 0];
% Coder's
setappdata(hObject,'conAxesIP',false);      %control_axes_isPressed
setappdata(hObject,'mapAxesIP',false);        %pathPaintisPressed
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes carControl wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = carControl_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function updata(obj,~,handles)
global iMapX;
global iMapY;
global iMapYaw;
if ishandle(handles.figure1)
    pos = get(handles.control_axes,'currentpoint');
    pos = [pos(1),pos(3)];
    lAngSpd = pos(2)+pos(1);
    rAngSpd = pos(2)-pos(1);
    dif = carkine(lAngSpd,rAngSpd,iMapYaw(1))*obj.period;
    iMapX = [iMapX(1)+dif(1),iMapX];
    iMapY = [iMapY(1)+dif(2),iMapY];
    tYaw = iMapYaw(1)+dif(3);
    if tYaw>=2*pi
        tYaw = tYaw-2*pi;
    elseif tYaw<=-2*pi
        tYaw = tYaw+2*pi;
    end
    iMapYaw =  [tYaw,iMapYaw];
    delete(get(handles.map_axes,'children'));       %�ۣ���ô�����㾦֮�ʣ�֮ǰ��������Ϊ�Ӷ���̫���ˣ���ȥ˯����������
     line(iMapX,iMapY,'parent',handles.map_axes,'erasemode','normal');
else
    stop(obj);
    delete(obj);
end


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global iMapX;
global iMapY;
global iMapYaw;
global pathX;
global pathY;
if  strcmp(get(gco,'Tag'),'control_axes')
   if strcmp(get(gcf,'selectiontype'),'normal')
    set(handles.map_axes,'xlim',[-2000,2000],'ylim',[-2000,2000]);
    setappdata(hObject,'conAxesIP',true);               %conAxesIP:Control_axes_isPressed
    t = timer('BusyMode','error','ExecutionMode','fixedRate',...
        'Period',0.08,'TimerFcn',{@updata,handles});
    start(t);
elseif strcmp(get(gcf,'selectiontype'),'alt')
    set(hObject,'UserData',[0,0]);
    iMapX = [0,0];
    iMapY = [0,0];
    iMapYaw = [0,0];
    delete(findobj('type','line','parent',handles.map_axes));
   end
end
if get(handles.path_painter,'value')&& ...          %path_painterѡ��
        strcmp(get(gco,'Tag'),'map_axes') && ...         %�����map����
            strcmp(get(gcf,'selectiontype'),'normal')         %���ѡ��
    setappdata(handles.figure1,'mapAxesIP',true);
    loc = get(handles.map_axes,'currentpoint');
    pathX = [loc(1),pathX];
    pathY = [loc(3),pathY];
    delete(findobj(handles.map_axes,'Tag','setPath'));        %����ǰ�Σ�Ѱ���»�
    line(pathX,pathY,'parent',handles.map_axes,'erasemode','normal','tag','setPath');
end


% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global pathX;
global pathY;
if getappdata(handles.figure1,'mapAxesIP') && ...   %�ж�����Ƿ���map�ϰ��������<-���Ѿ���path_painterѡ�н����ж���
        strcmp(get(gca,'Tag'),'map_axes')           %�ж���������Ƿ���map��
    loc = get(handles.map_axes,'currentpoint');
    pathX = [loc(1),pathX];
    pathY = [loc(3),pathY];
    delete(findobj(handles.map_axes,'Tag','setPath'));
    line(pathX,pathY,'parent',handles.map_axes,'erasemode','normal','tag','setPath');
end


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonUpFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if getappdata(hObject,'conAxesIP')
      setappdata(hObject,'conAxesIP',false);
      t = timerfind;
      stop(t);
      delete(t);
elseif getappdata(hObject,'mapAxesIP')
       setappdata(hObject,'mapAxesIP',false);
end


% --- Executes on button press in path_painter.
function path_painter_Callback(hObject, eventdata, handles)
% hObject    handle to path_painter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of path_painter
global pathX;
global pathY;
pathX = [0 0];
pathY = [0 0];
state = get(hObject,'value');
if state
    set(hObject,'string','������ͼ����');
    line(pathX,pathY,'parent',handles.map_axes,'tag','setPath');%������������ν
else
     set(hObject,'string','��ʼ��ͼ����');
     setappdata(handles.figure1,'mapAxesIP',false);
     hline = findobj(handles.map_axes,'Tag','setPath');
     linex=get(hline,'xdata');
     assignin('base','linex',linex);
     liney=get(hline,'ydata');
     assignin('base','liney',liney);
end

% --- Executes on button press in clear_path.
function clear_path_Callback(hObject, eventdata, handles)
% hObject    handle to clear_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if  ~get(handles.path_painter,'value')                          %�ж��Ƿ����·������
      if ~isempty(findobj(handles.map_axes,'Tag','setPath'))        %�ж�·������
         delete(findobj(handles.map_axes,'Tag','setPath'))          
      end
      clear global pathX;                       %���ȫ�ֱ���
      clear global pathY;
      drawnow;                                  %ˢ��...����ûûʲô����...ɾ������֮���ػ�һ�°ɣ���֤����
end
