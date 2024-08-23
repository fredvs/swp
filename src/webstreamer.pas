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
    tfacecomp2: tfacecomp;
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
    tfacecomp5: tfacecomp;
    tfacecomp6: tfacecomp;
    tfacecomp7: tfacecomp;
    tfacecomp8: tfacecomp;
    tfacecomp9: tfacecomp;
    tfacecomp10: tfacecomp;
    edeviceselected: tintegeredit;
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
  end;

const
  version = 240822;

var
  webstreamerfo: twebstreamerfo;
  webindex, webinindex, weboutindex, webPlugIndex: integer;
  rectrecform: rectty;
  xreclive, devcount, deviceselected: integer;
  plugsoundtouch: Boolean = False;
  isinit: Boolean = False;
  ordir, arecnp: string;
  pa, mp, st: string;
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
  prestr: string;
begin
  if uos_LoadLib(PChar(pa), nil, PChar(mp), nil, nil, nil) = -1 then
    application.terminate;

  UOS_GetInfoDevice();

  if UOSDeviceCount < 21 then
    devcount := UOSDeviceCount
  else
    devcount := 21;
  x := 0;
  while x < devcount do
  begin
    if x < 10 then
      prestr := ' '
    else
      prestr := '';

    if (msestring(UOSDeviceInfos[x].DeviceType) = 'In/Out') and
      (lowercase(msestring(UOSDeviceInfos[x].DeviceName)) <> 'default') then
      tmainmenu1.menu.itembynames(['config', 'devices', '-1']).Caption :=
        '-1 = Default = ' + msestring(UOSDeviceInfos[x].DeviceName);

    tmainmenu1.menu.itembynames(['config', 'devices', IntToStr(x)]).Visible := True;

    tmainmenu1.menu.itembynames(['config', 'devices', IntToStr(x)]).Caption :=
      prestr + msestring(IntToStr(UOSDeviceInfos[x].DeviceNum)) +
      ' = ' + msestring(UOSDeviceInfos[x].DeviceName);
    Inc(x);
  end;

  deviceselected := edeviceselected.Value; // for stat file 

  if deviceselected <> -1 then
    tmainmenu1.menu.itembynames(['config', 'devices', IntToStr(deviceselected)]).state :=
      [as_checked, as_localchecked, as_localcaption, as_localonafterexecute];

  uos_free;
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
const
  transpcolor = $B6C4AF;
begin
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
  sliderimage.bitmap.Canvas.drawline(poswavrec, poswavrec2, $AC99D6);
  poswavrec.y  := (panelwave.Height div 2);
  poswavrec2.y := poswavrec.y + (round((rv) * ((panelwave.Height div 2) - 3)));
  sliderimage.bitmap.Canvas.drawline(poswavrec, poswavrec2, $AC79D6);
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
  arec: string;
  aformat, sizebuf: integer;
