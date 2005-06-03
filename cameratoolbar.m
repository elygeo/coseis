function ret=cameratoolbar(varargin)
%CAMERATOOLBAR  Interactively manipulate camera.
%   CAMERATOOLBAR creates a new toolbar that enables interactive 
%   manipulation of a scene's camera and light by dragging the 
%   mouse on the figure window; the camera properties of the
%   current axes (gca) are affected. Several camera properties
%   are set when the toolbar is initialized. 
%
%   CAMERATOOLBAR('NoReset') creates the toolbar without setting
%   any camera properties.
% 
%   CAMERATOOLBAR('SetMode' mode) sets the mode of the
%   toolbar. Mode can be: 'orbit', 'orbitscenelight', 'pan',
%   'dollyhv', 'dollyfb', 'zoom', 'roll', 'nomode'.
%
%   CAMERATOOLBAR('SetCoordSys' coordsys) sets the principal axis
%   of the camera motion. coordsys can be: 'x', 'y', 'z', 'none'.
%
%   CAMERATOOLBAR('Show') shows the toolbar.
%   CAMERATOOLBAR('Hide') hides the toolbar.
%   CAMERATOOLBAR('Toggle') toggles the visibility of the toolbar.
%
%   CAMERATOOLBAR('ResetCameraAndSceneLight') resets the current
%   camera and scenelight.
%   CAMERATOOLBAR('ResetCamera') resets the current camera.
%   CAMERATOOLBAR('ResetSceneLight') resets the current scenelight.
%   CAMERATOOLBAR('ResetTarget') resets the current camera target.
%
%   MODE = CAMERATOOLBAR('GetMode') returns the current mode.
%   PAXIS = CAMERATOOLBAR('GetCoordSys') returns the current
%   principal axis. 
%   VIS = CAMERATOOLBAR('GetVisible') returns the visibility.
%   H = CAMERATOOLBAR returns the handle to the toolbar.
%
%   CAMERATOOLBAR('Close') removes the toolbar.
%
%   CAMERATOOLBAR(FIG,...) specify figure handle as first argument.
%
%   Note: Rendering performance is affected by presence of OpenGL 
%   hardware.
%
%   See also ROTATE3D, ZOOM.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.26.4.9 $  $Date: 2004/08/23 23:18:05 $

assignin( 'base', 'itstep', 0 )

persistent walk_flag

% First argument might be figure handle
if nargin>0 && isscalar(varargin{1}) && ishandle(varargin{1})
   [hfig,haxes] = currenthandles(varargin{1});
   vargin = {varargin{2:end}};
   nin = nargin-1;
else
   [hfig,haxes] = currenthandles; % use gcf/gcbf
   vargin = varargin;
   nin = nargin;
end

Udata = getUdata(hfig);
r = [];

if nin==0
  if iscameraobj(haxes)
    axis(haxes,'vis3d')
  end
  r = cameratoolbar(hfig,'show');
  cameratoolbar(hfig,'setmode', 'orbit')
  arg = '';
else
  arg = lower(vargin{1});
  if ~strcmp(arg, 'init') & ~strcmp(arg, 'motion') & ...
	(length(arg)<3 | any(arg(1:3)~='get')) & ...
	isempty(Udata)
    r = cameratoolbar(hfig,'init');
    Udata = getUdata(hfig);
    %if ~strcmp(arg, 'nomode')
    %  scribeclearmode(hfig,'cameratoolbar', 'nomode');
    %end
   end
end

switch arg
case 'down'
    if(isempty(haxes)) return; end
    %can call with cameratoolbar('down',0/1) to prohibit setting of windowbuttonfcn's
    switch get(hfig,'SelectionType')
