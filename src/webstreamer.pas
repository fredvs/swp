unit webstreamer;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
{$RANGECHECKS OFF} 
interface

uses
 {$ifdef unix}Unix,UnixType,{$else}Windows, dynlibs,
  Winsock,{$endif}Sockets,
  Types,
  uos_httpgetthread,
  uos_flat,
  Math,
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
  msegridsglob,
  msetimer,
  BGRABitmap,
  BGRAAnimatedGif,
  BGRABitmapTypes,
  mseimage,
  msefiledialogx;

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
    messagedlg: tstringdisp;
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
    edrecformat: tintegeredit;
    baddrow: TButton;
    bdelrow: TButton;
    tfacecomp2: tfacecomp;
    edstyle: tintegeredit;
    ttimer1: ttimer;
    PimgPreview: tpaintbox;
    timagelist1: timagelist;
    eurlname: tedit;
    edfullscreen: tintegeredit;
    ttimer2: ttimer;
    typurl: tstringdisp;
    tfiledialog1: tfiledialogx;
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
    procedure onchangehistory(const Sender: TObject);
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
    procedure onexecswpstyle(const Sender: TObject);
    procedure ontimericy(const Sender: TObject);
    procedure onpaintimg(const Sender: twidget; const acanvas: tcanvas);
    procedure getpicture(aurl: string);
    procedure onclickimage(const Sender: twidget; var ainfo: mouseeventinfoty);
    procedure onurl(const Sender: TObject);
    procedure afterdropdown(const Sender: TObject);
    function checkconnection(): Boolean;
    procedure onafterfullscreen(const Sender: TObject);
    procedure ontimeout(const Sender: TObject);
    procedure onimporte(const Sender: TObject);
    procedure m3uLoad(am3u: string);
    procedure onexport(const Sender: TObject);
    procedure m3uexport(am3u: string);
   procedure oncreated(const sender: TObject);
  end;

const
  versionnum = 250424;

var
  webstreamerfo: twebstreamerfo;
  loopok: Boolean = True;
  webindex, webinindex, weboutindex, webPlugIndex, fontheight: integer;
  rectrecform: rectty;
  xreclive, devcount, incview, deviceselected: integer;
  plugsoundtouch: Boolean = False;
  aboolicy: Boolean = False;
  aimage: TBGRAbitmap;
  isinit: Boolean = False;
  isbusy: Boolean = False;
  isexit: Boolean = False;
  hasbitmap: Boolean = False;
  ordir, arecnp, icystr, theplaying: string;
  pa, sf, mp, aa, op, st: string;
  boundchildsp: array of boundchild;
  noaac: Boolean = False;
  uaudiotype: integer;
  rectori: rectty;
  urlname: string = 'Simple Webstream Player';
 {$if defined(darwin) and defined(macapp)}
  binPath: string;
 {$ENDIF}

implementation

uses
  fphttpclient,
  openssl, { This implements the procedure InitSSLInterface }
  opensslsockets,
  webstreamer_mfm;

procedure twebstreamerfo.m3uexport(am3u: string);
var
  f: longint;
  s: msestring;
  meuf: Text;
begin
  AssignFile(meuf, am3u);
  FileMode := 1;
  ReWrite(meuf);
  Writeln(meuf, '#EXTM3U');
  Writeln(meuf, '#PLAYLIST: SWP');
  for f := 0 to griddisp.rowcount - 1 do
  begin
    Writeln(meuf, '#EXTINF:, ' + griddisp[0][f] + ' ; ' + griddisp[1][f]);
    Writeln(meuf, griddisp[2][f]);
  end;
  CloseFile(meuf);
end;

procedure twebstreamerfo.m3uLoad(am3u: string);
var
  f: longint;
  s, s2, s3: string;
  // sall: string;
  meuf: Text;