begin
  if uos_LoadLib(PChar(pa), nil, PChar(mp), nil, nil, nil) = -1 then
    application.terminate;

  if (uos_LoadPlugin('soundtouch', PChar(st)) = 0) then
    plugsoundtouch := True
  else
    plugsoundtouch := False;

  infopanel.font.color := cl_blue;
  infopanel.Value := 'Trying to get ' + historyfn.Value;
  application.ProcessMessages;
  webindex   := 0;
  webinindex := -1;

  uos_CreatePlayer(webindex);
  // Create the player.
  // PlayerIndex : from 0 to what your computer can do !
  // If PlayerIndex exists already, it will be overwriten...

  if brecord.tag = 0 then
    aformat := 0
  else
    aformat := 2;

  sizebuf := 1024 * 8;

  application.ProcessMessages;

  webinindex := uos_AddFromURL(webindex, PChar(ansistring(historyfn.Value)), -1, aformat, sizebuf, 0, False);

  // Add a Input from Audio URL with custom parameters
  // URL : URL of audio file (like  'http://someserver/somesound.mp3')
  // OutputIndex : OutputIndex of existing Output // -1: all output, -2: no output, other LongInt : existing Output
  // SampleFormat : -1 default : Int16 (0: Float32, 1:Int32, 2:Int16)
  // FramesCount : default : -1 (1024)
  // AudioFormat : default : -1 (mp3) (0: mp3, 1: opus)
  // ICY data on/off

  if webinindex <> -1 then
  begin

    weboutindex := uos_AddIntoDevOut(webindex, deviceselected, -1, uos_InputGetSampleRate(webindex, webinindex),
      uos_InputGetChannels(webindex, webinindex), aformat, sizebuf, -1);

    if brecord.tag = 1 then
    begin
      arecnp := 'records' + directoryseparator + 'rec_' +
        msestring(formatdatetime('YY_MM_DD_HH_mm_ss', now)) + '.wav';

      arec := ordir + arecnp;
      uos_AddIntoFile(webindex, PChar(arec), -1, -1, aformat, sizebuf, 0);

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

    infopanel.font.color := cl_black;
    if brecord.tag = 1 then
      infopanel.Value    := 'Play + Record ' + historyfn.Value
    else
      infopanel.Value    := 'Playing ' + historyfn.Value;

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

    tmainmenu1.menu.itembynames(['config', 'devices']).Enabled := False;

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
  st := AnsiString(ordir + 'lib\Windows\64bit\LibSoundTouch-64.dll');

  {$else}
  pa := AnsiString(ordir + 'lib\Windows\32bit\LibPortaudio-32.dll');
  mp := AnsiString(ordir + 'lib\Windows\32bit\LibMpg123-32.dll');
  st := AnsiString(ordir + 'lib\Windows\32bit\LibSoundTouch-32.dll');
  {$endif}
  {$ENDIF}

  {$if defined(CPUAMD64) and defined(linux) }
  pa := ordir + 'lib/Linux/64bit/LibPortaudio-64.so';
  mp := ordir + 'lib/Linux/64bit/LibMpg123-64.so';
  st := ordir + 'lib/Linux/64bit/LibSoundTouch-64.so';
  {$ENDIF}

  {$if defined(CPUAMD64) and defined(openbsd) }
  pa := AnsiString(ordir + 'lib/OpenBSD/64bit/LibPortaudio-64.so');
  mp := AnsiString(ordir + 'lib/OpenBSD/64bit/LibMpg123-64.so');
  st := AnsiString(ordir + 'lib/OpenBSD/64bit/LibSoundTouch-64.so');
  {$ENDIF}

  {$if defined(cpu64) and defined(darwin) }
  pa := AnsiString(ordir + 'lib/Mac/64bit/LibPortaudio-64.dylib');
  mp := AnsiString(ordir + 'lib/Mac/64bit/LibMpg123-64.dylib');
  st := AnsiString(ordir + 'lib/Mac/64bit/libSoundTouchDLL.dylib');
  {$ENDIF}

  {$if defined(cpu86) and defined(linux)}
  pa := AnsiString(ordir + 'lib/Linux/32bit/LibPortaudio-32.so');
  mp := AnsiString(ordir + 'lib/Linux/32bit/LibMpg123-32.so');
  st := AnsiString(ordir + 'lib/Linux/32bit/LibSoundTouch-32.so');
  {$ENDIF}

  {$if defined(linux) and defined(cpuarm)}
  pa := AnsiString(ordir + 'lib/Linux/arm_raspberrypi/libportaudio-arm.so');
  mp := AnsiString(ordir + 'lib/Linux/arm_raspberrypi/libmpg123-arm.so');
  st := AnsiString(ordir + 'lib/Linux/arm_raspberrypi/libsoundtouch-arm.so');
  {$ENDIF}

  {$if defined(linux) and defined(cpuaarch64)}
  pa := AnsiString(ordir + 'lib/Linux/aarch64_raspberrypi/libportaudio_aarch64.so');
  mp := AnsiString(ordir + 'lib/Linux/aarch64_raspberrypi/libmpg123_aarch64.so');
  st := AnsiString(ordir + 'lib/Linux/aarch64_raspberrypi/libsoundtouch_aarch64.so');
  {$ENDIF}

  {$if defined(freebsd) and defined(cpuamd64) }
  pa := AnsiString(ordir + 'lib/FreeBSD/amd64/libportaudio-64.so');
  mp := AnsiString(ordir + 'lib/FreeBSD/amd64/libmpg123-64.so');
  st := AnsiString(ordir + 'lib/FreeBSD/amd64/libsoundtouch-64.so');
  {$endif}

  {$if defined(freebsd) and defined(cpui386) }
  pa := AnsiString(ordir + 'lib/FreeBSD/i386/libportaudio-32.so');
  mp := AnsiString(ordir + 'lib/FreeBSD/i386/libmpg123-32.so');
  st := '';
  {$endif}

  {$if defined(freebsd) and defined(cpuamd64) }
  pa := AnsiString(ordir + 'lib/FreeBSD/aarch64/libportaudio-64.so');
  mp := AnsiString(ordir + 'lib/FreeBSD/aarch64/libmpg123-64.so');
  st := '';
  {$endif}

  brecord.color := $B6C4AF;
  brecord.tag   := 0;

  btempo.color := $B6C4AF;
  btempo.tag   := 0;

  tmainmenu1.menu.itembynames(['showwav']).Checked := showwave.Value;

  tmainmenu1.menu.itembynames(['config', 'playaf']).Checked := runselect.Value;

  tmainmenu1.menu.itembynames(['showgrid']).Checked := showgrid.Value;

  onchangeshowwave(nil);

  tmainmenu1.menu.itembynames(['about', 'title']).Caption :=
    '                  Simple Webstream Player v1.' + IntToStr(version);

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

  btempo.Enabled  := True;
  breset.Enabled  := True;
  edtempo.Enabled := True;
  edpitch.Enabled := True;
  if brecord.tag = 1 then
    infopanel.Value := 'Rec saved: ' + arecnp
  else
    infopanel.Value     := historyfn.Value + ' stopped...';
  brecord.tag           := 0;
  brecord.Caption       := 'Record';
  brecord.face.template := tfacecomp7;
  infopanel.face.template := tfacecomp3;
  uos_free;
  tmainmenu1.menu.itembynames(['config', 'devices']).Enabled := True;

