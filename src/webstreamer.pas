unit webstreamer;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface

uses
  uos_flat,
  msetypes,
  mseglob,
  mseguiglob,
  mseguiintf,
  mseapplication,
  msestat,
  ctypes,
  msemenus,
  msegui,
  msegraphics,
  msegraphutils,
  mseevent,
  Classes,
  mseclasses,
  mseforms,
  msedock,
  msesimplewidgets,
  msewidgets,
  msedispwidgets,
  mserichstring,
  mseact,
  msedataedits,
  msedropdownlist,
  mseedit,
  mseificomp,
  mseificompglob,
  mseifiglob,
  msestatfile,
  msestream,
  SysUtils,
  msegraphedits,
  msescrollbar,
  msebitmap,
  msedragglob,
  msegrids,
  msegridsglob;

type
  boundchild = record
    left: integer;
    top: integer;
    Width: integer;
    Height: integer;
    Name: string;
  end;

type
  twebstreamerfo = class(tdockform)
    historyfn: thistoryedit;
    infopanel: tstringdisp;
    panelcommand: tpaintbox;
    sliderimage: tbitmapcomp;
    breset: TButton;
    edvolr: tslider;
    vuRight: tprogressbar;
    vuLeft: tprogressbar;
    edvol: tslider;
    btnStop: TButton;
    btnResume: TButton;
    btnPause: TButton;
    btnStart: TButton;
    edtempo: tslider;
    tfacecomp3: tfacecomp;
    edpitch: tslider;
    lvl: tlabel;
    lvr: tlabel;
    lte: tlabel;
    lpi: tlabel;
    tstatfile1: tstatfile;
    btempo: TButton;
    brecord: TButton;
    tframecomp2: tframecomp;
    tmainmenu1: tmainmenu;
    runselect: tbooleanedit;
    showwave: tbooleanedit;
    thistoryedit2: thistoryedit;
    deleteallurl: tstringdisp;
    byes: TButton;
    bno: TButton;
    tfacecomp4: tfacecomp;
    panelwave: tpaintbox;
    timagelist3: timagelist;
    griddisp: tstringgrid;
    showgrid: tbooleanedit;
    tfacecomp6: tfacecomp;
    tfacecomp7: tfacecomp;
    tfacecomp8: tfacecomp;
    tfacecomp9: tfacecomp;
    edeviceselected: tintegeredit;
    mp3format: tbooleaneditradio;
    tlabel2: tlabel;
    tlabel3: tlabel;
    aacformat: tbooleaneditradio;
    edrecformat: tintegeredit;
    baddrow: TButton;
    bdelrow: TButton;
    tfacecomp2: tfacecomp;
    edstyle: tintegeredit;
    procedure onplay(const Sender: TObject);
    procedure oneventstart(const Sender: TObject);
    procedure onstop(const Sender: TObject);
    procedure onclosed(const Sender: TObject);
    procedure onpause(const Sender: TObject);
    procedure onresume(const Sender: TObject);
    procedure ShowLevel();
    procedure LoopProcPlayer1;
    procedure DrawLive(lv, rv: double);
    procedure InitDrawLive();
    procedure onchangevol(const Sender: TObject);
    procedure onchangeshowwave(const Sender: TObject);
    procedure oncreate(const Sender: TObject);
    procedure ChangePlugSetSoundTouch(const Sender: TObject);
    procedure onreset(const Sender: TObject);
    procedure onrec(const Sender: TObject);
    procedure ontempo(const Sender: TObject);
    procedure onafterdropdown(const Sender: TObject);
    procedure onaftermenushowwav(const Sender: TObject);
    procedure onafterplayafter(const Sender: TObject);
    procedure onclearhist(const Sender: TObject);
    procedure cancelclear(const Sender: TObject);
    procedure showclear(const Sender: TObject);
    procedure showlis(const Sender: TObject);
    procedure oncellev(const Sender: TObject; var info: celleventinfoty);
    procedure oncheckdevices();
    procedure onafterdevice(const Sender: TObject);
    procedure onexit(const Sender: TObject);
    procedure onupdevices(const Sender: TObject);
    procedure onaftermenusetrecformat(const Sender: TObject);
    procedure resizesp(fontheight: integer);
    procedure setstyle(style: integer);
    procedure addrow(const Sender: TObject);
    procedure deleterow(const Sender: TObject);
   procedure onexecswpstyle(const sender: TObject);
   end;

const
  version = 250211;

var
  webstreamerfo: twebstreamerfo;
  webindex, webinindex, weboutindex, webPlugIndex, fontheight: integer;
  rectrecform: rectty;
  xreclive, devcount, incview, deviceselected: integer;
  plugsoundtouch: Boolean = False;
  isinit: Boolean = False;
  isexit: Boolean = False;
  ordir, arecnp: string;
  pa, mp, aa, st: string;
  boundchildsp: array of boundchild;
  noaac: Boolean = False;
 {$if defined(darwin) and defined(macapp)}
  binPath: string;
 {$ENDIF}
// icy_data: pchar;

implementation

uses
  webstreamer_mfm;

procedure twebstreamerfo.oncheckdevices();
var
  x: integer;
  prestr, typ: string;
