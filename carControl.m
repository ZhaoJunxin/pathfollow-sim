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

% Last Modified by GUIDE v2.5 15-Apr-2017 15:41:06

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
blockunit = 20;
radius = 100;
setappdata(handles.map_axes,'radius',radius);
setappdata(handles.map_axes,'blockunit',blockunit); 
% pathX = [0 0];            在path_painter中赋值过了，备注在这理思路，误删
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



function remotecontrol(obj,~,handles)          %用于control_axes控制小车模型移动
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
    delete(get(handles.map_axes,'children'));       %哇，特么画龙点睛之笔，之前崩溃是因为子对象太多了，回去睡觉，美滋滋
     line(iMapX,iMapY,'parent',handles.map_axes,'erasemode','normal');
else
    stop(obj);                          %obj即当前的定时器对象
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
global tangent;
global block;
global waypoints;
if  strcmp(get(gco,'Tag'),'control_axes')
   if strcmp(get(gcf,'selectiontype'),'normal')    %左键开始控制仿真小车运动
    set(handles.map_axes,'xlim',[-2000,2000],'ylim',[-2000,2000]);
    setappdata(hObject,'conAxesIP',true);               %conAxesIP:Control_axes_isPressed
    t = timer('BusyMode','error','ExecutionMode','fixedRate',...
        'Period',0.08,'TimerFcn',{@remotecontrol,handles},'Tag','control');
    start(t);
    elseif strcmp(get(gcf,'selectiontype'),'alt')   %右键清空map中的路径
    set(hObject,'UserData',[0,0]);
    iMapX = [0,0];
    iMapY = [0,0];
    iMapYaw = [0,0];
    delete(findobj('type','line','parent',handles.map_axes));
   end
end
if get(handles.path_painter,'value')&& ...          %path_painter选中
        strcmp(get(gco,'Tag'),'map_axes') && ...         %鼠标在map里面
            strcmp(get(gcf,'selectiontype'),'normal')         %左键选择
    setappdata(handles.figure1,'mapAxesIP',true);
    loc = get(handles.map_axes,'currentpoint');
    pathX = [pathX,loc(1)];
    pathY = [pathY,loc(3)];
    delete(findobj(handles.map_axes,'Tag','setPath'));        %忘记前任，寻求新换
    line(pathX,pathY,'parent',handles.map_axes,'erasemode','normal','tag','setPath');
end
if get(handles.getrefbtn,'value')&& ...          %getrefbtn(get reference button)选中
        strcmp(get(gco,'Tag'),'map_axes') && ...         %鼠标在map里面
            strcmp(get(gcf,'selectiontype'),'normal')         %左键选择
%        tic
        loc = get(handles.map_axes,'currentpoint');
        for n = 2:length(pathX);
            radtemp = tangent(n) - pi/2;            %此处减去pi/2的原因是为了让参考目标方向成为Y轴
            ydiff = -sin(radtemp)*(loc(1)-pathX(n))+cos(radtemp)*(loc(3)-pathY(n));
            dist = norm([loc(1)-pathX(n),loc(3)-pathY(n)]);
            if ydiff<0 && dist > 200 && n > getappdata(gca,'refpointnum')
%                toc
                set(findobj('tag','refpoint'),'visible','on','xdata',pathX(n),'ydata',pathY(n));
                setappdata(gca,'refpointnum',n);
                break;
            end
        end
 %       toc
end
if get(handles.block_painter,'value')&& ...          %block_painter选中
        strcmp(get(gco,'Tag'),'map_axes') && ...         %鼠标在map里面
            strcmp(get(gcf,'selectiontype'),'normal')         %左键选择
        blockunit = getappdata(handles.map_axes,'blockunit');
        loc = get(handles.map_axes,'currentpoint');
%        block = [fix(loc(1)/blockunit),fix(loc(3)/blockunit);block];
        currentblock = [round(loc(1)/blockunit),round(loc(3)/blockunit)];        %round is better than the fix
        if ~ifexist(currentblock,block)
            block = [currentblock;block];
            rectangle('Position',[currentblock(1,1)*blockunit-blockunit/2,...
                currentblock(1,2)*blockunit-blockunit/2,blockunit,blockunit],...
                     'facecolor','b','hittest','off');
        end
        block = unique(block,'rows');
