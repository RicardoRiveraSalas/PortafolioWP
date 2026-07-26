@echo off
color 0D
cls
echo ============================================
echo    RESPALDO PORTFOLIO WORDPRESS
echo ============================================
echo.

:: Crear carpeta de respaldo con fecha
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set FECHA=%datetime:~0,4%%datetime:~4,2%%datetime:~6,2_%datetime:~8,2%%datetime:~10,2%%datetime:~12,2%
set BACKUP_DIR=backups\backup_%FECHA%

echo Creando respaldo en: %BACKUP_DIR%
echo.

mkdir "%BACKUP_DIR%" 2>nul

echo [1/4] Respaldando base de datos...
docker exec wordpress_db mysqldump -u root -proot123 wordpress > "%BACKUP_DIR%\wordpress_db.sql"
if %errorlevel% equ 0 (
    echo        Base de datos respaldada.
) else (
    echo        ERROR al respaldar base de datos.
)

echo [2/4] Respaldando archivos de WordPress...
docker exec wordpress_app tar -czf /tmp/wp_backup.tar.gz -C /var/www/html .
docker cp wordpress_app:/tmp/wp_backup.tar.gz "%BACKUP_DIR%\wordpress_files.tar.gz"
echo        Archivos respaldados.

echo [3/4] Respaldando configuracion...
copy .env "%BACKUP_DIR%\" >nul
copy docker-compose.yml "%BACKUP_DIR%\" >nul
echo        Configuracion respaldada.

echo [4/4] Guardando info del repositorio...
cd wordpress
git remote -v > "%BACKUP_DIR%\repo_info.txt"
git log --oneline -5 >> "%BACKUP_DIR%\repo_info.txt"
git status >> "%BACKUP_DIR%\repo_info.txt"
cd ..
echo        Info del repositorio guardada.

echo.
echo ============================================
echo    RESPALDO COMPLETADO
echo ============================================
echo    Ubicacion: %BACKUP_DIR%
echo.
echo    Archivos generados:
echo      - wordpress_db.sql (base de datos)
echo      - wordpress_files.tar.gz (archivos WP)
echo      - .env (configuracion)
echo      - docker-compose.yml
echo      - repo_info.txt (info del repo)
echo ============================================
echo.
pause