begin
  if isinit = False then
    UOS_GetInfoDevice()
  else
    uos_UpdateDevice;

  tmainmenu1.menu.itembynames(['config', 'devices', '-1']).Visible := True;

  for x := 0 to 30 do
    tmainmenu1.menu.itembynames(['config', 'devices', IntToStr(x)]).Visible := False;

  if UOSDeviceCount < 31 then
    devcount := UOSDeviceCount
  else
    devcount := 31;

  x := 0;
  while x < devcount do
  begin
    if x < 10 then
      prestr := ' '
    else
      prestr := '';

    if UOSDeviceInfos[x].DefaultDevOut = True then
      tmainmenu1.menu.itembynames(['config', 'devices', '-1']).Caption :=
        '-1 = Default = Out = ' + msestring(UOSDeviceInfos[x].DeviceName);

    if UOSDeviceInfos[x].DeviceType = 'In' then
    begin
      tmainmenu1.menu.itembynames(['config', 'devices', IntToStr(x)]).Enabled := False;
      typ := ' = In ';
    end
    else
    begin
      tmainmenu1.menu.itembynames(['config', 'devices', IntToStr(x)]).Enabled := True;
      typ := ' = Out ';
    end;

    tmainmenu1.menu.itembynames(['config', 'devices', IntToStr(x)]).Visible := True;

    tmainmenu1.menu.itembynames(['config', 'devices', IntToStr(x)]).Caption :=
      prestr + msestring(IntToStr(UOSDeviceInfos[x].DeviceNum)) + typ +
      '= ' + msestring(UOSDeviceInfos[x].DeviceName);
    Inc(x);
  end;

  deviceselected := edeviceselected.Value; // for stat file 

  if deviceselected <> -1 then
    tmainmenu1.menu.itembynames(['config', 'devices', IntToStr(deviceselected)]).state :=
      [as_checked, as_localchecked, as_localcaption, as_localonafterexecute];

end;

procedure twebstreamerfo.ChangePlugSetSoundTouch(const Sender: TObject);
var
  abool: Boolean;
begin
  if btempo.tag = 0 then
    abool := False
  else
    abool := True;
  if brecord.tag = 0 then
  begin
    if edtempo.Value = 0.5 then
      lte.Caption := 'Tempo'
    else
      lte.Caption := ' T' + IntToStr(round(edtempo.Value * 200));
    if edpitch.Value = 0.5 then
      lpi.Caption := 'Pitch'
    else
      lpi.Caption := 'P' + IntToStr(round(edpitch.Value * 200));
    uos_SetPluginSoundTouch(webindex, webplugindex, edtempo.Value * 2, edpitch.Value * 2, abool);
  end;

end;

procedure twebstreamerfo.InitDrawLive();
var transpcolor : longint = $B6C4AF;
begin

if edstyle.value = 0 then transpcolor := $5F605F;
if edstyle.value = 1 then transpcolor := cl_black;
if edstyle.value = 2 then transpcolor := $636363;

  rectrecform.pos  := nullpoint;
  rectrecform.size := panelwave.size;

  xreclive := 1;

  with sliderimage.bitmap do
  begin
    size   := rectrecform.size;
    init(transpcolor);
    masked := True;
    transparentcolor := transpcolor;
  end;

  panelwave.invalidate();
end;

procedure twebstreamerfo.DrawLive(lv, rv: double);
var
  poswavrec, poswavrec2: pointty;
begin
  sliderimage.bitmap.masked := False;
  poswavrec.x  := xreclive;
  poswavrec2.x := poswavrec.x;
  poswavrec.y  := (panelwave.Height div 2) - 2;
  poswavrec2.y := ((panelwave.Height div 2) - 1) - round((lv) * ((rectrecform.cy div 2) - 3));
  sliderimage.bitmap.Canvas.drawline(poswavrec, poswavrec2, $D69696);
  poswavrec.y  := (panelwave.Height div 2);
  poswavrec2.y := poswavrec.y + (round((rv) * ((panelwave.Height div 2) - 3)));
  sliderimage.bitmap.Canvas.drawline(poswavrec, poswavrec2, $859AE6);
  panelwave.invalidate();
  xreclive     := xreclive + 1;
end;

procedure twebstreamerfo.LoopProcPlayer1;
begin
  ShowLevel;
end;

procedure twebstreamerfo.ShowLevel();
var
  leftlev, rightlev: double;
begin
  vuLeft.Visible  := True;
  vuRight.Visible := True;

  leftlev  := uos_InputGetLevelLeft(webindex, webinindex);
  rightlev := uos_InputGetLevelRight(webindex, webinindex);

  if (leftlev >= 0) and (leftlev <= 1) then
    vuLeft.Value := leftlev;

  if (rightlev >= 0) and (rightlev <= 1) then
    vuRight.Value := rightlev;

  if panelwave.Visible = True then
  begin

    if (xreclive) > (Width) then
      InitDrawLive();

    DrawLive(leftlev, rightlev);
  end;
end;

procedure twebstreamerfo.onplay(const Sender: TObject);
var
  abool: Boolean;
  arec, outputstr: string;
  aformat, webformat, sizebuf: integer;
  latency: cfloat;