end
if get(handles.block_cleaner,'value')&& ...          %block_cleaner 选中
        strcmp(get(gco,'Tag'),'map_axes') && ...         %鼠标在map里面
            strcmp(get(gcf,'selectiontype'),'normal') && ...        %左键选择
                ~isempty(block)
        blockunit = getappdata(handles.map_axes,'blockunit');
        loc = get(handles.map_axes,'currentpoint');
        currentblock = [round(loc(1)/blockunit),round(loc(3)/blockunit)];        %round is better than the fix
        if ifexist(currentblock,block)
            ind = ifexist(currentblock,block);
            block(ind,:) = [];
            delete(findobj('type','rectangle','position',[currentblock(1,1)*blockunit-blockunit/2,...
                currentblock(1,2)*blockunit-blockunit/2,blockunit,blockunit],'facecolor','b'));
        end
        block = unique(block,'rows');
end
if get(handles.set_waypoint,'value')&& ...          %set_waypoint选中
        strcmp(get(gco,'Tag'),'map_axes') && ...         %鼠标在map里面
            strcmp(get(gcf,'selectiontype'),'normal')         %左键选择
        blockunit = getappdata(handles.map_axes,'blockunit');
        radius = getappdata(handles.map_axes,'radius');
        blockcircle = circlemaker(radius,blockunit);
        loc = get(handles.map_axes,'currentpoint');
%        block = [fix(loc(1)/blockunit),fix(loc(3)/blockunit);block];
        currentblock = [round(loc(1)/blockunit),round(loc(3)/blockunit)];        %round is better than the fix
        obstacle = block2obstacle(block,blockcircle);
        if ~ifexist(currentblock,obstacle)
            waypoints = [waypoints;currentblock];
            rectangle('Position',[currentblock(1,1)*blockunit-blockunit/2,...
                currentblock(1,2)*blockunit-blockunit/2,blockunit,blockunit],...
                     'facecolor','r','hittest','off');
        end
end
if get(handles.waypoint_cleaner,'value')&& ...          %waypoint_cleaner 选中
        strcmp(get(gco,'Tag'),'map_axes') && ...         %鼠标在map里面
            strcmp(get(gcf,'selectiontype'),'normal') && ...        %左键选择
                ~isempty(waypoints)
        blockunit = getappdata(handles.map_axes,'blockunit');
        loc = get(handles.map_axes,'currentpoint');
        currentblock = [round(loc(1)/blockunit),round(loc(3)/blockunit)];        %round is better than the fix
        if ifexist(currentblock,waypoints)
            ind = ifexist(currentblock,waypoints);
            waypoints(ind,:) = [];
            delete(findobj('type','rectangle','position',[currentblock(1,1)*blockunit-blockunit/2,...
                currentblock(1,2)*blockunit-blockunit/2,blockunit,blockunit],'facecolor','r'));
        end
end


% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global pathX;
global pathY;
global block;
global waypoints;
if getappdata(handles.figure1,'mapAxesIP') && ...   %判断鼠标是否在map上按下了左键<-这已经对path_painter选中进行判断了
        strcmp(get(gca,'Tag'),'map_axes')           %判断鼠标现在是否在map上
    loc = get(handles.map_axes,'currentpoint');
% %     pathX = [loc(1),pathX];
% %     pathY = [loc(3),pathY];
    pathX = [pathX,loc(1)];    %%这里用行的原因是因为pathX=get(hline,'xdata');得到的数据是行的，要统计数据格式
    pathY = [pathY,loc(3)];
    delete(findobj(handles.map_axes,'Tag','setPath'));
    line(pathX,pathY,'parent',handles.map_axes,'erasemode','normal','tag','setPath');
