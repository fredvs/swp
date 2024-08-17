unit webstreamer;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface

uses
 uos_flat,msetypes,mseglob,mseguiglob,mseguiintf,mseapplication,msestat,
 msemenus,msegui,msegraphics,msegraphutils,mseevent,Classes,mseclasses,mseforms,
 msedock,msesimplewidgets,msewidgets,msedispwidgets,mserichstring,mseact,
 msedataedits,msedropdownlist,mseedit,mseificomp,mseificompglob,mseifiglob,
 msestatfile,msestream,SysUtils,msegraphedits,msescrollbar,msebitmap;

type
  twebstreamerfo = class(tdockform)
    historyfn: thistoryedit;
    tstringdisp1: tstringdisp;
    panelcommand: tpaintbox;
    buttonicons: timagelist;
    sliderimage: tbitmapcomp;
    trackbar1: tslider;
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
    tlabel2: tlabel;
    tlabel3: tlabel;
    tlabel4: tlabel;
    tlabel5: tlabel;
    tstatfile1: tstatfile;
    btempo: TButton;
    brecord: TButton;
    timagelist3: timagelist;
    tframecomp2: tframecomp;
    tmainmenu1: tmainmenu;
    runselect: tbooleanedit;
    showwave: tbooleanedit;
   thistoryedit2: thistoryedit;
   tstringdisp2: tstringdisp;
   tbutton2: tbutton;
   tbutton3: tbutton;
   tfacecomp4: tfacecomp;
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
   procedure onclearhist(const sender: TObject);
   procedure cancelclear(const sender: TObject);
   procedure showclear(const sender: TObject);
  end;

var
  webstreamerfo: twebstreamerfo;
  webindex, webinindex, weboutindex, webPlugIndex: integer;
  rectrecform: rectty;
  xreclive: integer;
  plugsoundtouch: Boolean = False;
  isinit: Boolean = False;
  ordir, arecnp: string;


implementation

uses
  webstreamer_mfm;

procedure twebstreamerfo.ChangePlugSetSoundTouch(const Sender: TObject);
var
  abool: Boolean;
begin
  if btempo.tag = 0 then
    abool := False
  else
    abool := True;
  if brecord.tag = 0 then
    uos_SetPluginSoundTouch(webindex, webplugindex, edtempo.Value * 2, edpitch.Value * 2, abool);
end;

procedure twebstreamerfo.InitDrawLive();
const
  // transpcolor = $FFF0F0;
  transpcolor = $B6C4AF;
begin

  trackbar1.invalidate();

  rectrecform.pos  := nullpoint;
  rectrecform.size := trackbar1.paintsize;

  xreclive := 1;

  TrackBar1.Value := 0;

  with sliderimage.bitmap do
  begin
    size   := rectrecform.size;
    init(transpcolor);
    masked := True;
    transparentcolor := transpcolor;
  end;

end;

procedure twebstreamerfo.DrawLive(lv, rv: double);
var
  poswavrec, poswavrec2: pointty;
begin

  sliderimage.bitmap.masked := False;

  poswavrec.x  := xreclive;
  poswavrec2.x := poswavrec.x;
  poswavrec.y  := (trackbar1.Height div 2) - 2;
  poswavrec2.y := ((trackbar1.Height div 2) - 1) - round((lv) * ((rectrecform.cy div 2) - 3));
  sliderimage.bitmap.Canvas.drawline(poswavrec, poswavrec2, $AC99D6);

  poswavrec.y := (trackbar1.Height div 2);

  poswavrec2.y := poswavrec.y + (round((rv) * ((trackbar1.Height div 2) - 3)));
  sliderimage.bitmap.Canvas.drawline(poswavrec, poswavrec2, $AC79D6);

  xreclive := xreclive + 1;

end;