begin
  infopanel.font.color := cl_red;
  infopanel.Value := 'Trying to get ' + historyfn.Value;
  application.ProcessMessages;
  webindex   := 0;
  webinindex := -1;
  incview    := 0;

  uos_CreatePlayer(webindex);
  // Create the player.
  // PlayerIndex : from 0 to what your computer can do !
  // If PlayerIndex exists already, it will be overwriten...

  if mp3format.Value = True then
    webformat := 0
  else
    webformat := 2;

  if noaac then
    webformat := 0;

  if brecord.tag = 0 then
    aformat := 0
  else
    aformat := 2;

  if webformat = 2 then
  begin
    sizebuf := 16384;
    latency := 0.5;
  end
  else
  begin
    sizebuf := 8192;
    latency := -1;
  end;

  application.ProcessMessages;

  // 'https://radiorecord.hostingradio.ru/ps96.aacp';

  webinindex := uos_AddFromURL(webindex, PChar(ansistring(historyfn.Value)), -1, aformat, sizebuf, webformat, False);

  // Add a Input from Audio URL with custom parameters
  // URL : URL of audio file (like  'http://someserver/somesound.mp3')
  // OutputIndex : OutputIndex of existing Output // -1: all output, -2: no output, other LongInt : existing Output
  // SampleFormat : -1 default : Int16 (0: Float32, 1:Int32, 2:Int16)
  // FramesCount : default : -1 (1024)
  // AudioFormat : default : -1 (mp3) (0: mp3, 1: opus, 2: aac)
  // ICY data on/off

  if webinindex <> -1 then
  begin

    weboutindex := uos_AddIntoDevOut(webindex, deviceselected, latency, uos_InputGetSampleRate(webindex, webinindex),
      uos_InputGetChannels(webindex, webinindex), aformat, sizebuf, -1);

    if brecord.tag = 1 then
    begin

      if edrecformat.Value = 0 then
        outputstr := '.wav'
      else
        outputstr := '.ogg';

      arecnp := 'records' + directoryseparator + 'rec_' +
        msestring(formatdatetime('YY_MM_DD_HH_mm_ss', now)) + outputstr;

      arec := ordir + arecnp;
      uos_AddIntoFile(webindex, PChar(arec), -1, -1, aformat, sizebuf, edrecformat.Value);

      btempo.Enabled        := False;
      edtempo.Enabled       := False;
      edpitch.Enabled       := False;
      breset.Enabled        := False;
      brecord.face.template := tfacecomp9;
    end;

    // add a Output into device with custom parameters
    // PlayerIndex : Index of a existing Player
    // Device ( -1 is default Output device )
    // Latency  ( -1 is latency suggested ) )
    // SampleRate : delault : -1 (44100)   // here default samplerate of input
    // Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
    // SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16)
    // FramesCount : default : -1 (65536)
    // ChunkCount : default : -1 (= 512)
    //  result : -1 nothing created, otherwise Output Index in array

    uos_InputSetLevelEnable(webindex, webinindex, 2);
    // set calculation of level/volume (usefull for showvolume procedure)
    // set level calculation (default is 0)
    // 0 => no calcul
    // 1 => calcul before all DSP procedures.
    // 2 => calcul after all DSP procedures.
    // 3 => calcul before and after all DSP procedures.

    uos_LoopProcIn(webindex, webinindex, @LoopProcPlayer1);
    // Assign the procedure of object to execute inside the loop for a Input
    // PlayerIndex : Index of a existing Player
    // InIndex : Index of a existing Input
    // LoopProcPlayer1 : procedure of object to execute inside the loop

    uos_InputAddDSPVolume(webindex, webinindex, 1, 1);
    // DSP Volume changer
    // PlayerIndex1 : Index of a existing Player
    // In1Index : InputIndex of a existing input
    // VolLeft : Left volume  ( from 0 to 1 => gain > 1 )
    // VolRight : Right volume

    if (plugsoundtouch = True) and (brecord.tag = 0) then
    begin
      if btempo.tag = 0 then
        abool := False
      else
        abool := True;
      webPlugIndex := uos_AddPlugin(webindex, 'soundtouch', uos_InputGetSampleRate(webindex, webinindex),
        uos_InputGetChannels(webindex, webinindex));
      // add SoundTouch plugin with default samplerate(44100) / channels(2 = stereo)
      uos_SetPluginSoundTouch(webindex, webplugindex, edtempo.Value * 2, edpitch.Value * 2, abool);
      // Change plugin settings
    end;

    btnStart.Enabled        := False;
    btnStart.face.template  := tfacecomp6;
    btnResume.Enabled       := False;
    btnResume.Visible       := False;
    btnResume.face.template := tfacecomp6;
    btnStop.Enabled         := True;
    btnStop.face.template   := tfacecomp7;
    btnPause.Enabled        := True;
    btnpause.Visible        := True;
    btnPause.face.template  := tfacecomp7;

    brecord.Enabled       := False;
    brecord.face.template := tfacecomp7;

    if brecord.tag = 1 then
      brecord.face.template := tfacecomp9;

    if edstyle.Value = 0 then
      infopanel.font.color := cl_black
    else if edstyle.Value = 1 then
      infopanel.font.color := cl_white
    else if edstyle.Value = 2 then
      infopanel.font.color := cl_black;  

    if brecord.tag = 1 then
      infopanel.Value := 'Play + Record ' + historyfn.Value
    else
      infopanel.Value := 'Playing ' + historyfn.Value;

    if brecord.tag = 1 then
    begin
      brecord.Caption       := 'Recording...';
      brecord.face.template := tfacecomp9;
    end
    else
    begin
      brecord.Caption       := 'Playing...';
      brecord.face.template := tfacecomp7;
    end;

    onchangevol(nil);

    infopanel.face.template := tfacecomp4;

    InitDrawLive();

    tmainmenu1.menu.itembynames(['config', 'refresh']).Enabled := False;

    application.ProcessMessages;

    uos_Play(webindex);  // everything is ready, here we are, lets play it...

    //uos_InputUpdateICY(webindex, webplugindex, icy_data);
    //caption := icy_data;
  end
  else
  begin
    infopanel.font.color := cl_red;
    infopanel.Value      := 'URL did not accessed';
  end;
end;

procedure twebstreamerfo.oneventstart(const Sender: TObject);
var
  rect1: rectty;
