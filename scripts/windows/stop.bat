@echo off
color 0E
cls
echo ============================================
echo    DETENIENDO SERVICIOS WORDPRESS
echo ============================================
echo.

docker compose down
if %errorlevel% neq 0 (
    docker-compose down
)

echo.
echo Servicios detenidos correctamente.
echo.
pause
