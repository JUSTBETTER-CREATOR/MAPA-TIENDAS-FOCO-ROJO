@echo off
chcp 65001 >nul
setlocal

REM ============================================================
REM ACTUALIZADOR AUTOMATICO MAPA FOCO ROJO
REM Soluciona UnicodeEncodeError con PYTHONIOENCODING=utf-8
REM ============================================================

set "PYTHONIOENCODING=utf-8"
set "PYTHONUTF8=1"

set "OLD_REPO=C:\Users\analista.wallmart\Documents\TIENDAS-EN-FOCO-ROJO"
set "NEW_REPO=C:\Users\analista.wallmart\Documents\MAPA-FOCO-ROJO"

set "LOGDIR=%NEW_REPO%\logs"
if not exist "%LOGDIR%" mkdir "%LOGDIR%"

set "LOG=%LOGDIR%\actualizacion_mapa.log"

echo.>> "%LOG%"
echo ============================================================>> "%LOG%"
echo Inicio actualizacion: %date% %time%>> "%LOG%"
echo ============================================================>> "%LOG%"

if not exist "%OLD_REPO%\mapa_invex_github_auto.py" (
    echo ERROR: No encontre mapa_invex_github_auto.py en %OLD_REPO%>> "%LOG%"
    exit /b 1
)

if not exist "%NEW_REPO%\.git" (
    echo ERROR: %NEW_REPO% no parece ser repo Git.>> "%LOG%"
    exit /b 1
)

REM Evita que el Python intente hacer push al repo viejo trabado
python -c "from pathlib import Path; p=Path(r'%OLD_REPO%\mapa_invex_github_auto.py'); s=p.read_text(encoding='utf-8'); s=s.replace('AUTO_GIT_PUSH = True','AUTO_GIT_PUSH = False'); p.write_text(s, encoding='utf-8')" >> "%LOG%" 2>&1

cd /d "%OLD_REPO%"
echo Ejecutando mapa_invex_github_auto.py...>> "%LOG%"

python mapa_invex_github_auto.py >> "%LOG%" 2>&1

if errorlevel 1 (
    echo ERROR: Fallo la ejecucion del Python.>> "%LOG%"
    exit /b 1
)

if not exist "%OLD_REPO%\index.html" (
    echo ERROR: No se genero index.html en %OLD_REPO%.>> "%LOG%"
    exit /b 1
)

copy /Y "%OLD_REPO%\index.html" "%NEW_REPO%\index.html" >> "%LOG%" 2>&1

if not exist "%NEW_REPO%\.nojekyll" (
    type nul > "%NEW_REPO%\.nojekyll"
)

cd /d "%NEW_REPO%"

git add index.html .nojekyll >> "%LOG%" 2>&1

git diff --cached --quiet
if %ERRORLEVEL% EQU 0 (
    echo No hubo cambios nuevos en index.html. No se hizo commit.>> "%LOG%"
    echo Fin sin cambios: %date% %time%>> "%LOG%"
    exit /b 0
)

git commit -m "Actualizacion automatica mapa %date% %time%" >> "%LOG%" 2>&1

if errorlevel 1 (
    echo ERROR: Fallo git commit.>> "%LOG%"
    exit /b 1
)

git push >> "%LOG%" 2>&1

if errorlevel 1 (
    echo ERROR: Fallo git push.>> "%LOG%"
    exit /b 1
)

echo Mapa actualizado y publicado correctamente.>> "%LOG%"
echo Fin actualizacion: %date% %time%>> "%LOG%"

endlocal
