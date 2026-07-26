@echo off
color 0B
cls
echo ============================================
echo    ESTADO DE LOS SERVICIOS
echo ============================================
echo.

echo Contenedores:
echo ----------------------------------------
docker compose ps
echo.

echo Uso de recursos:
echo ----------------------------------------
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"
echo.

echo Volúmenes:
echo ----------------------------------------
docker volume ls | findstr "wordpress"
echo.

echo Red:
echo ----------------------------------------
docker network ls | findstr "wpnet"
echo.

pause
