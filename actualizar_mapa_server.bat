@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion

cd /d "%~dp0"

if not exist logs mkdir logs
if not exist backups mkdir backups

echo ================================================== >> logs\mapa_server.log
echo INICIO %date% %time% >> logs\mapa_server.log

if exist index.html (
    copy index.html "backups\index_backup_%random%.html" >nul 2>&1
)

echo Ejecutando mapa...
python mapa_invex_github_auto.py >> logs\mapa_server.log 2>&1

if errorlevel 1 (
    echo ERROR: fallo mapa_invex_github_auto.py. Revisa logs\mapa_server.log
    echo ERROR SCRIPT %date% %time% >> logs\mapa_server.log
    exit /b 1
)

if not exist index.html (
    echo ERROR: no se genero index.html.
    echo ERROR SIN INDEX %date% %time% >> logs\mapa_server.log
    exit /b 1
)

for %%A in (index.html) do set "SIZE=%%~zA"

if !SIZE! LSS 50000 (
    echo ERROR: index.html pesa muy poco: !SIZE! bytes. No se subira para evitar mapa en blanco.
    echo ERROR INDEX PEQUENO !SIZE! %date% %time% >> logs\mapa_server.log
    exit /b 1
)

echo Publicando en GitHub...
git pull --rebase >> logs\mapa_server.log 2>&1
git add index.html .github/workflows/deploy-pages.yml .gitignore .nojekyll requirements.txt >> logs\mapa_server.log 2>&1
git commit -m "Actualizacion automatica mapa desde servidor" >> logs\mapa_server.log 2>&1

if errorlevel 1 (
    git commit --allow-empty -m "Forzar deploy mapa desde servidor" >> logs\mapa_server.log 2>&1
)

git push >> logs\mapa_server.log 2>&1

if errorlevel 1 (
    echo ERROR: fallo git push. Revisa logs\mapa_server.log
    echo ERROR PUSH %date% %time% >> logs\mapa_server.log
    exit /b 1
)

echo FIN OK %date% %time% >> logs\mapa_server.log
exit /b 0
