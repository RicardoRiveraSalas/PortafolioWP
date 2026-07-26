@echo off
color 0B
cls
echo ============================================
echo    INICIANDO SERVICIOS WORDPRESS
echo ============================================
echo.

docker compose up -d
if %errorlevel% neq 0 (
    docker-compose up -d
)

if %errorlevel% neq 0 (
    color 0C
    echo ERROR: No se pudieron iniciar los servicios.
    pause
    exit /b 1
)

echo.
echo Servicios iniciados correctamente.
echo.
echo    WordPress:    http://localhost:8080
echo    phpMyAdmin:   http://localhost:8081
echo.
pause