%     case 'open'
%         if strcmp(get(haxes,'warptofill'),'on')
%             axis('vis3d');
%         else
%             axis('normal');
%         end
    case 'alt'
        postContextMenu(hfig,haxes);
    otherwise
		if strcmp(get(haxes,'warptofill'),'on') %& ...
			%~(isappdata(haxes,'CameratoolbarAxesOptimized') & ...
			%    isequal(getappdata(haxes,'CameratoolbarAxesOptimized'),1))
			if iscameraobj(haxes)
 				axis(haxes,'vis3d');
			else
				return
			end
			%setappdata(haxes,'CameratoolbarAxesOptimized',1);
			%bashMsg='Axes camera settings optimized for 3-D camera movement.  Type ''axis normal'' to restore';
			%disp(bashMsg);
		end
		Udata = getUdata(hfig);
                pt = hgconvertunits(hfig,[0 0 get(hfig,'CurrentPoint')],...
                                    get(hfig,'Units'),'pixels',0);
                pt = pt(3:4);
		Udata.figStartPoint = pt;
		Udata.figLastPoint  = pt;
        Udata.figLastLastPoint = pt;
        Udata.buttondown = 1;
        Udata.moving = 0;
        
        setUdata(hfig,Udata)
        
        validateScenelights(hfig,haxes)
        %updateScenelightOnOff(haxes,Udata.scenelightOn);
        if length(vargin)==1 | vargin{2}
            set(hfig, 'windowbuttonmotionfcn', 'cameratoolbar(''motion'')')
            set(hfig, 'windowbuttonupfcn', 'cameratoolbar(''up'')')
        end
    end
 case 'motion'
  if isstruct(Udata)
    pt = hgconvertunits(hfig,[0 0 get(hfig,'CurrentPoint')],...
                        get(hfig,'Units'),'pixels',0);
    pt = pt(3:4);
    deltaPix  = pt-Udata.figLastPoint;
    deltaPixStart  = pt-Udata.figStartPoint;
    Udata.figLastLastPoint = Udata.figLastPoint;
    Udata.figLastPoint = pt;

    Udata.time = clock;
    mode = lower(Udata.mode);
    setUdata(hfig,Udata)

    % Now perform the desired event from the rotation.
    switch mode
     case 'orbit'
      orbitPangca(hfig,haxes,deltaPix, 'o');
     case 'orbitscenelight'
      orbitLightgca(hfig,haxes,deltaPix);
     case 'pan'
      orbitPangca(hfig,haxes,deltaPix, 'p');
     case 'dollyhv'
      dollygca(hfig,haxes,deltaPix);
     case 'zoom'
      zoomgca(hfig,haxes,deltaPix);
     case 'dollyfb'
      forwardBackgca(hfig,haxes,deltaPix, 'c');
     case 'roll'
      rollgca(hfig,haxes,deltaPix, pt);
     case 'walk'
      Udata.moving = 1;
      setUdata(hfig,Udata)
      if isempty(walk_flag)
        walk_flag = 1;
        walkgca(hfig,haxes,deltaPixStart,[]);
      else
        walkgca(hfig,haxes,deltaPixStart,1);
      end
    end
  end
case 'up'
  set(hfig, 'windowbuttonmotionfcn', '')
  set(hfig, 'windowbuttonupfcn', '')
  Udata.buttondown = 0;
  Udata.moving   = 0;
  pt = hgconvertunits(hfig,[0 0 get(hfig,'CurrentPoint')],...
                      get(hfig,'Units'),'pixels',0);
  pt = pt(3:4);
  deltaPix  = pt-Udata.figLastLastPoint;
  deltaPixStart  = pt-Udata.figStartPoint;
  Udata.figLastPoint = pt;
  % Checking the sensitivity of the camera throw mode w.r.t mouse events
  % Speed at the end being proportional to the dist travelled at the end...
  speed_sense = sqrt((deltaPix(1)^2)+(deltaPix(2)^2));
  % Total distance travelled from start to finish:
  dist_sense = sqrt((deltaPixStart(1)^2)+(deltaPixStart(2)^2));
  % Scaling down the speed of motion in the throw mode
  mode = lower(Udata.mode);
  clear walk_flag;
  
  setUdata(hfig,Udata)
  % Scale down the deltas to get a reasonable speed.
  scaled_deltaPix = deltaPix/10;
  scaled_deltaPixStart = deltaPixStart/10;
  if etime(clock, Udata.time)<.5 & (speed_sense>=7) & (dist_sense>30) ...
   	& any(deltaPix) & ~strcmp('alt', get(hfig, 'selectiontype'))
    Udata.moving = 1;
    setUdata(hfig,Udata)
    switch mode
      case 'orbit'
	orbitPangca(hfig,haxes,scaled_deltaPix, 'o');
      case 'orbitscenelight'
	orbitLightgca(haxes,scaled_deltaPix);
      case 'pan'
	orbitPangca(hfig,haxes,scaled_deltaPix, 'p');
      %case 'roll'
	%rollgca(haxes,deltaPix);
	  case 'walk'
	walkgca(haxes,scaled_deltaPixStart,1);
    end
  end
case 'keymotion'
   cameratoolbar(hfig,'down',logical(0));
   
   Udata = getUdata(hfig);
   if isstruct(Udata) & isfield(Udata,'figLastPoint')
       if (etime(clock,Udata.time))<.3
           multFact=20;  %should rotate faster when the key is held down
       else
           multFact=5;
       end
       set(hfig,'currentpoint',Udata.figLastLastPoint + multFact*vargin{2});
       
       cameratoolbar(hfig,'motion');
       cameratoolbar(hfig,'up');
   end
case 'stopmoving'
  Udata.moving = 0;
  setUdata(hfig,Udata)
case 'updatetoolbar'
  updateToolbar(hfig)
case 'setmodegui'
    %setmodegui differs from setmode in that setting the same
    %mode as the current mode will toggle it off
    newmode = lower(vargin{2});
    if strcmp(Udata.mode, newmode)
        cameratoolbar(hfig,'nomode')
        Udata = getUdata(hfig);
    else
        showInfoDlg(haxes);
        Udata.mode = newmode;
        scribeclearmode(hfig,'cameratoolbar', 'nomode');
    end
	if iscameraobj(haxes)
		if strcmp(Udata.mode, 'walk')
			camproj(haxes,'perspective');
		end
	end
    setUdata(hfig,Udata)
    updateToolbar(hfig)