begin
  AssignFile(meuf, am3u);
  FileMode          := 0;
  ReSet(meuf);
  //sall := '';
  griddisp.rowcount := 0;
  while EOF(meuf) = False do
  begin
    ReadLn(meuf, s);
    if (copy(s, 1, 8) = 'https://') or (copy(s, 1, 7) = 'http://') then
    begin
      griddisp.rowcount := griddisp.rowcount + 1;
      if s3 = '' then
        griddisp[1][griddisp.rowcount - 1] := 'unknown'
      else
        griddisp[1][griddisp.rowcount - 1] := s3;
      if s2 = '' then
        s2 := copy(s, system.pos('//', s) + 2, 10);
      griddisp[0][griddisp.rowcount - 1] := trim(s2);
      griddisp[2][griddisp.rowcount - 1] := trim(s);
      // sall := sall + s + ' | ' + s2 + lineending;
    end
    else if system.pos(',', s) > 0 then
    begin
      s2   := copy(s, system.pos(',', s) + 1, length(s));
      if system.pos('[', s2) > 0 then
        s2 := trim(copy(s2, 1, system.pos('[', s2) - 2));
      s2 := StringReplace(s2, '&#039;', '''', [rfReplaceAll, rfIgnoreCase]);
      s2 := StringReplace(s2, '&apos;', '''', [rfReplaceAll, rfIgnoreCase]);
      if system.pos(';', s2) > 0 then
      begin
        s3 := trim(copy(s2, system.pos(';', s2) + 1, length(s2)));
        s2 := trim(copy(s2, 1, system.pos(';', s2) - 1));
      end;

    end;
  end; {next}

       //SL.Assign(s);
       //writeln('SL.values ' + inttostr(SL.count));
       //writeln(sall);
  CloseFile(meuf);
end;

function checkConnect(const hostAddress: string; portNumber: integer; timeout: integer = 3): Boolean;
var
  sock: longint;
  addr: TSockAddr;
  timeset: TTimeVal;
begin
  sock := fpsocket(AF_INET, SOCK_STREAM, 0);
  if sock = -1 then
  begin
    Result := False;
    Exit;
  end;

  timeset.tv_sec  := timeout;
  timeset.tv_usec := 0;
  fpsetsockopt(sock, SOL_SOCKET, SO_SNDTIMEO, @timeset, SizeOf(timeset));

  addr.sin_family := AF_INET;
  addr.sin_port   := htons(portNumber);
  addr.sin_addr   := TInAddr(StrToNetAddr(hostAddress));

  Result := 0 = fpconnect(sock, @addr, SizeOf(addr));

  CloseSocket(Sock);
end;

function checkAnyConnect(const hosts: TStringDynArray; const port: integer = 53): Boolean;
var
  host: string;
begin
  for host in hosts do
    if checkConnect(host, port) then
      Exit(True);
  Result := False;
end;

function twebstreamerfo.checkconnection(): Boolean;
begin
  Result := checkAnyConnect([
    '4.2.2.1',
    '4.2.2.2',
    '4.2.2.3',
    '4.2.2.4',
    '4.2.2.5',
    '4.2.2.6']);

  if Result = False then
  begin
    messagedlg.top        := infopanel.top + 5;
    messagedlg.Text       := '       No Internet connection...';
    messagedlg.font.color := cl_red;
    bno.font.color        := font.color;
    byes.Visible          := False;
    bno.Caption           := 'OK';
    messagedlg.Visible    := True;
  end;
end;

{$IFDEF windows}
procedure OpenURL(const aURL: String);
begin
  try
    {$IFNDEF wince}
    ShellExecute(0, 'open', PChar(aURL), nil, nil, 1 {SW_SHOWNORMAL});
    {$ENDIF}
  except
    // do nothing
  end;
end;
{$ELSE}

procedure OpenURL(const aURL: string);
var
  Helper: string;
begin
  Helper   := '';
  if fpsystem('which xdg-open') = 0 then
    Helper := 'xdg-open'
  else if FileExists('/usr/bin/sensible-browser') then
    Helper := '/usr/bin/sensible-browser'
  else if FileExists('/etc/alternatives/x-www-browser') then
    Helper := '/etc/alternatives/x-www-browser'
  else if fpsystem('which firefox') = 0 then
    Helper := 'firefox'
  else if fpsystem('which konqueror') = 0 then
    Helper := 'konqueror'
  else if fpsystem('which opera') = 0 then
    Helper := 'opera'
  else if fpsystem('which mozilla') = 0 then
    Helper := 'mozilla'
  else if fpsystem('which chrome') = 0 then
    Helper := 'chrome'
  else if fpsystem('which chromium') = 0 then
    Helper := 'chromium';

  if Helper <> '' then
    fpSystem(Helper + ' ' + aURL + '&');
end;

{$ENDIF}

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
  if uaudiotype <> 1 then
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
      if (edtempo.Value > 0.1) and (edpitch.Value > 0.1) then
        uos_SetPluginSoundTouch(webindex, webplugindex, edtempo.Value * 2, edpitch.Value * 2, abool);
    end;
  end;
end;

procedure twebstreamerfo.InitDrawLive();
var
  transpcolor: longint = $B6C4AF;
begin

  if edstyle.Value = 0 then
    transpcolor := $5F605F;
  if edstyle.Value = 1 then
    transpcolor := cl_black;
  if edstyle.Value = 2 then
    transpcolor := $636363;

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
//  if loopok then
    if (PimgPreview.tag = 0) then
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
    vuLeft.Value := leftlev * edvol.Value;

  if (rightlev >= 0) and (rightlev <= 1) then
    vuRight.Value := rightlev * edvolr.Value;

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
  aformat, webformat, sizebuf, res: integer;
  latency: cfloat;
begin
  if checkconnection() then
  begin
    res := CheckURLStatus(historyfn.Value);
    // writeln('CheckURLStatus = ', res);
    if (res = 0) then
    begin
      ttimer2.Enabled := False;
      ttimer2.Enabled := True;
      InitDrawLive();
      hasbitmap  := False;
      PimgPreview.Visible := False;
      btnStart.Enabled := False;
      btnStart.face.template := tfacecomp6;
      infopanel.font.color := cl_red;
      infopanel.Value := 'Trying to get ' + historyfn.Value;
      application.ProcessMessages;
      webindex   := 0;
      webinindex := -1;
      incview    := 0;
      icystr     := 'icy';
      uos_CreatePlayer(webindex);

      aboolicy := True;

      latency := -1;
      sizebuf := 16384;

      if brecord.tag = 0 then
        aformat := 0
      else if edrecformat.Value = 0 then
        aformat := 2
      else
        aformat := 0;

      application.ProcessMessages;

      // 'https://radiorecord.hostingradio.ru/ps96.aacp';

      theplaying := historyfn.Value;

      // Add a Input from Audio URL with custom parameters
      // URL : URL of audio file (like  'http://someserver/somesound.mp3')
      // OutputIndex : OutputIndex of existing Output // -1: all output, -2: no output, other LongInt : existing Output
      // SampleFormat : -1 default : Int16 (0: Float32, 1:Int32, 2:Int16)
      // FramesCount : default : -1 (1024)
      // AudioFormat : default : -1 (mp3) (0: mp3, 1: opus, 2: aac)
      // ICY data on/off
      webinindex := uos_AddFromURL(webindex, PChar(ansistring(historyfn.Value)), -1, aformat, sizebuf, -1, aboolicy);

      if webinindex <> -1 then
      begin
        Caption     := urlname;
        weboutindex := uos_AddIntoDevOut(webindex, deviceselected, latency, uos_InputGetSampleRate(webindex, webinindex),
          uos_InputGetChannels(webindex, webinindex), aformat, sizebuf, -1);

        if brecord.tag = 1 then
        begin
          if edrecformat.Value = 0 then
            outputstr := '.wav'
          else
          begin
            sizebuf   := sizebuf div 8;
            outputstr := '.ogg';  // needs sndfile library
          end;

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

        uos_inputSetLevelEnable(webindex, webinindex, 2);
        // set calculation of level/volume (usefull for showvolume procedure)
        // set level calculation (default is 0)
        // 0 => no calcul
        // 1 => calcul before all DSP procedures.
        // 2 => calcul after all DSP procedures.
        // 3 => calcul before and after all DSP procedures.

        uos_LoopProcIn(webindex, webinindex, @LoopProcPlayer1);
        // Assign the procedure of object to execute inside the loop for a Output
        // PlayerIndex : Index of a existing Player
        // InIndex : Index of a existing Output
        // LoopProcPlayer1 : procedure of object to execute inside the loop

        uos_OutputAddDSPVolume(webindex, weboutindex, 1, 1);
        // DSP Volume changer
        // PlayerIndex1 : Index of a existing Player
        // In1Index : OutputIndex of a existing Output
        // VolLeft : Left volume  ( from 0 to 1 => gain > 1 )
        // VolRight : Right volume

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

        tmainmenu1.menu.itembynames(['config', 'refresh']).Enabled := False;

        uaudiotype := uos_InputGetURLAudioType(webindex, webinindex);

        if (plugsoundtouch = True) and (brecord.tag = 0) and (uaudiotype <> 1) then
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

        application.ProcessMessages;

        uos_Play(webindex);  // everything is ready, here we are, lets play it...

        if uaudiotype = 1 then
        begin
          btempo.Enabled  := False;
          breset.Enabled  := False;
          edtempo.Enabled := False;
          edpitch.Enabled := False;
        end
        else
        begin
          btempo.Enabled  := True;
          breset.Enabled  := True;
          edtempo.Enabled := True;
          edpitch.Enabled := True;
        end;

        if uaudiotype = 0 then
          typurl.Text := 'MP3'
        else if uaudiotype = 1 then
          typurl.Text := 'OPUS'
        else if uaudiotype = 2 then
          typurl.Text := 'AAC';

        typurl.hint := ' Audio format is ' + typurl.Text + stringreplace(uos_InputGetURLiceAudioInfo(webindex, webinindex),
          ';', ' ', [rfReplaceAll, rfIgnoreCase]) + ' ';

        infopanel.hint := typurl.hint;

        typurl.Visible := True;

        //writeln('uaudiotype ' + inttostr(uaudiotype)); 

        if (aboolicy = True) then
          if uaudiotype = 0 then
            ttimer1.Enabled := True
          else
            ontimericy(nil);

        messagedlg.Visible := False;
        ttimer2.Enabled    := False;
      end;
    end
    else
    begin
      infopanel.font.color   := cl_red;
      infopanel.Value        := 'URL did not accessed';
      btnStart.Enabled       := True;
      btnStart.face.template := tfacecomp7;
    end;
  end;
end;

procedure twebstreamerfo.oneventstart(const Sender: TObject);
var
  rect1: rectty;
begin
  hide;
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
  // op := AnsiString(ordir + 'lib\Windows\64bit\LibOpusFile-64.dll');
  op := '';
  {$else}
  pa := AnsiString(ordir + 'lib\Windows\32bit\LibPortaudio-32.dll');
  mp := AnsiString(ordir + 'lib\Windows\32bit\LibMpg123-32.dll');
  aa := AnsiString(ordir + 'lib\Windows\32bit\libfdk-aac-32.dll');
  st := AnsiString(ordir + 'lib\Windows\32bit\LibSoundTouch-32.dll');
  op := AnsiString(ordir + 'lib\Windows\32bit\LibOpusFile-32.dll');
  //op := '';
  {$endif}
  {$ENDIF}

  {$if defined(CPUAMD64) and defined(linux) }
  pa := ordir + 'lib/Linux/64bit/LibPortaudio-64.so';
  mp := ordir + 'lib/Linux/64bit/LibMpg123-64.so';
  aa := ordir + 'lib/Linux/64bit/libfdk-aac-64.so';
  op := ordir + 'lib/Linux/64bit/LibOpusFile-64.so';
  st := ordir + 'lib/Linux/64bit/LibSoundTouch-64.so';
  {$ENDIF}

  {$if defined(CPUAMD64) and defined(openbsd) }
  pa := AnsiString(ordir + 'lib/OpenBSD/64bit/LibPortaudio-64.so');
  mp := AnsiString(ordir + 'lib/OpenBSD/64bit/LibMpg123-64.so');
  st := AnsiString(ordir + 'lib/OpenBSD/64bit/LibSoundTouch-64.so');
  aa := '';
  op := '';
  noaac := true;
  {$ENDIF}

  {$if defined(cpu64) and defined(darwin) }
  pa := AnsiString(ordir + 'lib/Mac/64bit/LibPortaudio-64.dylib');
  mp := AnsiString(ordir + 'lib/Mac/64bit/LibMpg123-64.dylib');
  st := AnsiString(ordir + 'lib/Mac/64bit/libSoundTouchDLL.dylib');
  noaac := true;
  aa := '';
  op := '';
  {$ENDIF}

  {$if defined(cpu86) and defined(linux)}
  pa := AnsiString(ordir + 'lib/Linux/32bit/LibPortaudio-32.so');
  mp := AnsiString(ordir + 'lib/Linux/32bit/LibMpg123-32.so');
  st := AnsiString(ordir + 'lib/Linux/32bit/LibSoundTouch-32.so');
  aa := AnsiString(ordir + 'lib/Linux/32bit/libfdk-aac-32.so');
  op := AnsiString(ordir + 'lib/Linux/32bit/LibOpusFile-32.so');
  {$ENDIF}

  {$if defined(linux) and defined(cpuarm)}
  pa := AnsiString(ordir + 'lib/Linux/arm_raspberrypi/libportaudio-arm.so');
  mp := AnsiString(ordir + 'lib/Linux/arm_raspberrypi/libmpg123-arm.so');
  st := AnsiString(ordir + 'lib/Linux/arm_raspberrypi/libsoundtouch-arm.so');
  aa := AnsiString(ordir + 'lib/Linux/arm_raspberrypi/libfdk-aac-arm.so');
  op := AnsiString(ordir + 'lib/Linux/arm_raspberrypi/libopusfile-arm.so');
  {$ENDIF}

  {$if defined(linux) and defined(cpuaarch64)}
  pa := AnsiString(ordir + 'lib/Linux/aarch64_raspberrypi/libportaudio_aarch64.so');
  mp := AnsiString(ordir + 'lib/Linux/aarch64_raspberrypi/libmpg123_aarch64.so');
  st := AnsiString(ordir + 'lib/Linux/aarch64_raspberrypi/libsoundtouch_aarch64.so');
  aa := AnsiString(ordir + 'lib/Linux/aarch64_raspberrypi/libfdk-aac_aarch64.so');
  op := AnsiString(ordir + 'lib/Linux/aarch64_raspberrypi/libopusfile_aarch64.so');
  {$ENDIF}

  {$if defined(freebsd) and defined(cpuamd64) }
  pa := AnsiString(ordir + 'lib/FreeBSD/amd64/libportaudio-64.so');
  mp := AnsiString(ordir + 'lib/FreeBSD/amd64/libmpg123-64.so');
  st := AnsiString(ordir + 'lib/FreeBSD/amd64/libsoundtouch-64.so');
  noaac := true;
  aa := '';
  op := '';
  {$endif}

  {$if defined(freebsd) and defined(cpui386) }
  pa := AnsiString(ordir + 'lib/FreeBSD/i386/libportaudio-32.so');
  mp := AnsiString(ordir + 'lib/FreeBSD/i386/libmpg123-32.so');
  st := '';
  aa := '';
  op := '';
  noaac := true;
  {$endif}

  {$if defined(freebsd) and defined(cpuamd64) }
  pa := AnsiString(ordir + 'lib/FreeBSD/aarch64/libportaudio-64.so');
  mp := AnsiString(ordir + 'lib/FreeBSD/aarch64/libmpg123-64.so');
  st := '';
  aa := '';
  op := '';
  noaac := true;
  {$endif}

  {$if defined(cpu86) and defined(windows)}
    dynlibs.safeloadlibrary(AnsiString(ordir + 'lib\Windows\32bit\libcrypto-1_1.dll'));
    dynlibs.safeloadlibrary(AnsiString(ordir + 'lib\Windows\32bit\libssl-1_1.dll'));
   {$endif}
   
   {$if defined(cpu64) and defined(windows)}
    dynlibs.safeloadlibrary(AnsiString(ordir + 'lib\Windows\64bit\libeay32.dll'));
    dynlibs.safeloadlibrary(AnsiString(ordir + 'lib\Windows\64bit\ssleay32.dll'));
   {$endif} 

  if uos_LoadLib(PChar(pa), PChar(sf), PChar(mp), nil, nil, PChar(op), nil, PChar(aa)) = -1 then
    if uos_LoadLib('system', 'system', 'system', nil, nil, nil, nil, 'system') = -1 then
      application.terminate;

  if (uos_LoadPlugin('soundtouch', PChar(st)) = 0) then
    plugsoundtouch := True
  else
    plugsoundtouch := False;

  brecord.tag := 0;

  btempo.tag := 0;

  if PChar(sf) <> '' then
    tmainmenu1.menu.itembynames(['config', 'recformat']).Visible := True;

  if edfullscreen.Value = 0 then
    tmainmenu1.menu.itembynames(['config', 'fullscreen']).Checked := False
  else
    tmainmenu1.menu.itembynames(['config', 'fullscreen']).Checked := True;

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
  end
  else if edstyle.Value = 1 then
  begin
    tmainmenu1.menu.itembynames(['config', 'style', 'swpstyle']).Checked := False;
    tmainmenu1.menu.itembynames(['config', 'style', 'carbonstyle']).Checked := True;
    tmainmenu1.menu.itembynames(['config', 'style', 'silverstyle']).Checked := False;
  end
  else if edstyle.Value = 2 then
  begin
    tmainmenu1.menu.itembynames(['config', 'style', 'swpstyle']).Checked := False;
    tmainmenu1.menu.itembynames(['config', 'style', 'carbonstyle']).Checked := False;
    tmainmenu1.menu.itembynames(['config', 'style', 'silverstyle']).Checked := True;
  end;

  tmainmenu1.menu.itembynames(['showwav']).Checked := showwave.Value;

  tmainmenu1.menu.itembynames(['config', 'playaf']).Checked := runselect.Value;

  tmainmenu1.menu.itembynames(['showgrid']).Checked := showgrid.Value;

  onchangeshowwave(nil);

  tmainmenu1.menu.itembynames(['about', 'title']).Caption :=
    '                 Simple Web Player v1.' + IntToStr(versionnum) + ' on ' + platformtext;

  rect1 := application.screenrect(window);

  fontheight := round(rect1.cy / 800 * 12);
  hide;
  resizesp(fontheight);
  hide;
  oncheckdevices();

  edrecformat.Value := 0;

  urlname := eurlname.Text;

  //  Visible := True;

  checkconnection();

  isinit := True;
  
  optionswindow := [wo_taskbar];
  
  window.recreatewindow;
  
  show;
  
  bringtofront;

end;

procedure twebstreamerfo.onstop(const Sender: TObject);
begin
  ttimer1.Enabled   := False;
  uos_Stop(webindex);
  typurl.Visible    := False;
  messagedlg.Visible := False;
  Caption           := 'Simple Webstream Player';
  btnStart.Enabled  := True;
  btnStart.face.template := tfacecomp7;
  btnResume.Enabled := False;
  btnResume.Visible := False;
  btnResume.face.template := tfacecomp6;
  btnStop.Enabled   := False;
  btnStop.face.template := tfacecomp6;
  btnPause.Enabled  := False;
  btnpause.Visible  := True;
  btnPause.face.template := tfacecomp6;
  brecord.Enabled   := True;
  brecord.face.template := tfacecomp7;
  btempo.Enabled    := True;
  breset.Enabled    := True;
  edtempo.Enabled   := True;
  edpitch.Enabled   := True;
  if brecord.tag = 1 then
    infopanel.Value := 'Rec saved: ' + arecnp
  else
    infopanel.Value   := 'Stopped...';
  brecord.tag         := 0;
  brecord.Caption     := 'Record';
  brecord.face.template := tfacecomp7;
  infopanel.face.template := tfacecomp3;
  tmainmenu1.menu.itembynames(['config', 'refresh']).Enabled := True;
  hasbitmap           := False;
  PimgPreview.Visible := False;
  tmainmenu1.menu.Visible := True;
end;

procedure twebstreamerfo.onclosed(const Sender: TObject);
begin
  eurlname.Text   := urlname;
  ttimer1.Enabled := False;
  uos_Stop(webindex);
  sleep(500);
  if Assigned(aimage) then
    aimage.Free;
end;

procedure twebstreamerfo.onpause(const Sender: TObject);
begin
  uos_Pause(webindex);
  if uaudiotype = 0 then
    ttimer1.Enabled         := False;
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
end;

procedure twebstreamerfo.onresume(const Sender: TObject);
begin
  uos_replay(webindex);
  if uaudiotype = 0 then
    ttimer1.Enabled         := true;
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
end;

procedure twebstreamerfo.onchangevol(const Sender: TObject);
begin
  lvl.Caption := IntToStr(round(edvol.Value * 100));
  lvr.Caption := IntToStr(round(edvolr.Value * 100));
  uos_OutputSetDSPVolume(webindex, weboutindex,
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

  if (PimgPreview.tag = 1) and (PimgPreview.Visible) then
  begin
    tmainmenu1.menu.Visible := False;
    PimgPreview.top         := 0;
    PimgPreview.Height      := Height + round(2 * fontheight / 12);
    PimgPreview.Width       := Width;
    PimgPreview.invalidatewidget;
  end;
end;

procedure twebstreamerfo.oncreate(const Sender: TObject);
var
  statname: string;
  i1, childn: integer;
  {$if defined(linux)}
  sessiontyp: string;
  {$ENDIF}
begin
  hide;
  
  SetExceptionMask(GetExceptionMask + [exZeroDivide] + [exInvalidOp] +
    [exDenormalized] + [exOverflow] + [exUnderflow] + [exPrecision]);

   {$if defined(linux) }
  sessiontyp := LowerCase(GetEnvironmentVariable('XDG_SESSION_TYPE'));
  if sessiontyp <> 'x11' then
    timagelist1.options := [bmo_masked];
   {$ENDIF}

   {$if defined(netbsd) or defined(darwin)}
   timagelist1.options := [bmo_masked] ;
   {$endif}

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

  with messagedlg do
  begin
    setlength(boundchildsp, length(boundchildsp) + messagedlg.childrencount);

    for i1 := 0 to messagedlg.childrencount - 1 do
    begin
      boundchildsp[i1 + childn].left   := children[i1].left;
      boundchildsp[i1 + childn].top    := children[i1].top;
      boundchildsp[i1 + childn].Width  := children[i1].Width;
      boundchildsp[i1 + childn].Height := children[i1].Height;
      boundchildsp[i1 + childn].Name   := children[i1].Name;
    end;
  end;

  childn := childn + messagedlg.childrencount;

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
  if uaudiotype <> 1 then
    ChangePlugSetSoundTouch(nil);
end;

procedure twebstreamerfo.onchangehistory(const Sender: TObject);
begin
  if (isinit) and (runselect.Value) then
  begin
    onstop(nil);
    application.ProcessMessages;
    sleep(300);
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
  messagedlg.Visible := False;
end;

procedure twebstreamerfo.cancelclear(const Sender: TObject);
begin
  messagedlg.Visible := False;
end;

procedure twebstreamerfo.showclear(const Sender: TObject);
begin
  messagedlg.top        := 20;
  messagedlg.Text       := '  Delete all URL history ?';
  byes.Visible          := True;
  bno.Caption           := 'No';
  messagedlg.font.color := font.color;
  bno.font.color        := font.color;
  byes.font.color       := font.color;
  messagedlg.Visible    := True;
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
    begin
      urlname := griddisp[0][griddisp.focusedcell.row];

      if (ss_double in info.mouseeventinfopo^.shiftstate) then
        if trim(griddisp[2][griddisp.focusedcell.row]) <> '' then
        begin
          historyfn.Value := griddisp[2][griddisp.focusedcell.row];
          historyfn.savehistoryvalue;
        end;
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

procedure twebstreamerfo.onexit(const Sender: TObject);
begin
  Close;
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
    edrecformat.Value := 3;
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

  messagedlg.font.Height := fontheight;
  byes.font.Height       := fontheight;
  bno.font.Height        := fontheight;

  historyfn.dropdown.cols[0].font.Height := fontheight;

  griddisp.font.Height := fontheight;
  griddisp.font.color  := font.color;

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
  griddisp[0].Width           := round(138 * ratio);
  griddisp[1].Width           := round(70 * ratio);
  griddisp[2].Width           := round(122 * ratio);
  griddisp.fixrows[-1].Height := round(18 * ratio);
  griddisp.frame.sbvert.Width := round(12 * ratio);

  infopanel.font.Height := fontheight;
  PimgPreview.Height    := infopanel.Height;
  PimgPreview.Width     := infopanel.Height;

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

  with messagedlg do
  begin
    font.Height := fontheight;
    for i1      := 0 to childrencount - 1 do
      for i2 := 0 to length(boundchildsp) - 1 do
        if messagedlg.children[i1].Name = boundchildsp[i2].Name then
        begin
          messagedlg.children[i1].left   := round(boundchildsp[i2].left * ratio);
          messagedlg.children[i1].top    := round(boundchildsp[i2].top * ratio);
          messagedlg.children[i1].Width  := round(boundchildsp[i2].Width * ratio);
          messagedlg.children[i1].Height := round(boundchildsp[i2].Height * ratio);
        end;
  end;

  typurl.Width  := round(36 * ratio);
  typurl.Height := round(13 * ratio);
  typurl.left   := round(309 * ratio);
  typurl.top    := round(1 * ratio);

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
    color           := cl_default;
    font.color      := cl_black;
    font.color      := cl_black;
    vuRight.bar_face.fade_color[1] := $616261;
    vuleft.bar_face.fade_color[1] := $616261;
    infopanel.font.color := cl_black;
    griddisp.font.color := cl_black;
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
    griddisp.datacols.colorfocused := $FFDBA8;
    griddisp[0].color := $E0E0E0;
    griddisp[1].color := $E0E0E0;
    griddisp[2].color := $E0E0E0;
    griddisp.fixrows[-1].color := $BFCCB9;
    griddisp.zebra_color := $F8FFF5;
    container.color := $B6C4AF;
    infopanel.font.color := cl_black;
    historyfn.frame.button.colorglyph := cl_black;
    griddisp.frame.sbvert.colorglyph := cl_black;
  end;

  if style = 1 then
  begin
    color           := $575757;
    font.color      := cl_white;
    infopanel.font.color := cl_white;
    griddisp.font.color := cl_white;
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
    tfacecomp8.template.fade_color.items[0] := $FF9900;
    tfacecomp8.template.fade_color.items[1] := $633C00;
    tfacecomp2.template.fade_color.items[0] := cl_dkgray;
    tfacecomp2.template.fade_color.items[1] := cl_black;
    griddisp.datacols.colorfocused := $B86B00;
    griddisp[0].color := cl_black;
    griddisp[1].color := cl_black;
    griddisp[2].color := cl_black;
    griddisp.fixrows[-1].color := $5C5C5C;
    griddisp.zebra_color := $5C5C5C;
    container.color := $5C5C5C;
    infopanel.font.color := cl_white;
    historyfn.frame.button.colorglyph := cl_white;
    griddisp.frame.sbvert.colorglyph := cl_white;
  end;

  if style = 2 then
  begin
    color           := cl_default;
    font.color      := cl_black;
    font.color      := cl_black;
    vuRight.bar_face.fade_color[1] := $666666;
    vuleft.bar_face.fade_color[1] := $666666;
    infopanel.font.color := cl_black;
    griddisp.font.color := cl_black;
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
    griddisp.datacols.colorfocused := $FFDBA8;
    griddisp[0].color := $E0E0E0;
    griddisp[1].color := $E0E0E0;
    griddisp[2].color := $E0E0E0;
    griddisp.fixrows[-1].color := $D4D4D4;
    griddisp.zebra_color := $F2F2F2;
    container.color := cl_default;
    infopanel.font.color := cl_black;
    historyfn.frame.button.colorglyph := cl_black;
    griddisp.frame.sbvert.colorglyph := cl_black;
  end;
end;

procedure twebstreamerfo.onexecswpstyle(const Sender: TObject);
begin
  if tmainmenu1.menu.itembynames(['config', 'style', 'swpstyle']).Checked = True then
    edstyle.Value := 0
  else if tmainmenu1.menu.itembynames(['config', 'style', 'carbonstyle']).Checked = True then
    edstyle.Value := 1
  else if tmainmenu1.menu.itembynames(['config', 'style', 'silverstyle']).Checked = True then
    edstyle.Value := 2;
  setstyle(edstyle.Value);
  InitDrawLive();
end;

procedure twebstreamerfo.getpicture(aurl: string);
var
  Http: TFPHTTPClient;
  amem: Tmemorystream;
begin
  //Writeln('aurl ' + aurl);
  PimgPreview.Visible := False;
  PimgPreview.invalidatewidget;
  InitSSLInterface;
  amem := Tmemorystream.Create;
  Http := TFPHTTPClient.Create(nil);
  try
    http.AllowRedirect := True;
    http.IOTimeout := 2000;
    Http.Get(aurl, amem);
    amem.Position := 0;
    if Assigned(aimage) then
      aimage.Free;
    aimage    := TBGRAbitmap.Create(amem);
    sleep(100);
    hasbitmap := True;
    PimgPreview.Visible := True;
    PimgPreview.invalidatewidget;
  except
    on E: Exception do
    begin
      infopanel.tag := 1;
      //Writeln('image failed: ' + E.Message);
    end;
  end;
  Http.Free;
  amem.Free;
end;

procedure twebstreamerfo.ontimericy(const Sender: TObject);
var
  atitle, apicture, adescri, agenre, aname, aurl, aurlcut, prefix: msestring;
  ares: integer;
  sicy: PChar;
begin
  sicy          := ' ';
  loopok        := False;
  prefix        := '';
  infopanel.tag := 0;
  //writeln('uaudiotype ' + inttostr(uaudiotype)); 
  if uaudiotype = 0 then
    uos_InputUpdateICY(0, 0, sicy);
  if trim(icystr) <> trim(sicy) then
  begin
    if uaudiotype = 0 then
      if system.Pos('StreamTitle=', sicy) > 0 then
      begin
        atitle := Copy(sicy, system.pos('StreamTitle=', sicy) + 12, Length(sicy));
        atitle := (Copy(atitle, 1, system.Pos(';', atitle) - 1));
      end;

    adescri := uos_InputGetURLicyDescription(webindex, webinindex);
    agenre  := uos_InputGetURLicyGenre(webindex, webinindex);
    aname   := uos_InputGetURLicyName(webindex, webinindex);
    aurl    := uos_InputGetURLicyUrl(webindex, webinindex);

    if uaudiotype = 0 then
      if system.Pos('StreamUrl=', sicy) > 0 then
      begin
        apicture := Copy(sicy, system.pos('StreamUrl=', sicy) + 10, Length(sicy));
        apicture := Copy(apicture, 2, system.Pos(';', apicture) - 1);
        apicture := Copy(apicture, 1, system.Pos('''', apicture) - 1);
        if trim(apicture) <> '' then
        begin
          getpicture(apicture);
          prefix := '          ';
        end;
      end;

    if infopanel.tag = 1 then
      prefix      := '';
    infopanel.tag := 0;

    if uaudiotype = 0 then
      if Length(atitle) > 50 then
        atitle := Copy(atitle, 1, Length(atitle) div 2) + '...' + #10 +
          prefix + '...' + Copy(atitle, (Length(atitle) div 2) + 1, (Length(atitle) div 2) + 1);

    if Length(aname) > 35 then
      aname  := trim(Copy(aname, 1, 35) + '...');
    if Length(agenre) > 10 then
      agenre := trim(Copy(agenre, 1, 10) + '...');

    aurlcut := copy(theplaying, system.Pos('//', theplaying) + 2, Length(theplaying));

    if Length(aurlcut) > 50 then
      aurlcut := trim(Copy(aurlcut, 1, 50) + '...');

    if Length(adescri) > 50 then
      adescri := trim(Copy(adescri, 1, 50) + '...');

    if length(aurl) > 0 then
      aurlcut := trim(aurl);
    if length(agenre) > 0 then
      agenre  := ' ' + agenre;
    if length(aname) > 0 then
      aurlcut := aname + agenre;
    if (length(atitle) = 0) and (length(adescri) > 0) then
      atitle  := adescri;
    infopanel.Value := prefix + aurlcut + #10 +
      prefix + atitle;
    icystr := sicy;
  end;
  loopok := True;
end;

procedure twebstreamerfo.onpaintimg(const Sender: twidget; const acanvas: tcanvas);
var
  theMemBitmap: TBGRABitmap;
begin
  if hasbitmap then
  begin
    theMemBitmap := aimage.Resample(PimgPreview.Width, PimgPreview.Height, rmFineResample) as TBGRABitmap;
    theMemBitmap.Rectangle(0, 0, PimgPreview.Width, PimgPreview.Height,
      BGRA(255, 192, 0), BGRA(80, 80, 80, 255), dmDrawWithTransparency, 8192);
    theMemBitmap.draw(acanvas, 0, 0, True);
    theMemBitmap.Free;
  end;
end;

procedure twebstreamerfo.onclickimage(const Sender: twidget; var ainfo: mouseeventinfoty);
var
  rect1: rectty;
begin

  if isinit then
    if (ainfo.eventkind = ek_buttonrelease) then
    begin
      if PimgPreview.tag = 0 then
      begin
        rectori.cx := left;
        rectori.cy := top;
        tmainmenu1.menu.Visible := False;
        if tmainmenu1.menu.itembynames(['config', 'fullscreen']).Checked then
        begin
          hide;
          bounds_cxmax := 0;
          bounds_cymax := 0;
          rect1        := application.screenrect(window);
          bounds_cx    := rect1.cx;
          bounds_cy    := rect1.cy - 50;
          left         := 0;
          top          := 20;
          bounds_cxmax := bounds_cx;
          bounds_cymax := bounds_cy;
        end;
        PimgPreview.top := 0;
        PimgPreview.Height := Height + round(2 * fontheight / 12);
        PimgPreview.Width  := Width;
        PimgPreview.tag    := 1;
      end
      else
      begin
        bounds_cxmax := bounds_cxmin;
        bounds_cymax := bounds_cymin;
        left         := rectori.cx;
        top          := rectori.cy;
        tmainmenu1.menu.Visible := True;
        PimgPreview.top := infopanel.top;
        PimgPreview.Height := infopanel.Height;
        PimgPreview.Width := infopanel.Height;
        PimgPreview.tag := 0;
      end;
      Show;
      bringtofront;
      PimgPreview.invalidatewidget;
    end;
end;

procedure twebstreamerfo.onurl(const Sender: TObject);
begin
  case tmenuitem(Sender).tag of
    0: openurl('https://www.freepascal.org/');
    1: openurl('https://github.com/mse-org/mseide-msegui/');
    2: openurl('https://github.com/fredvs/uos/');
    3: openurl('http://www.surina.net/soundtouch/');
    4: openurl('https://github.com/fredvs/swp/');
    5: openurl('https://github.com/bgrabitmap/bgrabitmap/');
  end;
end;

procedure twebstreamerfo.afterdropdown(const Sender: TObject);
begin
  Caption := 'Simple Webstream Player';
  urlname := Caption;
end;

procedure twebstreamerfo.onafterfullscreen(const Sender: TObject);
begin
  if tmainmenu1.menu.itembynames(['config', 'fullscreen']).Checked then
    edfullscreen.Value := 1
  else
    edfullscreen.Value := 0;
end;

procedure twebstreamerfo.ontimeout(const Sender: TObject);
begin
  onstop(nil);
  messagedlg.top        := infopanel.top + 5;
  messagedlg.Text       := '       URL did not respond...';
  messagedlg.font.color := cl_red;
  bno.font.color        := font.color;
  byes.Visible          := False;
  bno.Caption           := 'OK';
  btnStart.Enabled      := True;
  btnStart.face.template := tfacecomp7;
  messagedlg.Visible    := True;
end;

procedure twebstreamerfo.onimporte(const Sender: TObject);
begin
  tfiledialog1.controller.icon    := icon;
  tfiledialog1.controller.captionopen := 'Choose a .m3u file to import';
  tfiledialog1.controller.nopanel := False;
  tfiledialog1.controller.compact := False;
  tfiledialog1.controller.fontheight := font.Height;
  tfiledialog1.controller.filter  := '"*.m3u"';
  tfiledialog1.controller.filename := '';
  tfiledialog1.controller.fontcolor := cl_black;
  tfiledialog1.dialogkind         := fdk_open;
  tfiledialog1.controller.options := [fdo_sysfilename, fdo_savelastdir];
  tfiledialog1.controller.basedir := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0))) + 'm3u';
  tfiledialog1.controller.lastdir := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0))) + 'm3u';
  if tfiledialog1.controller.Execute(fdk_open) = mr_ok then
    m3uLoad(tfiledialog1.controller.filename);
end;

procedure twebstreamerfo.onexport(const Sender: TObject);
begin
  tfiledialog1.controller.icon     := icon;
  tfiledialog1.controller.captionopen := 'Choose a .m3u file name to export';
  tfiledialog1.controller.nopanel  := False;
  tfiledialog1.controller.compact  := False;
  tfiledialog1.controller.fontheight := font.Height;
  tfiledialog1.controller.filter   := '"*.m3u"';
  tfiledialog1.controller.fontcolor := cl_black;
  tfiledialog1.dialogkind          := fdk_save;
  tfiledialog1.controller.options  := [fdo_sysfilename, fdo_savelastdir];
  tfiledialog1.controller.basedir  := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0))) + 'm3u';
  tfiledialog1.controller.lastdir  := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0))) + 'm3u';
  tfiledialog1.controller.filename := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0))) + 'm3u' + directoryseparator + 'mylist.m3u';
  if tfiledialog1.controller.Execute(fdk_open) = mr_ok then
    m3uexport(tfiledialog1.controller.filename);
end;

procedure twebstreamerfo.oncreated(const sender: TObject);
begin
hide;
end;

end.
