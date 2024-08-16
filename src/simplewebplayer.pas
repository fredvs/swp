program simplewebplayer;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
{$ifdef FPC}
 {$ifdef mswindows}{$apptype gui}{$endif}
{$endif}

uses
 {$ifdef FPC} {$ifdef unix} cthreads, {$endif} {$endif}
  msegui,
  webstreamer,
  SysUtils;

begin
  application.createform(twebstreamerfo, webstreamerfo);
  application.run;
end.