case 'setmode'
    newmode = lower(vargin{2});
    if strcmp(newmode, 'nomode')
        cameratoolbar(hfig,'nomode')
    else
        Udata.mode = newmode;
        scribeclearmode(hfig,'cameratoolbar', 'nomode');
		
	    if iscameraobj(haxes)
			if strcmp(Udata.mode, 'walk')
				camproj(haxes,'perspective');
			end
		end
		setUdata(hfig,Udata)
        updateToolbar(hfig)
	end
case 'keypress'
    if(isempty(haxes)) return; end
    
    switch get(hfig,'currentcharacter')
    case 'o'
        cameratoolbar(hfig,'setmode','orbit');
    case 'l'
        cameratoolbar(hfig,'setmode','orbitscenelight');
    case 'p'
        cameratoolbar(hfig,'setmode','pan');
    case 'd'
        cameratoolbar(hfig,'setmode','dollyhv');
    case 'z'
        cameratoolbar(hfig,'setmode','zoom');
    case 'r'
        cameratoolbar(hfig,'setmode','roll');
    case 'w'
        cameratoolbar(hfig,'setmode','walk');
    case 'D'
        cameratoolbar(hfig,'setmode','dollyfb');
    case char(28) %left
        cameratoolbar(hfig,'keymotion',[-1  0]);
    case char(29) %right
        cameratoolbar(hfig,'keymotion',[ 1  0]);
    case char(30) %up
        cameratoolbar(hfig,'keymotion',[ 0  1]);
    case char(31) %down
        cameratoolbar(hfig,'keymotion',[ 0 -1]);
    case 'c'
        postContextMenu(hfig,haxes);
    end
case 'setcoordsys'
  newcoordsys = lower(vargin{2});
  Udata.coordsys = newcoordsys;
  setUdata(hfig,Udata)
  if iscameraobj(haxes)
	  if length(Udata.coordsys)==1
		  coordsysval =  lower(Udata.coordsys) - 'x' + 1;
		  
		  d = [0 0 0];
		  d(coordsysval) = 1;
		  
		  up = camup(haxes);
		  if up(coordsysval) < 0
			  d = -d;
		  end
		  
		  % Check if the camera up vector is parallel with the view direction;
		  % if not, set the up vector
		  if any(crossSimple(d,campos(haxes)-camtarget(haxes)))
			  camup(haxes,d)
			  validateScenelights(hfig,haxes)
			  updateScenelightPosition(hfig,haxes);
		  end  
	  end
  end
  updateToolbar(hfig)  
case 'togglescenelight'
  if iscameraobj(haxes)
	  validateScenelights(hfig,haxes)
	  Udata = getUdata(hfig);
	  sl = Udata.scenelights;
	  ax = haxes;
	  if isempty(sl)
		  val = 1;
	  else
		  index = find([sl.ax]==ax);
		  val = ~sl(index).on;
	  end
	  
	  if ~val & strcmp(Udata.mode, 'orbitscenelight')
		  Udata.mode = 'orbit';
		  setUdata(hfig,Udata)
		  updateToolbar(hfig)
	  end
	  updateScenelightOnOff(hfig,haxes,val);
	  updateScenelightPosition(hfig,haxes);
  end
case 'setprojection'
  if iscameraobj(haxes)
	  camproj(haxes,lower(vargin{2}));
  end
case 'resetscenelight'
  if iscameraobj(haxes)
	  resetScenelight(hfig,haxes);
  end
case 'resetall'
  h = [Udata.scenelights.h]; delete(h(ishandle(h)));
  initUdata(hfig);
  updateToolbar(hfig)
  cameratoolbar('resetcameraandscenelight');
case 'resetcameraandscenelight'
  if iscameraobj(haxes)
	  resetCameraProps(hfig,haxes)
	  resetScenelight(hfig,haxes);
  end
case 'resetcamera'
  if iscameraobj(haxes)
	  resetCameraProps(hfig,haxes);
  end
case 'resettarget'
  if iscameraobj(haxes)
	  camtarget(haxes,'auto');
	  validateScenelights(hfig,haxes)
	  updateScenelightPosition(hfig,haxes);
  end
case 'noreset'
  r=cameratoolbar(hfig,'show');
case 'nomode'
  Udata.mode = '';
  restoreWindowCallbacks(hfig,Udata.wcb);
  setUdata(hfig,Udata)
  updateToolbar(hfig)
  restoreWindowCursor(hfig,Udata.cursor);
  removeContextMenu(hfig);
case 'init'
  emptyUdata = isempty(Udata);
  wcb = getWindowCallBacks(hfig);
  cursor = getWindowCursor(hfig);
  ctb = findall(hfig, 'tag', 'CameraToolBar');
  if isempty(ctb)
    r = createToolbar(hfig);
  end
  if ~emptyUdata    
    h = [Udata.scenelights.h]; delete(h(ishandle(h)));
  end
  initUdata(hfig);
  Udata = getUdata(hfig);
  if emptyUdata
    Udata.wcb = wcb;
    Udata.cursor = cursor;
  end
  setUdata(hfig,Udata)
  updateToolbar(hfig)
case 'show'
  set(Udata.mainToolbarHandle, 'visible', 'on');
case 'hide'
  set(Udata.mainToolbarHandle, 'visible', 'off');
