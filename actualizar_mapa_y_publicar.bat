@echo off
chcp 65001 >nul
setlocal

REM ============================================================
REM ACTUALIZADOR AUTOMATICO MAPA FOCO ROJO
REM 1) Corre el codigo viejo que descarga Records y genera index.html
REM 2) Copia ese index.html al repo limpio
REM 3) Hace git commit y git push al repo limpio
REM ============================================================

set "OLD_REPO=C:\Users\analista.wallmart\Documents\TIENDAS-EN-FOCO-ROJO"
set "NEW_REPO=C:\Users\analista.wallmart\Documents\MAPA-FOCO-ROJO"

set "LOGDIR=%NEW_REPO%\logs"
if not exist "%LOGDIR%" mkdir "%LOGDIR%"

set "LOG=%LOGDIR%\actualizacion_mapa.log"

echo.>> "%LOG%"
echo ============================================================>> "%LOG%"
echo Inicio actualizacion: %date% %time%>> "%LOG%"
echo ============================================================>> "%LOG%"

REM Validar carpetas
if not exist "%OLD_REPO%\mapa_invex_github_auto.py" (
    echo ERROR: No encontre mapa_invex_github_auto.py en %OLD_REPO%>> "%LOG%"
    exit /b 1
)

if not exist "%NEW_REPO%\.git" (
    echo ERROR: %NEW_REPO% no parece ser repo Git.>> "%LOG%"
    exit /b 1
)

REM Desactivar push del repo viejo para evitar pelear con Pages viejo
python -c "from pathlib import Path; p=Path(r'%OLD_REPO%\mapa_invex_github_auto.py'); s=p.read_text(encoding='utf-8'); s=s.replace('AUTO_GIT_PUSH = True','AUTO_GIT_PUSH = False'); p.write_text(s, encoding='utf-8')" >> "%LOG%" 2>&1

REM Ejecutar generador del mapa
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

REM Copiar mapa nuevo al repo limpio
copy /Y "%OLD_REPO%\index.html" "%NEW_REPO%\index.html" >> "%LOG%" 2>&1

if not exist "%NEW_REPO%\.nojekyll" (
    type nul > "%NEW_REPO%\.nojekyll"
)

REM Subir al repo limpio
cd /d "%NEW_REPO%"

git add index.html .nojekyll >> "%LOG%" 2>&1

REM Si no hay cambios, no hace commit
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