begin
  {$if defined(darwin) and defined(macapp)}
  binPath := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)));
  ordir := copy(binPath, 1, length(binPath) -6) + 'Resources/';
  {$else}
  ordir := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)));
  {$ENDIF}

  {$IFDEF Windows}
  {$if defined(cpu64)}
  pa := AnsiString(ordir + 'lib\Windows\64bit\LibPortaudio-64.dll');
  mp := AnsiString(ordir + 'lib\Windows\64bit\LibMpg123-64.dll');
  aa := AnsiString(ordir + 'lib\Windows\64bit\libfdk-aac-64.dll');
  st := AnsiString(ordir + 'lib\Windows\64bit\LibSoundTouch-64.dll');
  {$else}
  pa := AnsiString(ordir + 'lib\Windows\32bit\LibPortaudio-32.dll');
  mp := AnsiString(ordir + 'lib\Windows\32bit\LibMpg123-32.dll');
  aa := AnsiString(ordir + 'lib\Windows\32bit\libfdk-aac-32.dll');
  st := AnsiString(ordir + 'lib\Windows\32bit\LibSoundTouch-32.dll');
  {$endif}
  {$ENDIF}

  {$if defined(CPUAMD64) and defined(linux) }
  pa := ordir + 'lib/Linux/64bit/LibPortaudio-64.so';
  mp := ordir + 'lib/Linux/64bit/LibMpg123-64.so';
  aa := ordir + 'lib/Linux/64bit/libfdk-aac-64.so';
  st := ordir + 'lib/Linux/64bit/LibSoundTouch-64.so';
  {$ENDIF}

  {$if defined(CPUAMD64) and defined(openbsd) }
  pa := AnsiString(ordir + 'lib/OpenBSD/64bit/LibPortaudio-64.so');
  mp := AnsiString(ordir + 'lib/OpenBSD/64bit/LibMpg123-64.so');
  st := AnsiString(ordir + 'lib/OpenBSD/64bit/LibSoundTouch-64.so');
  aa := '';
  noaac := true;
  {$ENDIF}

  {$if defined(cpu64) and defined(darwin) }
  pa := AnsiString(ordir + 'lib/Mac/64bit/LibPortaudio-64.dylib');
  mp := AnsiString(ordir + 'lib/Mac/64bit/LibMpg123-64.dylib');
  st := AnsiString(ordir + 'lib/Mac/64bit/libSoundTouchDLL.dylib');
  noaac := true;
  aa := '';
  {$ENDIF}

  {$if defined(cpu86) and defined(linux)}
  pa := AnsiString(ordir + 'lib/Linux/32bit/LibPortaudio-32.so');
  mp := AnsiString(ordir + 'lib/Linux/32bit/LibMpg123-32.so');
  st := AnsiString(ordir + 'lib/Linux/32bit/LibSoundTouch-32.so');
  aa := AnsiString(ordir + 'lib/Linux/32bit/libfdk-aac-32.so');
  {$ENDIF}

  {$if defined(linux) and defined(cpuarm)}
  pa := AnsiString(ordir + 'lib/Linux/arm_raspberrypi/libportaudio-arm.so');
  mp := AnsiString(ordir + 'lib/Linux/arm_raspberrypi/libmpg123-arm.so');
  st := AnsiString(ordir + 'lib/Linux/arm_raspberrypi/libsoundtouch-arm.so');
  aa := AnsiString(ordir + 'lib/Linux/arm_raspberrypi/libfdk-aac-32.so');
  {$ENDIF}

  {$if defined(linux) and defined(cpuaarch64)}
  pa := AnsiString(ordir + 'lib/Linux/aarch64_raspberrypi/libportaudio_aarch64.so');
  mp := AnsiString(ordir + 'lib/Linux/aarch64_raspberrypi/libmpg123_aarch64.so');
  st := AnsiString(ordir + 'lib/Linux/aarch64_raspberrypi/libsoundtouch_aarch64.so');
  aa := AnsiString(ordir + 'lib/Linux/aarch64_raspberrypi/libfdk-aac-64.so');
  {$ENDIF}

  {$if defined(freebsd) and defined(cpuamd64) }
  pa := AnsiString(ordir + 'lib/FreeBSD/amd64/libportaudio-64.so');
  mp := AnsiString(ordir + 'lib/FreeBSD/amd64/libmpg123-64.so');
  st := AnsiString(ordir + 'lib/FreeBSD/amd64/libsoundtouch-64.so');
  noaac := true;
  aa := '';
  {$endif}

  {$if defined(freebsd) and defined(cpui386) }
  pa := AnsiString(ordir + 'lib/FreeBSD/i386/libportaudio-32.so');
  mp := AnsiString(ordir + 'lib/FreeBSD/i386/libmpg123-32.so');
  st := '';
  aa := '';
  noaac := true;
  {$endif}

  {$if defined(freebsd) and defined(cpuamd64) }
  pa := AnsiString(ordir + 'lib/FreeBSD/aarch64/libportaudio-64.so');
  mp := AnsiString(ordir + 'lib/FreeBSD/aarch64/libmpg123-64.so');
  st := '';
  aa := '';
  noaac := true;
  {$endif}

  if uos_LoadLib(PChar(pa), nil, PChar(mp), nil, nil, nil, nil, PChar(aa)) = -1 then
    if uos_LoadLib('system', nil, 'system', nil, nil, nil, nil, 'system') = -1 then
      application.terminate;

  if (uos_LoadPlugin('soundtouch', PChar(st)) = 0) then
    plugsoundtouch := True
  else
    plugsoundtouch := False;

  brecord.tag := 0;

  btempo.tag := 0;

  if edrecformat.Value = 0 then
  begin
    tmainmenu1.menu.itembynames(['config', 'recformat', 'wavformat']).Checked := True;
    tmainmenu1.menu.itembynames(['config', 'recformat', 'oggformat']).Checked := False;
  end
  else
  begin
    tmainmenu1.menu.itembynames(['config', 'recformat', 'oggformat']).Checked := True;
    tmainmenu1.menu.itembynames(['config', 'recformat', 'wavformat']).Checked := False;
  end;
  
  if edstyle.Value = 0 then
  begin
    tmainmenu1.menu.itembynames(['config', 'style', 'swpstyle']).Checked := True;
    tmainmenu1.menu.itembynames(['config', 'style', 'carbonstyle']).Checked := False;
    tmainmenu1.menu.itembynames(['config', 'style', 'silverstyle']).Checked := False;    
  end  else
  if edstyle.Value = 1 then
  begin
    tmainmenu1.menu.itembynames(['config', 'style', 'swpstyle']).Checked := false;
    tmainmenu1.menu.itembynames(['config', 'style', 'carbonstyle']).Checked := true;
    tmainmenu1.menu.itembynames(['config', 'style', 'silverstyle']).Checked := False;    
  end else
  if edstyle.Value = 2 then
  begin
    tmainmenu1.menu.itembynames(['config', 'style', 'swpstyle']).Checked := false;
    tmainmenu1.menu.itembynames(['config', 'style', 'carbonstyle']).Checked := False;
    tmainmenu1.menu.itembynames(['config', 'style', 'silverstyle']).Checked := true;    
  end;

  tmainmenu1.menu.itembynames(['showwav']).Checked := showwave.Value;

  tmainmenu1.menu.itembynames(['config', 'playaf']).Checked := runselect.Value;

  tmainmenu1.menu.itembynames(['showgrid']).Checked := showgrid.Value;

  onchangeshowwave(nil);

  tmainmenu1.menu.itembynames(['about', 'title']).Caption :=
    '                  Simple Webstream Player v1.' + IntToStr(version);

  //noaac := true;  

  if noaac then
  begin
    tlabel2.Caption   := '    SWP';
    tlabel3.Visible   := False;
    mp3format.Visible := False;
    aacformat.Visible := False;
    brecord.top       := brecord.top - 10;
  end;

  rect1 := application.screenrect(window);

  fontheight := round(rect1.cy / 800 * 12);

  resizesp(fontheight);

  oncheckdevices();

  Visible := True;

  isinit := True;