end;

procedure twebstreamerfo.onclosed(const Sender: TObject);
begin
  uos_Stop(webindex);
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
begin
  bounds_cymax := 0;
  bounds_cymin := 0;

  if showwave.Value then
  begin
    panelwave.Visible := True;
    if showgrid.Value then
    begin
      griddisp.Visible := True;
      griddisp.top     := panelwave.bottom + 1;
      Height           := 18 + panelwave.bottom + griddisp.Height;
    end
    else
    begin
      griddisp.Visible := False;
      Height           := 18 + panelwave.bottom;
    end;
  end
  else
  begin
    panelwave.Visible := False;
    if showgrid.Value then
    begin
      griddisp.Visible := True;
      griddisp.top     := panelwave.top;
      Height           := 18 + griddisp.bottom;
    end
    else
    begin
      griddisp.Visible := False;
      Height           := 18 + panelcommand.bottom;
    end;
  end;
  application.ProcessMessages;

  bounds_cymax := bounds_cy;
  bounds_cymin := bounds_cy;

end;

procedure twebstreamerfo.oncreate(const Sender: TObject);
begin
  Height  := 154;
  Visible := False;
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
    btempo.face.template := tfacecomp10;
  end
  else
  begin
    btempo.face.template := tfacecomp7;
    btempo.tag           := 0;
  end;
end;

procedure twebstreamerfo.onafterdropdown(const Sender: TObject);
begin
  if (isinit) and (runselect.Value) then
  begin
    onstop(nil);
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
end;

end.