case 'toggle'
  h = Udata.mainToolbarHandle;
  newval = strcmp(get(h, 'visible'), 'off');
  set(h, 'visible', bool2OnOff(newval))
case 'getvisible'
  if isempty(Udata)
    r = 0;
  else
    h = Udata.mainToolbarHandle;
    r = strcmp(get(h, 'visible'), 'on');
  end
case 'getmode'
  if isempty(Udata)
    r = '';
  else
    r = Udata.mode;
  end
case 'getcoordsys'
  if isempty(Udata)
    r = 'z';
  else
    r = Udata.coordsys;
  end
case 'close'
  restoreWindowCallbacks(hfig,Udata.wcb);
  restoreWindowCursor(hfig,Udata.cursor);
  cameratoolbar('stopmoving')
  h = [Udata.scenelights.h]; delete(h(ishandle(h)));
  if ishandle(Udata.mainToolbarHandle) delete(Udata.mainToolbarHandle); end
  setUdata(hfig,[]);
case 'setaspectratio'
	axis(haxes,lower(vargin{2}));
end

if nargout>0
    ret = r;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localDrawnow(hfig)

Udata = getUdata(hfig);

% Calling drawnow will result in hang, see g201318
if Udata.moving == 1
  drawnow
else
  drawnow expose
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function orbitPangca(hfig,haxes,xy, mode)
Udata = getUdata(hfig);

%mode = 'o';  orbit
%mode = 'p';  pan


coordsys = lower(Udata.coordsys);
if coordsys(1)=='n'
  coordsysval = 0;
else
  coordsysval = coordsys(1) - 'x' + 1;
end

xy = -xy;

if mode=='p' % pan
  panxy = xy*camva(haxes)/500;
end
  
if coordsysval>0
  d = [0 0 0];
  d(coordsysval) = 1;
  
  up = camup(haxes);
  upsidedown = (up(coordsysval) < 0);
  if upsidedown 
    xy(1) = -xy(1);
    d = -d;
  end

  % Check if the camera up vector is parallel with the view direction;
  % if not, set the up vector
  if any(crossSimple(d,campos(haxes)-camtarget(haxes)))
    camup(haxes,d)
  end  
end

flag = 1;

while sum(abs(xy))> 0 & isstruct(Udata) & (flag | Udata.moving==1) & ishandle(haxes)
  flag = 0;
  Udata = getUdata(hfig);
  
  if mode=='o' %orbit
    if coordsysval==0 %unconstrained
      camorbit(haxes,xy(1), xy(2), coordsys)
    else
      camorbit(haxes,xy(1), xy(2), 'data', coordsys)
    end
  else %pan
    if coordsysval==0 %unconstrained
      campan(haxes,panxy(1), panxy(2), coordsys)
    else
      campan(haxes,panxy(1), panxy(2), 'data', coordsys)
    end
  end
  
  updateScenelightPosition(hfig,haxes);
  localDrawnow(hfig);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function orbitLightgca(hfig,haxes,xy)
Udata = getUdata(hfig);
sl = Udata.scenelights;
ax = haxes;
index = find([sl.ax]==ax);

if sum(abs(xy))> 0 & ~sl(index).on
  updateScenelightOnOff(hfig,haxes,1);
  Udata = getUdata(hfig);
  sl = Udata.scenelights;
end

% Check if the light is on the other side of the object
az = mod(abs(sl(index).az),360);
if az > 90 & az < 270
  xy(2) = -xy(2);
end

flag = 1;

while sum(abs(xy))> 0 & isstruct(Udata) & (flag | Udata.moving==1) & ishandle(haxes)
    
  Udata = getUdata(hfig);  
  
  flag = 0;
  
  az = sl(index).az;
  el = sl(index).el;
  
  az = mod(az + xy(1), 360);
  el = mod(el + xy(2), 360);
  
  if abs(el) > 90
    el = 180 - el;
    az = 180 + az;
    xy(2) = -xy(2);
  end
  
  sl(index).az = az;
  sl(index).el = el;

  Udata.scenelights = sl;
  setUdata(hfig,Udata)
  updateScenelightPosition(hfig,haxes);
  
  localDrawnow(hfig)
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function walkgca(hfig,haxes,xy1,walk_flag)
persistent xy v up d cva q
xy = xy1;

%Walk is unique in that it calls recursively, so we need to be
%careful not to blow the recursion limit.  Here we check to see
%if we are just shy of the limit.  If we are, stop walking.
if length(dbstack)<get(0,'recursionlimit')-16
	Udata = getUdata(hfig);
	
	coordsys = lower(Udata.coordsys);
	if coordsys(1)=='n'
		coordsysval = 0;
	else
		coordsysval = coordsys(1) - 'x' + 1;
	end
	if coordsysval>0
		
		d = [0 0 0];
		d(coordsysval) = 1;
		
		up = camup(haxes);
		if up(coordsysval) < 0
			d = -d;
		end
	end
	
	q = max(-.9, min(.9, xy(2)/700));
	cva = camva(haxes);
	
	recursionflag = 1;

	while sum(abs(xy))> 0 & isstruct(Udata) & recursionflag & Udata.moving==1 & ishandle(haxes)
		
        Udata = getUdata(hfig);
        
		if coordsysval==0 %unconstrained
			campan(haxes,xy(1)*cva/700, 0, 'camera')
			v = q*(camtarget(haxes)-campos(haxes));
		else
			campan(haxes,xy(1)*cva/700, 0, 'data', d)
			
			% Check if the camera up vector is parallel with the view direction;
			% if not, set the up vector
			if any(crossSimple(d,campos(haxes)-camtarget(haxes)))
				camup(haxes,d);
			end
			
			v = q*(camtarget(haxes)-campos(haxes));
			v(coordsysval) = 0;
		end
		camdolly(haxes,v(1), v(2), v(3), 'movetarget', 'data')
		updateScenelightPosition(hfig,haxes);
		if isempty(walk_flag)
			localDrawnow(hfig);
		else
			drawnow expose
			recursionflag = 0;
		end
	end