end;

procedure twebstreamerfo.onstop(const Sender: TObject);
begin
  uos_Stop(webindex);
  btnStart.Enabled        := True;
  btnStart.face.template  := tfacecomp7;
  btnResume.Enabled       := False;
  btnResume.Visible       := False;
  btnResume.face.template := tfacecomp6;
  btnStop.Enabled         := False;
  btnStop.face.template   := tfacecomp6;
  btnPause.Enabled        := False;
  btnpause.Visible        := True;
  btnPause.face.template  := tfacecomp6;
  brecord.Enabled         := True;
  brecord.face.template   := tfacecomp7;
  btempo.Enabled          := True;
  breset.Enabled          := True;
  edtempo.Enabled         := True;
  edpitch.Enabled         := True;
  if brecord.tag = 1 then
    infopanel.Value := 'Rec saved: ' + arecnp
  else
    infopanel.Value     := historyfn.Value + ' stopped...';
  brecord.tag           := 0;
  brecord.Caption       := 'Record';
  brecord.face.template := tfacecomp7;
  infopanel.face.template := tfacecomp3;
  tmainmenu1.menu.itembynames(['config', 'refresh']).Enabled := True;
end;

procedure twebstreamerfo.onclosed(const Sender: TObject);
begin
  if isexit = False then
  begin
    onstop(nil);
    sleep(300);
    application.ProcessMessages;
    uos_free();
    sleep(300);
  end;
end;

procedure twebstreamerfo.onpause(const Sender: TObject);
begin
  uos_Pause(webindex);
  btnStart.Enabled        := False;
  btnStart.face.template  := tfacecomp6;
  btnResume.Enabled       := True;
  btnResume.Visible       := True;
  btnResume.face.template := tfacecomp7;
  btnStop.Enabled         := True;
  btnStop.face.template   := tfacecomp7;
  btnPause.Enabled        := False;
  btnPause.Visible        := False;
  btnPause.face.template  := tfacecomp6;
  brecord.Caption         := 'Paused...';
  infopanel.Value         := historyfn.Value + ' paused...';
end;

procedure twebstreamerfo.onresume(const Sender: TObject);
begin
  uos_replay(webindex);
  btnStart.Enabled        := False;
  btnStart.face.template  := tfacecomp6;
  btnResume.Enabled       := False;
  btnResume.Visible       := False;
  btnResume.face.template := tfacecomp6;
  btnStop.Enabled         := True;
  btnStop.face.template   := tfacecomp7;
  btnPause.Enabled        := True;
  btnpause.Visible        := True;
  btnPause.face.template  := tfacecomp7;
  brecord.Caption         := 'Resumed...';
  infopanel.Value         := historyfn.Value + ' resumed...';
end;

procedure twebstreamerfo.onchangevol(const Sender: TObject);
begin
  lvl.Caption := IntToStr(round(edvol.Value * 100));
  lvr.Caption := IntToStr(round(edvolr.Value * 100));
  uos_InputSetDSPVolume(webindex, webinindex,
    edvol.Value, edvolr.Value, True);
end;

procedure twebstreamerfo.onchangeshowwave(const Sender: TObject);
var
  ratio: double;
begin
  bounds_cymax := 0;
  bounds_cymin := 0;

  ratio := fontheight / 12;

  if showwave.Value then
  begin
    panelwave.Visible := True;
    if showgrid.Value then
    begin
      griddisp.Visible := True;
      baddrow.Visible  := True;
      bdelrow.Visible  := True;
      griddisp.top     := panelwave.bottom + round(ratio * 1);
      baddrow.top      := griddisp.bottom + round(ratio * 1);
      bdelrow.top      := griddisp.bottom + round(ratio * 1);
      Height           := round(ratio * 18) + baddrow.bottom + round(ratio * 4);
    end
    else
    begin
      griddisp.Visible := False;
      baddrow.Visible  := False;
      bdelrow.Visible  := False;
      Height           := round(ratio * 18) + panelwave.bottom;
    end;
  end
  else
  begin
    panelwave.Visible := False;
    if showgrid.Value then
    begin
      griddisp.Visible := True;
      baddrow.Visible  := True;
      bdelrow.Visible  := True;
      griddisp.top     := panelwave.top + round(ratio * 1);
      baddrow.top      := griddisp.bottom + round(ratio * 1);
      bdelrow.top      := griddisp.bottom + round(ratio * 1);
      Height           := round(ratio * 18) + baddrow.bottom + round(ratio * 4);
    end
    else
    begin
      griddisp.Visible := False;
      baddrow.Visible  := False;
      bdelrow.Visible  := False;
      Height           := round(ratio * 18) + panelcommand.bottom + round(ratio * 2);
    end;
  end;
  application.ProcessMessages;

  bounds_cymax := bounds_cy;
  bounds_cymin := bounds_cy;
