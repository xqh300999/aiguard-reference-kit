@echo off
set "PATH=C:\Program Files\nodejs;%PATH%"
echo Installing dependencies...
call "C:\Program Files\nodejs\npm.cmd" install
if errorlevel 1 (
  echo Install failed.
  exit /b 1
)
echo Starting dev server...
call "C:\Program Files\nodejs\npm.cmd" run dev