procedure twebstreamerfo.LoopProcPlayer1;
begin
  ShowLevel;
{
  if isrecording = False then
    ShowPosition;

  if (spectrumrecfo.spect1.Value = True) and (spectrumrecfo.Visible = True) and
    (commanderfo.speccalc.Value = True) then
    ShowSpectrum(nil);
}
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

  if trackbar1.Visible = True then
  begin

    if (xreclive) > (Width) then
      InitDrawLive();

    TrackBar1.Value := xreclive / (TrackBar1.Width);
    DrawLive(leftlev, rightlev);
  end;
end;

procedure twebstreamerfo.onplay(const Sender: TObject);
var
  abool: Boolean;
  arec: string;
  aformat: integer;
begin
  tstringdisp1.font.color := cl_blue;
  tstringdisp1.Value := 'Trying to get ' + historyfn.Value;
  application.ProcessMessages;
  webindex   := 0;
  webinindex := -1;
  // PlayerIndex : from 0 to what your computer can do ! (depends of ram, cpu, ...)
  // If PlayerIndex exists already, it will be overwritten...

  InitDrawLive();

  uos_CreatePlayer(webindex);
  //// Create the player.
  //// PlayerIndex : from 0 to what your computer can do !
  //// If PlayerIndex exists already, it will be overwriten...

  if brecord.tag = 0 then
    aformat := 0
  else
    aformat := 2;

  application.ProcessMessages;

  webinindex := uos_AddFromURL(webindex, PChar(ansistring(historyfn.Value)), -1, aformat, 1024 * 2, 0, False);

  /////// Add a Input from Audio URL with custom parameters
  ////////// URL : URL of audio file (like  'http://someserver/somesound.mp3')
  ////////// OutputIndex : OutputIndex of existing Output // -1: all output, -2: no output, other LongInt : existing Output
  ////////// SampleFormat : -1 default : Int16 (0: Float32, 1:Int32, 2:Int16)
  //////////// FramesCount : default : -1 (1024)
  //////////// AudioFormat : default : -1 (mp3) (0: mp3, 1: opus)
  // ICY data on/off

  if webinindex <> -1 then
  begin

    // radiogroup1.Enabled := False;

    weboutindex := uos_AddIntoDevOut(webindex, -1, 1.5, uos_InputGetSampleRate(webindex, webinindex),
      uos_InputGetChannels(webindex, webinindex), aformat, 1024 * 2, -1);

    if brecord.tag = 1 then
    begin
      arecnp := 'records' + directoryseparator + 'rec_' +
        msestring(formatdatetime('YY_MM_DD_HH_mm_ss', now)) + '.wav';

      arec := ordir + arecnp;
      uos_AddIntoFile(webindex, PChar(arec), -1, -1, aformat, 1024 * 2, 0);

      btempo.Enabled  := False;
      edtempo.Enabled := False;
      edpitch.Enabled := False;
      breset.Enabled  := False;
      brecord.color   := cl_red;
    end;

    //// add a Output into device with custom parameters
    //////////// PlayerIndex : Index of a existing Player
    //////////// Device ( -1 is default Output device )
    //////////// Latency  ( -1 is latency suggested ) )
    //////////// SampleRate : delault : -1 (44100)   /// here default samplerate of input
    //////////// Channels : delault : -1 (2:stereo) (0: no channels, 1:mono, 2:stereo, ...)
    //////////// SampleFormat : -1 default : Int16 : (0: Float32, 1:Int32, 2:Int16)
    //////////// FramesCount : default : -1 (65536)
    // ChunkCount : default : -1 (= 512)
    //  result : -1 nothing created, otherwise Output Index in array

    uos_InputSetLevelEnable(webindex, webinindex, 2);
    ///// set calculation of level/volume (usefull for showvolume procedure)
    ///////// set level calculation (default is 0)
    // 0 => no calcul
    // 1 => calcul before all DSP procedures.
    // 2 => calcul after all DSP procedures.
    // 3 => calcul before and after all DSP procedures.

    uos_LoopProcIn(webindex, webinindex, @LoopProcPlayer1);
    ///// Assign the procedure of object to execute inside the loop for a Input
    //////////// PlayerIndex : Index of a existing Player
    //////////// InIndex : Index of a existing Input
    //////////// LoopProcPlayer1 : procedure of object to execute inside the loop

    uos_InputAddDSPVolume(webindex, webinindex, 1, 1);
    ///// DSP Volume changer
    ////////// PlayerIndex1 : Index of a existing Player
    ////////// In1Index : InputIndex of a existing input
    ////////// VolLeft : Left volume  ( from 0 to 1 => gain > 1 )
    ////////// VolRight : Right volume

    uos_InputSetDSPVolume(webindex, webinindex, edvol.Value / 100, edvolr.Value / 100, True);
    ////////// PlayerIndex1 : Index of a existing Player
    ////////// In1Index : InputIndex of a existing Input
    ////////// VolLeft : Left volume
    ////////// VolRight : Right volume
    ////////// Enable : Enabled

    if (plugsoundtouch = True) and (brecord.tag = 0) then
    begin
      if btempo.tag = 0 then
        abool := False
      else
        abool := True;
      webPlugIndex := uos_AddPlugin(webindex, 'soundtouch', uos_InputGetSampleRate(webindex, webinindex),
        uos_InputGetChannels(webindex, webinindex));
      ///// add SoundTouch plugin with default samplerate(44100) / channels(2 = stereo)
      uos_SetPluginSoundTouch(webindex, webplugindex, edtempo.Value * 2, edpitch.Value * 2, abool);
      //// Change plugin settings
    end;

    /////// procedure to execute when stream is terminated
    // uos_EndProc(webindex, @ClosePlayer1);
    ///// Assign the procedure of object to execute at end
    //////////// PlayerIndex : Index of a existing Player
    //////////// ClosePlayer1 : procedure of object to execute inside the loop


    btnStart.Enabled  := False;
    btnResume.Enabled := False;
    btnStop.Enabled   := True;
    btnPause.Enabled  := True;
    brecord.Enabled   := False;
    if brecord.tag = 1 then
      brecord.color := cl_red;

    tstringdisp1.font.color := cl_black;
    if brecord.tag = 1 then
      tstringdisp1.Value    := 'Play + Record ' + historyfn.Value
    else
      tstringdisp1.Value    := 'Playing ' + historyfn.Value;

    if brecord.tag = 1 then
      brecord.Caption := 'Recording...'
    else
      brecord.Caption := 'Only playing';

    onchangevol(nil);
    
    tstringdisp1.face.template := tfacecomp4;
    
    application.ProcessMessages;

    uos_Play(webindex);  /////// everything is ready, here we are, lets play it...
  end
  else
  begin
    tstringdisp1.font.color := cl_red;
    tstringdisp1.Value      := 'URL did not accessed';
  end;
