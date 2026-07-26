@echo off
color 0C
cls
echo ============================================
echo    DESINSTALAR WORDPRESS DOCKER
echo ============================================
echo.
echo    Esto eliminara:
echo      - Todos los contenedores
echo      - Volúmenes de base de datos
echo      - Redes Docker
echo.
echo    NOTA: Los archivos de WordPress y respaldos
echo          NO se eliminan.
echo.
set /p CONFIRMAR="¿Continuar? (S/N): "
if /i not "%CONFIRMAR%"=="S" (
    echo Operacion cancelada.
    pause
    exit /b 0
)

echo.
echo [1/3] Deteniendo contenedores...
docker compose down -v
if %errorlevel% neq 0 (
    docker-compose down -v
)

echo [2/3] Eliminando imagenes...
docker rmi wordpress:latest 2>nul
docker rmi mysql:8.0 2>nul
docker rmi phpmyadmin/phpmyadmin 2>nul

echo [3/3] Limpiando...
docker system prune -f 2>nul

echo.
echo ============================================
echo    DESINSTALACION COMPLETADA
echo ============================================
echo.
pause