else
	%In the event that we are near our recursion limit,
	%stop moving the camera.
	%
	%This is essentially the code in "cameratoolbar('up')"
	%it is copied here instead of referenced because calling
	%cameratoolbar('up') from here seems to cause timing issues.
	%Also, cameratoolbar('up') contains some checking for throws
	%which we don't want here.
	
	hfig = hfig;
	set(hfig, 'windowbuttonmotionfcn', '')
	set(hfig, 'windowbuttonupfcn', '')
	
	Udata = getUdata(hfig);
	Udata.buttondown = 0;
	Udata.moving   = 0;
        pt = hgconvertunits(hfig,[0 0 get(hfig,'CurrentPoint')],...
                            get(hfig,'Units'),'pixels',0);
        pt = pt(3:4);
	deltaPix  = pt-Udata.figLastLastPoint;
	deltaPixStart  = pt-Udata.figStartPoint;
	Udata.figLastPoint = pt;
	setUdata(hfig,Udata)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dollygca(hfig,haxes,xy)
camdolly(haxes,-xy(1), -xy(2), 0, 'movetarget', 'pixels')
updateScenelightPosition(hfig,haxes);
localDrawnow(hfig);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function zoomgca(hfig,haxes,xy)

q = max(-.9, min(.9, sum(xy)/70));

% hueristic avoids small view angles which will crash on solaris
MIN_VIEW_ANGLE = .001;  
va = camva(haxes);

if va>MIN_VIEW_ANGLE
  camzoom(haxes,1+q);
  localDrawnow(hfig);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function forwardBackgca(hfig,haxes,xy, mode)

q = max(-.9, min(.9, sum(xy)/70));

if mode=='b'
  camdolly(haxes,0,0,q);
else
  camdolly(haxes,0,0,q, 'f');
end

updateScenelightPosition(hfig,haxes);
localDrawnow(hfig);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rollgca(hfig,haxes,dxy, pt)
Udata = getUdata(hfig);

% find the pixel center of the axes
pos = hgconvertunits(hfig,get(haxes,'Position'),...
                     get(haxes,'Units'),'pixels',get(haxes,'parent'));
center = pos(1:2)+pos(3:4)/2;

startpt = pt - dxy;

v1 = pt-center;
v2 = startpt-center;

v1 = v1/norm(v1);
v2 = v2/norm(v2);
theta = acos(sum(v2.*v1)) * 180/pi;
cross =  crossSimple([v1 0],[v2 0]);
if cross(3) >0
  theta = -theta;
end

flag = 1;

while isstruct(Udata) & (flag | Udata.moving==1) & ishandle(haxes)
  flag = 0;
  Udata = getUdata(hfig);
   
  camroll(haxes,theta);
  
  updateScenelightPosition(hfig,haxes);

  localDrawnow(hfig)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=createToolbar(hfig)
h = uitoolbar(hfig, 'HandleVisibility','off');
props.Parent = h;

Udata.mainToolbarHandle = h;

load camtoolbarimages

props.HandleVisibility = 'off';

u = [];
props.ClickedCallback = 'cameratoolbar(''setmodeGUI'', ''orbit'')';
props.ToolTip = 'Orbit Camera';
props.CData = camtoolbarimages.orbit;
props.Tag = 'orbit';
u(end+1) = uitoggletool(props);

props.ClickedCallback = 'cameratoolbar(''setmodeGUI'', ''orbitscenelight'')';
props.ToolTip = 'Orbit Scene Light';
props.CData = camtoolbarimages.orbitlight;
props.Tag = 'orbitscenelight';
u(end+1) = uitoggletool(props);

props.ClickedCallback = 'cameratoolbar(''setmodeGUI'', ''pan'')';
props.ToolTip = 'Pan/Tilt Camera';
props.CData = camtoolbarimages.pan;
props.Tag = 'pan';
u(end+1) = uitoggletool(props);

props.ClickedCallback = 'cameratoolbar(''setmodeGUI'', ''dollyhv'')';
props.ToolTip = 'Move Camera Horizontally/Vertically';
props.CData = camtoolbarimages.hv;
props.Tag = 'dollyhv';
u(end+1) = uitoggletool(props);

props.ClickedCallback = 'cameratoolbar(''setmodeGUI'', ''dollyfb'')';
props.ToolTip = 'Move Camera Forward/Back';
props.CData = camtoolbarimages.fb;
props.Tag = 'dollyfb';
u(end+1) = uitoggletool(props);