end;

procedure twebstreamerfo.oncreate(const Sender: TObject);
var
  statname: string;
  i1, childn: integer;
begin

  setlength(boundchildsp, childrencount);
  childn := childrencount;

  for i1 := 0 to childrencount - 1 do
  begin
    boundchildsp[i1].left   := children[i1].left;
    boundchildsp[i1].top    := children[i1].top;
    boundchildsp[i1].Width  := children[i1].Width;
    boundchildsp[i1].Height := children[i1].Height;
    boundchildsp[i1].Name   := children[i1].Name;
  end;

  with deleteallurl do
  begin
    setlength(boundchildsp, length(boundchildsp) + deleteallurl.childrencount);

    for i1 := 0 to deleteallurl.childrencount - 1 do
    begin
      boundchildsp[i1 + childn].left   := children[i1].left;
      boundchildsp[i1 + childn].top    := children[i1].top;
      boundchildsp[i1 + childn].Width  := children[i1].Width;
      boundchildsp[i1 + childn].Height := children[i1].Height;
      boundchildsp[i1 + childn].Name   := children[i1].Name;
    end;
  end;

  childn := childn + deleteallurl.childrencount;

  with panelcommand do
  begin
    setlength(boundchildsp, length(boundchildsp) + panelcommand.childrencount);

    for i1 := 0 to panelcommand.childrencount - 1 do
    begin
      boundchildsp[i1 + childn].left   := children[i1].left;
      boundchildsp[i1 + childn].top    := children[i1].top;
      boundchildsp[i1 + childn].Width  := children[i1].Width;
      boundchildsp[i1 + childn].Height := children[i1].Height;
      boundchildsp[i1 + childn].Name   := children[i1].Name;
    end;
  end;

  statname := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0))) + 'swp.ini';
  tstatfile1.filename := statname;

end;

procedure twebstreamerfo.onreset(const Sender: TObject);
begin
  edtempo.Value := 0.5;
  edpitch.Value := 0.5;
  //uos_InputUpdateICY(webindex, webplugindex, icy_data);
  //caption := icy_data;
end;

procedure twebstreamerfo.onrec(const Sender: TObject);
begin
  if brecord.tag = 0 then
  begin
    brecord.tag           := 1;
    brecord.face.template := tfacecomp8;
    brecord.Caption       := 'Cue Record';
  end
  else
  begin
    brecord.face.template := tfacecomp7;
    brecord.Caption       := 'Record';
    brecord.tag           := 0;
  end;
end;

procedure twebstreamerfo.ontempo(const Sender: TObject);
begin
  if btempo.tag = 0 then
  begin
    btempo.tag           := 1;
    btempo.face.template := tfacecomp8;
  end
  else
  begin
    btempo.face.template := tfacecomp7;
    btempo.tag           := 0;
  end;
  ChangePlugSetSoundTouch(nil);
end;

procedure twebstreamerfo.onafterdropdown(const Sender: TObject);
begin
  if (isinit) and (runselect.Value) then
  begin
    onstop(nil);
    sleep(100);
    application.ProcessMessages;
    onplay(nil);
  end;
end;

procedure twebstreamerfo.onaftermenushowwav(const Sender: TObject);
begin
  showwave.Value := tmainmenu1.menu.itembynames(['showwav']).Checked;
  showgrid.Value := tmainmenu1.menu.itembynames(['showgrid']).Checked;
  onchangeshowwave(nil);
end;

procedure twebstreamerfo.onafterplayafter(const Sender: TObject);
begin
  runselect.Value := tmainmenu1.menu.itembynames(['config', 'playaf']).Checked;
end;

procedure twebstreamerfo.onclearhist(const Sender: TObject);
begin
  historyfn.dropdown.valuelist.asarray := thistoryedit2.dropdown.valuelist.asarray;
  deleteallurl.Visible := False;
end;

procedure twebstreamerfo.cancelclear(const Sender: TObject);
begin
  deleteallurl.Visible := False;
end;

procedure twebstreamerfo.showclear(const Sender: TObject);
begin
  deleteallurl.Visible := True;
end;

procedure twebstreamerfo.showlis(const Sender: TObject);
begin
  if griddisp.Visible = True then
    griddisp.Visible := False
  else
    griddisp.Visible := True;

  onchangeshowwave(nil);
end;

procedure twebstreamerfo.oncellev(const Sender: TObject; var info: celleventinfoty);
begin
  if isinit and griddisp.Visible then
    if (info.eventkind = cek_buttonrelease) then
      if (ss_double in info.mouseeventinfopo^.shiftstate) then
      begin
        historyfn.Value := griddisp[2][griddisp.focusedcell.row];
        historyfn.savehistoryvalue;
        if lowercase(griddisp[3][griddisp.focusedcell.row]) = 'aac' then
          aacformat.Value := True
        else
          mp3format.Value := True;
      end;
end;

procedure twebstreamerfo.onafterdevice(const Sender: TObject);
var
  x: integer;
begin
  x := 0;
  if tmainmenu1.menu.itembynames(['config', 'devices', '-1']).Checked then
    deviceselected := -1
  else
    while x < devcount do
    begin
      if tmainmenu1.menu.itembynames(['config', 'devices', IntToStr(x)]).Checked then
        deviceselected := StrToInt(tmainmenu1.menu.itembynames(['config', 'devices', IntToStr(x)]).Name);
      Inc(x);
    end;
  edeviceselected.Value := deviceselected; // for stat file 
  // if btnStart.enabled = false then onafterdropdown(nil);
end;

procedure twebstreamerfo.onexit(const Sender: TObject);
begin
  isexit := True;
  onstop(nil);
  sleep(300);
  application.ProcessMessages;
  uos_free();
  sleep(300);
  application.ProcessMessages;
  application.terminate;
