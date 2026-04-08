@echo off
setlocal enabledelayedexpansion

:: Forza lo script a lavorare nella cartella dove è salvato
cd /d "%~dp0"

echo Directory attuale: %cd%
echo Controllo file in corso...
echo.

:: Cicla per ogni file che contiene un underscore
for %%F in ("*_*.*") do (
    set "full_name=%%~nF"
    set "extension=%%~xF"

    :: Divide il nome usando l'underscore come separatore e prende la prima parte
    for /f "tokens=1 delims=_" %%A in ("!full_name!") do (
        set "new_name=%%A"
    )

    if not "!new_name!"=="" (
        echo Rinomino: "%%F" --^> "!new_name!!extension!"
        ren "%%F" "!new_name!!extension!"
    )
)

echo.
echo Operazione terminata.
pause