end;

procedure twebstreamerfo.oneventstart(const Sender: TObject);
var
  pa, mp, st: string;
 {$if defined(darwin) and defined(macapp)}
  binPath: string;
{$ENDIF}
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
 //op :=  ordir + 'lib/Linux/64bit/LibOpusFile-64.so';
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

  if uos_LoadLib(PChar(pa), nil, PChar(mp), nil, nil, nil) = -1 then
    application.terminate;

  if (uos_LoadPlugin('soundtouch', PChar(st)) = 0) then
    plugsoundtouch := True
  // writeln('Yes plugsoundtouch');
  else
    plugsoundtouch := False;
  // writeln('NO plugsoundtouch');

  Visible := True;

  brecord.color := $B6C4AF;
  brecord.tag   := 0;

  btempo.color := $B6C4AF;
  btempo.tag   := 0;

  tmainmenu1.menu.itembynames(['showwav']).Checked := showwave.Value;

  tmainmenu1.menu.itembynames(['playaf']).Checked := runselect.Value;

  onchangeshowwave(nil);

  isinit := True;

  application.ProcessMessages;
 
end;

procedure twebstreamerfo.onstop(const Sender: TObject);
begin
  uos_Stop(webindex);
  btnStart.Enabled  := True;
  btnResume.Enabled := False;
  btnStop.Enabled   := False;
  btnPause.Enabled  := False;
  brecord.Enabled   := True;
  btempo.Enabled    := True;
  breset.Enabled    := True;
  edtempo.Enabled   := True;
  edpitch.Enabled   := True;
  if brecord.tag = 1 then
    tstringdisp1.Value := 'Rec saved: ' + arecnp
  else
    tstringdisp1.Value := historyfn.Value + ' stopped...';
  brecord.tag          := 0;
  brecord.Caption      := 'Record';
  brecord.color        := $B6C4AF;
  tstringdisp1.face.template := tfacecomp3;
