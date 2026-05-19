program simplewebplayer;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
{$ifdef FPC}
 {$ifdef mswindows}{$apptype gui}{$endif}
{$endif}
{$ifdef mswindows}
 {$R dp.res}
{$endif}
{$RANGECHECKS OFF} 
{$ifdef unix}
{$define FPC_USE_LIBC}
{$endif}
uses
  {$ifdef FPC} {$ifdef unix}cthreads, {$endif} {$endif}
  msegui,
  uos_flat,
  //webstreamer
  splash;
 // SysUtils;

begin
 // application.createform(twebstreamerfo, webstreamerfo);
  application.createform(tsplashfo, splashfo);
  application.run;
  {$ifdef unix}uos_free();{$endif} 
end.