end;

procedure twebstreamerfo.onupdevices(const Sender: TObject);
begin
  if btnStart.Enabled = True then
    oncheckdevices();
end;

procedure twebstreamerfo.onaftermenusetrecformat(const Sender: TObject);
begin
  if tmainmenu1.menu.itembynames(['config', 'recformat', 'wavformat']).Checked = True then
    edrecformat.Value := 0
  else
    edrecformat.Value := 2;
end;

procedure twebstreamerfo.resizesp(fontheight: integer);
var
  i1, i2: integer;
  ratio: double;
begin
  ratio       := fontheight / 11;
  font.Height := fontheight;
  
  messagefontheight := fontheight;
  
  tmainmenu1.menu.font.Height       := fontheight;
  tmainmenu1.menu.fontactive.Height := fontheight;
  
  historyfn.dropdown.cols[0].font.Height := fontheight;

  griddisp.font.Height := fontheight;
  griddisp.font.color  := font.color;

  btnStart.font.Height  := round(ratio * 18);
  btnPause.font.Height  := round(ratio * 12);
  btnStop.font.Height   := round(ratio * 18);
  btnResume.font.Height := round(ratio * 14);

  for i1 := 0 to childrencount - 1 do
    for i2 := 0 to length(boundchildsp) - 1 do
      if children[i1].Name = boundchildsp[i2].Name then
      begin
        children[i1].left   := round(boundchildsp[i2].left * ratio);
        children[i1].top    := round(boundchildsp[i2].top * ratio);
        children[i1].Width  := round(boundchildsp[i2].Width * ratio);
        children[i1].Height := round(boundchildsp[i2].Height * ratio);
      end;

  griddisp.datarowheight      := round(15 * ratio);
  griddisp.font.Height        := fontheight;
  griddisp[0].Width           := round(70 * ratio);
  griddisp[1].Width           := round(52 * ratio);
  griddisp[2].Width           := round(160 * ratio);
  griddisp[3].Width           := round(48 * ratio);
  griddisp.fixrows[-1].Height := round(18 * ratio);
  griddisp.frame.sbvert.Width := round(12 * ratio);

  infopanel.font.Height := fontheight;

  with panelcommand do
  begin
    font.Height := fontheight;
    for i1      := 0 to childrencount - 1 do
      for i2 := 0 to length(boundchildsp) - 1 do
        if panelcommand.children[i1].Name = boundchildsp[i2].Name then
        begin
          panelcommand.children[i1].left   := round(boundchildsp[i2].left * ratio);
          panelcommand.children[i1].top    := round(boundchildsp[i2].top * ratio);
          panelcommand.children[i1].Width  := round(boundchildsp[i2].Width * ratio);
          panelcommand.children[i1].Height := round(boundchildsp[i2].Height * ratio);
        end;
  end;

  with deleteallurl do
  begin
    font.Height := fontheight;
    for i1      := 0 to childrencount - 1 do
      for i2 := 0 to length(boundchildsp) - 1 do
        if deleteallurl.children[i1].Name = boundchildsp[i2].Name then
        begin
          deleteallurl.children[i1].left   := round(boundchildsp[i2].left * ratio);
          deleteallurl.children[i1].top    := round(boundchildsp[i2].top * ratio);
          deleteallurl.children[i1].Width  := round(boundchildsp[i2].Width * ratio);
          deleteallurl.children[i1].Height := round(boundchildsp[i2].Height * ratio);
        end;
  end;

  bounds_cxmax := 0;
  bounds_cxmin := 0;
  bounds_cymax := 0;
  bounds_cymin := 0;
  bounds_cxmax := round(346 * ratio);
  bounds_cxmin := bounds_cxmax;

  onchangeshowwave(nil);

  setstyle(edstyle.Value);

end;

procedure twebstreamerfo.addrow(const Sender: TObject);
begin
  griddisp.rowcount := griddisp.rowcount + 1;
end;

procedure twebstreamerfo.deleterow(const Sender: TObject);
begin
  if (griddisp.rowcount > 1) and (griddisp.focusedcell.row > -1) then
    griddisp.deleterow(griddisp.focusedcell.row);
end;

