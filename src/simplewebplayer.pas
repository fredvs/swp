program simplewebplayer;

{$ifdef FPC}{$mode delphi}{$h+}{$endif}
{$ifdef FPC}
 {$ifdef mswindows}{$apptype gui}{$endif}
{$endif}
{$ifdef mswindows}
 {$R dp.res}
{$endif}

uses
  cmem,
 {$ifdef FPC} {$ifdef unix}cthreads, {$endif} {$endif}
  msegui,
  uos_flat,
  webstreamer,
  SysUtils;

begin
  application.createform(twebstreamerfo, webstreamerfo);
  application.run;
  uos_free();
end.

