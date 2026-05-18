unit splash;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface

uses
 msetypes,sysutils,mseglob,mseguiglob,mseguiintf,mseapplication,msestat,
 msemenus,msegui,msegraphics,msebitmap,msegraphutils,mseevent,mseclasses,
 msewidgets,mseforms,msesimplewidgets, mseimage;

type
  tsplashfo = class(tmseform)
   timage1: timage;
    procedure oneventloop(const Sender: TObject);
   procedure oncrea(const sender: TObject);
   procedure oncreated(const sender: TObject);
  end;

var
  splashfo: tsplashfo;

implementation

uses
  webstreamer,
  splash_mfm;

procedure tsplashfo.oneventloop(const Sender: TObject);
begin
  application.ProcessMessages;
  invalidatewidget;
  sleep(200);
  application.createform(twebstreamerfo, webstreamerfo);
end;

procedure tsplashfo.oncrea(const sender: TObject);
begin
//visible := false;
mse_shapebmp := timage1.bitmap;
optionswindow := [wo_alwaysontop,wo_noframe,wo_customshape];
end;

procedure tsplashfo.oncreated(const sender: TObject);
begin
end;

end.