props.ClickedCallback = 'cameratoolbar(''setmodeGUI'', ''zoom'')';
props.ToolTip = 'Zoom Camera';
props.CData = camtoolbarimages.zoom;
props.Tag = 'zoom';
u(end+1) = uitoggletool(props);

props.ClickedCallback = 'cameratoolbar(''setmodeGUI'', ''roll'')';
props.ToolTip = 'Roll Camera';
props.CData = camtoolbarimages.roll;
props.Tag = 'roll';
u(end+1) = uitoggletool(props);

% props.ClickedCallback = 'cameratoolbar(''setmodeGUI'', ''walk'')';
% props.ToolTip = 'Walk Camera';
% props.CData = camtoolbarimages.walk;
% props.Tag = 'walk';
% u(end+1) = uitoggletool(props);

Udata.ModeHandles = u;

u = [];
props.ClickedCallback = 'cameratoolbar(''setcoordsys'', ''x'')';
props.ToolTip = 'Principal Axis X';
props.CData = camtoolbarimages.x;
props.Tag = 'x';
u(end+1) = uitoggletool(props,...
        'Separator', 'on');

props.ClickedCallback = 'cameratoolbar(''setcoordsys'', ''y'')';
props.ToolTip = 'Principal Axis Y';
props.CData = camtoolbarimages.y;
props.Tag = 'y';
u(end+1) = uitoggletool(props);

props.ClickedCallback = 'cameratoolbar(''setcoordsys'', ''z'')';
props.ToolTip = 'Principal Axis Z';
props.CData = camtoolbarimages.z;
props.Tag = 'z';
u(end+1) = uitoggletool(props);

props.ClickedCallback = 'cameratoolbar(''setcoordsys'', ''none'')';
props.ToolTip = 'No Principal Axis';
props.CData = camtoolbarimages.none;
props.Tag = 'none';
u(end+1) = uitoggletool(props);

Udata.PrincipalAxisHandles = u;

u = [];
props.ClickedCallback = 'cameratoolbar(''togglescenelight'')';
props.ToolTip = 'Toggle Scene Light';
props.CData = camtoolbarimages.light;
u(end+1) = uipushtool(props,...
        'Separator', 'on');

props.ClickedCallback = 'cameratoolbar(''setprojection'', ''orthographic'')';
props.ToolTip = 'Orthographic Projection';
props.CData = camtoolbarimages.ortho;
u(end+1) = uipushtool(props,...
        'Separator', 'on');

props.ClickedCallback = 'cameratoolbar(''setprojection'', ''perspective'')';
props.ToolTip = 'Perspective Projection';
props.CData = camtoolbarimages.perspective;
u(end+1) = uipushtool(props);

	
props.ClickedCallback = 'cameratoolbar(''resetcameraandscenelight'')';
props.ToolTip = 'Reset Camera and Scene Light';
props.CData = camtoolbarimages.reset;
u(end+1) = uipushtool(props,...
        'Separator', 'on');

u = [];
props.ClickedCallback = 'cameratoolbar(''stopmoving'')';
props.ToolTip = 'Stop Camera/Light Motion';
props.CData = camtoolbarimages.stop;
u(end+1) = uipushtool(props);

Udata.stopMovingHandle = u;

set(Udata.mainToolbarHandle, 'tag', 'CameraToolBar', 'visible', 'off','serializable','off');
setUdata(hfig,Udata)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function updateToolbar(hfig)
Udata = getUdata(hfig);

set(Udata.ModeHandles, 'state', 'off')
set(findall(Udata.ModeHandles, 'tag', Udata.mode), 'state', 'on');

set(Udata.PrincipalAxisHandles, 'state', 'off', 'enable', 'on')
if ~isempty(Udata.mode) & strmatch(Udata.mode, {'orbit' 'pan' 'walk'})
  set(findall(Udata.PrincipalAxisHandles, 'tag', Udata.coordsys), 'state', 'on');
else
  set(Udata.PrincipalAxisHandles, 'enable', 'off');
end

if ~isempty(Udata.mode)
  initWindowCallbacks(hfig);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Udata = getUdata(hfig)

Udata = getappdata(hfig, 'ctb200jaz');

% Since the camera toolbar IS NOT serialized by design, Udata 
% will have an invalid toolbar handle when opening a fig file 
% since the figure object, which IS serialized, stores the Udata.
if ~isempty(Udata) & isfield(Udata,'mainToolbarHandle') & ~ishandle(Udata.mainToolbarHandle)     
       Udata = [];
end
     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setUdata(hfig,Udata)

setappdata(hfig, 'ctb200jaz', Udata);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function initUdata(hfig)
Udata = getUdata(hfig);

Udata.mode = '';
Udata.coordsys = 'z';
%Udata.optimizeaxesmode = 'ask';

Udata.buttondown = 0;
Udata.moving = 0;
Udata.time = clock;

Udata.defaultAz = 30;
Udata.defaultEl = 30;
Udata.scenelights = struct('ax', {}, 'h', {}, 'on', {}, 'az', {}, 'el', {});

