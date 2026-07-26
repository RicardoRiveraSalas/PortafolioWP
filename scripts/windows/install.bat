@echo off
color 0A
cls
echo ============================================
echo    INSTALADOR PORTFOLIO WORDPRESS
echo    GitHub: RicardoRiveraSalas/PortafolioWP
echo ============================================
echo.

:: Verificar si Git esta instalado
echo [1/6] Verificando Git...
git --version >nul 2>&1
if %errorlevel% neq 0 (
    color 0C
    echo ERROR: Git no esta instalado.
    echo.
    echo Por favor instala Git desde:
    echo https://git-scm.com/download/win
    echo.
    pause
    exit /b 1
)
echo        Git encontrado.
git --version

:: Verificar si Docker esta instalado
echo.
echo [2/6] Verificando Docker...
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    color 0C
    echo ERROR: Docker no esta instalado.
    echo.
    echo Por favor instala Docker Desktop desde:
    echo https://www.docker.com/products/docker-desktop/
    echo.
    pause
    exit /b 1
)
echo        Docker encontrado.
docker --version

:: Verificar si Docker esta corriendo
echo.
echo [3/6] Verificando Docker Desktop...
docker info >nul 2>&1
if %errorlevel% neq 0 (
    color 0C
    echo ERROR: Docker Desktop no esta ejecutandose.
    echo.
    echo Por favor abre Docker Desktop y espera a que este listo.
    pause
    exit /b 1
)
echo        Docker esta ejecutandose.

:: Clonar repositorio
echo.
echo [4/6] Clonando repositorio PortafolioWP...
if exist "wordpress\.git" (
    echo        Repositorio ya existe, actualizando...
    cd wordpress
    git pull
    cd ..
) else (
    if exist "wordpress" (
        rmdir /s /q wordpress
    )
    git clone https://github.com/RicardoRiveraSalas/PortafolioWP.git wordpress
)
if %errorlevel% neq 0 (
    color 0C
    echo ERROR: Error al clonar el repositorio.
    pause
    exit /b 1
)
echo        Repositorio clonado correctamente.

:: Levantar servicios
echo.
echo [5/6] Levantando servicios Docker...
echo.
docker compose up -d
if %errorlevel% neq 0 (
    docker-compose up -d
)

if %errorlevel% neq 0 (
    color 0C
    echo.
    echo ERROR: Error al levantar los servicios.
    pause
    exit /b 1
)

:: Verificar contenedores
echo.
echo [6/6] Verificando contenedores...
timeout /t 15 /nobreak >nul
docker compose ps

echo.
echo ============================================
echo    INSTALACION COMPLETADA
echo ============================================
echo.
echo    Repositorio: PortafolioWP
echo.
echo    WordPress:    http://localhost:8080
echo    phpMyAdmin:   http://localhost:8081
echo.
echo    Base de datos:
echo      Usuario:     wpuser
echo      Contrasena:  wp123456
echo      Base:        wordpress
echo.
echo    Siguiente paso:
echo      1. Abre http://localhost:8080
echo      2. Sigue el instalador de WordPress
echo      3. Configura tu portafolio
echo.
echo ============================================
echo.
pause