procedure twebstreamerfo.setstyle(style: integer);
begin
  if style = 0 then
  begin
    color      := cl_default;
    font.color := cl_black;
    font.color := cl_black;
    vuRight.bar_face.fade_color[1] := $616261;
    vuleft.bar_face.fade_color[1] := $616261;
    infopanel.font.color := cl_black;
    griddisp.font.color := cl_black;
    btnStart.font.color := cl_black;
    btnPause.font.color := cl_black;
    btnStop.font.color := cl_black;
    btnResume.font.color := cl_black;
    tmainmenu1.menu.color := cl_default;
    tmainmenu1.menu.font.color := cl_black;
    tmainmenu1.menu.fontactive.color := $DE6B00;
    tmainmenu1.menu.colorglyph := cl_black;
    tmainmenu1.menu.colorglyphactive := cl_black;
    tfacecomp7.template.fade_color.items[0] := $BECCB6;
    tfacecomp7.template.fade_color.items[1] := $787878;
    tfacecomp3.template.fade_color.items[0] := $FCFFFA;
    tfacecomp3.template.fade_color.items[1] := $B6C4AF;
    tfacecomp4.template.fade_color.items[0] := $FCFFFA;
    tfacecomp4.template.fade_color.items[1] := $F0E2C9;
    tfacecomp6.template.fade_color.items[0] := $8A8A8A;
    tfacecomp6.template.fade_color.items[1] := $5E5E5E;
    tfacecomp9.template.fade_color.items[0] := $FFBDBD;
    tfacecomp9.template.fade_color.items[1] := cl_red;
    tfacecomp8.template.fade_color.items[0] := $FFF8EB;
    tfacecomp8.template.fade_color.items[1] := $F0BB60;
    tfacecomp2.template.fade_color.items[0] := $A4B09D;
    tfacecomp2.template.fade_color.items[1] := $5C5C5C;
    container.color := $B6C4AF;
    griddisp[0].color          := $E0E0E0;
    griddisp[1].color          := $E0E0E0;
    griddisp[2].color          := $E0E0E0;
    griddisp[3].color          := $E0E0E0;
    griddisp.fixrows[-1].color := $BFCCB9;
    griddisp.zebra_color := $F8FFF5;
    container.color      := $B6C4AF;
    infopanel.font.color := cl_black;
    historyfn.frame.button.colorglyph := cl_black;
    griddisp.frame.sbvert.colorglyph := cl_black;
  end;

  if style = 1 then
  begin
    color      := $575757;
    font.color := cl_white;
    infopanel.font.color := cl_white;
    griddisp.font.color := cl_white;
    btnStart.font.color := cl_white;
    btnPause.font.color := cl_white;
    btnStop.font.color := cl_white;
    btnResume.font.color := cl_white;
    vuRight.bar_face.fade_color[1] := $0E0E0E;
    vuleft.bar_face.fade_color[1] := $0E0E0E;
    tmainmenu1.menu.color := $575757;
    tmainmenu1.menu.font.color := cl_white;
    tmainmenu1.menu.fontactive.color := $EDBA8A;
    tmainmenu1.menu.colorglyph := cl_white;
    tmainmenu1.menu.colorglyphactive := cl_white;
    tfacecomp7.template.fade_color.items[0] := cl_dkgray;
    tfacecomp7.template.fade_color.items[1] := cl_black;
    tfacecomp3.template.fade_color.items[0] := cl_dkgray;
    tfacecomp3.template.fade_color.items[1] := cl_black;
    tfacecomp4.template.fade_color.items[0] := $F09800;
    tfacecomp4.template.fade_color.items[1] := $734900;
    tfacecomp6.template.fade_color.items[0] := $4C4C4C;
    tfacecomp6.template.fade_color.items[1] := cl_black;
    tfacecomp9.template.fade_color.items[0] := $FFBDBD;
    tfacecomp9.template.fade_color.items[1] := cl_dkred;
    tfacecomp8.template.fade_color.items[0] := $FFF8EB;
    tfacecomp8.template.fade_color.items[1] := cl_black;
    tfacecomp2.template.fade_color.items[0] := cl_dkgray;
    tfacecomp2.template.fade_color.items[1] := cl_black;
    griddisp[0].color          := cl_black;
    griddisp[1].color          := cl_black;
    griddisp[2].color          := cl_black;
    griddisp[3].color          := cl_black;
    griddisp.fixrows[-1].color := $5C5C5C;
    griddisp.zebra_color := $5C5C5C;
    container.color      := $5C5C5C;
    infopanel.font.color := cl_white;
    historyfn.frame.button.colorglyph := cl_white;
    griddisp.frame.sbvert.colorglyph := cl_white;
  end;

  if style = 2 then
  begin
    color      := cl_default;
    font.color := cl_black;
    font.color := cl_black;
    vuRight.bar_face.fade_color[1] := $666666;
    vuleft.bar_face.fade_color[1] := $666666;
    infopanel.font.color := cl_black;
    griddisp.font.color := cl_black;
    btnStart.font.color := cl_black;
    btnPause.font.color := cl_black;
    btnStop.font.color := cl_black;
    btnResume.font.color := cl_black;
    tmainmenu1.menu.color := cl_default;
    tmainmenu1.menu.font.color := cl_black;
    tmainmenu1.menu.fontactive.color := $DE6B00;
    tmainmenu1.menu.colorglyph := cl_black;
    tmainmenu1.menu.colorglyphactive := cl_black;
    tfacecomp7.template.fade_color.items[0] := $F2F2F2;
    tfacecomp7.template.fade_color.items[1] := $5C5C5C;
    tfacecomp3.template.fade_color.items[0] := $FCFFFA;
    tfacecomp3.template.fade_color.items[1] := $A3A3A3;
    tfacecomp4.template.fade_color.items[0] := $FCFFFA;
    tfacecomp4.template.fade_color.items[1] := $F0E2C9;
    tfacecomp6.template.fade_color.items[0] := $8A8A8A;
    tfacecomp6.template.fade_color.items[1] := $5E5E5E;
    tfacecomp9.template.fade_color.items[0] := $FFBDBD;
    tfacecomp9.template.fade_color.items[1] := cl_red;
    tfacecomp8.template.fade_color.items[0] := $FFF8EB;
    tfacecomp8.template.fade_color.items[1] := $F0BB60;
    tfacecomp2.template.fade_color.items[0] := $F2F2F2;
    tfacecomp2.template.fade_color.items[1] := $5C5C5C;
    container.color := $B6C4AF;
    griddisp[0].color          := $E0E0E0;
    griddisp[1].color          := $E0E0E0;
    griddisp[2].color          := $E0E0E0;
    griddisp[3].color          := $E0E0E0;
    griddisp.fixrows[-1].color := $D4D4D4;
    griddisp.zebra_color := $F2F2F2;
    container.color      := cl_default;
    infopanel.font.color := cl_black;
    historyfn.frame.button.colorglyph := cl_black;
    griddisp.frame.sbvert.colorglyph := cl_black;
  end;
end;

procedure twebstreamerfo.onexecswpstyle(const sender: TObject);
begin
 if  tmainmenu1.menu.itembynames(['config', 'style', 'swpstyle']).Checked = True
 then edstyle.Value := 0 else
 if tmainmenu1.menu.itembynames(['config', 'style', 'carbonstyle']).Checked = true
 then edstyle.Value := 1 else
 if tmainmenu1.menu.itembynames(['config', 'style', 'silverstyle']).Checked = true
 then edstyle.Value := 2;   
setstyle(edstyle.Value);
InitDrawLive();
end;

end.