setUdata(hfig,Udata);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function updateScenelightPosition(hfig,haxes)

Udata = getUdata(hfig);
sl = Udata.scenelights;
ax = haxes;
index = find([sl.ax]==ax);

sl = sl(index);
if sl.on
  camlight(sl.h, sl.az, sl.el, 'infinite')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function updateScenelightOnOff(hfig,haxes,val)
Udata = getUdata(hfig);
sl = Udata.scenelights;
ax = haxes;
index = find([sl.ax]==ax);

sl(index).on = val;
set(sl(index).h, 'vis', bool2OnOff(val))

Udata.scenelights = sl;
setUdata(hfig,Udata);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function validateScenelights(hfig,haxes)
Udata = getUdata(hfig);
sl = Udata.scenelights;
index = ~ishandle([sl.ax]); sl(index) = [];
index = ~ishandle([sl.h]); sl(index) = [];
ax = haxes;
if isempty(sl)
  index = [];
else
  index = find([sl.ax]==ax);
end

if isempty(index)
  index = prod(size(sl))+1;
  sl(index) = struct('ax', ax, 'h', -1, 'on', 0, ...
		     'az', Udata.defaultAz, 'el', Udata.defaultEl);
end

if ~ishandle(sl(index).h)
  h = light('parent',haxes);
  sl(index).h = h;
  set(h, 'visible', 'off', 'HandleVisibility', 'off', ...
	 'tag', 'CameraToolBarScenelight')
end

Udata.scenelights = sl;
setUdata(hfig,Udata)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function resetScenelight(hfig,haxes)
validateScenelights(hfig,haxes)

Udata = getUdata(hfig);
sl = Udata.scenelights;
ax = haxes;
index = find([sl.ax]==ax);

sl(index).az = Udata.defaultAz;
sl(index).el = Udata.defaultEl;

Udata.scenelights = sl;
setUdata(hfig,Udata)

updateScenelightPosition(hfig,haxes);
  

  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dlgShown=showInfoDlg(haxes)

persistent CameratoolbarInfoDialogShown

if isempty(CameratoolbarInfoDialogShown)
    CameratoolbarInfoDialogShown=0;
end

if ~CameratoolbarInfoDialogShown
    ax=haxes;
    CameratoolbarInfoDialogShown=1;
    [selectedButton,dlgShown]=uigetpref('cameratoolbar','donotshowinfodlg',...
        'Aspect Ratio Adjustment',...
        {'Plots may change appearance so that aspect ratios remain'
        'unchanged during 3D rotation.  Check the "Auto aspect'
        'ratio" context menu item to have the axes reshape to fit'
        'the figure.'},...
        {'OK'},...
        'DefaultButton','OK',...
        'HelpString','Help',...
        'HelpFcn','helpview(fullfile(docroot,''mapfiles'',''visualize.map''), ''axes_aspect_ratio'');');
else
    dlgShown=0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function initWindowCallbacks(hfig)
set(hfig, 'windowbuttondownfcn',   'cameratoolbar(''down'')')
set(hfig, 'windowbuttonupfcn',     '')
set(hfig, 'windowbuttonmotionfcn', '')
%set(hfig, 'keypressfcn',           'cameratoolbar(''keypress'')');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ret = getWindowCallBacks(hfig)
ret{1} = get(hfig, 'windowbuttondownfcn'   );
ret{2} = get(hfig, 'windowbuttonmotionfcn' );
ret{3} = get(hfig, 'windowbuttonupfcn'     );
%ret{4} = get(hfig, 'keypressfcn'           );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ret = restoreWindowCallbacks(hfig,cb)
set(hfig, 'windowbuttondownfcn',   cb{1});
set(hfig, 'windowbuttonmotionfcn', cb{2});
set(hfig, 'windowbuttonupfcn',     cb{3});
%set(hfig, 'keypressfcn',           cb{4});


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ret = getWindowCursor(hfig)
ret{1} = get(hfig, 'pointer'  );
ret{2} = get(hfig, 'pointershapecdata' );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ret = restoreWindowCursor(hfig,cursor)
set(hfig, 'pointer'  ,         cursor{1});
set(hfig, 'pointershapecdata', cursor{2});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ret=bool2OnOff(val)
if val
  ret = 'on';