end
%%%%%%%%%%%%%%%%障碍/目标点绘制，辅助显示，注意：WindowButtonMotionFcn需要按下右键才会调用************
if get(handles.block_painter,'value')||...       %block_painter选中
     get(handles.block_cleaner,'value')||...        %block_cleaner选中
        get(handles.set_waypoint,'value')|| ...  	  %set_waypoint选中
           get(handles.waypoint_cleaner,'value')&& ...  
        strcmp(get(gco,'Tag'),'map_axes')          %鼠标在map里面
    loc = get(handles.map_axes,'currentpoint'); 
    blockunit = getappdata(handles.map_axes,'blockunit');
    roundloc = [round(loc(1)/blockunit),round(loc(3)/blockunit)];        %round is better than the fix 
    delete(findobj(handles.map_axes,'Tag','assiblock'));
    if get(handles.block_painter,'value') || get(handles.set_waypoint,'value')
        rectangle('Position',[roundloc(1,1)*blockunit-blockunit/2,...
            roundloc(1,2)*blockunit-blockunit/2,blockunit,blockunit],...
                 'facecolor','c','hittest','off','tag','assiblock');
    elseif (get(handles.block_cleaner,'value')  &&  ~isempty(block)) || ...
        (get(handles.waypoint_cleaner,'value') && ~isempty(waypoints))
        rectangle('Position',[roundloc(1,1)*blockunit-blockunit/2,...
            roundloc(1,2)*blockunit-blockunit/2,blockunit,blockunit],...
                 'facecolor','y','hittest','off','tag','assiblock');
    end
%    set(handles.map_axes,'currentpoint',loc); 
end



% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonUpFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if getappdata(hObject,'conAxesIP')
      setappdata(hObject,'conAxesIP',false);
      t = timerfind('Tag','control');
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
pathX = 0;                          %此处赋值为[0 0]，保证路径起点从原点开始
pathY = 0;
state = get(hObject,'value');
if state
    set(hObject,'string','结束地图绘制');
    line(pathX,pathY,'parent',handles.map_axes,'tag','setPath');%见不建立无所谓
else
     set(hObject,'string','开始地图绘制');
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
if  ~get(handles.path_painter,'value')                          %判断是否结束路径绘制
      if ~isempty(findobj(handles.map_axes,'Tag','setPath'))        %判断路径存在
         delete(findobj(handles.map_axes,'Tag','setPath'))          
      end
      clear global pathX;                       %清除全局变量
      clear global pathY;
      drawnow;                                  %刷新...好像没没什么卵用...删除对象之后重绘一下吧，保证精度
end


% --- Executes on button press in getrefbtn.
function getrefbtn_Callback(hObject, eventdata, handles)
% hObject    handle to getrefbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of getrefbtn
state = get(hObject,'value');
if state
    set(hObject,'string','结束目标点获取');
    patch('xdata',0,'ydata',0,'Marker','o','edgecolor','r','visible','off','tag','refpoint');
    setappdata(gca,'refpointnum',1);
    setappdata(gca,'curvpointnum',1);    
%    setappdata(hObject,'getrefIP',true);
else
    set(hObject,'string','开始目标点获取');
    delete(findobj('tag','refpoint'));
    rmappdata(gca,'refpointnum');
    rmappdata(gca,'curvpointnum');
%    setappdata(hObject,'getrefIP',false);
end