end;

procedure twebstreamerfo.onclosed(const Sender: TObject);
begin
  uos_Stop(webindex);
  uos_free;
end;

procedure twebstreamerfo.onpause(const Sender: TObject);
begin
  uos_Pause(webindex);
  btnStart.Enabled   := False;
  btnResume.Enabled  := True;
  btnStop.Enabled    := True;
  btnPause.Enabled   := False;
  tstringdisp1.Value := historyfn.Value + ' paused...';
end;

procedure twebstreamerfo.onresume(const Sender: TObject);
begin
  uos_replay(webindex);
  btnStart.Enabled   := False;
  btnResume.Enabled  := False;
  btnStop.Enabled    := True;
  btnPause.Enabled   := True;
  tstringdisp1.Value := historyfn.Value + ' resumed...';
end;

procedure twebstreamerfo.onchangevol(const Sender: TObject);
begin
  uos_InputSetDSPVolume(webindex, webinindex,
    edvol.Value, edvolr.Value, True);
end;

procedure twebstreamerfo.onchangeshowwave(const Sender: TObject);
begin
  if showwave.Value then
  begin
    trackbar1.Visible := True;
    Height := 234;
  end
  else
  begin
    trackbar1.Visible := False;
    Height := 154;
  end;
end;

procedure twebstreamerfo.oncreate(const Sender: TObject);
begin
  Height  := 154;
  Visible := False;
end;

procedure twebstreamerfo.onreset(const Sender: TObject);
begin
 askconfirmation('Do you want to delete all the history of url?');

  edtempo.Value := 0.5;
  edpitch.Value := 0.5;
end;

procedure twebstreamerfo.onrec(const Sender: TObject);
begin
  if brecord.tag = 0 then
  begin
    brecord.tag     := 1;
    brecord.color   := $FFB759;
    brecord.Caption := 'Cue Record';
  end
  else
  begin
    brecord.color   := $B6C4AF;
    brecord.Caption := 'Record';
    brecord.tag     := 0;
  end;
end;

procedure twebstreamerfo.ontempo(const Sender: TObject);
begin
  if btempo.tag = 0 then
  begin
    btempo.tag   := 1;
    btempo.color := cl_green;
  end
  else
  begin
    btempo.color := $B6C4AF;
    btempo.tag   := 0;
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
  onchangeshowwave(nil);
end;

procedure twebstreamerfo.onafterplayafter(const Sender: TObject);
begin
  runselect.Value := tmainmenu1.menu.itembynames(['playaf']).Checked;
end;

procedure twebstreamerfo.onclearhist(const sender: TObject);
begin
 historyfn.dropdown.valuelist.asarray := thistoryedit2.dropdown.valuelist.asarray;
 tstringdisp2.visible := false;
end;

procedure twebstreamerfo.cancelclear(const sender: TObject);
begin
tstringdisp2.visible := false;
end;

procedure twebstreamerfo.showclear(const sender: TObject);
begin
tstringdisp2.visible := true;
end;

end.