else
  ret = 'off';
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% simple cross product
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=crossSimple(a,b)
c(1) = b(3)*a(2) - b(2)*a(3);
c(2) = b(1)*a(3) - b(3)*a(1);
c(3) = b(2)*a(1) - b(1)*a(2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function resetCameraProps(hfig,haxes)
camva(haxes,'auto'); campos(haxes,'auto'); camtarget(haxes,'auto'); daspect(haxes,'auto'); camup(haxes,'auto'); 
view(haxes,3);
daspect(haxes,daspect(haxes)); camva(haxes,camva(haxes)); 
axis(haxes,'tight');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=postContextMenu(hfig,haxes)

menuTag='CameratoolbarContextMenu';

h = findall(hfig,'type','uicontextmenu','tag',menuTag);
if isempty(h)
    h=uicontextmenu('parent',hfig,...
        'HandleVisibility','off',...
        'tag',menuTag);
    
    menus={...
        'Camera &Motion',                  'CameraMotionMode',          '',
        '>&Orbit Camera',                  'CameraMode_orbit',          'cameratoolbar setmodegui orbit',
        '>Orbit Scene &Light',             'CameraMode_orbitscenelight','cameratoolbar setmodegui orbitscenelight',
        '>&Pan - Turn/Tilt',               'CameraMode_pan',            'cameratoolbar setmodegui pan',
        '>Move - &Horizontally/Vertically','CameraMode_dollyhv',        'cameratoolbar setmodegui dollyhv',
        '>Move - &Forward/Back',           'CameraMode_dollyfb',        'cameratoolbar setmodegui dollyfb',
        '>&Zoom',                          'CameraMode_zoom',           'cameratoolbar setmodegui zoom',
        '>&Roll',                          'CameraMode_roll',           'cameratoolbar setmodegui roll',
        '>&Walk',                          'CameraMode_walk',           'cameratoolbar setmodegui walk',
        'Camera A&xis',                    'CameraPAx',                 '',
        '>&X Principal Axis',              'CameraAxis_x',              'cameratoolbar setcoordsys x',
        '>&Y Principal Axis',              'CameraAxis_y',              'cameratoolbar setcoordsys y',
        '>&Z Principal Axis',              'CameraAxis_z',              'cameratoolbar setcoordsys z',
        '>&No Principal Axis',             'CameraAxis_none',           'cameratoolbar setcoordsys none',
        'Camera Re&set',                   'CameraReset_parent',        '',
        '>Reset &Camera && Scene Light',   'CameraReset_',              'cameratoolbar(''resetcameraandscenelight'');',
        '>Reset &Target Point',            'CameraReset_cameralight',   'cameratoolbar(''resettarget'')',
        '>Reset &Scene Light',             'CameraReset_targetpoint',   'cameratoolbar(''resetscenelight'');',
        '-------',                         'CameraReset_scenelight',    '',
        '&Projection',                     'CameraProj',                '',
        '>&Orthographic',                  'CameraProj_orthographic',   'cameratoolbar(''setprojection'', ''orthographic'')',
        '>&Perspective',                   'CameraProj_perspective',    'cameratoolbar(''setprojection'', ''perspective'')',
        '&Auto aspect ratio',              'CameraBash',                'cameratoolbar(''setaspectratio'', ''normal'')',
        };
    
    makemenu(h,str2mat(menus{:,1}),str2mat(menus{:,3}),str2mat(menus{:,2}));
else
    h=h(1);
end


%initialize camera motion mode check
hCameraMotion=findobj(h,'tag','CameraMotionMode');
hCameraMotionChildren=get(hCameraMotion,'children');
set(hCameraMotionChildren,'checked','off');
hCameraMotionTarget=findobj(hCameraMotionChildren,'tag',['CameraMode_' cameratoolbar(hfig,'getmode')]);
set(hCameraMotionTarget,'checked','on');

%initialize camera principal axis check
paxParent=findall(h,'tag','CameraPAx');
paxItems=allchild(paxParent);
offon={'off','on'};
isActive=ismember(cameratoolbar(hfig,'getmode'), {'orbit' 'pan' 'walk'});
set(paxItems,'checked','off','enable',offon{isActive+1});

if isActive
    currPAx=cameratoolbar(hfig,'getcoordsys');
    activeItem=findall(paxItems,'tag',['figMenuAxis_' currPAx]);
    set(activeItem,'Checked','on');
end

%initialize projection
projParent =  findall(h,'tag','CameraProj');
projItems=allchild(projParent);
set(projItems,'checked','off');
activeItem=findall(projItems,'tag',['CameraProj_' get(haxes,'projection')]);
set(activeItem,'Checked','on');

%initialize axis vis3d item
if strcmp(get(haxes,'warptofill'),'off')
    check='off';
    cbk='cameratoolbar(''setaspectratio'', ''normal'')'; %'axis(haxes,normal)';
else
    check='on';
    cbk='cameratoolbar(''setaspectratio'', ''vis3d'')'; %'axis(haxes,vis3d)';
end
vis3dItem=findall(h,'tag','CameraBash');
set(vis3dItem,'checked',check,'callback',cbk);

%post menu==========================
set(h,...
    'Position',get(hfig,'CurrentPoint'),...
    'Visible','on')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function removeContextMenu(hfig)

menuTag='CameratoolbarContextMenu';
h = findall(hfig,'type','uicontextmenu','tag',menuTag);
delete(h);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function val=iscameraobj(haxes)
% Checking if the selected axes is for a valid object to perform camera functions on.

if ~isempty(haxes)
	if ~isa(handle(haxes),'graph2d.legend') & ~isa(handle(haxes),'graph3d.colorbar')
		val = logical(1);
	else
		val = logical(0);
	end
else
	val = logical(0);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hfig,haxes]=currenthandles(hfig)
% Obtaining the correct handle to the current figure and axes in all cases:
% handlevisibility ON-gcbf; OFF-gcbf/gcf.

if nargin<1
    if ~isempty(gcbf)
	   hfig=gcbf;
    else
	   hfig=gcf;
    end
end

haxes = get(hfig,'CurrentAxes');

