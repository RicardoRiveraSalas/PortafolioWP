@echo off
color 0B
cls
echo ============================================
echo    ACTUALIZAR PORTFOLIO
echo ============================================
echo.

echo [1/3] Actualizando repositorio...
if exist "wordpress\.git" (
    cd wordpress
    git pull
    cd ..
) else (
    echo No se encontro el repositorio. Ejecuta install.bat primero.
    pause
    exit /b 1
)

echo.
echo [2/3] Reiniciando WordPress...
docker compose restart wordpress

echo.
echo [3/3] Verificando...
docker compose ps

echo.
echo ============================================
echo    ACTUALIZACION COMPLETADA
echo ============================================
echo.
pause