% --- Executes on button press in pathjudger.
function pathjudger_Callback(hObject, eventdata, handles)
% hObject    handle to pathjudger (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global pathX;
global pathY;
global tangent;
global curX;
global curY;
global currad;
global curtan;
hline = findobj(handles.map_axes,'Tag','setPath');
pathX=get(hline,'xdata');
pathY=get(hline,'ydata');
%[pathX,pathY,tangent] = pathjudger(pathX,pathY);
[pathX,pathY] = pathjudger(pathX,pathY);
[pathX,pathY,tangent] = pathjudger2(pathX,pathY);
assignin('base','pathX',pathX);
assignin('base','pathY',pathY);
assignin('base','tangent',tangent);
delete(findobj(handles.map_axes,'Tag','setPath'));
line(pathX,pathY,'parent',handles.map_axes,'erasemode','normal','tag','setPath');
[curX,curY,currad,curtan] = pathcurv(pathX,pathY,20);
assignin('base','curX',curX);
assignin('base','curY',curY);
assignin('base','currad',currad);
assignin('base','curtan',curtan);


% --- Executes on button press in pathfollowbtn.
function pathfollowbtn_Callback(hObject, eventdata, handles)
% hObject    handle to pathfollowbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pathfollowbtn
global carposX;
global carposY;
global carposYaw;
state = get(hObject,'value');
if state
    set(hObject,'string','结束路径跟踪');
    carposX = [0,0];
    carposY = [0,0];
    carposYaw = 0;
    line(carposX,carposY,'parent',handles.map_axes,'erasemode','normal','Tag','motionpath');
     patch('xdata',0,'ydata',0,'Marker','o','markersize',2,'edgecolor','r','tag','mobilerbt','parent',handles.map_axes);
    setappdata(handles.map_axes,'refpointfeq',1);
    setappdata(handles.map_axes,'curvpointnum',1);
    setappdata(handles.map_axes,'curvsecnum',6);
    t = timer('BusyMode','error','ExecutionMode','fixedRate',...
        'Period',0.08,'TimerFcn',{@following,handles},'Tag','pathfollow');
    start(t);
else
    set(hObject,'string','开始路径跟踪');
    delete(findobj('tag','mobilerbt'));
    delete(findobj('parent',handles.map_axes,'Tag','motionpath','type','line')); 
    delete(findobj('parent',handles.map_axes,'Tag','mobilerbt','type','patch'));
    delete(findobj('tag','refpoint'));
    rmappdata(handles.map_axes,'refpointfeq');
    rmappdata(handles.map_axes,'curvpointnum');
    t = timerfind('Tag','pathfollow');
    stop(t);
    delete(t);
end

function following (obj,~,handles)
global pathX;
global pathY;
global tangent;
global carposX;
global carposY;
global carposYaw;
global curX;
global curY;
global currad;
global curtan;
%linespd = 0;
maxspd = 20; %rad/s
minlinespd = 6.5;   %rad/s
%minspd = 0;
tic
%%%%%%%%%%%%%%%%%获取参考目标点，获取路径弯曲程度%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%可修改参数有：目标点：1.决定是否改变目标点的判定距离  2.目标点选取时的最近距离
%             道路弯曲程度：1.弯曲程度切分距离   2.弯曲程度选取范围-curvsecnum
refpointfeq = getappdata(handles.map_axes,'refpointfeq');
curvpointnum = getappdata(handles.map_axes,'curvpointnum');
followref = [pathX(refpointfeq),pathY(refpointfeq),tangent(refpointfeq)];
radtemp = followref(3) - pi/2;            %此处减去pi/2的原因是为了让参考目标方向成为Y轴
ydiff = -sin(radtemp)*(carposX(1)-followref(1))+cos(radtemp)*(carposY(1)-followref(2));
dist = norm([carposX(1)-followref(1),carposY(1)-followref(2)]);
% % refpointfeq = refpointfeq
% % lengthpathX = length(pathX)-1
% % lengthcurx = length(curX)-1
% % curvpointnum = curvpointnum

if refpointfeq >= length(pathX) || curvpointnum >= length(curX)-1
    if ydiff >0 || dist < 50
    t = timerfind('Tag','pathfollow');
    stop(t);
    %delete(t);
    return;                 %停止定时器后，还需要中断定时器函数运行才可以
    end
end
xdiff = abs(cos(radtemp)*(carposX(1)-followref(1))+sin(radtemp)*(carposY(1)-followref(2)));
if ydiff >0 || dist <10
    for n = refpointfeq:length(pathX);
        radtemp = tangent(n) - pi/2;            %此处减去pi/2的原因是为了让参考目标方向成为Y轴
        ydiff = -sin(radtemp)*(carposX(1)-pathX(n))+cos(radtemp)*(carposY(1)-pathY(n));
        dist = norm([carposX(1)-pathX(n),carposY(1)-pathY(n)]);
        if ydiff<0 && dist > 50 && n > getappdata(handles.map_axes,'refpointfeq')
%            set(findobj('tag','refpoint'),'visible','on','xdata',pathX(n),'ydata',pathY(n));
            followref = [pathX(n),pathY(n),tangent(n)];        %path following ref point
            setappdata(handles.map_axes,'refpointfeq',n);
            break;
        end
    end
    xdiff = abs(cos(radtemp)*(carposX(1)-pathX(n))+sin(radtemp)*(carposY(1)-pathY(n)));     %已取abs绝对值
end
    
%%curvpointnum = getappdata(handles.map_axes,'curvpointnum')
curvsecnum = getappdata(handles.map_axes,'curvsecnum');     %curve section number 弯曲段落数
curvref = [curX(curvpointnum),curY(curvpointnum),sum(currad(curvpointnum:1:curvpointnum+curvsecnum))];
radtemp = curtan(curvpointnum) - pi/2;
ydiff = -sin(radtemp)*(carposX(1)-curvref(1))+cos(radtemp)*(carposY(1)-curvref(2));
%dist = norm([carposX(1)-curvref(1),carposY(1)-curvref(2)]);
%if ydiff >0 || dist <20
if ydiff >0
    for m = curvpointnum:length(curX);
        radtemp = curtan(m) - pi/2;            %此处减去pi/2的原因是为了让参考目标方向成为Y轴
        ydiff = -sin(radtemp)*(carposX(1)-curX(m))+cos(radtemp)*(carposY(1)-curY(m));
%        dist = norm([carposX(1)-curX(m),carposY(1)-curY(m)]);
%        if ydiff<0 && dist > 20 && m > getappdata(handles.map_axes,'curvpointnum')
        if ydiff<0 && m > getappdata(handles.map_axes,'curvpointnum')
            if m+curvsecnum>=length(curX)
                curvsecnum = length(curX) - m;
                setappdata(handles.map_axes,'curvsecnum',curvsecnum);
%                 pathX = length(pathX)
%                 refpfeq = getappdata(handles.map_axes,'refpointfeq')
            end
            curvref = [curX(m),curY(m),sum(currad(m:1:m+curvsecnum))];            %path curv ref point
            setappdata(handles.map_axes,'curvpointnum',m);
            break;
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%计算变换后的参考方向%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%可修改的参数： 1.lambda  2.Kxdiff
%注：xdiff在上面计算时已经取abs绝对值
    lambda = 150;
    Kxdiff = 4;
%    carposYaw = carposYaw
%    folrefrad = followref(3)
%     deltarad = carposYaw - followref(3);
%     if deltarad > pi
%         deltarad = deltarad - 2*pi;
%     elseif deltarad < -pi
%         deltarad = 2*pi + deltarad;
%     end
    deltacr = vec2rad([1,0],[followref(1) - carposX(1),followref(2) - carposY(1)]);
    if deltacr > pi
        deltacr = deltacr - 2*pi;
    end
    deltar = followref(3);
    deltarad = deltacr - deltar;
%    xdiff = xdiff
    gamma = 1/(pi/2+atan(lambda));
%    followref3 = followref(3)
    refangle = followref(3) + (deltarad) * gamma * (atan(Kxdiff*xdiff-lambda)+atan(lambda));
%     if refangle > pi 
%         refangle = refangle-2*pi;
%     end
%%%%%%%%%%%%%%%%%%%%%计算期望线速度%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%可修改的参数： 1.k1-方向角误差的影响系数  2.k2-道路弯曲程度影响系数
    refdeltarad = carposYaw - refangle;
    if refdeltarad > pi
        refdeltarad = refdeltarad-2*pi;
    elseif refdeltarad < -pi
        refdeltarad = 2*pi + refdeltarad;
    end
    k1 = 0.1;
    k2 = 0.6;
%    curref = curvref(3)
    linespd = (1-k1*abs(refdeltarad)-k2*curvref(3))*maxspd;
    if linespd <= minlinespd
        linespd = minlinespd;
    end
%%%%%%%%%%%%%%%%%%%%计算期望角速度%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%可修改的参数：    1.k3-方向角误差对左右轮差分的影响系数
%    refdeltarad = refdeltarad
    k3 = 60;
    lAngSpd = linespd + (k3*refdeltarad);
    if lAngSpd > maxspd
        lAngSpd = maxspd;
    elseif lAngSpd < minlinespd
        lAngSpd = 0;
    end
    rAngSpd = linespd - (k3*refdeltarad);
    if rAngSpd > maxspd
        rAngSpd = maxspd;
    elseif rAngSpd < minlinespd
        rAngSpd = 0;
    end
%     lAngSpd = lAngSpd
%     rAngSpd = rAngSpd
%%%%%%%%%%%%%%%%%%%输入动力学模型，模拟实际运动%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    dif = carkine(lAngSpd,rAngSpd,carposYaw)*obj.period;
%     dif1 = dif(1)
%     dif2 = dif(2)
    carposX = [carposX(1)+dif(1),carposX];
    carposY = [carposY(1)+dif(2),carposY];
    tYaw = carposYaw+dif(3);
    if tYaw>=2*pi
        tYaw = tYaw-2*pi;
    elseif tYaw<=-2*pi
        tYaw = tYaw+2*pi;
    end
    if tYaw < 0                                  %角度统一使用0~2pi范围
        tYaw = tYaw +2*pi;
    end
    carposYaw =  tYaw;
    toc
%%%%%%%%%%%%%%%%%%%%%显示运动点%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    delete(findobj('parent',handles.map_axes,'Tag','motionpath','type','line'));
%    line(carposX,carposY,'parent',handles.map_axes,'erasemode','normal','tag','motionpath','Marker','o','markersize',2,'Markeredgecolor','r');
    line(carposX,carposY,'parent',handles.map_axes,'erasemode','normal','tag','motionpath');    
     delete(findobj('parent',handles.map_axes,'Tag','mobilerbt'));
     patch('xdata',carposX(1),'ydata',carposY(1),'Marker','o','markersize',2,'edgecolor','r','tag','mobilerbt','parent',handles.map_axes);
 
     
% --- Executes on button press in pathsavebtn.
function pathsavebtn_Callback(hObject, eventdata, handles)
% hObject    handle to pathsavebtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
     hline = findobj(handles.map_axes,'Tag','setPath');
     linex=get(hline,'xdata');
     liney=get(hline,'ydata');
     pathfilename = get(findobj('tag','pathfilename'),'string');
     if ~isempty(pathfilename)
        save([pathfilename,'.mat'],'linex','liney'); %这里会显示上面linex liney没用上，不过确实要这么写
     else
        warndlg('输个文件名呗','保存路径')
     end


% --- Executes on button press in loadpathbtn.
function loadpathbtn_Callback(hObject, eventdata, handles)
% hObject    handle to loadpathbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global pathX;
global pathY;
    pathfilename = get(findobj('tag','pathfilename'),'string');
    if ~isempty(pathfilename)
        load([pathfilename,'.mat']);
        pathX = linex;
        pathY = liney;
        if ~isempty(findobj(handles.map_axes,'Tag','setPath'))        %判断路径存在
             delete(findobj(handles.map_axes,'Tag','setPath'))          
        end
        line(linex,liney,'parent',handles.map_axes,'erasemode','normal','tag','setPath');
    else
        warndlg('输个文件名呗','读取路径')
    end


% --- Executes on button press in block_painter.
function block_painter_Callback(hObject, eventdata, handles)
% hObject    handle to block_painter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of block_painter
if get(handles.block_cleaner,'value')
    set(hObject,'value',false);
    return;
end
global block;               %visible part
% % global obstacle;            %visible & invisible part
state = get(hObject,'value');
% % blockunit = 20;
% % radius = 100;
if state
    set(get(handles.map_axes,'parent'),'pointer','fullcrosshair');
% %     obstacle = [[-1,0];obstacle];
% %     blockcircle = circlemaker(radius,blockunit);
% %     obstacle = [blockcircle(:,1),blockcircle(:,2)+(radius/blockunit)+1;obstacle];
% %     obstacle = [blockcircle(:,1),blockcircle(:,2)-((radius/blockunit)+1);obstacle];    
% %     obstacle = unique(obstacle,'rows');
    set(hObject,'string','结束障碍绘制');
% %     set(hObject,'userdata',blockunit);
% %     setappdata(handles.block_painter,'radius',radius);
% %     setappdata(handles.block_painter,'blockunit',blockunit); 
% %    setappdata(handles.map_axes,'blockcircle',blockcircle);
else
    set(hObject,'string','开始障碍绘制');
% %     blockcircle = getappdata(handles.map_axes,'blockcircle');
% %     obstacle = [zeros(size(blockcircle,1)*size(block,1),2);obstacle];
% %     for n = 1:size(block,1)
% %     obstacle((n-1)*size(blockcircle,1)+1:n*size(blockcircle,1),:) = [blockcircle(:,1)+block(n,1),blockcircle(:,2)+block(n,2)];
% %     end
% %     obstacle = unique(obstacle,'rows');
    assignin('base','lastblock',block);
% %     assignin('base','lastobstacle',obstacle);
    set(get(handles.map_axes,'parent'),'pointer','arrow');
end


% --- Executes on button press in clear_block.
function clear_block_Callback(hObject, eventdata, handles)
% hObject    handle to clear_block (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global block;
% global obstacle;
delete(findobj(handles.map_axes,'type','rectangle','facecolor','b'));
block = [];
% obstacle = [];


% --- Executes on button press in block_cleaner.
function block_cleaner_Callback(hObject, eventdata, handles)
% hObject    handle to block_cleaner (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of block_cleaner
if get(handles.block_painter,'value')
    set(hObject,'value',false);
    return;
end
global block;               %visible part
% % global obstacle;            %visible & invisible part
state = get(hObject,'value');
% blockunit = 20;
% radius = 100;
% blockcircle = circlemaker(radius,blockunit);
% %     blockunit = getappdata(handles.block_painter,'blockunit');
% %     blockcircle = getappdata(handles.map_axes,'blockcircle');
% %     radius = getappdata(handles.block_painter,'radius');
    if state && ~isempty(block)
        set(hObject,'string','结束障碍擦除');   
        set(get(handles.map_axes,'parent'),'pointer','fullcrosshair');
% %         obstacle = [-1,0];
% %         obstacle = [blockcircle(:,1),blockcircle(:,2)+(radius/blockunit)+1;obstacle];
% %         obstacle = [blockcircle(:,1),blockcircle(:,2)-((radius/blockunit)+1);obstacle];    
% %         obstacle = unique(obstacle,'rows');
    else
        set(hObject,'string','开始障碍擦除');
% %         obstacle = [zeros(size(blockcircle,1)*size(block,1),2);obstacle];
% %         for n = 1:size(block,1)
% %         obstacle((n-1)*size(blockcircle,1)+1:n*size(blockcircle,1),:) = ...
% %             [blockcircle(:,1)+block(n,1),blockcircle(:,2)+block(n,2)];
% %         end
% %         obstacle = unique(obstacle,'rows');     
        set(get(handles.map_axes,'parent'),'pointer','arrow');
    end


% --- Executes on button press in saveblockbtn.
function saveblockbtn_Callback(hObject, eventdata, handles)
% hObject    handle to saveblockbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global block;
%global obstacle;
     pathfilename = get(findobj('tag','pathfilename'),'string');
     if ~isempty(pathfilename)
        save([pathfilename,'.mat'],'block');
        assignin('base','lastblock',block);
%        assignin('base','lastobstacle',obstacle);
     else
        warndlg('输个文件名呗','保存障碍')
     end

% --- Executes on button press in loadblockbtn.
function loadblockbtn_Callback(hObject, eventdata, handles)
% hObject    handle to loadblockbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 障碍读取部分，这里直接读取了block和obstacle两个数组，其实只读一个block就可以得到obstacle了
% 算了，我还是写了吧，我只是觉得代码太长不好看不想写而已，不是偷懒噢
global block;
%global obstacle;
blockunit = getappdata(handles.map_axes,'blockunit');
%radius = 100;
%blockcircle = circlemaker(radius,blockunit);
    pathfilename = get(findobj('tag','pathfilename'),'string');
    if ~isempty(pathfilename)
        temp = load([pathfilename,'.mat']);        %block only
        if ~isempty(temp.block)
            block = temp.block;
%             obstacle = zeros(size(blockcircle,1)*size(block,1),2);
%             for n = 1:size(block,1)
%             obstacle((n-1)*size(blockcircle,1)+1:n*size(blockcircle,1),:) = ...
%                 [blockcircle(:,1)+block(n,1),blockcircle(:,2)+block(n,2)];
%             end
            delete(findobj(handles.map_axes,'type','rectangle'));
            for n = 1:size(block,1)
                rectangle('Position',[block(n,1)*blockunit-blockunit/2,...
                        block(n,2)*blockunit-blockunit/2,blockunit,blockunit],...
                             'facecolor','b','hittest','off','parent',handles.map_axes);
            end
        end
    else
        warndlg('输个文件名呗','读取障碍')
    end


% --- Executes on button press in set_waypoint.
function set_waypoint_Callback(hObject, eventdata, handles)
% hObject    handle to set_waypoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of set_waypoint
if get(handles.waypoint_cleaner,'value')
    set(hObject,'value',false);
    return;
end
global waypoints;               %visible part
state = get(hObject,'value');
if state
    set(get(handles.map_axes,'parent'),'pointer','fullcrosshair');
    set(hObject,'string','结束目标点设定');
else
    set(hObject,'string','开始目标点设定');
    assignin('base','lastwaypoints',waypoints);
    set(get(handles.map_axes,'parent'),'pointer','arrow');
end

% --- Executes on button press in waypoint_cleaner.
function waypoint_cleaner_Callback(hObject, eventdata, handles)
% hObject    handle to waypoint_cleaner (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of waypoint_cleaner
if get(handles.set_waypoint,'value')
    set(hObject,'value',false);
    return;
end
global waypoints;               %visible part
state = get(hObject,'value');
if state
    set(get(handles.map_axes,'parent'),'pointer','fullcrosshair');
    set(hObject,'string','结束目标点擦除');
else
    set(hObject,'string','开始目标点擦除');
    assignin('base','lastwaypoints',waypoints);
    set(get(handles.map_axes,'parent'),'pointer','arrow');
end

% --- Executes on button press in clear_waypoint.
function clear_waypoint_Callback(hObject, eventdata, handles)
% hObject    handle to clear_waypoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global waypoints;
    % global obstacle;
    delete(findobj(handles.map_axes,'type','rectangle','facecolor','r'));
    waypoints = [];


% --- Executes on button press in getpath_astar.
function getpath_astar_Callback(hObject, eventdata, handles)
% hObject    handle to getpath_astar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global pathX;
global pathY;
global block;
global waypoints;
pathX = [];
pathY = [];
startvector = [0,0;-1,0];
radius = getappdata(handles.map_axes,'radius');
blockunit = getappdata(handles.map_axes,'blockunit');
%waypoints = [startvector,waypoints];
for n = 1:size(waypoints,1)
    [path,~] = astar(block,startvector,waypoints(n,:),radius,blockunit);
    startvector = [waypoints(n,:);path(size(path,1)-1,:)];
%    waypoints(n,:) = [];
    pathX = [pathX;path(:,1)];
    pathY = [pathY;path(:,2)];
end
linex = pathX*blockunit;
liney = pathY*blockunit;
assignin('base','aslinex',linex);
assignin('base','asliney',liney);
if ~isempty(findobj(handles.map_axes,'Tag','setPath'))        %判断路径存在
     delete(findobj(handles.map_axes,'Tag','setPath'))          
end
line(linex,liney,'parent',handles.map_axes,'erasemode','normal','tag','setPath');